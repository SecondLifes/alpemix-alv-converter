# Libraries and Tools — Alpemix ALV Converter Spec-Kit

This project uses no application framework. What follows are the few
libraries and external tools it does depend on, and the rules each one
carries. Keeping this list short is a design goal, not an accident.

## Delphi RTL + Windows API

- **When to use:** the entire Delphi implementation
- **Style:** dotted unit namespaces (`Alv.Core`, `Alv.FFmpeg`, `Alv.Export`),
  `T`/`E`/`F` prefixes, plain `record` types for parsed data
- **Features used:** `TFileStream`, `TBytes`, GDI (`CreateHalftonePalette`),
  anonymous pipes, `{$POINTERMATH}` for scanline arithmetic
- **Installation:** none — ships with RAD Studio
- **Rules:** `.agents/rules/delphi-conventions.md`

**No third-party Delphi package, deliberately.** The dependency-free
property is the reason this build exists alongside the Python one; adding a
package to do something the RTL already does spends it for nothing.

## Pillow (Python)

- **When to use:** decoding codec-1 JPEG payloads, writing PNG frames
- **Critical rule:** a decoded JPEG's dimensions are validated against the
  enclosing region before use — a mismatch is a parse error, not something
  to scale around
- **Installation:** `pip install -r requirements.txt` (pinned `>=12.0,<13`)
- **Rules:** `.agents/rules/python-conventions.md`,
  `.agents/rules/defensive-parsing.md`

## zlib

- **When to use:** codec-0 payloads on both sides
- **Critical rules:** the declared `uncompressed_size` is a *claim* —
  validate it against the safety ceiling before allocating, and the expanded
  raw bitmap must be exactly `1 + align4(width * bpp) * height` bytes, not
  merely large enough
- **Rules:** `.agents/rules/alv-format.md`, `.agents/rules/defensive-parsing.md`

## FFmpeg (external process)

- **When to use:** MP4 output only. Image export must not require it
- **Access:** raw `rgb24` frames written to stdin over an anonymous pipe;
  nothing is staged on disk
- **Critical rules:** drain stderr while writing or a long conversion
  deadlocks; check the exit code, or a failed encode looks like a successful
  conversion producing an unplayable file
- **Licensing:** vendored with its build source, both SHA-256 values and its
  licence text — `.agents/rules/third-party-licensing.md`
- **Rules:** `.agents/rules/streaming-pipeline.md`

## PyInstaller

- **When to use:** producing the standalone Windows EXE from the Python side
- **Features:** one-file bundle carrying Python and Pillow, so the target
  machine needs neither installed. Output is
  `src/bin/AlvConverter-Python.exe`, built by `src/python/build_exe.bat`
- **FFmpeg is not embedded** — it sits beside the executable, the same
  layout the Delphi build uses
- **Installation:** `pip install -r requirements-dev.txt`
- **Rules:** `.agents/rules/third-party-licensing.md` — the licence text
  travels beside `ffmpeg.exe`, in the same folder as both executables

## Decision guide

```
Need to convert a recording to MP4?          -> FFmpeg pipe (alv2mp4 / Alv.FFmpeg)
Need frames as images?                       -> PNG export (alv_extract / Alv.Export)
                                                does NOT need FFmpeg
Need to validate a file without output?      -> alv_inspect
Deploying where nothing may be installed?    -> Python one-file EXE (needs ffmpeg.exe beside it)
Deploying where dependencies are unwelcome?  -> Delphi EXE + ffmpeg.exe beside it
Exploring an open format question?           -> Python side: it has the test suite
```

## Transversal golden rules

Regardless of which library or implementation is in play:

1. **Every unowned allocation gets `try..finally` on the immediately
   following line; every Python file and pipe gets a `with` block.** File
   streams, GDI palette handles, pipe handles, FFmpeg process handles. A
   leaked pipe handle is invisible in a one-shot run and fatal in a batch
   loop.
2. **Typed errors, never swallowed.** `EAlvError`; `ALVParseError` for
   malformed input versus `ALVUnsupportedError` for an ungraded path. The
   only broad catch belongs at the top-level boundary, where it prints a
   clean message and sets a non-zero exit code — a reporting point, not a
   suppression point.
3. **Never guess at an ungraded format path.** Reject it
   (`.agents/rules/evidence-grading.md`).

## General rules

- Clean Code applies regardless of the language
- This project's naming conventions always apply, each language its own
- Tests accompany behaviour changes on the Python side; the Delphi side is
  verified by cross-implementation frame comparison and that is stated as
  manual verification, never as "tests pass"
- **There is no layered architecture here** — this is a pipeline, and the
  only structural rule is that the sink never reaches back into the parser
  (`.kiro/steering/structure.md`)
