# Product — Alpemix ALV Converter Spec-Kit

## Purpose

This spec-kit provides the rules, conventions and standards for working on
the **Alpemix ALV converter** — a tool that reads `.alv`, the proprietary
session-recording format written by the Alpemix remote-support product, and
converts it to MP4 or a PNG frame sequence.

The format is undocumented. Everything the kit teaches about it was
reconstructed by static analysis of the vendor's own player and legacy
converter binaries, then validated against a real recording parsed end to
end. Two co-equal implementations exist, **Delphi** and **Python**.

The kit ensures generated code follows:

- **Evidence discipline** — every format claim is labelled sample-verified,
  static-analysis-derived, or UNKNOWN, and an UNKNOWN path is rejected
  rather than guessed at
- **Defensive parsing** — every read bounded before it happens, every
  failure naming its record and byte offset, a parse that ends at exact EOF
- **Streaming** — one canvas, frames piped to FFmpeg, memory that never
  scales with recording length
- **Each language's own idiom** — Delphi PascalCase with `T`/`E`/`F`
  prefixes; Python `snake_case` with `ALV`-prefixed classes. Neither is
  forced onto the other

Note what is deliberately **absent**: there is no layered
Domain/Application/Infrastructure architecture here, and none should be
introduced. This is a pipeline — bytes in, frames out — and the only
dependency rule that matters is that the sink never reaches back into the
parser.

## Target Audience

- Delphi and Python developers working on the ALV converter with AI
  assistance
- Anyone maintaining a reader for a proprietary format that has no
  specification, where the cost of a wrong guess is a file that looks
  correct and is not
- Teams that need a converter's failure messages to be diagnosable by
  someone holding only the broken file

## References

- `AGENTS.md` in the project root contains the complete reference of all rules
- `.agents/rules/alv-format.md` is the format itself, with evidence grades
- `.agents/rules/evidence-grading.md` is the discipline the rest rests on
- Code examples in `examples/` demonstrate the applied patterns
