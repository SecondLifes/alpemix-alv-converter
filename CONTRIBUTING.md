# Contributing to Alpemix ALV Converter

First off, thank you for considering contributing! It's people like you who make this kit better for everyone using it.

By participating in this project, you agree to abide by its [Code of Conduct](CODE_OF_CONDUCT.md).

## How Can I Contribute?

### Reporting Bugs

* Check the [issue tracker](https://github.com/SecondLifes/alpemix-alv-converter/issues) to see if the bug has already been reported.
* If not, open a new issue. Clearly describe the problem and include steps to reproduce it.

### Suggesting Enhancements

* Open an issue with the tag `enhancement`.
* Explain why this would be useful to most users of this kit.

### Pull Requests

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Implement your changes.
4. Follow the conventions in `AGENTS.md` and `.agents/rules/*.md` (consistent with the rest of the project).
5. Verify by actually running/applying your change — see `.agents/skills/*/references/verification-checklist.md` (or this stack's equivalent) rather than declaring it correct from reading alone.
6. Submit a Pull Request targeting the `main` branch.

## Technical Standards

This kit's own conventions are the technical standard for contributions —
not restated here to avoid drift between two copies of the same rules.
See `AGENTS.md`'s "Main Guidelines" section for Delphi and Python's
naming, error-handling, and architecture conventions.

To add new capability rather than fix an existing one:

1. **Rule** → `.agents/rules/your-topic.md`, then copy it by hand to `.claude/rules/your-topic.md` and `.cursor/rules/your-topic.mdc` (note the `.mdc`) — do **not** edit those two folders directly; nothing regenerates them, so an edit made only there silently diverges from the source.
2. **Skill** → `.agents/skills/your-skill/SKILL.md` (one copy, the only place it is ever edited). Afterwards create the link Claude Code needs — `mklink /J ".claude\skills\your-skill" ".agents\skills\your-skill"` — without which it never discovers the skill, plus a thin `/your-skill` wrapper at `.claude/commands/your-skill.md`.
3. **Reference** → mention it in `AGENTS.md` (and `.gemini/rules/project-rules.md` if it's framework/database-specific, matching the existing entries) and in `docs/proje-haritasi.md`.

### Testing

* Verify changes by actually applying/running them — see `AGENTS.md`'s "Tests" entry in Project Stack for this kit's own verification approach.

## Communication

* Use the [issue tracker](https://github.com/SecondLifes/alpemix-alv-converter/issues) for bugs, questions, and proposals.
* Respect all contributors and maintainers — see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
