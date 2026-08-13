unit Alv.FFmpeg;

interface

uses
  System.SysUtils,
  Winapi.Windows;

type
  TFFmpegConfig = record
    Executable: string;
    OutputFile: string;
    Width: Integer;
    Height: Integer;
    Fps: Double;
    Codec: string;
    Crf: Integer;
    Preset: string;
    PixelFormat: string;
    Overwrite: Boolean;
  end;

  TFFmpegPipe = class
  private
    FProcess: THandle;
    FInput: THandle;
    FFinished: Boolean;
    procedure AbortProcess;
  public
    constructor Create(const Config: TFFmpegConfig);
    destructor Destroy; override;
    procedure WriteFrame(const Frame: TBytes);
    procedure Finish;
  end;

implementation

uses
  Alv.Core;

function QuoteArg(const Value: string): string;
begin
  Result := '"' + StringReplace(Value, '"', '\"', [rfReplaceAll]) + '"';
end;

function FpsText(Value: Double): string;
var
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Create('en-US');
  Result := FloatToStr(Value, FS);
end;

constructor TFFmpegPipe.Create(const Config: TFFmpegConfig);
var
  Security: TSecurityAttributes;
  Startup: TStartupInfo;
  ProcessInfo: TProcessInformation;
  ReadPipe, WritePipe: THandle;
  CommandLine, PadFilter, OverwriteArg: string;
  ErrorCode: Cardinal;
begin
  inherited Create;
  FProcess := 0;
  FInput := 0;
  FFinished := False;

  if not FileExists(Config.Executable) then
    raise EAlvError.Create('FFmpeg not found beside converter: ' + Config.Executable);

  FillChar(Security, SizeOf(Security), 0);
  Security.nLength := SizeOf(Security);
  Security.bInheritHandle := True;
  if not CreatePipe(ReadPipe, WritePipe, @Security, 0) then
    raise EAlvError.Create('CreatePipe failed: ' + SysErrorMessage(GetLastError));
  try
    if not SetHandleInformation(WritePipe, HANDLE_FLAG_INHERIT, 0) then
      raise EAlvError.Create('SetHandleInformation failed: ' +
        SysErrorMessage(GetLastError));

    FillChar(Startup, SizeOf(Startup), 0);
    Startup.cb := SizeOf(Startup);
    Startup.dwFlags := STARTF_USESTDHANDLES;
    Startup.hStdInput := ReadPipe;
    Startup.hStdOutput := GetStdHandle(STD_OUTPUT_HANDLE);
    Startup.hStdError := GetStdHandle(STD_ERROR_HANDLE);
    FillChar(ProcessInfo, SizeOf(ProcessInfo), 0);

    if Config.Overwrite then
      OverwriteArg := '-y'
    else
      OverwriteArg := '-n';
    CommandLine := QuoteArg(Config.Executable) +
      ' -hide_banner ' + OverwriteArg +
      ' -f rawvideo -pixel_format rgb24 -video_size ' +
      IntToStr(Config.Width) + 'x' + IntToStr(Config.Height) +
      ' -framerate ' + FpsText(Config.Fps) +
      ' -i pipe:0 -an -c:v ' + QuoteArg(Config.Codec) +
      ' -preset ' + QuoteArg(Config.Preset) +
      ' -crf ' + IntToStr(Config.Crf);
    if Odd(Config.Width) or Odd(Config.Height) then
    begin
      PadFilter := 'pad=ceil(iw/2)*2:ceil(ih/2)*2';
      CommandLine := CommandLine + ' -vf ' + QuoteArg(PadFilter);
    end;
    CommandLine := CommandLine + ' -pix_fmt ' + QuoteArg(Config.PixelFormat) +
      ' -movflags +faststart ' + QuoteArg(Config.OutputFile);
    UniqueString(CommandLine);

    if not CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil, nil,
      Startup, ProcessInfo) then
    begin
      ErrorCode := GetLastError;
      raise EAlvError.Create('Cannot start FFmpeg: ' + SysErrorMessage(ErrorCode));
    end;
    FProcess := ProcessInfo.hProcess;
    CloseHandle(ProcessInfo.hThread);
    FInput := WritePipe;
    WritePipe := 0;
  finally
    CloseHandle(ReadPipe);
    if WritePipe <> 0 then
      CloseHandle(WritePipe);
  end;
end;

destructor TFFmpegPipe.Destroy;
begin
  if not FFinished then
    AbortProcess;
  inherited;
end;

procedure TFFmpegPipe.AbortProcess;
begin
  if FInput <> 0 then
  begin
    CloseHandle(FInput);
    FInput := 0;
  end;
  if FProcess <> 0 then
  begin
    if WaitForSingleObject(FProcess, 5000) = WAIT_TIMEOUT then
      TerminateProcess(FProcess, 2);
    WaitForSingleObject(FProcess, INFINITE);
    CloseHandle(FProcess);
    FProcess := 0;
  end;
  FFinished := True;
end;

procedure TFFmpegPipe.WriteFrame(const Frame: TBytes);
var
  Offset, Written: Cardinal;
begin
  if FFinished or (FInput = 0) then
    raise EAlvError.Create('FFmpeg pipe is not writable');
  Offset := 0;
  while Offset < Cardinal(Length(Frame)) do
  begin
    Written := 0;
    if not WriteFile(FInput, Frame[Offset], Cardinal(Length(Frame)) - Offset,
      Written, nil) then
      raise EAlvError.Create('FFmpeg closed its input: ' +
        SysErrorMessage(GetLastError));
    if Written = 0 then
      raise EAlvError.Create('FFmpeg pipe wrote zero bytes');
    Inc(Offset, Written);
  end;
end;

procedure TFFmpegPipe.Finish;
var
  ExitStatus: Cardinal;
begin
  if FFinished then
    Exit;
  if FInput <> 0 then
  begin
    CloseHandle(FInput);
    FInput := 0;
  end;
  WaitForSingleObject(FProcess, INFINITE);
  if not GetExitCodeProcess(FProcess, ExitStatus) then
    raise EAlvError.Create('GetExitCodeProcess failed: ' +
      SysErrorMessage(GetLastError));
  CloseHandle(FProcess);
  FProcess := 0;
  FFinished := True;
  if ExitStatus <> 0 then
    raise EAlvError.CreateFmt('FFmpeg failed with exit code %d', [ExitStatus]);
end;

end.
