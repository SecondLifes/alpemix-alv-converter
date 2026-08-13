# Evidence Grading — the rule this whole kit is built on

This project reconstructs an undocumented format. Most of what it "knows"
was inferred, not read from a specification. **The discipline that makes
that trustworthy is refusing to state an inference as a fact**, and it is
the single most transferable convention here — everything in
`alv-format.md` carries a grade because of this rule.

## Three grades, always stated

| Grade | Means | What you may do with it |
|---|---|---|
| **Sample-verified** | A real recording exercised this path and the parse validated end to end. | Implement it. State it plainly. |
| **Static-analysis-derived** | Read out of the vendor's own binary; no supplied sample exercises it. | Implement it if useful, but label it in code comments and docs. Never let it read as verified. |
| **UNKNOWN** | Neither a sample nor a readable code path settles it. | Do not implement. Do not guess. Reject the input and say why. |

Where the project stands today:

- **Sample-verified:** block types 2, 3 and 4; codec 0 (zlib) and codec 1
  (JPEG); 8-bit indexed decoding through the GDI halftone palette.
- **Static-analysis-derived:** block type 1 (handled as a single
  full-canvas image, following the player's own path); the RGB565 and
  24-bit colour paths.
- **UNKNOWN:** the semantic difference between type 3 and type 4; the
  meaning of `box_shaped`; the layouts of types 5-8 and 255.

## Reject rather than guess

An input that hits an ungraded path **fails with a clear message**. It
does not get a best-effort interpretation.

This is not caution for its own sake. A converter that guesses at an
unknown block layout produces a file that *looks* like a successful
conversion — playable, plausible, wrong. The person who receives it has no
way to tell. A refusal costs one support conversation; a silently wrong
recording costs the trust in every recording the tool ever converted.

So: types 5-8 and 255 are rejected by name, not skipped, not
approximated. When a sample eventually establishes one of those layouts,
the fix is to implement it *and* move it to sample-verified in
`alv-format.md` — both, in the same change.

## Say what you did not test

Where a path is implemented from static analysis alone, say so in the
user-facing documentation too, not only in code comments. The README's
"Known limits" section exists for this and is not optional decoration:

> Type 1 support follows the player path but was not present in the
> sample. 8-bit decoding is sample-verified; RGB565 and 24-bit follow
> static player behaviour but lack supplied samples.

A reader deciding whether to trust this tool with their recording needs
that. Removing it to make the README look stronger makes the tool weaker.

## Do not attribute a cause you did not observe

The legacy vendor converter fails on the validated sample. Static
comparison shows the two binaries gate the header version differently,
and both use Delphi `ReadBuffer`, whose failure surfaces as the generic
"Read beyond end of file". That is as far as the evidence goes.

**Naming the exact failing instruction would require running and debugging
that binary, which was not done — so it is not claimed.** What *is*
claimed, and is provable: the sample is not truncated, because strict
parsing and decompression reach exact EOF.

The general form: when a plausible cause and a provable observation
diverge, publish the observation. "The file is complete and the legacy
tool rejects it" is useful and true. "The legacy tool has a bug at offset
X" is a guess wearing the clothes of a finding.

## Third-party binaries are untrusted input

The vendor executables analysed here were **inspected statically and never
launched**. Treat any binary you did not build the same way: read it,
hash it, do not execute it. If a question genuinely cannot be answered
without running it, that question stays open and gets recorded as open —
see the preceding section for what happens to it.

## Applying this to new work

Before adding a rule, an example, or a decoder branch to this kit, answer
in one line: *what evidence supports this, and at which grade?* If the
answer is "it seems reasonable", it does not go in — not as code, and
especially not as documentation.
