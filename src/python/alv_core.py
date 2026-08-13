"""Safe parser and image decoder for the Alpemix ALV recording format."""

from __future__ import annotations

import ctypes
import io
import os
import statistics
import struct
import zlib
from collections.abc import Iterator
from dataclasses import dataclass
from datetime import datetime, timedelta
from functools import lru_cache
from pathlib import Path
from typing import BinaryIO


MAX_DECOMPRESSED_BLOCK = 512 * 1024 * 1024
MAX_CANVAS_PIXELS = 100_000_000


class ALVError(Exception):
    """Base class for controlled ALV failures."""


class ALVUnsupportedError(ALVError):
    """Raised when a valid-looking but unsupported feature is encountered."""


class ALVParseError(ALVError):
    """A bounds, structure, or payload validation failure with byte context."""

    def __init__(
        self,
        message: str,
        *,
        offset: int | None = None,
        expected: int | str | None = None,
        remaining: int | None = None,
        context: str | None = None,
    ) -> None:
        self.message = message
        self.offset = offset
        self.expected = expected
        self.remaining = remaining
        self.context = context
        super().__init__(str(self))

    def __str__(self) -> str:
        parts = ["ALV parse error"]
        if self.offset is not None:
            parts.append(f"at offset 0x{self.offset:X}")
        if self.context:
            parts.append(f"in {self.context}")
        parts.append(f": {self.message}")
        if self.expected is not None:
            parts.append(f"; expected {self.expected}")
        if self.remaining is not None:
            parts.append(f"; remaining {self.remaining} byte(s)")
        return " ".join(parts)


@dataclass(frozen=True)
class ALVHeader:
    prologue: int
    version: int
    header_payload_length: int
    recorded_at_tdatetime: float
    recorded_at: datetime | None
    strings: tuple[str, str, str, str, str]
    color_depth_code: int
    background_color: int
    width: int
    height: int
    records_offset: int
    trailing_header_bytes: bytes = b""


@dataclass(frozen=True)
class ALVRecord:
    index: int
    offset: int
    timestamp_delta_ms: int
    block_type: int
    codec: int
    payload: bytes
    box_shaped: bool | None = None
    x: int | None = None
    y: int | None = None
    width: int | None = None
    height: int | None = None

    @property
    def end_offset(self) -> int:
        return self.offset + self.encoded_size

    @property
    def encoded_size(self) -> int:
        if self.block_type in (1, 2):
            return 4 + 1 + 1 + 4 + len(self.payload)
        return 4 + 1 + 1 + 1 + 8 + 4 + len(self.payload)


@dataclass(frozen=True)
class ALVRegion:
    x: int
    y: int
    width: int
    height: int
    codec: int
    payload: bytes
    context: str


def codec_name(codec: int) -> str:
    return {0: "zlib/raw-bitmap", 1: "jpeg"}.get(codec, f"unknown({codec})")


class SafeReader:
    """Little-endian reader that never exposes struct/EOF exceptions."""

    def __init__(
        self,
        stream: BinaryIO,
        *,
        size: int,
        base_offset: int = 0,
        context: str = "file",
    ) -> None:
        self.stream = stream
        self.size = size
        self.base_offset = base_offset
        self.context = context

    def tell(self) -> int:
        return self.stream.tell()

    def absolute_offset(self) -> int:
        return self.base_offset + self.tell()

    def remaining(self) -> int:
        return self.size - self.tell()

    def read_exact(self, count: int, label: str) -> bytes:
        if count < 0:
            raise ALVParseError(
                f"negative size for {label}",
                offset=self.absolute_offset(),
                expected=">= 0",
                remaining=self.remaining(),
                context=self.context,
            )
        remaining = self.remaining()
        if count > remaining:
            raise ALVParseError(
                f"truncated {label}",
                offset=self.absolute_offset(),
                expected=f"{count} byte(s)",
                remaining=remaining,
                context=self.context,
            )
        data = self.stream.read(count)
        if len(data) != count:
            raise ALVParseError(
                f"short read for {label}",
                offset=self.absolute_offset() - len(data),
                expected=f"{count} byte(s)",
                remaining=len(data),
                context=self.context,
            )
        return data

    def _unpack(self, fmt: str, size: int, label: str):
        return struct.unpack(fmt, self.read_exact(size, label))[0]

    def u8(self, label: str) -> int:
        return self._unpack("<B", 1, label)

    def u16(self, label: str) -> int:
        return self._unpack("<H", 2, label)

    def u32(self, label: str) -> int:
        return self._unpack("<I", 4, label)

    def f64(self, label: str) -> float:
        return self._unpack("<d", 8, label)


