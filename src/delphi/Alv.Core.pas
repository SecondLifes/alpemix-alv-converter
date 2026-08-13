unit Alv.Core;

interface

{$POINTERMATH ON}

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows;

const
  MaxDecompressedBlock = 512 * 1024 * 1024;
  MaxCanvasPixels = 100000000;

type
  EAlvError = class(Exception);

  TAlvHeader = record
    Prologue: Cardinal;
    Version: Byte;
    HeaderPayloadLength: Cardinal;
    RecordedAt: TDateTime;
    Strings: array[0..4] of string;
    ColorDepthCode: Byte;
    BackgroundColor: Word;
    Width: Word;
    Height: Word;
    RecordsOffset: Int64;
  end;

  TAlvRecord = record
    Index: Integer;
    Offset: Int64;
    TimestampDeltaMs: Cardinal;
    BlockType: Byte;
    Codec: Byte;
    BoxShaped: Boolean;
    X: Word;
    Y: Word;
    Width: Word;
    Height: Word;
    Payload: TBytes;
  end;

  TAlvRegion = record
    X: Word;
    Y: Word;
    Width: Word;
    Height: Word;
    Codec: Byte;
    Payload: TBytes;
    Context: string;
  end;

  TAlvReader = class
  private
    FStream: TFileStream;
    FHeader: TAlvHeader;
    FRecordIndex: Integer;
    procedure ReadExact(var Buffer; Count: NativeInt; const Context: string);
    function ReadByte(const Context: string): Byte;
    function ReadWord(const Context: string): Word;
    function ReadCardinal(const Context: string): Cardinal;
    function ReadBytes(Count: Cardinal; const Context: string): TBytes;
    procedure ReadHeader;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    function ReadNext(out Rec: TAlvRecord): Boolean;
    property Header: TAlvHeader read FHeader;
  end;

  TAlvDecoder = class
  private
    FHeader: TAlvHeader;
    FCanvas: TBytes;
    FPalette: array[0..255] of TPaletteEntry;
    FHasFrame: Boolean;
    procedure BuildPalette;
    procedure ValidateRegion(const Region: TAlvRegion);
    procedure DecodeRaw(const Region: TAlvRegion);
    procedure DecodeJpeg(const Region: TAlvRegion);
    procedure ApplyRegion(const Region: TAlvRegion);
  public
    constructor Create(const Header: TAlvHeader);
    procedure Apply(const Rec: TAlvRecord);
    property Frame: TBytes read FCanvas;
    property HasFrame: Boolean read FHasFrame;
  end;

function DecompressPayload(const Payload: TBytes; const Context: string): TBytes;

implementation

uses
  System.ZLib,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg;

type
  TByteCursor = class
  private
    FData: TBytes;
    FPosition: NativeInt;
    FContext: string;
    procedure Require(Count: NativeInt; const Field: string);
  public
    constructor Create(const Data: TBytes; const Context: string);
    function Remaining: NativeInt;
    function ReadByte(const Field: string): Byte;
    function ReadWord(const Field: string): Word;
    function ReadCardinal(const Field: string): Cardinal;
    function ReadDouble(const Field: string): Double;
    function ReadBytes(Count: NativeInt; const Field: string): TBytes;
  end;

constructor TByteCursor.Create(const Data: TBytes; const Context: string);
begin
  inherited Create;
  FData := Data;
  FPosition := 0;
  FContext := Context;
end;

procedure TByteCursor.Require(Count: NativeInt; const Field: string);
begin
  if (Count < 0) or (Count > Remaining) then
    raise EAlvError.CreateFmt('%s: truncated %s at +0x%x; expected %d, remaining %d',
      [FContext, Field, FPosition, Count, Remaining]);
end;

function TByteCursor.Remaining: NativeInt;
begin
  Result := Length(FData) - FPosition;
end;

function TByteCursor.ReadByte(const Field: string): Byte;
begin
  Require(1, Field);
  Result := FData[FPosition];
  Inc(FPosition);
end;

function TByteCursor.ReadWord(const Field: string): Word;
begin
  Require(2, Field);
  Result := Word(FData[FPosition]) or (Word(FData[FPosition + 1]) shl 8);
  Inc(FPosition, 2);
end;

function TByteCursor.ReadCardinal(const Field: string): Cardinal;
begin
  Require(4, Field);
  Result := Cardinal(FData[FPosition]) or
    (Cardinal(FData[FPosition + 1]) shl 8) or
    (Cardinal(FData[FPosition + 2]) shl 16) or
    (Cardinal(FData[FPosition + 3]) shl 24);
  Inc(FPosition, 4);
