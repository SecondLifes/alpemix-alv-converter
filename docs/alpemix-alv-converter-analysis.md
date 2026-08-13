# Five-Lens Self-Audit — Alpemix ALV Converter Spec-Kit

Build-completion audit (Step 11), run against the kit as it stands at
version `0.1.0`, before any git history exists. Five lenses applied
simultaneously: Prompt Engineer & Analyst, Repo Auditor, DevOps/Config
Engineer, Systems Forensics Analyst, Context Engineer.

The kit was produced in **Extraction Mode** from four read-only source
documents describing a real Delphi + Python ALV converter. No source file
was modified, copied, or inherited — including `.git`. Every rule here was
written fresh from patterns observed in those documents.

---

## Mechanical gates

`pwsh tools/verify-kit.ps1`, as it stood at the time of the audit:

| Gate | Result |
|---|---|
| Generator drift | OK — generated copies match `.agents/` |
| Cursor rule extension | OK — 13 rules, all `.mdc` |
| Claude skill discovery | OK — 4 skills reachable under `.claude/skills/` |
| SKILL.md frontmatter | OK — 4 files, spec-compliant |
| Unfilled placeholders | OK |
| README image links | OK — every embedded `docs/images/*` resolves |
| LICENSE | OK |
| Declared counts | OK — 13 rules / 4 skills match disk |
| Dead references | OK — every backticked repo-relative path resolves |

`pwsh tools/generate-ai-configs.ps1` additionally reported
`docs/proje-haritasi.md` coverage OK and folder/reference consistency OK.

**Both scripts have since been removed** along with the rest of `tools/`. This
section is left as the record of what passed when the kit was built; the checks
it describes are no longer runnable here. `.github/workflows/verify.yml` now
carries the drift and placeholder checks inline.

---

## Findings

### F1 — Copilot was instructed to build the architecture the constitution forbids · FIXED

`.github/copilot-instructions.md` still carried the blank scaffold's
"Design Patterns" section, telling Copilot to follow
Domain/Application/Infrastructure layering. `.specify/constitution.md` §5
states the opposite in as many words: *"There is no Domain/Application/
Infrastructure architecture here and none should be added."*

This was the most serious finding in the audit, and it is the failure mode
Extraction Mode is most prone to: nine hand-written rules were correct, and
a scaffold default sitting two files away quietly contradicted all of them.
A generic default is more dangerous than an obvious blank, because a blank
gets filled and a plausible default does not get read.

Replaced with the four-stage pipeline and the single dependency rule.

### F2 — Gemini's own pipeline section was titled "Layered Architecture" and rendered as a code block · FIXED

`.gemini/rules/project-rules.md` kept the scaffold's heading over correct
replacement prose, so the heading asserted exactly what the body denied. The
same edit had also left a stray fence, nesting a second ``` inside an
unclosed one — the whole section rendered as literal code rather than
guidance. Retitled and unfenced.

### F3 — The README section the rules call mandatory did not exist · FIXED

`.agents/rules/evidence-grading.md` says the README's "Known limits"
section *"exists for this and is not optional decoration"* — and neither
README had one. A kit whose central discipline is stating what you did not
verify, failing to state what it did not verify.

Added to both languages, in the same turn, with the evidence-grade table
(sample-verified / static-analysis-derived / UNKNOWN) plus the structural
limits: Windows-only exact 8-bit output, no Delphi test suite, no
keyframes, no observed audio/cursor/input track.

### F4 — Three README image embeds were dead at audit time · RESOLVED during the run

`docs/images/{overview,core-features,design-philosophy}.png` are embedded by
both READMEs and were absent when the gate first ran, inherited from
`blank-scaffold/` and reproducing across the portfolio. They were generated
from this kit's own `Prompts/image-prompts.md` (the "Cylinder Archive" visual
world) while the audit was in progress, and the gate now passes.

The portfolio-wide version of this problem — the same three embeds dead in
`blank-scaffold/` and the other kits — remains open and is tracked at the
workspace level, not here.

### F5 — `.specify/` templates specified a CRUD database application · FIXED

`spec-template.md`, `plan-template.md` and `tasks-template.md` were the
scaffold's originals: Entity/Repository/Service layers, SQL migrations,
list and edit views. This kit has no database, no UI and no entities, and
its constitution forbids the layering all three templates prescribed.

Rewritten around what this project actually does — an evidence table that
grades every claim before it can become a requirement, the four pipeline
stages, failure paths designed before happy paths, a both-implementations
scope table, and a checklist covering exact-EOF, the silent-corruption
traps (bottom-up scanlines, 4-byte stride, BGR order, hardcoded palette)
and the honest-reporting rule for the Delphi side.

### F6 — Two comparison-table rows described a stack this kit does not have · FIXED

Both READMEs' "Why use it?" tables carried scaffold rows about UI-layer
business logic and tests coupled to a real database. Replaced with the four
failures this kit actually prevents.

---

## Lens notes

**Prompt Engineer & Analyst.** The identity is stated once and reworded per
tool rather than copy-pasted, and its centre of gravity — *refuse rather
than guess* — survives every rewording. The four AI-primary files now agree
on the stack facts they each state (Delphi 37.0 / Python 3.11+, no DUnitX,
no layering). F1 and F2 were both cases of the identity being correct and a
neighbouring default disagreeing with it.

**Repo Auditor.** 13 rules, 4 bundled skills, counts match disk, no dead
references, no placeholders. `CHANGELOG.md`'s `[0.1.0]` entry carries the
real file inventory by path rather than a summary. `settings.json` declares
`0.1.0`, matching.

**DevOps/Config Engineer.** The generator round-trips cleanly; `.cursor/`
output is `.mdc` throughout; `.claude/skills/` is four junctions, correctly
gitignored. `.gitignore` and `.cursorignore` now list the real artifact
extensions for both languages (`*.dcu`, `*.identcache`, `__history/`,
`__pycache__/`) instead of the scaffold's placeholder comments — which had
meant a Delphi build's output was not actually ignored.

**Systems Forensics Analyst.** The rules never overstate what is known:
block types 5-8 and 255 are documented as rejected rather than described,
the type-3/type-4 distinction and `box_shaped` are recorded as UNKNOWN, and
`evidence-grading.md` explicitly declines to name a failing instruction in
the vendor's legacy converter because that would have required running a
binary that was only ever read. No credential, hostname or customer datum
from the source material appears anywhere in this kit.

**Context Engineer.** `AGENTS.md` is the one long file; per-topic detail
lives in 13 focused rules that reference each other rather than restating.
The heaviest cross-reference load falls on `evidence-grading.md` and
`defensive-parsing.md`, which is the right shape — they are the two rules
every other rule depends on.

---

## State at completion

- Not a git repository. Not registered with the `.rad` hub. Not published.
  All three are separate, explicitly-approved steps.
- All nine mechanical gates pass.
- The Delphi test gap is recorded as observed, in `testing.md`,
  `delphi-conventions.md`, the constitution and both READMEs. No DUnitX
  suite was invented to make the kit look complete.