def _decode_shortstring(raw: bytes) -> str:
    for encoding in ("utf-8", "cp1254", "latin-1"):
        try:
            return raw.decode(encoding)
        except UnicodeDecodeError:
            continue
    return raw.decode("latin-1", errors="replace")


def _delphi_datetime(value: float) -> datetime | None:
    try:
        return datetime(1899, 12, 30) + timedelta(days=value)
    except (OverflowError, ValueError):
        return None


def parse_header(reader: SafeReader) -> ALVHeader:
    prologue = reader.u32("file prologue")
    version = reader.u8("format version")
    payload_length = reader.u32("header payload length")
    payload_offset = reader.absolute_offset()
    payload = reader.read_exact(payload_length, "header payload")
    inner = SafeReader(
        io.BytesIO(payload),
        size=len(payload),
        base_offset=payload_offset,
        context="header payload",
    )
    recorded_value = inner.f64("Delphi TDateTime")
    strings: list[str] = []
    for number in range(1, 6):
        length = inner.u8(f"ShortString {number} length")
        strings.append(
            _decode_shortstring(inner.read_exact(length, f"ShortString {number}"))
        )
    color_depth = inner.u8("color depth code")
    background = inner.u16("background color")
    width = inner.u16("canvas width")
    height = inner.u16("canvas height")
    if width == 0 or height == 0:
        raise ALVParseError(
            "zero-sized canvas",
            offset=payload_offset,
            expected="non-zero width and height",
            context="header payload",
        )
    trailing = inner.read_exact(inner.remaining(), "header trailing bytes")
    return ALVHeader(
        prologue=prologue,
        version=version,
        header_payload_length=payload_length,
        recorded_at_tdatetime=recorded_value,
        recorded_at=_delphi_datetime(recorded_value),
        strings=tuple(strings),  # type: ignore[arg-type]
        color_depth_code=color_depth,
        background_color=background,
        width=width,
        height=height,
        records_offset=reader.absolute_offset(),
        trailing_header_bytes=trailing,
    )


class ALVParser:
    """Streaming parser for one ALV file."""

    def __init__(self, path: str | os.PathLike[str]) -> None:
        self.path = Path(path)
        self._stream: BinaryIO | None = None
        self.reader: SafeReader | None = None
        self.header: ALVHeader | None = None

    def __enter__(self) -> "ALVParser":
        try:
            self._stream = self.path.open("rb")
        except OSError as exc:
            raise ALVError(f"cannot open {self.path}: {exc}") from None
        try:
            size = self.path.stat().st_size
            self.reader = SafeReader(self._stream, size=size, context=str(self.path))
            self.header = parse_header(self.reader)
        except BaseException:
            self._stream.close()
            self._stream = None
            raise
        return self

    def __exit__(self, exc_type, exc, traceback) -> None:
        if self._stream is not None:
            self._stream.close()

    def iter_records(self) -> Iterator[ALVRecord]:
        if self.reader is None or self.header is None:
            raise ALVError("ALVParser must be used as a context manager")
        reader = self.reader
        index = 0
        while reader.remaining():
            index += 1
            offset = reader.absolute_offset()
            context = f"record {index}"
            timestamp = reader.u32(f"{context} timestamp delta")
            block_type = reader.u8(f"{context} block type")
            if block_type in (1, 2):
                codec = reader.u8(f"{context} codec")
                size = reader.u32(f"{context} payload size")
                payload = reader.read_exact(size, f"{context} payload")
                yield ALVRecord(index, offset, timestamp, block_type, codec, payload)
                continue
            if block_type in (3, 4):
                codec = reader.u8(f"{context} codec")
                box_shaped = bool(reader.u8(f"{context} box-shaped flag"))
                x = reader.u16(f"{context} x")
                y = reader.u16(f"{context} y")
                width = reader.u16(f"{context} width")
                height = reader.u16(f"{context} height")
                size = reader.u32(f"{context} payload size")
                payload = reader.read_exact(size, f"{context} payload")
                yield ALVRecord(
                    index,
                    offset,
                    timestamp,
                    block_type,
                    codec,
                    payload,
                    box_shaped,
                    x,
                    y,
                    width,
                    height,
                )
                continue
            raise ALVUnsupportedError(
                f"unsupported block type {block_type} at record {index}, "
                f"offset 0x{offset:X}"
            )


