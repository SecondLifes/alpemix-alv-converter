# -*- mode: python ; coding: utf-8 -*-
#
# PyInstaller one-file build of the Python implementation.
#
# FFmpeg is deliberately NOT bundled. It sits beside the produced executable
# in `src/bin/` as its own replaceable file, exactly as the Delphi build does
# — see .agents/rules/third-party-licensing.md. `resolve_ffmpeg()` in
# alv2mp4.py finds it there via `Path(sys.executable).with_name("ffmpeg.exe")`,
# which is the real executable path when frozen.
#
# The artifact is named AlvConverter-Python so it does not overwrite the
# Delphi build's own AlvConverter.exe, which lives in the same folder.
#
# Output location is set by build_exe.bat via --distpath, not here.

from pathlib import Path

project_dir = Path(SPECPATH)

a = Analysis(
    [str(project_dir / "alv2mp4.py")],
    pathex=[str(project_dir)],
    binaries=[],
    datas=[],
    hiddenimports=["PIL.JpegImagePlugin", "PIL.PngImagePlugin"],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=1,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name="AlvConverter-Python",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
