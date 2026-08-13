# src/

This folder holds two different things, and keeping them apart matters.

## Committed — the converter itself

| Path | What it is |
|---|---|
| `delphi/` | The Delphi implementation: `Alv.Core`, `Alv.FFmpeg`, `Alv.Export`, `Alv.Converter`, and the `AlvConverter.dpr` entry point. RTL + Windows API only, no third-party package |
| `python/` | The Python implementation: `alv_core.py` plus one thin entry point per action (`alv_inspect`, `alv_extract`, `alv2mp4`), the PyInstaller spec, and `build_exe.bat` |

These are the sources the published release binaries were built from. The
conventions they follow are not optional — see `.agents/rules/delphi-conventions.md`
and `.agents/rules/python-conventions.md`.

## Not committed — working area

| Path | Why it stays out of git |
|---|---|
| `bin/` | Build output and the release archive. The archive is already published as a release asset; committing it would carry the same 53 MB a second time, permanently, into every clone |
| `temp/` | Delphi `.dcu` output, PyInstaller's work directory, the local build venv |
| `*.alv` | A real recording is proprietary, large, and never belongs in this repo |

This is also the drop box for whichever recording is currently being worked
on, and the default output location for anything the AI generates. Resolving
*which* recording is the subject of a request is
`.agents/rules/input-resolution.md`'s job — an explicit path in the request
always wins over anything sitting here, and two recordings staged at once mean
a question, never a guess.

It is a staging area, not an archive. Do not accumulate recordings here, and do
not treat a leftover file from a previous session as the current input without
confirming.

## What this is not

- `examples/` — curated reference material demonstrating good practice,
  hand-maintained, not a scratch or output area
- `docs/` — documentation, not code

See `AGENTS.md`'s "Working Directory" and "Pipeline Structure" sections for the
full picture.
