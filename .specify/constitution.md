# Constitution — Alpemix ALV Converter Spec-Kit

> Fundamental principles that govern all development in this project.

## Language and Platform

This project maintains **two co-equal implementations** of one converter:
**Object Pascal (Delphi, RAD Studio 37.0)** using only the RTL and the
Windows API, and **Python 3.11+** using Pillow. FFmpeg is invoked as an
external process. **Windows is required** — exact 8-bit decoding depends on
the Windows GDI halftone palette.

There is no database and no application framework.

## Non-Negotiable Principles

### 1. Evidence discipline outranks everything else

Every claim about the format is labelled **sample-verified**,
**static-analysis-derived**, or **UNKNOWN**, and says which.

- An UNKNOWN path is **rejected**, never guessed at. Block types 5-8 and
  255 fail by name.
- A cause you did not observe is not asserted. Publish the provable
  observation instead.
- Third-party binaries are read, never executed.

This is first because it is the principle that makes the rest worth having.
A converter that guesses produces a file that looks correct, plays, and is
wrong — and the person who receives it has no way to tell.

### 2. Defensive parsing

- Bound **every** read before it happens; no raw stream access outside
  `TAlvReader` / `SafeReader`.
- Every failure names the record index, byte offset, expected size and
  remaining bytes.
- Sizes read from the file are claims — validate before allocating.
- Safety ceilings are named constants documented as **ours**, not the
  format's.
- A correct parse ends at **exact EOF**; the format has no footer, checksum
  or index, so that is the only whole-file integrity signal.

### 3. Stream, never accumulate

One canvas, mutated in place. Frames piped to FFmpeg as `rgb24`. No frame
list, no temporary image sequence, no memory that scales with recording
length.

### 4. Clean code

- Functions ≤ **60** lines (ideal: under 25); the codec dispatch is a flat
  switch, not nested logic
- Self-describing names: **PascalCase** in Delphi, **`snake_case`** in
  Python — each language keeps its own idiom
- Guard clauses instead of nesting
- Named constants, no magic numbers
- **XMLDoc (`///`)** on public Delphi methods, **docstrings** on public
  Python functions and classes

### 5. Pipeline, not layers

```
parse -> decode -> canvas -> sink (FFmpeg pipe | PNG export)
```

**There is no Domain/Application/Infrastructure architecture here and none
should be added.** The one dependency rule: the sink never reaches back
into the parser, and the parser knows nothing about FFmpeg or PNG. A
decoded region is the boundary — which is what lets one core feed both
output paths, and why image export needs no encoder installed.

### 6. Naming

- Delphi: `T` types, `E` exceptions, `F` private fields, dotted unit
  namespaces (`Alv.Core`, `Alv.FFmpeg`, `Alv.Export`)
- Python: `ALV`-prefixed classes and exceptions, leading underscore for
  internal helpers, `alv_core.py` + one `alv_<verb>.py` per action
- Shared across both: the domain vocabulary — `header`, `record`, `region`,
  `codec`, `canvas`, `payload`

### 7. Absolute prohibitions

- ❌ Guessing at an ungraded block layout instead of rejecting it
- ❌ Reading from a stream without bounding the read first
- ❌ Bare `Exception` raised or caught in parsing code
- ❌ Buffering decoded frames instead of streaming them
- ❌ Top-down scanlines, or ignoring the 4-byte row alignment
- ❌ Hardcoding the 8-bit palette instead of obtaining it from GDI
- ❌ Parallelising record decode — there are no keyframes
- ❌ Global variables; `with` in Delphi
- ❌ Bypassing resource management (`try..finally` / `with`)
- ❌ Adding a third-party package to the Delphi build

## Development Process

1. **Specify** — requirements and acceptance criteria
2. **Plan** — design the units/modules before implementing
3. **Implement** — clean code following the principles above
4. **Test** — Python `unittest` with **synthetic** fixtures; test the
   refusals, not only the successes. The Delphi side has **no automated
   suite**; it is verified by cross-implementation frame comparison, and
   that is reported as manual verification, never as "tests pass"
5. **Review** — `/review` against this constitution
6. **Record** — every file added, removed or renamed goes into
   `CHANGELOG.md` by path, in the same commit