def decompress_payload(
    payload: bytes, *, context: str, payload_offset: int | None = None
) -> bytes:
    if len(payload) < 4:
        raise ALVParseError(
            "compressed payload lacks its uncompressed-size field",
            offset=payload_offset,
            expected="at least 4 byte(s)",
            remaining=len(payload),
            context=context,
        )
    declared = struct.unpack("<I", payload[:4])[0]
    if declared > MAX_DECOMPRESSED_BLOCK:
        raise ALVParseError(
            "declared uncompressed block exceeds safety limit",
            offset=payload_offset,
            expected=f"at most {MAX_DECOMPRESSED_BLOCK} byte(s)",
            remaining=declared,
            context=context,
        )
    try:
        inflater = zlib.decompressobj()
        decoded = inflater.decompress(payload[4:], declared + 1)
        if len(decoded) <= declared:
            decoded += inflater.flush(declared + 1 - len(decoded))
    except zlib.error as exc:
        raise ALVParseError(
            f"invalid zlib stream: {exc}", offset=payload_offset, context=context
        ) from None
    if not inflater.eof:
        raise ALVParseError(
            "truncated zlib stream", offset=payload_offset, context=context
        )
    if inflater.unused_data:
        raise ALVParseError(
            "bytes follow zlib end marker",
            offset=payload_offset,
            expected="no trailing compressed bytes",
            remaining=len(inflater.unused_data),
            context=context,
        )
    if len(decoded) != declared:
        raise ALVParseError(
            "uncompressed size mismatch",
            offset=payload_offset,
            expected=f"{declared} byte(s)",
            remaining=len(decoded),
            context=context,
        )
    return decoded


def parse_region_list(record: ALVRecord) -> list[ALVRegion]:
    if record.block_type != 2:
        raise ALVError("parse_region_list requires a type-2 record")
    decoded = decompress_payload(
        record.payload,
        context=f"record {record.index} type-2 container",
        payload_offset=record.offset,
    )
    reader = SafeReader(
        io.BytesIO(decoded),
        size=len(decoded),
        context=f"record {record.index} type-2 region list",
    )
    count = reader.u32("region count")
    if count > reader.remaining() // 13:
        raise ALVParseError(
            "region count cannot fit in container",
            offset=reader.absolute_offset() - 4,
            expected=f"at most {reader.remaining() // 13} region descriptor(s)",
            remaining=count,
            context=reader.context,
        )
    regions: list[ALVRegion] = []
    for region_index in range(1, count + 1):
        context = f"record {record.index} embedded region {region_index}"
        x = reader.u16(f"{context} x")
        y = reader.u16(f"{context} y")
        width = reader.u16(f"{context} width")
        height = reader.u16(f"{context} height")
        codec = reader.u8(f"{context} codec")
        size = reader.u32(f"{context} payload size")
        payload = reader.read_exact(size, f"{context} payload")
        regions.append(ALVRegion(x, y, width, height, codec, payload, context))
    if reader.remaining():
        raise ALVParseError(
            "unparsed bytes after type-2 region list",
            offset=reader.absolute_offset(),
            expected="end of container",
            remaining=reader.remaining(),
            context=reader.context,
        )
    return regions


def record_regions(record: ALVRecord, header: ALVHeader) -> list[ALVRegion]:
    if record.block_type == 1:
        return [
            ALVRegion(
                0,
                0,
                header.width,
                header.height,
                record.codec,
                record.payload,
                f"record {record.index} full frame",
            )
        ]
    if record.block_type == 2:
        return parse_region_list(record)
    assert record.x is not None and record.y is not None
    assert record.width is not None and record.height is not None
    return [
        ALVRegion(
            record.x,
            record.y,
            record.width,
            record.height,
            record.codec,
            record.payload,
            f"record {record.index} region",
        )
    ]


