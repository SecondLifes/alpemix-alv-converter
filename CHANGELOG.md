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
`.agents/commands/`, `.agents/skills/`, or any root-level document must name
that file here, in the same commit.** Not "updated the rules" —
the actual path, and one clause saying what it is for.

This is not bookkeeping for its own sake. Three things in this kit read the
file inventory and go wrong silently when it drifts:

- `docs/proje-haritasi.md` claims what exists, and nothing checks those claims
  against disk any more — this kit has no `tools/` folder.
- Every source file under `.agents/` has hand-made copies under `.claude/` and
  `.cursor/`; a file nobody recorded is a file whose copies nobody notices
  going missing.
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

### Removed

- `tools/generate-ai-configs.ps1` — produced `.claude/rules/`, `.cursor/rules/`
  (`.mdc`), `.claude/commands/` and the `.claude/skills/` links from `.agents/`
- `tools/verify-kit.ps1` — the mechanical consistency gate
- `tools/register.bat` — registered this kit with the machine-wide `.rad` hub

The `tools/` folder no longer exists. What each script did still has to happen;
it is now manual, and documented where it is needed rather than assumed:

### Changed

- `.agents/rules/sync-workflow.md` rewritten around hand-syncing: which copy
  belongs to which source, the `mklink /J` command for skill links, a drift
  check to run before committing, and a plain statement of the cost — anyone
  cloning this kit has no `.claude/skills/` entries, and therefore no skills
  reachable by Claude Code, until they create the junctions themselves
- `.agents/rules/local-machine-registry.md` — registration now calls the hub's
  own `rad.ps1 -Action Register` directly instead of the removed wrapper
- `.github/workflows/verify.yml` no longer invokes the deleted script. It runs
  the checks inline instead: rule and command copies match their `.agents/`
  source, no orphaned copy whose source was deleted, `.cursor/rules` uses
  `.mdc`, no unfilled placeholders, `LICENSE` present. This workflow is now the
  only thing standing between a forgotten copy and a rule that applies to one
  tool but not another
- `.claude/settings.json`'s allow-list is empty — the command it pre-approved
  is gone
- `docs/proje-haritasi.md`'s `tools/` section now records what was removed and
  what replaced it, rather than describing three files that are not there
- `AGENTS.md`, `.claude/CLAUDE.md`, both READMEs and both CONTRIBUTING files
  updated: the `.claude/` and `.cursor/` folders are hand-synced copies, not
  generated output, and nothing overwrites a stray edit any more

**Not replaced, and worth knowing:** `verify-kit.ps1`'s `SKILL.md` frontmatter
validation and its README image-embed check have no successor. Nothing verifies
either now.

<!--
Accumulate entries here as work lands. On release: rename this heading to
"## [X.Y.Z] - YYYY-MM-DD", write the same version into settings.json's
versioning.current_version, commit both together, then create the matching
annotated tag (git tag -a vX.Y.Z). Start a fresh empty [Unreleased] above it.

Use only the sections that actually apply — don't ship empty headings:
### Added / ### Changed / ### Fixed / ### Removed / ### Deprecated / ### Security
-->

## [0.1.0] - 2026-08-13

### Fixed

- The Python build could never have worked: `src/python/AlvConverter.spec`
  line 7 read `project_dir /../ "bin"`, which is not valid Python (`..` is not
  a token). PyInstaller executes the spec as Python, so the build died with a
  `SyntaxError` before doing anything. A second, independent failure sat
  behind it — the build script copied `THIRD_PARTY_NOTICES.md` from the
  project directory, where no such file exists

### Added

- `src/python/build_exe.bat` — builds the Python one-file executable.
  Checks each precondition separately so a failure names which one
  (`ffmpeg.exe` and `FFMPEG_LICENSE.txt` present in `src/bin/`), passes
  `--distpath src/bin` and `--workpath src/temp`, and verifies the artifact
  exists before reporting success. When the interpreter it is given has no
  PyInstaller, it provisions a private virtual environment under
  `src/temp/buildvenv` and builds from there — the system Python is never
  modified, and running the script with no arguments just works
- `.gitattributes` — forces CRLF on `*.bat`, `*.cmd` and `*.ps1`. `cmd.exe`
  reads batch files by byte offset and loses its place on LF-only endings,
  executing fragments of lines (`'tlocal' is not recognized`). Observed on
  the first run of this very script, whose author wrote it with LF endings

### Removed

- `src/python/build_exe.ps1` — replaced by `build_exe.bat`

### Changed

- The Python build no longer embeds FFmpeg. It packs Python and Pillow only;
  `ffmpeg.exe` stays a separate replaceable file beside the executable, which
  is the layout the Delphi build already used. `resolve_ffmpeg()` finds it
  through `Path(sys.executable).with_name("ffmpeg.exe")`, the real executable
  path when frozen. Verified end to end: the built executable reports
  `FFmpeg: ...\srcinfmpeg.exe`
- The Python artifact is named `AlvConverter-Python.exe`. It lands in
  `src/bin/`, where the Delphi build's `AlvConverter.exe` already lives — the
  previous name would have silently overwritten it
- `.agents/rules/third-party-licensing.md`, `.agents/rules/python-conventions.md`,
  `.kiro/steering/frameworks.md`, `.kiro/steering/tech.md`, `AGENTS.md`,
  `.claude/CLAUDE.md`, both READMEs and both ACKNOWLEDGMENTS files updated to
  describe the one bundling strategy that now applies to both builds
- `.gitignore` and `.cursorignore` exclude `src/temp/` (Delphi `.dcu` output,
  PyInstaller's work directory, any local build venv); `.cursorignore` also
  excludes `src/bin/`, which holds a 100 MB `ffmpeg.exe`


### Added

- Initial kit scaffold: `.agents/` as the single source of truth (rules,
  commands, skills), with `.claude/`, `.cursor/` and `.claude/skills/`
  derived from it
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
- `THIRD_PARTY_NOTICES.md` — provenance and SHA-256 of every binary in the
  release archive, the FFmpeg build's licence class, and an explicit statement
  that no Alpemix code, binary or recording is distributed here

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
