---
description: "How this repo's multi-tool AI config is organized and kept in sync — read this before editing any rule, command or skill."
alwaysApply: true
---

# AI Config Source of Truth & Sync Workflow

This repo supports five AI coding tools (Claude Code, Cursor, Codex CLI, GitHub
Copilot, Gemini/Antigravity CLI). To avoid maintaining near-duplicate copies by
hand, most content has a single canonical source under `.agents/`.

## Where content actually lives

| Content | Canonical source | Generated / native copies |
|---|---|---|
| Rules (per-topic, glob-scoped) | `.agents/rules/*.md` | `.claude/rules/*.md` and `.cursor/rules/*.mdc` — **hand-synced copies**, never edited in place. Note the extension: Cursor recognizes only `.mdc` under `.cursor/rules` and silently ignores `.md` there (cursor.com/docs/rules). |
| Slash commands | `.agents/commands/*.md` | `.claude/commands/*.md` — **hand-synced copy**, never edited in place |
| Skills | `.agents/skills/*/SKILL.md` | content is never copied, but Claude Code needs an entry point: a junction/symlink per skill at `.claude/skills/<skill-name>` → `.agents/skills/<skill-name>`, created by hand. Claude Code additionally gets a thin wrapper at `.claude/commands/<skill-name>.md` so the skill is also invocable as an explicit `/<skill-name>` command — see below. |
| Root universal summary | `AGENTS.md` | none — hand-authored, references `.agents/rules` for detail |
| Gemini/Antigravity summary | `.gemini/rules/project-rules.md` | none — hand-authored, same role as `AGENTS.md` but Gemini-specific. Reached through the root `GEMINI.md`, which imports it with `@./.gemini/rules/project-rules.md`: Gemini CLI builds context from the `GEMINI.md` hierarchy and does not read `.gemini/rules/` on its own (geminicli.com/docs/cli/gemini-md). |
| Gemini entry point | `GEMINI.md` (repo root) | none — hand-authored, deliberately thin: an import plus a pointer, so no content is duplicated |
| Copilot pre-prompt | `.github/copilot-instructions.md` | none — hand-authored, references `AGENTS.md` |
| Kiro steering docs | `.kiro/steering/*.md` | none — different concept (living project context, not per-topic rules), intentionally out of this sync scheme |

## Mandatory workflow — the copies are now synced by hand

> **This kit has no `tools/` folder.** It previously shipped
> `generate-ai-configs.ps1` (which produced every copy and link described
> below), `verify-kit.ps1` (a mechanical consistency gate) and `register.bat`.
> All three were removed deliberately. Everything they automated is still
> required — it is now your responsibility on every turn, and nothing will
> warn you if you skip it.

**Whenever you add, edit or delete a file under `.agents/rules/` or
`.agents/commands/`, propagate it in the same turn, before finishing:**

| Source you touched | Copies you must update by hand |
|---|---|
| `.agents/rules/<name>.md` | `.claude/rules/<name>.md` (same content) **and** `.cursor/rules/<name>.mdc` (same content, **`.mdc` extension**) |
| `.agents/commands/<name>.md` | `.claude/commands/<name>.md` |
| deleted a source file | delete every copy of it too |
| added a skill folder `.agents/skills/<name>/` | create the junction `.claude/skills/<name>` → `.agents/skills/<name>`, and a thin `/<name>` wrapper at `.claude/commands/<name>.md` |

On Windows a junction needs neither elevation nor Developer Mode:

```
mklink /J ".claude\skills\<name>" ".agents\skills\<name>"
```

A quick drift check before committing — it should print nothing:

```bash
for f in .agents/rules/*.md; do n=$(basename "$f" .md)
  diff -q "$f" ".claude/rules/$n.md"
  diff -q "$f" ".cursor/rules/$n.mdc"
done
```

The same check runs in CI (`.github/workflows/verify.yml`), which is now the
only thing standing between a forgotten copy and a rule that silently applies
to Claude but not to Cursor. **Editing a file under `.claude/rules/`,
`.cursor/rules/` or `.claude/commands/` instead of its `.agents/` source is
still wrong** — nothing overwrites it any more, so the two simply diverge and
the divergence is invisible until someone notices two tools behaving
differently. `.agents/` remains the single source of truth; that did not
change when the generator went away.

**Whenever you add, remove or rename a file under `.agents/rules/`,
`.agents/commands/` or `.agents/skills/`, also update
`docs/proje-haritasi.md` in the same turn** — add/remove/rename the
corresponding row and write a short Turkish description of what it does,
including the declared count at the top of that section.

**And record it in `CHANGELOG.md`, in the same commit.** Adding, deleting or
renaming a file under `.agents/rules/`, `.agents/commands/` or
`.agents/skills/` gets its own line naming the actual path — not a summary
like "updated the rules". Two things break quietly when that inventory drifts:
`docs/proje-haritasi.md` states counts that no longer match disk and nothing
checks them any more, and anyone auditing this kit later reconstructs what
happened from the CHANGELOG plus `git log`. Editing the *contents* of an
existing file needs no inventory line — describe the behavior that changed
instead. See `CHANGELOG.md`'s own header for the format.

**Why rules are copied, not symlinked:** this kit is distributed via
`git clone` into arbitrary projects. A symlink *committed to the repo*
requires Developer Mode/admin on Windows and `core.symlinks=true` in git to
survive a clone correctly; when that isn't the case the symlink degrades into
a plain text file containing the target path, and the tool silently finds zero
rules. Copies have no such failure mode.

**Why skills ARE linked, and why that's not a contradiction:** the paragraph
above is about links stored *in git*. The `.claude/skills/` entries are never
committed — `.gitignore` excludes them — so the degrades-on-clone failure
simply cannot occur. They are created after the clone, on the machine that
will use them, with `mklink /J` as shown above.

**The cost of losing the generator, stated plainly:** anyone who clones this
kit gets no `.claude/skills/` entries at all, and therefore no skills reachable
by Claude Code, until they create the junctions by hand. That used to be one
command. There is no longer a command; it is now a documented manual step, and
this paragraph exists so nobody discovers it by wondering why the skills never
trigger.

**Why the link is needed at all:** Claude Code discovers skills only from
`.claude/skills/` (plus `~/.claude/skills`, plugins and enterprise paths).
`.agents/skills/` is **not** one of its discovery locations — verified against
`code.claude.com/docs/en/skills`. Linking keeps `.agents/skills/` the single
editable source while making every skill actually reachable; Claude Code
resolves the links and loads a skill reachable from several paths only once.

> **Corrected claim.** Earlier versions of this file, `AGENTS.md` and
> `docs/ai-ignore-strategy.md` all asserted
> that `.agents/skills/` "is read as a fallback location natively by every
> supported tool as of 2026." That was never verified and is false for Claude
> Code. The consequence was not cosmetic: every skill in every kit built from
> this scaffold was invisible to trigger matching, reachable only if the user
> happened to type the `/<skill-name>` wrapper by hand.

The `/<skill-name>` command wrapper is still optional — it exists so a user who types the skill's name as a slash command
(instead of describing what they want) reaches it deterministically, from its
first step.
