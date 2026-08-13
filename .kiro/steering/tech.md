# Technical Stack — Alpemix ALV Converter

## Languages and Runtimes

Two co-equal implementations of the same converter, each idiomatic in its
own language rather than a transliteration of the other.

- **Languages:** Object Pascal (Delphi) and Python 3.11+
- **Compiler/Runtime:** RAD Studio 37.0 (Win32 console) · CPython 3.11+
- **Build System:** `build.ps1` (Delphi) · `build_exe.bat` + PyInstaller (Python)
- **Native IDE:** RAD Studio for the Delphi side; any editor for Python
- **Platform:** **Windows, required.** Exact 8-bit decoding needs the
  Windows GDI halftone palette — this is a correctness constraint, not a
  convenience

## Libraries and external tools

| Component | Usage |
|---|---|
| Delphi RTL + Windows API | The entire Delphi implementation. **No third-party package**, deliberately — that dependency-free property is why this build is worth shipping |
| Pillow 12.x | Python only: decodes codec-1 JPEG payloads, writes PNG frames |
| zlib | Codec-0 payloads on both sides |
| FFmpeg | External process; receives raw `rgb24` frames over a pipe |
| PyInstaller 6.14+ | One-file packaging of the Python build (FFmpeg not embedded) |

## Databases

**None.** This project reads a binary file and writes video or image files.
There is no connection string, no schema, no persistence layer, and none
should be introduced — a converter that needs a database to convert a file
has acquired a dependency it cannot justify.

## Concurrency — critical rules

- **Rule of thumb: decoding is strictly sequential and must stay that way.**
  Each record is a delta painted onto the shared canvas and there are no
  keyframes; frame N cannot exist without every record before it, in order.
  Parallelising record decode is a correctness bug, not an optimisation.
- Encoding already runs concurrently by construction: frames are piped to a
  child FFmpeg process while the decode loop continues.
- **Drain FFmpeg's stderr while writing.** An undrained error pipe deadlocks
  when the OS buffer fills — the converter appears to hang partway through a
  long recording.
- Rules: `.agents/rules/streaming-pipeline.md`

## External dependencies — philosophy

**Standard library first, and on the Delphi side exclusively.** The Delphi
build's value is that it needs nothing beyond the RTL and WinAPI; adding a
package to solve something the RTL already does costs exactly that. Python
carries one runtime dependency (Pillow) and one packaging dependency
(PyInstaller), and should not grow more without a reason that survives
`.agents/rules/evidence-grading.md`'s standard of proof.

FFmpeg is an external *process*, not a linked library — see
`.agents/rules/third-party-licensing.md` for what shipping it obliges.

## Code standards

### File types

| Extension | Description |
|---|---|
| `.pas` | Delphi unit — one concern each (`Alv.Core`, `Alv.FFmpeg`, `Alv.Export`) |
| `.dpr` | Delphi project/entry point — thin: argument parsing only |
| `.py` | Python module — `alv_core.py` plus one `alv_<verb>.py` per action |
| `.ps1` | Build scripts |
| `.alv` | Input recordings (never committed) |

### Notable conventions

Frozen dataclasses for every parsed value on the Python side:

```python
@dataclass(frozen=True)
class ALVHeader:
    ...
```

A parsed header or record is a fact about the file; nothing downstream
should be able to edit it and have the edit look like something the file
said. The canvas is the one mutable thing in the pipeline, on purpose.

Delphi uses plain `record` types for the same data — no allocation, no
lifetime, no `try..finally` needed around them.

## Testing and quality

- **Test framework:** Python `unittest`. **The Delphi side has no automated
  suite** — that is the observed state, recorded rather than papered over
  (`.agents/rules/testing.md`).
- **Synthetic fixtures only.** Tests build the recordings they need
  in-process; nothing requires a real `.alv` file. A suite that depends on a
  proprietary recording runs on one machine and then rots.
- **Test the refusals, not only the successes.** An ungraded block type must
  raise `ALVUnsupportedError`, distinct from `ALVParseError`. An untested
  refusal quietly degrades into a guess the first time someone makes the
  parser "more permissive".
- **Delphi verification today** is cross-implementation frame comparison:
  export frames from both and diff them. The two decoders share no code, so
  a disagreement localises a real bug. Report it as manual verification —
  never as "tests pass".
- **Resource cleanup in teardown** applies here too: file handles, pipe
  handles and process handles all get released, in tests as in production.

There is no lint or format configuration in this project (no `pyproject.toml`,
`ruff`, `flake8` or `.editorconfig`). Conventions are enforced by review.
Adding a linter would be a reasonable improvement and belongs in its own
commit — do not describe a gate that does not exist.
