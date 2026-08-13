# project:review

`project:review`

Please review the current diffs (`git diff` and `git diff --cached`) against
this project's coding standards from `.claude/CLAUDE.md` and the appropriate
rules within `.claude/rules/` (generated from the canonical `.agents/rules/`).
Structure the review around this checklist: correctness, evidence discipline,
defensive parsing, resource management, naming, and tests. This kit bundles no
code-review skill; the checklist below is the review contract.

Confirm at minimum that:

- **Evidence grade is stated for every format claim.** New handling for a
  block type, codec, or colour depth says whether it is sample-verified,
  static-analysis-derived, or UNKNOWN — and an UNKNOWN path is *rejected*, not
  implemented on a guess (`evidence-grading.md`).
- **Every read is bounded before it happens**, and every raised error names the
  record index, byte offset, expected size and remaining bytes. No new call
  site reads a stream directly instead of going through `TAlvReader` /
  `SafeReader` (`defensive-parsing.md`).
- **Sizes read from the file are validated before allocation** — zlib expanded
  size against the ceiling, raw bitmap length against
  `1 + align4(width * bpp) * height` exactly, JPEG dimensions against the
  enclosing region, region bounds against the canvas.
- **Naming follows each language's own convention:** Delphi PascalCase with
  `T`/`E`/`F` prefixes and dotted unit namespaces; Python `snake_case` modules
  with `ALV`-prefixed classes and exceptions. Neither is forced onto the other.
- **Resource discipline holds:** every unowned `.Create` has `try..finally` on
  the immediately following line; every Python file and pipe is in a `with`.
  Check pipe and process handles specifically — a leak there is invisible in a
  single run and fatal in a batch loop.
- **Exceptions stay specific:** `EAlvError`; `ALVParseError` for malformed
  input versus `ALVUnsupportedError` for an ungraded path. No bare `Exception`
  raised or caught.
- **Nothing accumulates.** One canvas, frames piped to FFmpeg; no frame list,
  no temporary image sequence, no memory that scales with recording length
  (`streaming-pipeline.md`).
- **The pixel traps are respected:** bottom-up scanlines, 4-byte row alignment,
  and the 8-bit palette obtained from GDI at runtime. Each of these produces
  output that decodes without any error and is visibly wrong, so a read-through
  will not catch them — say so if you could not verify by running.
- **Tests accompany behaviour changes**, built on synthetic fixtures rather
  than a sample recording, and a new refusal path has a test proving it
  refuses (`testing.md`).
- **Vendored binary changes update `THIRD_PARTY_NOTICES.md`** — both SHA-256
  values and the build's licence class (`third-party-licensing.md`).
- **File additions, removals and renames are recorded in `CHANGELOG.md`** in
  the same commit, by path.