end;

function TByteCursor.ReadDouble(const Field: string): Double;
begin
  Require(SizeOf(Result), Field);
  Move(FData[FPosition], Result, SizeOf(Result));
  Inc(FPosition, SizeOf(Result));
end;

function TByteCursor.ReadBytes(Count: NativeInt; const Field: string): TBytes;
begin
  Require(Count, Field);
  SetLength(Result, Count);
  if Count > 0 then
    Move(FData[FPosition], Result[0], Count);
  Inc(FPosition, Count);
end;

constructor TAlvReader.Create(const FileName: string);
begin
  inherited Create;
  try
    FStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    ReadHeader;
  except
    FStream.Free;
    raise;
  end;
end;

destructor TAlvReader.Destroy;
begin
  FStream.Free;
  inherited;
end;

procedure TAlvReader.ReadExact(var Buffer; Count: NativeInt; const Context: string);
var
  Remaining: Int64;
begin
  Remaining := FStream.Size - FStream.Position;
  if (Count < 0) or (Int64(Count) > Remaining) then
    raise EAlvError.CreateFmt(
      'ALV parse error at 0x%x in %s: expected %d byte(s), remaining %d',
      [FStream.Position, Context, Count, Remaining]);
  if (Count > 0) and (FStream.Read(Buffer, Count) <> Count) then
    raise EAlvError.CreateFmt('ALV short read at 0x%x in %s',
      [FStream.Position, Context]);
end;

function TAlvReader.ReadByte(const Context: string): Byte;
begin
  ReadExact(Result, 1, Context);
end;

function TAlvReader.ReadWord(const Context: string): Word;
var
  B: array[0..1] of Byte;
begin
  ReadExact(B, SizeOf(B), Context);
  Result := Word(B[0]) or (Word(B[1]) shl 8);
end;

function TAlvReader.ReadCardinal(const Context: string): Cardinal;
var
  B: array[0..3] of Byte;
begin
  ReadExact(B, SizeOf(B), Context);
  Result := Cardinal(B[0]) or (Cardinal(B[1]) shl 8) or
    (Cardinal(B[2]) shl 16) or (Cardinal(B[3]) shl 24);
end;

function TAlvReader.ReadBytes(Count: Cardinal; const Context: string): TBytes;
begin
  if Count > Cardinal(MaxInt) then
    raise EAlvError.CreateFmt('%s is too large: %u byte(s)', [Context, Count]);
  SetLength(Result, Integer(Count));
  if Count > 0 then
    ReadExact(Result[0], Count, Context);
end;

procedure TAlvReader.ReadHeader;
var
  Payload, RawString: TBytes;
  Cursor: TByteCursor;
  I, L: Integer;
begin
  FHeader.Prologue := ReadCardinal('file prologue');
  FHeader.Version := ReadByte('format version');
  FHeader.HeaderPayloadLength := ReadCardinal('header payload length');
  Payload := ReadBytes(FHeader.HeaderPayloadLength, 'header payload');
  Cursor := TByteCursor.Create(Payload, 'header payload');
  try
    FHeader.RecordedAt := Cursor.ReadDouble('Delphi TDateTime');
    for I := 0 to 4 do
    begin
      L := Cursor.ReadByte(Format('ShortString %d length', [I + 1]));
      RawString := Cursor.ReadBytes(L, Format('ShortString %d', [I + 1]));
      FHeader.Strings[I] := TEncoding.ANSI.GetString(RawString);
    end;
    FHeader.ColorDepthCode := Cursor.ReadByte('color depth code');
    FHeader.BackgroundColor := Cursor.ReadWord('background color');
    FHeader.Width := Cursor.ReadWord('canvas width');
    FHeader.Height := Cursor.ReadWord('canvas height');
    if (FHeader.Width = 0) or (FHeader.Height = 0) then
      raise EAlvError.Create('ALV header contains a zero-sized canvas');
  finally
    Cursor.Free;
  end;
  FHeader.RecordsOffset := FStream.Position;
end;

function TAlvReader.ReadNext(out Rec: TAlvRecord): Boolean;
var
  Context: string;
  PayloadSize: Cardinal;
