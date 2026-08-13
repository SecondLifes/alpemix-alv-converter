# Testing

## The honest current state

| Side | Automated tests | How it is actually verified |
|---|---|---|
| Python | **Yes** — `unittest`, synthetic fixtures | `python -m unittest discover -s tests -v` |
| Delphi | **No** | Manual: export frames, compare against Python's output |

That asymmetry is real and is written down rather than papered over. This
kit does not describe a DUnitX suite for the Delphi side, because there
isn't one — see `evidence-grading.md`, whose rule against claiming
unverified things applies to this project's own tooling as much as to the
format it parses.

## Synthetic fixtures, never a sample recording

Tests build the recordings they need **in-process**: a full-frame zlib
record, a JPEG-delta record, a truncated file, a corrupt zlib stream.
Nothing in the suite requires an `.alv` file to exist.

This is the rule to preserve above all others here. A real recording is
proprietary, large, and cannot be committed — a suite that depends on one
runs on exactly one machine, then rots. Synthetic fixtures also let a test
construct the *exact* malformed input a defensive branch exists for, which
no real capture will conveniently contain.

## What the suite covers

- **Exact-EOF parsing** — a well-formed file consumes to the last byte
  (`defensive-parsing.md`'s integrity signal).
- **Reconstruction** — a decoded region lands in the right place on the
  canvas, right way up, with the correct stride.
- **Truncated reads** — a file cut mid-record raises `ALVParseError` with
  a locating message, not a bare `struct.error`.
- **Corrupt zlib** — a damaged stream is reported as such, not as a crash.

When a new decoder branch is added, it needs a fixture before it needs an
optimisation.

## Testing the refusals, not only the successes

`evidence-grading.md` requires ungraded paths to be **rejected**. That
refusal is behaviour and gets a test: a synthetic type-5 record must raise
`ALVUnsupportedError`, distinct from `ALVParseError`.

An untested refusal quietly degrades into a best-effort guess the first
time someone "fixes" the parser to be more permissive.

## Verifying the Delphi side today

Until a suite exists, the working method is cross-implementation
comparison — and it is a genuinely strong check, because the two decoders
share no code:

```powershell
bin\AlvConverter.exe input.alv --export-images frames_delphi --image-limit 10
python alv_extract.py input.alv frames_python --limit 10
```

Compare the PNGs. Both implementations decode the same bytes independently,
so a disagreement localises a real bug in one of them rather than a shared
misreading.

State plainly, in any report, that this is manual verification. Do not
present a passing manual comparison as "tests pass".

## Never claim untested

If you cannot run something in the current environment — no Delphi
compiler, no FFmpeg, no sample file — say exactly what went unverified and
why, and ask for it to be run rather than reporting it as working.
"Looks correct on read" is not a test result, and a binary format is the
last place to guess: the bottom-up scanline order and the 4-byte row
alignment in `alv-format.md` both produce output that decodes without a
single error and is visibly wrong.
