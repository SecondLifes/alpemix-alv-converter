# AI Ignore Strategy — Alpemix ALV Converter Spec Kit

> Defines which files and folders should be **excluded** from AI context/indexing, and which must be **preserved**.

## Layered Approach

The strategy is applied in three complementary layers:

| Layer | File | Scope |
|-------|------|-------|
| **Universal** | `.gitignore` | All tools; prevents tracking of binaries, build artifacts and sensitive files |
| **IDE / Workspace** | `.vscode/settings.json` | `files.exclude` and `search.exclude` reduce noise in VS Code navigation and search |
| **Cursor-specific** | `.cursorignore` | Prevents Cursor AI from indexing heavy/irrelevant paths |
| **Instruction-based** | `AGENTS.md`, `.github/copilot-instructions.md` | Tells AI agents explicitly what context to use and what to skip |

## What to Exclude (all layers)

### Build Artifacts
- `*.dcu`, `*.exe`, `*.obj`, `*.pyc`, `__pycache__/`

### IDE / Tool Temporary Files
- `*.local`, `*.identcache`, `*.stat`, `*.~*`, `*.tvsconfig`, `__history/`, `__recovery/`
- `.serena/` — working directory of the Serena MCP coding-agent toolkit (project memory/config it manages itself); exclude from AI context and IDE indexing/search regardless of stack

### Build / Output Directories
- `Win32/`, `Win64/`, `x64/`, `x86/`, `Debug/`, `Release/`, `build/`, `dist/`, `output/`

### Dependencies and Package Caches
- `node_modules/`, `.venv/`, `.pytest_cache/`, `.mypy_cache/`, `modules/`

### Sensitive / Credential Files
- `*.key`, `*.pfx`, `*.p12`, `.env`, `.env.*`

### Large / Noisy Files
- `*.log`, `*.dmp`, `*.bak`, `*.tmp`

## What to Preserve (NEVER exclude)

These files are essential for AI context and must always remain indexed and accessible:

| File / Path | Reason |
|-------------|--------|
| `AGENTS.md` | Universal rules for all AI agents (Codex CLI, Antigravity, Copilot, Cursor, Kiro) |
| `README.md` | Project overview and quick start |
| `src/**/*` | This project's actual generated deliverables (the default output location) |
| `examples/**/*` | Good practice examples |
| `docs/**/*.md` | Documentation |
| `.agents/rules/**/*.md` | **Single source of truth** for per-topic rules — generates `.claude/rules` and `.cursor/rules` |
| `.agents/commands/**/*.md` | Single source of truth for slash-commands — generates `.claude/commands` |
| `.agents/skills/**/SKILL.md` | Single source of truth for skills — content is never copied; Claude Code reaches it through generated links under `.claude/skills/` |
| `.github/copilot-instructions.md` | Copilot pre-prompt |
| `.claude/CLAUDE.md`, `.claude/rules/**/*.md` (generated), `.claude/commands/**/*.md` (generated) | Claude Code master prompt + generated rule/command copies |
| `.cursor/rules/**/*.mdc` (generated) | Cursor rules — `.mdc` is mandatory; Cursor ignores `.md` in this folder |
| `GEMINI.md` | Gemini CLI's entry point at the repo root — imports `.gemini/rules/project-rules.md` |
| `.gemini/rules/project-rules.md` | Gemini/Antigravity summary (hand-authored, same role as `AGENTS.md`) |
| `.kiro/steering/**/*.md` | Kiro steering docs |

> **Note:** `.claude/rules`, `.cursor/rules`, `.claude/commands` and the `.claude/skills` links are all **generated** from `.agents/` by `tools/generate-ai-configs.ps1` — never hand-edit them directly, and never exclude `.agents/` itself from indexing. `.claude/skills/` is additionally gitignored: it holds machine-local junctions/symlinks, not content, and committing it would duplicate every skill. See `.agents/rules/sync-workflow.md` for the full architecture. A given AI session should only load the rule set matching the tool it runs as — see `AGENTS.md`'s "AI Context Policy" for the per-tool table.

## Tool-Specific Support Matrix

| AI Tool | Dedicated Ignore File | Behavior |
|---------|----------------------|----------|
| **Cursor** | `.cursorignore` | Explicit ignore for indexing and context |
| **Claude Code** | N/A | Uses rules/instructions; respects `.gitignore` and workspace excludes |
| **GitHub Copilot** | N/A | Follows `files.exclude`, `search.exclude`, `.gitignore` and instruction files |
| **Gemini / Antigravity** | N/A | Follows workspace structure and `.gitignore` |
| **Kiro** | N/A | Follows workspace structure and `.gitignore` |

## Maintenance Checklist

When adding new modules or subprojects:

- [ ] Verify build output folders are covered by `.gitignore`
- [ ] Verify `.cursorignore` includes any new heavy/binary paths
- [ ] Verify essential instruction files are NOT excluded
- [ ] Verify `.vscode/settings.json` excludes are up to date