begin
  if FStream.Position = FStream.Size then
    Exit(False);
  if FStream.Position > FStream.Size then
    raise EAlvError.Create('ALV stream position is beyond EOF');

  Rec := Default(TAlvRecord);
  Inc(FRecordIndex);
  Rec.Index := FRecordIndex;
  Rec.Offset := FStream.Position;
  Context := Format('record %d', [Rec.Index]);
  Rec.TimestampDeltaMs := ReadCardinal(Context + ' timestamp delta');
  Rec.BlockType := ReadByte(Context + ' block type');
  case Rec.BlockType of
    1, 2:
      begin
        Rec.Codec := ReadByte(Context + ' codec');
        PayloadSize := ReadCardinal(Context + ' payload size');
        Rec.Payload := ReadBytes(PayloadSize, Context + ' payload');
      end;
    3, 4:
      begin
        Rec.Codec := ReadByte(Context + ' codec');
        Rec.BoxShaped := ReadByte(Context + ' box flag') <> 0;
        Rec.X := ReadWord(Context + ' x');
        Rec.Y := ReadWord(Context + ' y');
        Rec.Width := ReadWord(Context + ' width');
        Rec.Height := ReadWord(Context + ' height');
        PayloadSize := ReadCardinal(Context + ' payload size');
        Rec.Payload := ReadBytes(PayloadSize, Context + ' payload');
      end;
  else
    raise EAlvError.CreateFmt('Unsupported ALV block type %d at record %d, offset 0x%x',
      [Rec.BlockType, Rec.Index, Rec.Offset]);
  end;
  Result := True;
end;

function DecompressPayload(const Payload: TBytes; const Context: string): TBytes;
var
  Declared: Cardinal;
  Source: TMemoryStream;
  ZStream: TZDecompressionStream;
  Total, Got: Integer;
  Extra: Byte;
begin
  if Length(Payload) < 4 then
    raise EAlvError.Create(Context + ': compressed payload lacks size field');
  Declared := Cardinal(Payload[0]) or (Cardinal(Payload[1]) shl 8) or
    (Cardinal(Payload[2]) shl 16) or (Cardinal(Payload[3]) shl 24);
  if Declared > MaxDecompressedBlock then
    raise EAlvError.CreateFmt('%s: expanded size %u exceeds safety limit',
      [Context, Declared]);

  Source := TMemoryStream.Create;
  try
    if Length(Payload) > 4 then
      Source.WriteBuffer(Payload[4], Length(Payload) - 4);
    Source.Position := 0;
    ZStream := nil;
    try
      try
        ZStream := TZDecompressionStream.Create(Source);
        SetLength(Result, Integer(Declared));
        Total := 0;
        while Total < Integer(Declared) do
        begin
          Got := ZStream.Read(Result[Total], Integer(Declared) - Total);
          if Got <= 0 then
            raise EAlvError.CreateFmt('%s: truncated zlib stream at %d/%u bytes',
              [Context, Total, Declared]);
          Inc(Total, Got);
        end;
        if ZStream.Read(Extra, 1) <> 0 then
          raise EAlvError.CreateFmt('%s: zlib output exceeds declared size %u',
            [Context, Declared]);
      finally
        ZStream.Free;
      end;
      if Source.Position <> Source.Size then
        raise EAlvError.CreateFmt('%s: %d trailing compressed byte(s)',
          [Context, Source.Size - Source.Position]);
    except
      on E: EAlvError do
        raise;
      on E: Exception do
        raise EAlvError.CreateFmt('%s: invalid zlib stream: %s',
          [Context, E.Message]);
    end;
  finally
    Source.Free;
  end;
end;

function ParseRegionList(const Rec: TAlvRecord): TArray<TAlvRegion>;
var
  Data: TBytes;
  Cursor: TByteCursor;
  Count: Cardinal;
  I: Integer;
  PayloadSize: Cardinal;
begin
  Data := DecompressPayload(Rec.Payload,
    Format('record %d type-2 container', [Rec.Index]));
  Cursor := TByteCursor.Create(Data,
    Format('record %d type-2 region list', [Rec.Index]));
  try
    Count := Cursor.ReadCardinal('region count');
    if Count > Cardinal(Cursor.Remaining div 13) then
      raise EAlvError.CreateFmt('record %d: region count %u cannot fit container',
        [Rec.Index, Count]);
    SetLength(Result, Integer(Count));
    for I := 0 to Integer(Count) - 1 do
    begin
      Result[I].Context := Format('record %d embedded region %d',
        [Rec.Index, I + 1]);
      Result[I].X := Cursor.ReadWord(Result[I].Context + ' x');
      Result[I].Y := Cursor.ReadWord(Result[I].Context + ' y');
      Result[I].Width := Cursor.ReadWord(Result[I].Context + ' width');
      Result[I].Height := Cursor.ReadWord(Result[I].Context + ' height');
      Result[I].Codec := Cursor.ReadByte(Result[I].Context + ' codec');
      PayloadSize := Cursor.ReadCardinal(Result[I].Context + ' payload size');
      if PayloadSize > Cardinal(MaxInt) then
        raise EAlvError.Create(Result[I].Context + ': payload too large');
      Result[I].Payload := Cursor.ReadBytes(Integer(PayloadSize),
        Result[I].Context + ' payload');
    end;
    if Cursor.Remaining <> 0 then
      raise EAlvError.CreateFmt('record %d: %d unparsed container byte(s)',
        [Rec.Index, Cursor.Remaining]);
  finally
    Cursor.Free;
  end;
