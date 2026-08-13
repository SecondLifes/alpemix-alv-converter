@echo off
setlocal EnableExtensions

rem ============================================================================
rem  Builds the Python implementation into a one-file Windows executable:
rem      src\bin\AlvConverter-Python.exe
rem
rem  FFmpeg is NOT embedded. The built executable looks for ffmpeg.exe beside
rem  itself at runtime, so both files must stay in the same folder -- see
rem  .agents\rules\third-party-licensing.md.
rem
rem  The artifact is named AlvConverter-Python so it does not overwrite the
rem  Delphi build's AlvConverter.exe in that same folder.
rem
rem  Build dependencies (PyInstaller, Pillow) are installed into a private
rem  virtual environment under src\temp\buildvenv on first run. Your system
rem  Python is never modified.
rem
rem  Usage:  build_exe.bat  [path\to\python.exe]
rem          The argument is the interpreter used to CREATE the venv, and
rem          defaults to "python" on PATH. Pass one that already has
rem          PyInstaller installed and it is used directly instead.
rem ============================================================================

set "PROJECT_DIR=%~dp0"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

set "BASE_PYTHON=%~1"
if "%BASE_PYTHON%"=="" set "BASE_PYTHON=python"

set "BIN_DIR=%PROJECT_DIR%\..\bin"
set "TEMP_DIR=%PROJECT_DIR%\..\temp"
set "VENV_DIR=%TEMP_DIR%\buildvenv"
set "VENV_PYTHON=%VENV_DIR%\Scripts\python.exe"
set "WORK_DIR=%TEMP_DIR%\pyinstaller"
set "SPEC=%PROJECT_DIR%\AlvConverter.spec"
set "FFMPEG=%BIN_DIR%\ffmpeg.exe"
set "LICENSE=%BIN_DIR%\FFMPEG_LICENSE.txt"
set "PRODUCED=%BIN_DIR%\AlvConverter-Python.exe"

rem --- Preconditions that no amount of installing can fix ---------------------

if not exist "%SPEC%" (
    echo ERROR: Spec file not found: %SPEC%
    exit /b 1
)

rem FFmpeg is not built in, but it must be present next to the output or the
rem executable this script produces cannot convert anything. Fail now rather
rem than at the user's first conversion.
if not exist "%FFMPEG%" (
    echo ERROR: ffmpeg.exe must sit in %BIN_DIR% beside the built executable; it is missing.
    exit /b 1
)
if not exist "%LICENSE%" (
    echo ERROR: FFMPEG_LICENSE.txt must travel with ffmpeg.exe in %BIN_DIR%; it is missing.
    exit /b 1
)

rem --- Pick an interpreter that can actually build -----------------------------

set "PYTHON="

rem 1. Did the caller hand us one that is already equipped?
"%BASE_PYTHON%" -c "import PyInstaller, PIL" >nul 2>&1
if not errorlevel 1 (
    set "PYTHON=%BASE_PYTHON%"
    echo Using %BASE_PYTHON% ^(PyInstaller and Pillow already present^).
    goto :build
)

rem 2. Is the private build venv already set up from a previous run?
if exist "%VENV_PYTHON%" (
    "%VENV_PYTHON%" -c "import PyInstaller, PIL" >nul 2>&1
    if not errorlevel 1 (
        set "PYTHON=%VENV_PYTHON%"
        echo Using the build venv at %VENV_DIR%.
        goto :build
    )
)

rem 3. Build it. This is the only step that touches the network.
echo.
echo PyInstaller is not available to "%BASE_PYTHON%".
echo Creating a private build environment instead - your system Python is not modified.
echo   Location: %VENV_DIR%
echo.

"%BASE_PYTHON%" --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: "%BASE_PYTHON%" is not a working Python interpreter.
    echo        Install Python 3.11+ and put it on PATH, or pass a full path:
    echo            build_exe.bat "C:\path\to\python.exe"
    exit /b 1
)

if not exist "%VENV_PYTHON%" (
    "%BASE_PYTHON%" -m venv "%VENV_DIR%"
    if errorlevel 1 (
        echo ERROR: Could not create a virtual environment at %VENV_DIR%
        exit /b 1
    )
)

echo Installing PyInstaller and Pillow into the build environment...
"%VENV_PYTHON%" -m pip install --quiet --disable-pip-version-check pyinstaller "Pillow>=12.0,<13"
if errorlevel 1 (
    echo ERROR: Could not install the build dependencies. Check your network connection.
    exit /b 1
)

"%VENV_PYTHON%" -c "import PyInstaller, PIL" >nul 2>&1
if errorlevel 1 (
    echo ERROR: The build environment is still missing PyInstaller or Pillow after installing.
    exit /b 1
)
set "PYTHON=%VENV_PYTHON%"
echo Build environment ready.

rem --- Build ------------------------------------------------------------------

:build
echo.

pushd "%PROJECT_DIR%" || exit /b 1

"%PYTHON%" -m PyInstaller --noconfirm --clean ^
    --distpath "%BIN_DIR%" ^
    --workpath "%WORK_DIR%" ^
    "%SPEC%"
set "RC=%ERRORLEVEL%"

popd

if not "%RC%"=="0" (
    echo ERROR: PyInstaller failed with exit code %RC%
    exit /b %RC%
)

if not exist "%PRODUCED%" (
    echo ERROR: PyInstaller reported success but %PRODUCED% does not exist.
    exit /b 1
)

for %%F in ("%PRODUCED%") do set "OUT=%%~fF"
for %%F in ("%FFMPEG%")   do set "FF=%%~fF"
for %%F in ("%LICENSE%")  do set "LIC=%%~fF"

echo.
echo Built: %OUT%
for %%F in ("%PRODUCED%") do echo Size:  %%~zF bytes    %%~tF
echo.
echo ffmpeg.exe is NOT embedded. Keep it beside the executable:
echo   %FF%
echo   %LIC%

endlocal
exit /b 0
