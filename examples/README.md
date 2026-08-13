# examples/

Curated, **complete and working** reference implementations for this
stack — not scratch space and not generated output.

## What belongs here

- Full, runnable examples that demonstrate a pattern end to end, in the
  form a practitioner would actually ship it.
- Code the AI can read to see *how a rule is really applied*, when the
  short snippet inside a `.agents/rules/*.md` file isn't enough.

## What does not belong here

- **AI-generated deliverables** — those go to `src/`, the working/output
  root (see `AGENTS.md`'s "Working Directory"). A live test once caught an
  AI writing generated scripts into `examples/` because the rule was
  stated in `AGENTS.md` only; every AI-primary file now says it.
- Half-finished sketches or snippets that don't run. An example that
  doesn't execute teaches the wrong thing — `rad-template-builder`'s
  Step 11 requires every example here to be actually run (happy path plus
  at least one error path), not just read.

## Why this file exists

Git does not track empty directories. Without a file here, `examples/`
silently disappears from any fresh clone — while `AGENTS.md`,
`.github/copilot-instructions.md` and `docs/ai-ignore-strategy.md` all
still list `examples/**/*` as always-load context, leaving a dead
reference in every kit built from that clone. This is the same guarantee
`src/README.md` and `docs/images/README.md` provide for their own folders.

Replace or extend this file freely once real examples land — just don't
delete it while the folder is otherwise empty.
