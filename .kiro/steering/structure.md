# Structure and Conventions — Alpemix ALV Converter

## Pipeline, not layered architecture

This project has **no** Domain/Application/Infrastructure/Presentation
split, and should not acquire one. It is a pipeline: bytes in, frames out.
Imposing an application architecture on a converter adds indirection with
nothing to hold.

```
parse  ->  decode  ->  canvas  ->  sink
                                   ├── FFmpeg pipe (MP4)
                                   └── PNG frame export
```

| Stage | Does | Lives in |
|---|---|---|
| parse | header, record envelope, bounded reads | `Alv.Core` / `alv_core` |
| decode | codec 0 (zlib), codec 1 (JPEG) → region | `Alv.Core` / `alv_core` |
| canvas | blit region onto the single RGB24 canvas | `Alv.Core` / `alv_core` |
| sink | encode or write frames | `Alv.FFmpeg`, `Alv.Export` / `alv2mp4`, `alv_extract` |
| drive | argument parsing, orchestration | `AlvConverter.dpr` / `alv_inspect` |

## The one dependency rule

**The sink never reaches back into the parser, and the parser knows nothing
about FFmpeg or PNG.** A decoded region is the boundary between them.

That single rule is what lets one core feed both output paths — and it is
why image export can run without FFmpeg installed at all.

## File/Module Naming

```
Delphi:  Alv.<Concern>.pas        Alv.Core.pas, Alv.FFmpeg.pas, Alv.Export.pas
         AlvConverter.dpr         entry point, thin

Python:  alv_core.py              all format knowledge, one module
         alv_<verb>.py            one entry point per action
         tests/test_alv.py
```

| Stage | Delphi | Python |
|---|---|---|
| parse / decode / canvas | `Alv.Core.pas` | `alv_core.py` |
| video sink | `Alv.FFmpeg.pas` | `alv2mp4.py` |
| image sink | `Alv.Export.pas` | `alv_extract.py` |
| validation only | — | `alv_inspect.py` |
| orchestration | `Alv.Converter.pas`, `AlvConverter.dpr` | each entry point |

There is no component-based UI in this project — both implementations are
console tools — so no component-prefix convention applies.

## File/Module Sections

```
Delphi unit:   unit / interface / uses / const / type / implementation / uses / end.

Python module: __future__ import / stdlib imports / third-party imports /
               module constants / exceptions / dataclasses / functions / classes
```

## What `src/` means in this kit

`src/` here is a **staging and output area**, not a source tree: the
recording currently being worked on is dropped in, and generated
deliverables land there. The converter's own Delphi and Python sources live
in their own project. Which recording a request acts on is resolved by
`.agents/rules/input-resolution.md`.