end;

constructor TAlvDecoder.Create(const Header: TAlvHeader);
var
  PixelCount: Int64;
begin
  inherited Create;
  FHeader := Header;
  PixelCount := Int64(Header.Width) * Header.Height;
  if PixelCount > MaxCanvasPixels then
    raise EAlvError.CreateFmt('Canvas %dx%d exceeds safety limit',
      [Header.Width, Header.Height]);
  SetLength(FCanvas, PixelCount * 3);
  BuildPalette;
end;

procedure TAlvDecoder.BuildPalette;
var
  DC: HDC;
  Palette: HPALETTE;
begin
  DC := GetDC(0);
  if DC = 0 then
    raise EAlvError.Create('GetDC failed while creating 8-bit palette');
  try
    Palette := CreateHalftonePalette(DC);
    if Palette = 0 then
      raise EAlvError.Create('CreateHalftonePalette failed');
    try
      if GetPaletteEntries(Palette, 0, 256, FPalette[0]) <> 256 then
        raise EAlvError.Create('GetPaletteEntries did not return 256 colors');
    finally
      DeleteObject(Palette);
    end;
  finally
    ReleaseDC(0, DC);
  end;
end;

procedure TAlvDecoder.ValidateRegion(const Region: TAlvRegion);
begin
  if (Region.Width = 0) or (Region.Height = 0) then
    raise EAlvError.Create(Region.Context + ': zero-sized region');
  if (Cardinal(Region.X) + Region.Width > FHeader.Width) or
     (Cardinal(Region.Y) + Region.Height > FHeader.Height) then
    raise EAlvError.CreateFmt('%s: region %d,%d %dx%d exceeds %dx%d canvas',
      [Region.Context, Region.X, Region.Y, Region.Width, Region.Height,
       FHeader.Width, FHeader.Height]);
end;

procedure TAlvDecoder.DecodeRaw(const Region: TAlvRegion);
var
  Raw: TBytes;
  BytesPerPixel, Stride, Expected: NativeInt;
  Row, Col, SourceIndex, DestIndex: NativeInt;
  PaletteIndex: Byte;
  Pixel16: Word;
begin
  Raw := DecompressPayload(Region.Payload, Region.Context);
  case FHeader.ColorDepthCode of
    0: BytesPerPixel := 1;
    1: BytesPerPixel := 2;
  else
    BytesPerPixel := 3;
  end;
  Stride := (NativeInt(Region.Width) * BytesPerPixel + 3) and not 3;
  Expected := 1 + Stride * Region.Height;
  if Length(Raw) <> Expected then
    raise EAlvError.CreateFmt('%s: raw bitmap size %d, expected %d',
      [Region.Context, Length(Raw), Expected]);
  if Raw[0] <> 0 then
    raise EAlvError.CreateFmt('%s: unsupported pixel payload version %d',
      [Region.Context, Raw[0]]);

  for Row := 0 to Region.Height - 1 do
  begin
    SourceIndex := 1 + (NativeInt(Region.Height) - 1 - Row) * Stride;
    DestIndex := ((NativeInt(Region.Y) + Row) * FHeader.Width + Region.X) * 3;
    for Col := 0 to Region.Width - 1 do
    begin
      case FHeader.ColorDepthCode of
        0:
          begin
            PaletteIndex := Raw[SourceIndex + Col];
            FCanvas[DestIndex] := FPalette[PaletteIndex].peRed;
            FCanvas[DestIndex + 1] := FPalette[PaletteIndex].peGreen;
            FCanvas[DestIndex + 2] := FPalette[PaletteIndex].peBlue;
          end;
        1:
          begin
            Pixel16 := Word(Raw[SourceIndex + Col * 2]) or
              (Word(Raw[SourceIndex + Col * 2 + 1]) shl 8);
            FCanvas[DestIndex] := ((Pixel16 shr 11) and $1F) * 255 div 31;
            FCanvas[DestIndex + 1] := ((Pixel16 shr 5) and $3F) * 255 div 63;
            FCanvas[DestIndex + 2] := (Pixel16 and $1F) * 255 div 31;
          end;
      else
        FCanvas[DestIndex] := Raw[SourceIndex + Col * 3 + 2];
        FCanvas[DestIndex + 1] := Raw[SourceIndex + Col * 3 + 1];
        FCanvas[DestIndex + 2] := Raw[SourceIndex + Col * 3];
      end;
      Inc(DestIndex, 3);
    end;
  end;