def bytes_per_pixel(color_depth_code: int) -> int:
    if color_depth_code == 0:
        return 1
    if color_depth_code == 1:
        return 2
    return 3


def aligned_stride(width: int, color_depth_code: int) -> int:
    row_bytes = width * bytes_per_pixel(color_depth_code)
    return (row_bytes + 3) & ~3


def _validate_region_geometry(region: ALVRegion, header: ALVHeader) -> None:
    if region.width == 0 or region.height == 0:
        raise ALVParseError(
            "zero-sized region", expected="non-zero width and height", context=region.context
        )
    if region.x + region.width > header.width or region.y + region.height > header.height:
        raise ALVParseError(
            "region exceeds canvas bounds",
            expected=f"inside {header.width}x{header.height}",
            context=region.context,
        )


def validate_region(region: ALVRegion, header: ALVHeader) -> None:
    _validate_region_geometry(region, header)
    if region.codec == 0:
        raw = decompress_payload(region.payload, context=region.context)
        expected = 1 + aligned_stride(region.width, header.color_depth_code) * region.height
        if len(raw) != expected:
            raise ALVParseError(
                "raw bitmap size mismatch",
                expected=f"{expected} byte(s)",
                remaining=len(raw),
                context=region.context,
            )
        if raw[0] != 0:
            raise ALVUnsupportedError(
                f"unsupported pixel payload version {raw[0]} in {region.context}"
            )
        return
    if region.codec == 1:
        if len(region.payload) < 4 or not region.payload.startswith(b"\xFF\xD8"):
            raise ALVParseError("JPEG SOI marker missing", context=region.context)
        if not region.payload.endswith(b"\xFF\xD9"):
            raise ALVParseError("JPEG EOI marker missing", context=region.context)
        image = _open_jpeg(region)
        image.close()
        return
    raise ALVUnsupportedError(f"unsupported codec {region.codec} in {region.context}")


def _require_pillow():
    try:
        from PIL import Image
    except ImportError:
        raise ALVError(
            "Pillow is required for image decoding; install requirements.txt"
        ) from None
    return Image


@lru_cache(maxsize=1)
def windows_halftone_palette() -> tuple[int, ...]:
    """Return the exact 256-entry palette used by VCL pf8bit on Windows."""
    if os.name != "nt":
        raise ALVUnsupportedError(
            "8-bit ALV palette reconstruction requires Windows GDI"
        )
    user32 = ctypes.WinDLL("user32", use_last_error=True)
    gdi32 = ctypes.WinDLL("gdi32", use_last_error=True)
    user32.GetDC.argtypes = [ctypes.c_void_p]
    user32.GetDC.restype = ctypes.c_void_p
    user32.ReleaseDC.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
    user32.ReleaseDC.restype = ctypes.c_int
    gdi32.CreateHalftonePalette.argtypes = [ctypes.c_void_p]
    gdi32.CreateHalftonePalette.restype = ctypes.c_void_p
    gdi32.GetPaletteEntries.argtypes = [
        ctypes.c_void_p,
        ctypes.c_uint,
        ctypes.c_uint,
        ctypes.c_void_p,
    ]
    gdi32.GetPaletteEntries.restype = ctypes.c_uint
    gdi32.DeleteObject.argtypes = [ctypes.c_void_p]
    gdi32.DeleteObject.restype = ctypes.c_int

    class PALETTEENTRY(ctypes.Structure):
        _fields_ = [
            ("peRed", ctypes.c_ubyte),
            ("peGreen", ctypes.c_ubyte),
            ("peBlue", ctypes.c_ubyte),
            ("peFlags", ctypes.c_ubyte),
        ]

    dc = user32.GetDC(None)
    if not dc:
        raise ALVError("GetDC failed while reconstructing the VCL palette")
    palette_handle = None
    try:
        palette_handle = gdi32.CreateHalftonePalette(dc)
        if not palette_handle:
            raise ALVError("CreateHalftonePalette failed")
        entries = (PALETTEENTRY * 256)()
        count = gdi32.GetPaletteEntries(palette_handle, 0, 256, entries)
        if count != 256:
            raise ALVError(f"GetPaletteEntries returned {count}, expected 256")
        flattened: list[int] = []
        for entry in entries:
            flattened.extend((entry.peRed, entry.peGreen, entry.peBlue))
        return tuple(flattened)
    finally:
        if palette_handle:
            gdi32.DeleteObject(palette_handle)
        user32.ReleaseDC(None, dc)


