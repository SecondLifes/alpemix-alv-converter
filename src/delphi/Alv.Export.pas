unit Alv.Export;

interface

procedure ExportAlvFrames(const InputFile, OutputDirectory: string;
  ImageLimit: Integer; Overwrite: Boolean);

implementation

uses
  System.SysUtils,
  Alv.Core,
  Vcl.Graphics,
  Vcl.Imaging.pngimage;

type
  TFramePngWriter = class
  private
    FBitmap: TBitmap;
    FPng: TPngImage;
    FWidth: Integer;
    FHeight: Integer;
  public
    constructor Create(Width, Height: Integer);
    destructor Destroy; override;
    procedure Save(const Frame: TBytes; const FileName: string);
  end;

constructor TFramePngWriter.Create(Width, Height: Integer);
begin
  inherited Create;
  FWidth := Width;
  FHeight := Height;
  FBitmap := TBitmap.Create;
  FPng := TPngImage.Create;
  FBitmap.PixelFormat := pf24bit;
  FBitmap.SetSize(Width, Height);
end;

destructor TFramePngWriter.Destroy;
begin
  FPng.Free;
  FBitmap.Free;
  inherited;
end;

procedure TFramePngWriter.Save(const Frame: TBytes; const FileName: string);
var
  Scan: PByte;
  Row, Col, SourceIndex: NativeInt;
begin
  if Length(Frame) <> FWidth * FHeight * 3 then
    raise EAlvError.CreateFmt('RGB frame size %d, expected %d',
      [Length(Frame), FWidth * FHeight * 3]);
  for Row := 0 to FHeight - 1 do
  begin
    Scan := FBitmap.ScanLine[Row];
    SourceIndex := Row * FWidth * 3;
    for Col := 0 to FWidth - 1 do
    begin
      Scan[Col * 3] := Frame[SourceIndex + Col * 3 + 2];
      Scan[Col * 3 + 1] := Frame[SourceIndex + Col * 3 + 1];
      Scan[Col * 3 + 2] := Frame[SourceIndex + Col * 3];
    end;
  end;
  FPng.Assign(FBitmap);
  FPng.SaveToFile(FileName);
end;

procedure ExportAlvFrames(const InputFile, OutputDirectory: string;
  ImageLimit: Integer; Overwrite: Boolean);
var
  Reader: TAlvReader;
  Decoder: TAlvDecoder;
  Writer: TFramePngWriter;
  Rec: TAlvRecord;
  FileName, ExpandedDirectory: string;
  SavedCount: Integer;
begin
  if not FileExists(InputFile) then
    raise EAlvError.Create('Input file does not exist: ' + InputFile);
  if ImageLimit < 0 then
    raise EAlvError.Create('Image limit cannot be negative');
  ExpandedDirectory := ExpandFileName(OutputDirectory);
  if not DirectoryExists(ExpandedDirectory) and
     not ForceDirectories(ExpandedDirectory) then
    raise EAlvError.Create('Cannot create image directory: ' + ExpandedDirectory);

  Reader := TAlvReader.Create(InputFile);
  Decoder := nil;
  Writer := nil;
  try
    Decoder := TAlvDecoder.Create(Reader.Header);
    Writer := TFramePngWriter.Create(Reader.Header.Width, Reader.Header.Height);
    SavedCount := 0;
    while Reader.ReadNext(Rec) do
    begin
      Decoder.Apply(Rec);
      FileName := IncludeTrailingPathDelimiter(ExpandedDirectory) +
        Format('frame_%.6d.png', [Rec.Index]);
      if FileExists(FileName) and not Overwrite then
        raise EAlvError.Create('Image exists; pass --overwrite: ' + FileName);
      Writer.Save(Decoder.Frame, FileName);
      Inc(SavedCount);
      if (SavedCount mod 100 = 0) then
        Writeln(Format('Exported %d PNG frames...', [SavedCount]));
      if (ImageLimit > 0) and (SavedCount >= ImageLimit) then
        Break;
    end;
    Writeln(Format('Exported %d PNG frame(s) to %s',
      [SavedCount, ExpandedDirectory]));
  finally
    Writer.Free;
    Decoder.Free;
    Reader.Free;
  end;
end;

end.

