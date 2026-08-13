unit Alv.Converter;

interface

uses
  System.SysUtils;

type
  TAlvConvertOptions = record
    InputFile: string;
    OutputFile: string;
    FFmpegFile: string;
    Fps: Double;
    FpsSpecified: Boolean;
    Codec: string;
    Crf: Integer;
    Preset: string;
    PixelFormat: string;
    Overwrite: Boolean;
    ExportImages: Boolean;
    ExportDirectory: string;
    ImageLimit: Integer;
  end;

procedure ConvertAlv(const Options: TAlvConvertOptions);

implementation

uses
  System.Classes,
  System.Generics.Collections,
  System.Math,
  Alv.Core,
  Alv.FFmpeg;

procedure ReadTiming(const InputFile: string; out Fps, MedianMs: Double);
var
  Reader: TAlvReader;
  Rec: TAlvRecord;
  Deltas: TList<Cardinal>;
  Middle: Integer;
begin
  Deltas := TList<Cardinal>.Create;
  Reader := TAlvReader.Create(InputFile);
  try
    while Reader.ReadNext(Rec) do
      if Rec.TimestampDeltaMs > 0 then
        Deltas.Add(Rec.TimestampDeltaMs);
  finally
    Reader.Free;
  end;
  try
    if Deltas.Count = 0 then
      MedianMs := 40.0
    else
    begin
      Deltas.Sort;
      Middle := Deltas.Count div 2;
      if Odd(Deltas.Count) then
        MedianMs := Deltas[Middle]
      else
        MedianMs := (Double(Deltas[Middle - 1]) + Deltas[Middle]) / 2.0;
    end;
    Fps := 1000.0 / MedianMs;
  finally
    Deltas.Free;
  end;
end;

procedure ConvertAlv(const Options: TAlvConvertOptions);
var
  Reader: TAlvReader;
  Decoder: TAlvDecoder;
  Pipe: TFFmpegPipe;
  PipeConfig: TFFmpegConfig;
  Rec: TAlvRecord;
  Fps, MedianMs: Double;
  TimelineMs, TargetFrames, EmittedFrames: Int64;
  RecordCount: Integer;
  OutputDirectory: string;

  procedure EmitUntil(Target: Int64);
  begin
    while EmittedFrames < Target do
    begin
      Pipe.WriteFrame(Decoder.Frame);
      Inc(EmittedFrames);
    end;
  end;

begin
  if not FileExists(Options.InputFile) then
    raise EAlvError.Create('Input file does not exist: ' + Options.InputFile);
  if not FileExists(Options.FFmpegFile) then
    raise EAlvError.Create('ffmpeg.exe must be beside the converter: ' +
      Options.FFmpegFile);
  if FileExists(Options.OutputFile) and not Options.Overwrite then
    raise EAlvError.Create('Output exists; pass --overwrite: ' + Options.OutputFile);
  if Options.FpsSpecified then
  begin
    Fps := Options.Fps;
    MedianMs := 1000.0 / Fps;
  end
  else
    ReadTiming(Options.InputFile, Fps, MedianMs);
  if (Fps <= 0) or (Fps > 1000) then
    raise EAlvError.Create('FPS must be greater than 0 and at most 1000');

  OutputDirectory := ExtractFileDir(ExpandFileName(Options.OutputFile));
  if (OutputDirectory <> '') and not DirectoryExists(OutputDirectory) and
     not ForceDirectories(OutputDirectory) then
    raise EAlvError.Create('Cannot create output directory: ' + OutputDirectory);

  Reader := TAlvReader.Create(Options.InputFile);
  Decoder := nil;
  Pipe := nil;
  try
    Decoder := TAlvDecoder.Create(Reader.Header);
    PipeConfig.Executable := Options.FFmpegFile;
    PipeConfig.OutputFile := Options.OutputFile;
    PipeConfig.Width := Reader.Header.Width;
    PipeConfig.Height := Reader.Header.Height;
    PipeConfig.Fps := Fps;
    PipeConfig.Codec := Options.Codec;
    PipeConfig.Crf := Options.Crf;
    PipeConfig.Preset := Options.Preset;
    PipeConfig.PixelFormat := Options.PixelFormat;
    PipeConfig.Overwrite := Options.Overwrite;
    Pipe := TFFmpegPipe.Create(PipeConfig);

    TimelineMs := 0;
    EmittedFrames := 0;
    RecordCount := 0;
    while Reader.ReadNext(Rec) do
    begin
      if Decoder.HasFrame then
      begin
        Inc(TimelineMs, Rec.TimestampDeltaMs);
        TargetFrames := System.Round(TimelineMs * Fps / 1000.0);
        EmitUntil(TargetFrames);
      end;
      Decoder.Apply(Rec);
      Inc(RecordCount);
      if (RecordCount = 1) and (Rec.TimestampDeltaMs > 0) then
      begin
        Inc(TimelineMs, Rec.TimestampDeltaMs);
        TargetFrames := System.Round(TimelineMs * Fps / 1000.0);
        EmitUntil(TargetFrames);
      end;
    end;
    if not Decoder.HasFrame then
      raise EAlvError.Create('ALV recording contains no frames');

    Inc(TimelineMs, System.Round(MedianMs));
    TargetFrames := System.Round(TimelineMs * Fps / 1000.0);
    if TargetFrames < EmittedFrames + 1 then
      TargetFrames := EmittedFrames + 1;
    EmitUntil(TargetFrames);
    Pipe.Finish;

    Writeln(Format('Created %s: %d frames, %.6g fps, %.3f s',
      [ExpandFileName(Options.OutputFile), EmittedFrames, Fps,
       TimelineMs / 1000.0]));
  finally
    Pipe.Free;
    Decoder.Free;
    Reader.Free;
  end;
end;

end.
