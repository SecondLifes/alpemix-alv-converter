# Defensive Parsing

Every byte read by this project comes from a file whose format is
reconstructed, whose producer is a third-party product, and which may be
truncated, corrupt, or simply a version nobody has seen. **The parser
assumes nothing and validates before it reads.**

## Bound every read

No read happens without first checking that the bytes are there. Both
implementations funnel reads through one guarded surface — Delphi's
`TAlvReader.ReadByte/ReadWord/ReadCardinal/ReadBytes`, Python's
`SafeReader` — and neither exposes a raw stream read to calling code.

The point is not that unbounded reads crash. It is that they crash
*uselessly*: Delphi's `ReadBuffer` raises "Read beyond end of file", which
names neither the record nor the offset nor what was expected. That
message is exactly why the vendor's own legacy converter is impossible to
diagnose — see `evidence-grading.md`.

## Every failure names its location

A parse error carries, at minimum: **which record, which byte offset,
what was expected, what remained.**

```pascal
raise EAlvError.CreateFmt(
  '%s: truncated %s at +0x%x; expected %d, remaining %d',
  [Context, Field, Offset, Expected, Remaining]);
```

Every read helper takes a `Context`/`Field` string for this reason — the
caller says what it was reading, so the error can too. That parameter is
not optional decoration; a helper called without it produces an error
nobody can act on.

Aim for the person holding a broken 23 MB file with no format
documentation. "Truncated" is useless to them. "Record 38,214, field
`payload_size` at +0x15A2C10, expected 4 bytes, 2 remaining" tells them
whether the file was cut short, and where.

## Validate derived sizes before allocating

Sizes read from the file are **claims**, not facts. Validate each before
acting on it:

- zlib `uncompressed_size` against the declared safety ceiling
- expanded raw-bitmap length against `1 + align4(width * bpp) * height` —
  it must match **exactly**, not merely be large enough
- JPEG decoded dimensions against the enclosing region's
- every region's `x, y, width, height` against the canvas bounds

A `u32` length field can claim 4 GB. Allocating on that claim turns a
corrupt file into an out-of-memory kill, which reads as a tool bug rather
than a bad input.

## Safety ceilings are named constants, and they are ours

```pascal
MaxDecompressedBlock = 512 * 1024 * 1024;   // 512 MiB
MaxCanvasPixels      = 100000000;           // 100M pixels
```

**These are implementation limits, not fields in the format**, and they
must be documented as such wherever they appear. Writing them as bare
magic numbers invites the next reader to mistake them for something the
specification requires — and then to "fix" a legitimate large recording by
raising a number they think came from the vendor.

## Exact EOF is the integrity signal

A correct parse ends **precisely** at the last byte. Not "near" the end,
not "with some trailing bytes we ignored".

The format has no footer, no checksum and no index, so this is the only
whole-file integrity check available. Leftover bytes mean the record
stream desynchronised somewhere upstream and every record after that point
is suspect. Treat trailing data as an error, and report the offset where
parsing stopped alongside the file size — that pair localises the
desync immediately.

## One exception hierarchy, and it is specific

Delphi: `EAlvError` — one root, raised in every failure path in the core.
Python: `ALVError` → `ALVParseError` (malformed input) and
`ALVUnsupportedError` (well-formed but ungraded — see
`evidence-grading.md`).

Never raise a bare `Exception`/`ValueError`, and never catch broadly
enough to swallow one of these. The distinction between "this file is
broken" and "this file uses a path we deliberately refuse" is the most
useful thing the caller learns, and a generic catch destroys it.

## Streaming, not slurping

Retain only the current canvas. Do not accumulate decoded frames, and do
not stage them as a temporary image sequence on disk — see
`streaming-pipeline.md`. A recording is tens of thousands of frames;
memory use must not scale with recording length.