def _open_jpeg(region: ALVRegion):
    Image = _require_pillow()
    try:
        image = Image.open(io.BytesIO(region.payload))
    except Exception as exc:
        raise ALVParseError(f"invalid JPEG: {exc}", context=region.context) from None
    if image.size != (region.width, region.height):
        actual = image.size
        image.close()
        raise ALVParseError(
            "JPEG dimensions do not match region",
            expected=f"{region.width}x{region.height}",
            context=f"{region.context}; decoded {actual[0]}x{actual[1]}",
        )
    try:
        image.load()
    except Exception as exc:
        image.close()
        raise ALVParseError(f"invalid JPEG: {exc}", context=region.context) from None
    return image


def decode_region(region: ALVRegion, header: ALVHeader):
    Image = _require_pillow()
    _validate_region_geometry(region, header)
    if region.codec == 1:
        if len(region.payload) < 4 or not region.payload.startswith(b"\xFF\xD8"):
            raise ALVParseError("JPEG SOI marker missing", context=region.context)
        if not region.payload.endswith(b"\xFF\xD9"):
            raise ALVParseError("JPEG EOI marker missing", context=region.context)
        image = _open_jpeg(region)
        try:
            return image.convert("RGB")
        finally:
            image.close()

    if region.codec != 0:
        raise ALVUnsupportedError(f"unsupported codec {region.codec} in {region.context}")
    raw = decompress_payload(region.payload, context=region.context)
    expected = 1 + aligned_stride(region.width, header.color_depth_code) * region.height
    if len(raw) != expected:
        raise ALVParseError(
            "raw bitmap size mismatch",
            expected=f"{expected} byte(s)",
            remaining=len(raw),
            context=region.context,
        )
    if raw[0] != 0:
        raise ALVUnsupportedError(
            f"unsupported pixel payload version {raw[0]} in {region.context}"
        )
    pixels = raw[1:]
    stride = aligned_stride(region.width, header.color_depth_code)
    size = (region.width, region.height)
    try:
        if header.color_depth_code == 0:
            image = Image.frombytes("P", size, pixels, "raw", "P", stride, -1)
            image.putpalette(windows_halftone_palette())
            rgb = image.convert("RGB")
            image.close()
            return rgb
        if header.color_depth_code == 1:
            return Image.frombytes("RGB", size, pixels, "raw", "BGR;16", stride, -1)
        return Image.frombytes("RGB", size, pixels, "raw", "BGR", stride, -1)
    except (ValueError, OSError) as exc:
        raise ALVParseError(
            f"cannot decode raw bitmap: {exc}", context=region.context
        ) from None


class ALVDecoder:
    """Incrementally reconstruct frames while retaining only one canvas."""

    def __init__(self, header: ALVHeader) -> None:
        if header.width * header.height > MAX_CANVAS_PIXELS:
            raise ALVUnsupportedError(
                f"canvas {header.width}x{header.height} exceeds the "
                f"{MAX_CANVAS_PIXELS:,}-pixel safety limit"
            )
        self.header = header
        self.canvas = None

    def apply(self, record: ALVRecord):
        Image = _require_pillow()
        regions = record_regions(record, self.header)
        if self.canvas is None:
            if not regions or not any(
                r.x == 0
                and r.y == 0
                and r.width == self.header.width
                and r.height == self.header.height
                for r in regions
            ):
                raise ALVParseError(
                    "first decodable record is not a full canvas",
                    expected=f"region 0,0 {self.header.width}x{self.header.height}",
                    context=f"record {record.index}",
                )
            self.canvas = Image.new("RGB", (self.header.width, self.header.height))
        for region in regions:
            image = decode_region(region, self.header)
            try:
                self.canvas.paste(image, (region.x, region.y))
            finally:
                image.close()
        return self.canvas


def positive_delta_median(deltas: list[int]) -> float:
    positive = [value for value in deltas if value > 0]
    return float(statistics.median(positive)) if positive else 40.0
