# Changelog

All notable changes to the Alpemix ALV Converter AI Spec-Kit are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) ·
Versioning: [SemVer](https://semver.org/) via annotated git tags.

This file is the arbiter when `settings.json`'s `versioning.current_version`
and the git tag list disagree — see `.agents/rules/kit-settings.md`. Keep it
current in the same commit as the change it describes, not afterwards.

**What counts as which bump** (from the shared `commit-versioning.md` rule):
PATCH for fixes and corrections, MINOR for an added rule/skill/capability,
MAJOR for a removed or renamed skill/rule or any other breaking change to
what a consumer of this kit can rely on.

## Mandatory: record every file that was added, removed or renamed

**Any commit that adds, deletes or renames a file under `.agents/rules/`,
`.agents/commands/`, `.agents/skills/`, `tools/`, or any root-level document
must name that file here, in the same commit.** Not "updated the rules" —
the actual path, and one clause saying what it is for.

This is not bookkeeping for its own sake. Three things in this kit read the
file inventory and go wrong silently when it drifts:

- `docs/proje-haritasi.md` claims what exists, and the count gate in
  `tools/verify-kit.ps1` compares those claims against disk.
- `tools/generate-ai-configs.ps1` generates one copy or link per source file;
  a file nobody recorded is a file nobody notices going stale.
- Anyone auditing this kit later reconstructs "what changed and why" from the
  CHANGELOG plus `git log`. A summary that says only "improvements" forces
  them to re-derive the inventory by hand, which is exactly how the counts
  drifted in the first place.

Use the section that matches, and write the path:

```markdown
### Added
- `.agents/rules/caching.md` — when to cache, and what must never be cached

### Removed
- `.agents/skills/legacy-orm/` — superseded by `.agents/skills/orm/`

### Changed
- Renamed `.agents/rules/db.md` to `.agents/rules/db-access.md`
```

A change that only edits the *contents* of an existing file does not need its
own inventory line — describe the behavior that changed instead. The rule is
about files appearing, disappearing or moving, because those are the changes
that break something else in the kit.

## [Unreleased]

<!--
Accumulate entries here as work lands. On release: rename this heading to
"## [X.Y.Z] - YYYY-MM-DD", write the same version into settings.json's
versioning.current_version, commit both together, then create the matching
annotated tag (git tag -a vX.Y.Z). Start a fresh empty [Unreleased] above it.

Use only the sections that actually apply — don't ship empty headings:
### Added / ### Changed / ### Fixed / ### Removed / ### Deprecated / ### Security
-->

## [0.1.0] - 2026-08-13

### Added

- Initial kit scaffold: `.agents/` as the single source of truth (rules,
  commands, skills), with `.claude/`, `.cursor/` and `.claude/skills/`
  generated from it by `tools/generate-ai-configs.ps1`
- **Nine topic rules** under `.agents/rules/`, every one drafted from
  evidence observed in a real Delphi + Python ALV converter, none invented:
  - `alv-format.md` — the container itself: header, record envelope, block
    types 1-4, codec 0 (zlib) and 1 (JPEG), Delphi `TDateTime`/`ShortString`
    decoding, bottom-up scanlines with 4-byte row alignment, and the 8-bit
    palette that must come from GDI at runtime
  - `evidence-grading.md` — sample-verified vs static-analysis-derived vs
    UNKNOWN, and the rule to reject an ungraded path rather than guess
  - `defensive-parsing.md` — bound every read, validate declared sizes
    before allocating, name the record and byte offset on failure, finish
    at exact EOF
  - `streaming-pipeline.md` — one canvas, frames piped to FFmpeg as
    `rgb24`, millisecond timing resampled with a cumulative accumulator
  - `delphi-conventions.md` — dotted units, `T`/`E`/`F` prefixes,
    `try..finally` discipline, RTL + WinAPI only
  - `python-conventions.md` — `snake_case` modules, `ALV`-prefixed classes,
    frozen dataclasses, a three-level exception tree
  - `testing.md` — synthetic fixtures needing no sample binary, and the
    honest record that the Delphi side has no automated suite
  - `third-party-licensing.md` — vendored binary provenance, both SHA-256
    values, licence text shipped beside the executable
  - `input-resolution.md` — explicit path > `src/` > ask
- **Four bundled workspace skills** under `.agents/skills/`:
  `rad-prompt-studio`, `rad-skill-finder`, `rad-web-scraping`, `python`.
  No stack-specific skill was added: a search of the 78-skill local library
  across seven query phrasings (binary, parser, ffmpeg/video/codec, reverse
  engineering, zlib, pyinstaller, image/bitmap) returned no relevant match,
  and nothing is installed without one.
- Four AI-primary identity files (`AGENTS.md`, `.claude/CLAUDE.md`,
  `.github/copilot-instructions.md`, `.gemini/rules/project-rules.md`),
  plus `GEMINI.md`, `.kiro/steering/` and the `.specify/` templates
- `docs/alpemix-alv-converter-analysis.md` — the five-lens self-audit run at
  build completion: mechanical gate results, and the six findings it turned up

### Changed

- `.specify/spec-template.md`, `.specify/plan-template.md` and
  `.specify/tasks-template.md` rewritten around this project's four-stage
  pipeline. They had specified a CRUD database application — Entity /
  Repository / Service layers, SQL migrations, list and edit views — which
  this kit has none of and whose layering `.specify/constitution.md` §5
  explicitly forbids
- `.github/copilot-instructions.md` and `.gemini/rules/project-rules.md` no
  longer instruct their tools to impose Domain/Application/Infrastructure
  layering; both now describe `parse -> decode -> canvas -> sink` and the
  single dependency rule
- `README.md` and `README.tr-TR.md` gained the "Known limits" section that
  `.agents/rules/evidence-grading.md` requires, stating the evidence grade of
  every implemented path plus the structural limits (Windows-only exact 8-bit
  output, no Delphi test suite, no keyframes, no observed audio/cursor track)
- `.gitignore` and `.cursorignore` now list this project's real build and IDE
  artifacts (`*.dcu`, `*.identcache`, `__history/`, `__pycache__/`) instead of
  scaffold placeholder comments, which had left Delphi build output untracked
  by the ignore rules entirely
- `.gitignore` also excludes `src/*` (keeping `src/README.md`) and
  `docs/images/*/`. `src/` is a working staging area, not repo content: a real
  `.alv` recording is proprietary and large, and the converter's own Delphi and
  Python sources belong to their own project rather than to this kit
