# Delphi Conventions

The Delphi implementation is a Win32 console EXE with **no dependency
beyond the RTL and the Windows API** — no Python, no Pillow, no third-party
component. That constraint is the point of this implementation existing;
keep it. Adding a package to solve something the RTL already does costs the
one property that makes this build worth shipping.

This kit is deliberately standalone: it does not resolve Delphi base rules
from another kit, so the language conventions it relies on are written
here.

## Unit naming and layout

Dotted namespaces, one concern per unit:

```
Alv.Core       parser, decoder, canvas
Alv.FFmpeg     pipe and process handling
Alv.Export     PNG frame export
Alv.Converter  orchestration
AlvConverter.dpr  entry point, argument parsing
```

The `.dpr` stays thin — argument parsing and a call into `Alv.Converter`.
Decoding logic does not live in the project file.

## Identifiers

| Kind | Convention | Example |
|---|---|---|
| Types | `T` prefix, PascalCase | `TAlvReader`, `TAlvHeader`, `TAlvRecord`, `TAlvRegion` |
| Exceptions | `E` prefix | `EAlvError` |
| Private fields | `F` prefix | `FStream`, `FHeader`, `FRecordIndex` |
| Constants | PascalCase | `MaxDecompressedBlock` |
| Parameters | plain, no Hungarian prefix | `Count`, `Context` |

Records (not classes) for plain data — `TAlvHeader`, `TAlvRecord` and
`TAlvRegion` are all `record`. They carry no behaviour and no lifetime, so
they need no allocation and no `try..finally` around them. Reach for a
class only when something genuinely owns a resource.

## Memory and resource safety

Anything created with `.Create` that has no owner gets a `try..finally`
opening on the **immediately following line**:

```pascal
Reader := TAlvReader.Create(FileName);
try
  while Reader.ReadNext(Rec) do
    ProcessRecord(Rec);
finally
  Reader.Free;
end;
```

Same for every handle this project opens: file streams, the GDI palette,
the anonymous pipe handles, the FFmpeg process handles. A converter that
leaks a pipe handle per run is invisible in a one-shot CLI and fatal in a
batch loop.

`TBytes` payloads are managed — do not free them manually, and do not hold
a pointer into one past the lifetime of the record that owns it.

## Exceptions

One root, `EAlvError`, raised with `CreateFmt` and full locating context —
see `defensive-parsing.md`, which owns the message format. Never raise a
bare `Exception`. Never write `except end` or an `on E: Exception` that
swallows: the distinction between a malformed file and an unsupported path
is the most useful thing the caller learns.

At the top-level boundary (`.dpr`), catch `EAlvError` to print a clean
message and set a non-zero exit code — that is a *reporting* boundary, not
a suppression point, and it is the only place a broad catch belongs.

## Windows-specific reality

- `{$POINTERMATH ON}` is used for scanline arithmetic in `Alv.Core`. Scope
  it to the unit that needs it rather than switching it on globally.
- The 8-bit halftone palette comes from GDI at runtime
  (`CreateHalftonePalette`), never from a hardcoded table — see
  `alv-format.md`.
- Bounded little-endian reads are hand-written against `TFileStream`; the
  RTL's `ReadBuffer` is deliberately not used directly, because its
  "Read beyond end of file" carries no context.

## Build

RAD Studio 37.0 via `build.ps1`, output to `bin`. `ffmpeg.exe` and
`FFMPEG_LICENSE.txt` sit **beside** the executable and are deliberately
**not** embedded as `RCDATA` — see `third-party-licensing.md` for why that
is a licensing decision rather than a packaging preference.

## Testing — stated honestly

**There is no automated test suite on the Delphi side.** Verification is
manual: export frames with `--export-images` and compare them against the
Python implementation's output for the same input.

This is recorded as the observed state, not endorsed as sufficient. See
`testing.md`, which documents the gap plainly rather than describing a
DUnitX suite that does not exist.