end;

procedure TAlvDecoder.DecodeJpeg(const Region: TAlvRegion);
var
  Source: TBytesStream;
  Jpeg: TJPEGImage;
  Bitmap: TBitmap;
  Scan: PByte;
  Row, Col, DestIndex: NativeInt;
begin
  if (Length(Region.Payload) < 4) or
     (Region.Payload[0] <> $FF) or (Region.Payload[1] <> $D8) or
     (Region.Payload[Length(Region.Payload) - 2] <> $FF) or
     (Region.Payload[Length(Region.Payload) - 1] <> $D9) then
    raise EAlvError.Create(Region.Context + ': invalid JPEG markers');

  Source := TBytesStream.Create(Region.Payload);
  Jpeg := TJPEGImage.Create;
  Bitmap := TBitmap.Create;
  try
    try
      Jpeg.LoadFromStream(Source);
      if (Jpeg.Width <> Region.Width) or (Jpeg.Height <> Region.Height) then
        raise EAlvError.CreateFmt('%s: JPEG is %dx%d, expected %dx%d',
          [Region.Context, Jpeg.Width, Jpeg.Height, Region.Width, Region.Height]);
      Bitmap.Assign(Jpeg);
      Bitmap.PixelFormat := pf24bit;
      for Row := 0 to Region.Height - 1 do
      begin
        Scan := Bitmap.ScanLine[Row];
        DestIndex := ((NativeInt(Region.Y) + Row) * FHeader.Width + Region.X) * 3;
        for Col := 0 to Region.Width - 1 do
        begin
          FCanvas[DestIndex] := Scan[Col * 3 + 2];
          FCanvas[DestIndex + 1] := Scan[Col * 3 + 1];
          FCanvas[DestIndex + 2] := Scan[Col * 3];
          Inc(DestIndex, 3);
        end;
      end;
    except
      on E: EAlvError do
        raise;
      on E: Exception do
        raise EAlvError.CreateFmt('%s: JPEG decode failed: %s',
          [Region.Context, E.Message]);
    end;
  finally
    Bitmap.Free;
    Jpeg.Free;
    Source.Free;
  end;
end;

procedure TAlvDecoder.ApplyRegion(const Region: TAlvRegion);
begin
  ValidateRegion(Region);
  case Region.Codec of
    0: DecodeRaw(Region);
    1: DecodeJpeg(Region);
  else
    raise EAlvError.CreateFmt('%s: unsupported codec %d',
      [Region.Context, Region.Codec]);
  end;
end;

procedure TAlvDecoder.Apply(const Rec: TAlvRecord);
var
  Regions: TArray<TAlvRegion>;
  Region: TAlvRegion;
  I: Integer;
  HasFullRegion: Boolean;
begin
  case Rec.BlockType of
    1:
      begin
        SetLength(Regions, 1);
        Regions[0].X := 0;
        Regions[0].Y := 0;
        Regions[0].Width := FHeader.Width;
        Regions[0].Height := FHeader.Height;
        Regions[0].Codec := Rec.Codec;
        Regions[0].Payload := Rec.Payload;
        Regions[0].Context := Format('record %d full frame', [Rec.Index]);
      end;
    2: Regions := ParseRegionList(Rec);
    3, 4:
      begin
        SetLength(Regions, 1);
        Regions[0].X := Rec.X;
        Regions[0].Y := Rec.Y;
        Regions[0].Width := Rec.Width;
        Regions[0].Height := Rec.Height;
        Regions[0].Codec := Rec.Codec;
        Regions[0].Payload := Rec.Payload;
        Regions[0].Context := Format('record %d region', [Rec.Index]);
      end;
  else
    raise EAlvError.CreateFmt('Unsupported block type %d', [Rec.BlockType]);
  end;

  if not FHasFrame then
  begin
    HasFullRegion := False;
    for Region in Regions do
      if (Region.X = 0) and (Region.Y = 0) and
         (Region.Width = FHeader.Width) and (Region.Height = FHeader.Height) then
      begin
        HasFullRegion := True;
        Break;
      end;
    if not HasFullRegion then
      raise EAlvError.CreateFmt('Record %d does not initialize the full canvas',
        [Rec.Index]);
  end;

  for I := 0 to Length(Regions) - 1 do
    ApplyRegion(Regions[I]);
  FHasFrame := True;
end;

end.

