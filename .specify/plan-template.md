# Technical Plan: [Feature Name]

## Overview

<!-- How the feature will be implemented technically -->

## Pipeline position

This project is a pipeline, **not a layered architecture** — see
`.specify/constitution.md` §5. Mark where the change lands:

```
parse  ->  decode  ->  canvas  ->  sink (FFmpeg pipe | PNG export)
  [ ]        [ ]        [ ]         [ ]
```

The one dependency rule: the sink never reaches back into the parser, and
the parser knows nothing about FFmpeg or PNG. If a change needs to violate
that, it is the wrong change.

## Components to create or modify

### Delphi

| Unit | Change | Description |
|---|---|---|
| `Alv.Core.pas` | new / modified | [parser, decoder, canvas] |
| `Alv.FFmpeg.pas` | new / modified | [pipe and process handling] |
| `Alv.Export.pas` | new / modified | [PNG frame export] |
| `Alv.Converter.pas` | new / modified | [orchestration] |

### Python

| Module | Change | Description |
|---|---|---|
| `alv_core.py` | new / modified | [format knowledge lives here and nowhere else] |
| `alv_inspect.py` / `alv_extract.py` / `alv2mp4.py` | new / modified | [thin entry point] |
| `tests/test_alv.py` | new / modified | [synthetic fixtures] |

**Format knowledge belongs in exactly one module per language.** If a
second file starts unpacking a struct, that logic moves into
`alv_core` / `Alv.Core`.

## Failure paths

Every new read gets a failure path designed before the happy path.

| Condition | Exception | Message carries |
|---|---|---|
| [truncated field] | `ALVParseError` / `EAlvError` | record index, offset, expected, remaining |
| [ungraded block/codec] | `ALVUnsupportedError` / `EAlvError` | which type, and that it is refused deliberately |
| [size claim over ceiling] | `ALVParseError` / `EAlvError` | claimed size, the ceiling, that the ceiling is ours |

## Safety ceilings touched

- [ ] None
- [ ] `MaxDecompressedBlock` / `MaxCanvasPixels` — document any change as
      **our** implementation limit, never as something the format requires

## Risks and Considerations

- [Risk and how to mitigate]
- Silent-corruption risks specifically: bottom-up scanlines, 4-byte row
  stride, BGR byte order, hardcoded palette — each decodes without error
  and is visibly wrong

## Compliance Checklist

- [ ] Every claim about the format carries an evidence grade
- [ ] Ungraded paths rejected by name, never approximated
- [ ] Every read bounded before it happens; every failure locates itself
- [ ] Nothing accumulates — memory flat in recording length
- [ ] Parse still ends at exact EOF
- [ ] Clean code (functions ≤ 60 lines, guard clauses, no globals)
- [ ] Naming: `T`/`E`/`F` + PascalCase (Delphi), `snake_case` + `ALV`
      prefix (Python)
- [ ] **XMLDoc (`///`)** on public Delphi methods, **docstrings** on public
      Python functions and classes
- [ ] `try..finally` on the next line after every unowned `.Create`;
      `with` on every Python file and pipe
- [ ] No third-party package added to the Delphi build
- [ ] Python tests cover the refusals, not only the successes
- [ ] Delphi side verified by cross-implementation frame comparison, and
      reported as **manual verification** — never as "tests pass"
- [ ] Files added/removed/renamed recorded in `CHANGELOG.md` by path, same
      commit
