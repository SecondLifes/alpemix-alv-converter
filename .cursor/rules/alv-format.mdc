# The ALV Container Format

`.alv` is the proprietary session-recording format written by **Alpemix**,
a remote-support product: a support operator's remote-desktop session is
captured to disk and replayed later inside Alpemix itself. There is no
published specification. Everything below was reconstructed by static
analysis of the vendor's own player and legacy converter binaries, then
validated by parsing a real recording end to end.

**Read `evidence-grading.md` before adding anything to this file.** Every
statement here carries a confidence level, and a claim that cannot be
backed by a validated sample does not get written as fact.

## Ground rules

- **Little-endian** throughout. Every multi-byte integer.
- **No magic bytes.** There is no ASCII signature to sniff; the first bytes
  are a `u32` prologue. Do not write a format detector that looks for one.
- **No footer, no checksum, no index.** Parsing ends when the byte count
  runs out. A correct parse consumes the file to *exact* EOF — see
  `defensive-parsing.md`, where that is the primary integrity signal.
- Strings are Delphi `ShortString`: a `u8` length followed by exactly that
  many bytes. Not NUL-terminated, not length-prefixed with `u32`.
- Timestamps in the header are Delphi `TDateTime`: an `f64` counting days
  since **1899-12-30**, not the Unix epoch.

## File header

| Offset | Type | Meaning |
|---:|---|---|
| `0x00` | `u32` | prologue (observed `0`; purpose unknown) |
| `0x04` | `u8` | format version |
| `0x05` | `u32` | header-payload length |
| `0x09` | bytes | bounded header payload |

The payload holds, in order:

1. `f64` — Delphi `TDateTime`, when the recording started
2. five Delphi `ShortString` values
3. `u8` `color_depth_code`
4. `u16` `background_color`
5. `u16` `canvas_width`
6. `u16` `canvas_height`

The record stream starts immediately after the payload. **The start offset
is dynamic** — it moves with the five variable-length strings. Never
hardcode it; compute it. (In the validated sample it lands at `0x51`, but
that number is a property of that file, not of the format.)

## Record envelope

Every record opens with `u32 timestamp_delta_ms` and `u8 block_type`.
The delta is milliseconds **since the previous record**, not an absolute
time — see `streaming-pipeline.md` for how those deltas become a
constant-rate video without accumulating drift.

**Types 1 and 2** then carry `u8 codec`, `u32 payload_size`, and the
payload. A type-2 codec-0 payload expands to a region list:

```text
u32 region_count
repeat region_count times:
    u16 x, y, width, height
    u8  codec
    u32 payload_size
    u8  payload[payload_size]
```

**Types 3 and 4** share one layout:

```text
u8  codec
u8  box_shaped
u16 x, y, width, height
u32 payload_size
u8  payload[payload_size]
```

Their semantic difference is **UNKNOWN**. The player routes both through
the same region decoder, and `box_shaped` does not change pixel placement
on the observed playback path — it is preserved on read and otherwise
ignored. Do not invent a meaning for either; if a future sample settles
it, update this file and `evidence-grading.md` together.

**Types 5-8 and 255** exist as branches in the player but have no
validated layout. They are **rejected**, not guessed — see
`evidence-grading.md`.

## Codecs

**Codec 0 — zlib.** A serialized Delphi `TSikismisData`: `u32
uncompressed_size` followed by one zlib stream. For a pixel region the
expanded bytes are:

```text
u8 pixel_payload_version    # 0 in every validated record
u8 bottom_up_scanlines[align4(width * bytes_per_pixel) * height]
```

Two things bite here, both inherited from the VCL bitmaps this came from:

- **Scanlines are bottom-up.** Row 0 of the buffer is the *bottom* row of
  the image. Writing them top-down produces a vertically mirrored frame
  that still decodes without error — a silent corruption, not a crash.
- **Each row is padded to a 4-byte boundary.** The stride is
  `align4(width * bytes_per_pixel)`, not `width * bytes_per_pixel`.
  Ignoring the padding shears the image progressively.

**Codec 1 — JPEG.** A raw JPEG stream (`FF D8 … FF D9`). Its decoded
dimensions must match the enclosing region; a mismatch is a parse error,
not something to scale around.

## Colour depth

`color_depth_code` selects the pixel format:

| Code | Format |
|---:|---|
| `0` | 8-bit indexed |
| `1` | RGB565 |
| other | 24-bit BGR |

**8-bit is the one with a trap.** The palette is not stored in the file.
It is the Windows *halftone* palette that VCL's
`TBitmap.SetPixelFormat(pf8bit)` creates via `CreateHalftonePalette`.
Obtain it from GDI at runtime — never hardcode a table, and never
substitute a generic 256-colour palette. This is why exact 8-bit output
requires Windows; on any other platform, say so rather than emitting
approximate colours silently.

Note the byte order on the 24-bit path: **BGR**, not RGB.

## Canvas model

One canvas, mutated in place. A record paints its region into the current
canvas; the canvas after record N is the frame at record N. Records are
deltas against what came before — you cannot decode record N without
having decoded every record before it, and there are no keyframes to
resynchronise from. A parse error partway through is therefore fatal to
everything after it, which is precisely why `defensive-parsing.md` insists
every read is bounded and every failure names its byte offset.

## What is not in the format

No separate keyboard, mouse, audio or cursor records were observed. That
information may be absent, or already rasterised into the frames. **Both
readings are consistent with the evidence, so neither is asserted.** Do
not add an audio path, a cursor overlay, or an input track on the
assumption that one exists.
