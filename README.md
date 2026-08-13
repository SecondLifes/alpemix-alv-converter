# 🚀 Alpemix ALV Converter AI Spec-Kit

<div align="center">

**An opinionated ecosystem of rules, *skills* and *steerings* to elevate Delphi and Python work on an undocumented binary format to state-of-the-art with Artificial Intelligence.**

[![🇹🇷 Türkçe ](https://img.shields.io/badge/Turkish-Türkiye-red)](README.tr-TR.md)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![GitHub Copilot](https://img.shields.io/badge/GitHub%20Copilot-Ready-blue?logo=github)](https://github.com/features/copilot)
[![Cursor](https://img.shields.io/badge/Cursor-Rules-purple)](https://cursor.sh)
[![Claude](https://img.shields.io/badge/Claude-Code-brown?logo=anthropic)](https://claude.ai)
[![Gemini](https://img.shields.io/badge/Gemini-Skills-orange?logo=google)](https://gemini.google.com)
[![Kiro](https://img.shields.io/badge/Kiro-Steering-teal)](https://kiro.dev)
[![Qwen](https://img.shields.io/badge/Qwen-AGENTS.md-purple)](https://chat.qwen.ai)
[![Kimi](https://img.shields.io/badge/Kimi-AGENTS.md-lightgrey)](https://kimi.moonshot.cn)

*[🇹🇷 Türkçe](README.tr-TR.md) · [Contributing](CONTRIBUTING.md) · [Code of Conduct](CODE_OF_CONDUCT.md) · [Security](SECURITY.md) · [Acknowledgments](ACKNOWLEDGMENTS.md)*

![Overview](docs/images/overview.png)

</div>

## 📋 Index

- [Turkish-](README.tr-TR.md)Türkçe
- [What is this project?](#-what-is-this-project)
- [Why use?](#-why-use)
- [Supported AI-Tools](#-supported-ai-tools)
- [Main Guidelines](#-main-guidelines-taught-to-ai)
- [Supported Frameworks](#️-supported-frameworks-and-libraries)
- [Kit Structure](#-kit-structure)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Code Examples](#-examples-of-good-practices)
- [Known Limits](#⚠️-known-limits)
- [Design & Philosophy](#-design--philosophy)
- [Acknowledgments](#-acknowledgments)
- [Contributions](#-contributions)

---

## 💡 What is this project?

The **Alpemix ALV Converter AI Spec-Kit** is not a code framework — it's a set of **behavior guidelines** for your favorite AI. It "teaches" the assistant to work on this converter so that it is:

- ✅ **Honest** — every format claim carries its evidence grade; an unproven path is rejected, never guessed at
- ✅ **Defensive** — every read bounded before it happens, every failure naming its record and byte offset, every handle released
- ✅ **Testable** — Python `unittest` on synthetic recordings built in-process; no proprietary sample file needed to run the suite
- ✅ **Streaming** — one canvas mutated in place, frames piped straight to FFmpeg; memory never scales with recording length

> Without this kit, an AI writing a reader for an undocumented format will confidently implement the block types it has never seen — and produce a converted video that opens, plays, and is wrong in a way nobody downstream can detect.

---

## 🤔 Why use it?

| Without Spec-Kit | With the Spec-Kit |
|---|---|
| AI implements a block type it has never seen | Ungraded paths are rejected by name, not approximated |
| Streams, handles and GDI palettes left to leak | Every unowned resource gets `try..finally` / `with` on the next line |
| Frames buffered until memory runs out | One canvas in place, frames piped straight to FFmpeg |
| Scanlines written top-down, row padding ignored | Bottom-up order and 4-byte stride applied at the one blit point |
| A `u32` length field trusted straight into an allocation | Declared sizes validated before anything is allocated |

---

## 🤖 Supported AI Tools

| Tool | Configuration File | How It Works |
|---|---|---|
| **GitHub Copilot** | `.github/copilot-instructions.md` | Pre-prompt injected into Workspace/Chat |
| **Cursor** | `.cursor/rules/*.mdc` (generated) | Rules loaded by context |
| **Claude Code** | `.claude/` (rules, commands and skill links all generated) | Rules by context; skills discovered through `.claude/skills/` |
| **Codex CLI** | `AGENTS.md` | Reads it directly, no dedicated folder needed |
| **Google Gemini / Antigravity** | `GEMINI.md` (root) → imports `.gemini/rules/project-rules.md` | Gemini CLI loads the `GEMINI.md` hierarchy; it does not read `.gemini/rules/` on its own |
| **Kiro AI** | `.kiro/steering/*.md` | Stack and architectural constraints |
| **Qwen / Kimi** | `AGENTS.md` (manual) | No native auto-discovery — point the tool at `AGENTS.md` explicitly; unlike the tools above, it is not read automatically |
| **Any AI** | `AGENTS.md` | Universal rules (project root) |
| **All of the above** | `.agents/skills/*/SKILL.md` | Shared skills — one editable copy, never duplicated per tool |

> Rules and commands have a single canonical source at `.agents/rules/` and
> `.agents/commands/`; `.claude/rules`, `.cursor/rules` (as `.mdc`),
> `.claude/commands` and the `.claude/skills/` links are all generated from it
> by hand from `.agents/` — see `.agents/rules/sync-workflow.md`.
> Run that script once after cloning: the skill links are machine-local and
> deliberately not committed, so without it Claude Code finds no skills.

---

## 🌟 Main Guidelines Taught to AI

![Core Features](docs/images/core-features.png)

### Evidence discipline

Every statement about the format says how strongly it is known —
**sample-verified**, **static-analysis-derived**, or **UNKNOWN** — and an
UNKNOWN path is refused rather than approximated:

```pascal
// Types 5-8 and 255 exist in the player, but no sample establishes their
// layout. Reject by name; do not approximate.
raise EAlvError.CreateFmt('record %d: block type %d is not supported',
  [Rec.Index, Rec.BlockType]);
```

### Defensive parsing

Bound the read, then read. Every failure locates itself:

```pascal
raise EAlvError.CreateFmt(
  '%s: truncated %s at +0x%x; expected %d, remaining %d',
  [Context, Field, Offset, Expected, Remaining]);
```

A correct parse consumes the file to **exact EOF** — with no footer,
checksum or index in the format, that is the only whole-file integrity
signal there is.

### Streaming, never accumulating

One canvas, mutated in place; frames piped to FFmpeg as `rgb24`. A
recording is tens of thousands of frames at desktop resolution, so memory
must not scale with its length — and nothing is ever staged as a temporary
image sequence.

### Two languages, each in its own idiom

```pascal
TAlvReader = class            // Delphi: T/E/F prefixes, dotted units
```
```python
@dataclass(frozen=True)       # Python: snake_case modules, ALV-prefixed classes
class ALVHeader: ...
```

Only the domain vocabulary is shared — `header`, `record`, `region`,
`codec`, `canvas`, `payload` — so a rule written against one implementation
reads correctly against the other.

---

## 🛠️ Supported Frameworks and Libraries

| Framework/Library | Domain | Rules Included |
|---|---|---|
| FFmpeg | MP4 encoding | Frames piped as `rgb24`; stderr drained while writing, exit code checked |
| Pillow 12.x | JPEG decode, PNG write (Python) | Decoded dimensions validated against the enclosing region |
| zlib | Codec-0 payloads | Expanded size checked against the ceiling *and* the exact expected bitmap length |
| Windows GDI | 8-bit halftone palette (Delphi) | Obtained at runtime — never a hardcoded table |
| PyInstaller | One-file Windows EXE | Bundles Python and Pillow; FFmpeg stays a separate file beside the executable, with its licence text |

---

## 📂 Kit Structure

```
[project-name]-spec-kit/
│
├── AGENTS.md                        # 🌐 Universal rules (Codex, Copilot, Kiro, Antigravity, Gemini)
│
├── .agents/                         # 📦 SINGLE SOURCE OF TRUTH — edit here, nowhere else
│   ├── rules/                       # Context-specific rules (one file per topic)
│   │   └── sync-workflow.md         # How this whole multi-tool setup is kept in sync — read first
│   ├── commands/
│   │   └── review.md                # Slash-command source: /review
│   └── skills/                      # On-demand skills (SKILL.md per folder) — the only editable copy;
│       │                             # Claude Code reaches them via generated .claude/skills/ links
│       ├── rad-skill-finder/        # Bundled — finds existing skills before writing one from scratch
│       ├── python/              # Bundled — for ad-hoc helper scripts the AI writes while working here
│       ├── rad-prompt-studio/       # Bundled — five-lens prompt design/analysis/edit
│       └── rad-web-scraping/        # Bundled — web scraping / structured data extraction (tool selection, discovery priority)
│                                     # (add stack-specific skills here as the stack is filled in — see Step 7/8)
│
├── GEMINI.md                        # 🌐 Gemini CLI entry point — imports .gemini/rules/project-rules.md
├── CHANGELOG.md                     # Version history; arbiter when settings.json and git tags disagree
│
├── .claude/
│   ├── CLAUDE.md                    # 🧠 Master system prompt for Claude
│   ├── settings.json                # Permission settings
│   ├── commands/                    # 📋 Hand-synced copy of .agents/commands — edit the source, not this
│   │   └── review.md
│   ├── rules/                       # 📋 Hand-synced copy of .agents/rules — edit the source, not this
│   └── skills/                      # 🔗 Links → .agents/skills — gitignored, created with mklink /J
│
├── .github/
│   ├── copilot-instructions.md      # 🤖 Pre-prompt for GitHub Copilot (hand-authored, references AGENTS.md)
│   └── workflows/
│       └── verify.yml               # CI: checks .agents/ copies for drift on push and PR
│
├── .cursor/
│   └── rules/                       # 📋 Hand-synced copy of .agents/rules as *.mdc — edit the source
│
├── .gemini/
│   └── rules/
│       └── project-rules.md         # Hand-authored summary, same role as AGENTS.md but Gemini-specific
│
├── .kiro/
│   └── steering/
│       ├── product.md               # Product vision
│       ├── tech.md                  # Technology stack
│       ├── structure.md             # Layer architecture
│       └── frameworks.md            # Framework guides
│
├── .specify/                        # AI-assisted spec templates
│   ├── constitution.md              # Project constitution and constraints
│   ├── plan-template.md             # Implementation plan template
│   ├── spec-template.md             # Feature specification template
│   └── tasks-template.md            # Task breakdown template
│
├── docs/
│   ├── proje-haritasi.md            # "What does every file do" map (human-facing)
│   └── ai-ignore-strategy.md        # AI context inclusion/exclusion strategy
│
├── examples/                        # Complete, compilable example code
│                                     # (empty — add real examples here as the stack is filled in)
│
└── src/                             # 🎯 Default working/output root — AI-generated
    └── README.md                    # deliverables go here unless told otherwise (see AGENTS.md)
```

---

## 🔧 Prerequisites

- **PowerShell 7+ (`pwsh`)** — used by the Delphi build script. The AI config copies need no tooling; they are kept in step by hand.
- **Node.js / `npx`** — required only for the bundled `rad-skill-finder` skill's
  primary search path (`npx skills find <topic>`). Not required to use the
  kit itself; without it, `rad-skill-finder` falls back to its web-based
  search steps — see `.agents/skills/rad-skill-finder/SKILL.md`.
- **Windows** — required, not incidental: exact 8-bit decoding depends on the Windows GDI halftone palette
- **RAD Studio / Delphi 37.0** to build the Delphi implementation (not needed to use the Python one)
- **Python 3.11+** with Pillow for the Python implementation
- **FFmpeg** for MP4 output — vendored beside the executable, or on `PATH`

---

## ⚡ Quick Start

### 1. Clone or download the kit

```bash
git clone https://github.com/SecondLifes/alpemix-alv-converter
```

### 2. Copy to the root of your project

```
YourProject/
├── src/                             # staging: drop the .alv here; generated output lands here
├── AGENTS.md          ← copy from the root
├── .agents/           ← copy the folder (single source of truth: rules, commands, skills)
├── .claude/           ← copy the folder (generated rules/commands already included)
├── .github/           ← copy the folder
├── .cursor/           ← copy the folder (generated rules already included)
├── .gemini/           ← copy the folder
├── .kiro/             ← copy the folder
└── .specify/          ← copy the folder (optional — spec templates)
```

If you later add or edit a file under `.agents/rules/` or `.agents/commands/`,
copy it into `.claude/rules/` and `.cursor/rules/` (as `.mdc`) by hand to refresh
`.claude/rules`, `.cursor/rules` and `.claude/commands`.

### 3. AI automatically takes over the rules

- **Claude Code** — Applies `.claude/CLAUDE.md`, reads `.claude/rules/*.md` (generated) and `.agents/skills/*/SKILL.md` directly
- **Cursor** — Reads `.cursor/rules/*.mdc` (generated) automatically by context
- **Codex CLI** — Reads `AGENTS.md` at the project root, plus `.agents/skills/*/SKILL.md`
- **GitHub Copilot** — Reads `.github/copilot-instructions.md` in workspace, plus `.agents/skills/*/SKILL.md`
- **Antigravity / Gemini** — Reads `.gemini/rules/project-rules.md`, plus `.agents/skills/*/SKILL.md`
- **Kiro** — Reads `.kiro/steering/*.md` as fixed product context

> **No additional configuration required.** Open the project, use your preferred AI and notice the difference.

---

## 💡 Examples of Good Practices

This kit ships no runnable example programs: the converter's own Delphi
and Python sources live in their own project, and a worked example here
would require a real `.alv` recording, which is proprietary and cannot be
committed. What `examples/` is for is small, self-contained fragments that
demonstrate a rule — a bounded-read helper, a synthetic-fixture builder —
added as they are written.

---

## ⚠️ Known Limits

`.agents/rules/evidence-grading.md` requires this section: a reader
deciding whether to trust this tool with their recording needs to know
which parts were proven and which were inferred. Removing it to make the
README look stronger makes the tool weaker.

| Area | Status |
|---|---|
| Block types 2, 3, 4 · codecs 0 (zlib) and 1 (JPEG) · 8-bit indexed decoding | **Sample-verified** — a real recording parsed end to end |
| Block type 1 · RGB565 and 24-bit BGR colour paths | **Static-analysis-derived** — implemented following the player's own path, but no supplied sample exercises them |
| Difference between block types 3 and 4 · meaning of `box_shaped` · layout of types 5-8 and 255 | **UNKNOWN** — rejected by name, never approximated |

Additional limits that are structural rather than evidentiary:

- **Windows is required** for exact 8-bit output — the palette is the
  Windows GDI halftone palette, obtained at runtime.
- **No automated tests on the Delphi side.** It is verified by comparing
  exported frames against the Python implementation, which is manual
  verification and is reported as such — never as "tests pass".
- **No keyframes exist in the format**, so records cannot be decoded in
  parallel or seeked into; a parse error partway through is fatal to
  everything after it.
- **No audio, cursor or input track was observed.** It may be absent or
  already rasterised into the frames. Both readings fit the evidence, so
  neither is asserted.

---

## 🎯 Design & Philosophy

![Design & Philosophy](docs/images/design-philosophy.png)

**Reconstruct, grade, and refuse to guess.**


This kit exists because of one asymmetry. A converter that refuses an
input costs its user a support conversation. A converter that *guesses* at
an undocumented structure costs them a file that opens, plays, and is
silently wrong — and neither they nor anyone downstream has any way to
notice. Those two failures are not comparable, so the rules here are
deliberately lopsided: bound every read, validate every declared size,
label every claim with the evidence behind it, and when the evidence runs
out, stop rather than interpolate. The format was reconstructed by reading
the vendor's own binaries statically and validating against a real
recording end to end; the parts that could not be established that way are
written down as unknown and rejected in code, not quietly filled in.

---

## 🚫 AI Ignore / Context Checklist

This project enforces a multi-layer strategy to control what AI agents index and use as context. Before submitting a PR:

- [ ] Build output folders of any new subproject are covered by `.gitignore`
- [ ] `.cursorignore` includes any new heavy or binary paths
- [ ] Essential instruction files (`AGENTS.md`, rules, skills, examples) are **NOT** excluded
- [ ] `.vscode/settings.json` excludes are up to date for new artifact types
- [ ] No secrets (`*.key`, `*.pfx`, `.env`) are committed or referenced

> See [docs/ai-ignore-strategy.md](docs/ai-ignore-strategy.md) for the full rationale and maintenance guide.

---

## 🙏 Acknowledgments

See [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md) for the open-source projects,
commercial tools, and references this kit was built on.

---

## 🤝 Contributions

Pull Requests are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for the
full guide (bug reports, PR process, technical standards) and
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community expectations.
Found a security issue instead? See [SECURITY.md](SECURITY.md) — don't
open a public issue for it.

Quick version — if your favorite framework or library needs a guide for AI, add:

1. **Rule** → `.agents/rules/your-framework.md`, then copy it to `.claude/rules/` and `.cursor/rules/` (as `.mdc`) to regenerate `.claude/rules/` and `.cursor/rules/` — do **not** hand-edit those two folders directly, your change will be overwritten on the next run.
2. **Skill** → `.agents/skills/your-framework/SKILL.md` (one copy, the only place it is ever edited — no content to regenerate, but run `pwsh tools/generate-ai-configs.ps1` afterward so Claude Code gets both its `.claude/skills/your-framework` link, without which it never discovers the skill, and the matching `/your-framework` command wrapper).
3. **Reference** → mention it in `AGENTS.md` (and `.gemini/rules/project-rules.md` if it's framework/database-specific, matching the existing entries).

### How to contribute

```bash
# Fork and clone
git fork https://github.com/SecondLifes/alpemix-alv-converter
git clone https://github.com/<your-account>/alpemix-alv-converter.git

# Create a descriptive branch
git checkout -b feat/add-something

# Commit and Pull Request
git commit -m "feat: add something"
git push origin feat/add-something
```

---

## 🗣️ AI Commands You Can Use

Open **this kit itself** as the working folder in any supported AI CLI (Claude Code, Codex, Gemini/Antigravity, Cursor) — the commands below run locally, driven by the bundled `rad-prompt-studio` skill and this kit's own `AGENTS.md`:

| You say | What happens |
|---|---|
| `Sistemi analiz et` / `Analyze the system` | Analyzes this kit's own system layer (`.agents/skills/`, `.agents/rules/`, `.agents/commands/`, `AGENTS.md`, `.claude/CLAUDE.md`) — `examples/`, `docs/`, `src/`, `tools/` stay out unless you ask. The report lands in this kit's own `analysis/result/{ai}_v{n}.md` — a local working artifact, gitignored by design; the permanent record of applied fixes is git history + issues + CHANGELOG. |
| `Değerlendir` / `Evaluate the findings` | Grades the existing reports in `analysis/result/` against current content (`STILL_VALID`/`STALE`/`REFUTED`...), presents a correction list, and waits for your approval. |
| `Düzelt: <hedef>` / `Fix <target>` | Approval-gated edit: analysis → evaluation of priors → your explicit approval → the edit. If the edited file is a bundled shared skill (`rad-*`) and this kit sits inside its parent AI-Spec-Kits-Maker workspace, the same fix is applied to the parent's master copy too — both sides stay current. |
| `<konu> için skill var mı?` / `Is there a skill for <topic>?` | The bundled `rad-skill-finder` searches local → `npx skills` ecosystem → directories → MCP/plugin registries → web with visible evidence (≥3 query phrasings); finds go through quarantine + a security scan, then a single install approval. |

---

<div align="center">

Made with ❤️ for everyone who has to read a format nobody documented.

*[🇹🇷 Türkçe](README.tr-TR.md) · [Contributing](CONTRIBUTING.md) · [Code of Conduct](CODE_OF_CONDUCT.md) · [Security](SECURITY.md) · [Acknowledgments](ACKNOWLEDGMENTS.md) · [License](LICENSE)*

*If this kit helped you, leave a ⭐ in the repository!*

</div>
