program AlvConverter;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  Alv.Core in 'Alv.Core.pas',
  Alv.FFmpeg in 'Alv.FFmpeg.pas',
  Alv.Converter in 'Alv.Converter.pas',
  Alv.Export in 'Alv.Export.pas';

const
  AppVersion = '1.0.0';

procedure PrintUsage;
begin
  Writeln('AlvConverter Delphi ' + AppVersion);
  Writeln('Usage:');
  Writeln('  AlvConverter.exe input.alv [output.mp4] [options]');
  Writeln;
  Writeln('Options:');
  Writeln('  --fps N          Output frame rate (default: recording median)');
  Writeln('  --codec NAME     FFmpeg video codec (default: libx264)');
  Writeln('  --crf N          Encoder quality (default: 18)');
  Writeln('  --preset NAME    Encoder preset (default: medium)');
  Writeln('  --pix-fmt NAME   Output pixel format (default: yuv420p)');
  Writeln('  --ffmpeg PATH    Override adjacent ffmpeg.exe');
  Writeln('  --export-images DIR  Export every reconstructed frame as PNG');
  Writeln('  --image-limit N      Export only first N frames (0 = all)');
  Writeln('  --overwrite      Replace an existing output');
  Writeln('  --help           Show this help');
  Writeln('  --version        Show version');
end;

function ParseFloat(const Value, Name: string): Double;
var
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Create('en-US');
  if not TryStrToFloat(Value, Result, FS) then
    raise EAlvError.Create('Invalid ' + Name + ': ' + Value);
end;

function NextValue(var Index: Integer; const OptionName: string): string;
begin
  Inc(Index);
  if Index > ParamCount then
    raise EAlvError.Create('Missing value for ' + OptionName);
  Result := ParamStr(Index);
end;

function ParseOptions(out Options: TAlvConvertOptions): Boolean;
var
  Positionals: TStringList;
  I, ParsedInteger: Integer;
  Arg, Value: string;
begin
  Result := False;
  Options := Default(TAlvConvertOptions);
  Options.Codec := 'libx264';
  Options.Crf := 18;
  Options.Preset := 'medium';
  Options.PixelFormat := 'yuv420p';
  Options.FFmpegFile := IncludeTrailingPathDelimiter(
    ExtractFilePath(ExpandFileName(ParamStr(0)))) + 'ffmpeg.exe';
  Positionals := TStringList.Create;
  try
    I := 1;
    while I <= ParamCount do
    begin
      Arg := ParamStr(I);
      if SameText(Arg, '--help') or SameText(Arg, '-h') then
      begin
        PrintUsage;
        Exit(False);
      end
      else if SameText(Arg, '--version') then
      begin
        Writeln('AlvConverter Delphi ' + AppVersion);
        Exit(False);
      end
      else if SameText(Arg, '--overwrite') then
        Options.Overwrite := True
      else if SameText(Arg, '--fps') then
      begin
        Value := NextValue(I, Arg);
        Options.Fps := ParseFloat(Value, 'FPS');
        Options.FpsSpecified := True;
      end
      else if SameText(Arg, '--codec') then
        Options.Codec := NextValue(I, Arg)
      else if SameText(Arg, '--crf') then
      begin
        Value := NextValue(I, Arg);
        if not TryStrToInt(Value, ParsedInteger) then
          raise EAlvError.Create('Invalid CRF: ' + Value);
        Options.Crf := ParsedInteger;
      end
      else if SameText(Arg, '--preset') then
        Options.Preset := NextValue(I, Arg)
      else if SameText(Arg, '--pix-fmt') then
        Options.PixelFormat := NextValue(I, Arg)
      else if SameText(Arg, '--ffmpeg') then
        Options.FFmpegFile := ExpandFileName(NextValue(I, Arg))
      else if SameText(Arg, '--export-images') then
      begin
        Options.ExportImages := True;
        Options.ExportDirectory := ExpandFileName(NextValue(I, Arg));
      end
      else if SameText(Arg, '--image-limit') then
      begin
        Value := NextValue(I, Arg);
        if not TryStrToInt(Value, ParsedInteger) or (ParsedInteger < 0) then
          raise EAlvError.Create('Invalid image limit: ' + Value);
        Options.ImageLimit := ParsedInteger;
      end
      else if Copy(Arg, 1, 2) = '--' then
        raise EAlvError.Create('Unknown option: ' + Arg)
      else
        Positionals.Add(Arg);
      Inc(I);
    end;

    if Positionals.Count = 0 then
    begin
      PrintUsage;
      raise EAlvError.Create('Input ALV path is required');
    end;
    if Positionals.Count > 2 then
      raise EAlvError.Create('Too many positional arguments');
    if Options.ExportImages and (Positionals.Count > 1) then
      raise EAlvError.Create(
        'MP4 output argument cannot be combined with --export-images');
    if (Options.ImageLimit > 0) and not Options.ExportImages then
      raise EAlvError.Create('--image-limit requires --export-images');
    Options.InputFile := ExpandFileName(Positionals[0]);
    if Positionals.Count = 2 then
      Options.OutputFile := ExpandFileName(Positionals[1])
    else
      Options.OutputFile := ChangeFileExt(Options.InputFile, '.mp4');
    Result := True;
  finally
    Positionals.Free;
  end;
end;

var
  Options: TAlvConvertOptions;

begin
  ExitCode := 0;
  try
    if ParseOptions(Options) then
    begin
      Writeln('Input:   ' + Options.InputFile);
      if Options.ExportImages then
      begin
        Writeln('Images:  ' + Options.ExportDirectory);
        ExportAlvFrames(Options.InputFile, Options.ExportDirectory,
          Options.ImageLimit, Options.Overwrite);
      end
      else
      begin
        Writeln('Output:  ' + Options.OutputFile);
        Writeln('FFmpeg:  ' + Options.FFmpegFile);
        ConvertAlv(Options);
      end;
    end;
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, 'ERROR: ' + E.Message);
      ExitCode := 2;
    end;
  end;
end.
