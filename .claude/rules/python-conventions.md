# Python Conventions

The Python implementation is the exploratory and testable half of this
project: fast to change while a format question is still open, and the only
side with an automated test suite. It targets **Python 3.11+** and depends
on **Pillow** alone at runtime.

## Module layout

```
alv_core.py      parser, decoder, canvas — everything reusable
alv_inspect.py   validate and report, no output files
alv_extract.py   PNG frame export
alv2mp4.py       FFmpeg pipe
tests/test_alv.py
```

`snake_case` module names. The three entry points are thin: argument
parsing plus a call into `alv_core`. Format knowledge lives in exactly one
module — if a second file starts unpacking a struct, that logic belongs in
`alv_core`.

## Identifiers

| Kind | Convention | Example |
|---|---|---|
| Classes | `ALV` prefix, then PascalCase | `ALVParser`, `ALVDecoder`, `ALVHeader`, `ALVRegion` |
| Exceptions | `ALV` prefix, `Error` suffix | `ALVError`, `ALVParseError`, `ALVUnsupportedError` |
| Functions | `snake_case` | `parse_header`, `validate_region`, `codec_name` |
| Internal helpers | leading underscore | `_decode_shortstring`, `_delphi_datetime` |

The `ALV` prefix is uppercase because it is an acronym; do not "fix" it to
`AlvParser`. It also makes `from alv_core import ALVParser` unambiguous at
a call site that already has half a dozen imports.

## Typing and value objects

`from __future__ import annotations` at the top of every module. Annotate
every public function's parameters and return type.

Value types are **frozen dataclasses**:

```python
@dataclass(frozen=True)
class ALVHeader:
    ...
```

`frozen=True` is deliberate. A parsed header or record is a fact about the
file; nothing downstream should be able to edit it and have the edit look
like something the file said. The canvas is the one mutable thing in the
pipeline, and it is mutable on purpose.

## Exceptions

Three levels, and the distinction is load-bearing:

```
ALVError                 # root — catch this to catch everything from the parser
├── ALVParseError        # the file is malformed
└── ALVUnsupportedError  # the file is well-formed but uses an ungraded path
```

`ALVUnsupportedError` is how `evidence-grading.md`'s "reject rather than
guess" reaches the user: a type-5 block is not corrupt, it is simply not
something this tool is willing to interpret. Collapsing the two into one
exception loses that, and the caller can no longer tell "your file is
broken" from "this tool won't guess".

Never raise a bare `Exception` or `ValueError` from parsing code, and
never `except Exception:` around a parse — see `defensive-parsing.md`.

## Reading bytes

All reads go through `SafeReader`, which bounds every read and carries the
field context into the error message. Use `struct` with explicit
little-endian format characters (`<I`, `<H`, `<B`, `<d`) — never native
byte order, which silently differs by platform.

## Streaming discipline

Generators and iterators over records, not lists. `Iterator[ALVRecord]`,
not `list[ALVRecord]`. Only the current canvas is retained; frames are
piped straight to FFmpeg (see `streaming-pipeline.md`). Memory must not
scale with recording length.

`@lru_cache` where a pure lookup is genuinely repeated — the palette
resolution is the real case — never as a general-purpose speed patch on a
function with side effects.

## Testing

`unittest`, not pytest. Tests build **synthetic recordings in-process**
(full-frame zlib and JPEG-delta paths) and cover exact-EOF parsing,
reconstruction, truncated reads and corrupt zlib data. No sample binary is
needed to run the suite:

```powershell
python -m unittest discover -s tests -v
```

Keeping the fixtures synthetic is what makes the suite runnable by anyone
who clones the repo, including someone with no `.alv` file at all. A test
that needs a proprietary recording is a test that will not run in CI and
will quietly rot. Details in `testing.md`.

## Packaging

PyInstaller one-file (`AlvConverter.spec`, `build_exe.bat`), bundling
Python and Pillow so the target machine needs neither installed. The
artifact is `src/bin/AlvConverter-Python.exe` — named apart from the Delphi
build's `AlvConverter.exe`, which lands in the same folder.

**FFmpeg is not embedded.** It sits beside the executable exactly as it does
on the Delphi side, and `resolve_ffmpeg()` finds it there via
`Path(sys.executable).with_name("ffmpeg.exe")` — the real executable path
when frozen, not the unpacked `_MEIPASS` directory. See
`third-party-licensing.md` for what that obliges you to ship.

## No lint configuration — say so

There is currently **no** `pyproject.toml`, `ruff`, `flake8` or
`.editorconfig` in this project. The conventions above are enforced by
review, not by a tool. That is the observed state; do not describe a
linting gate that does not exist. Adding one is a reasonable improvement
and would belong in a commit of its own.
