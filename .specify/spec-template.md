# Specification: [Feature Name]

## Context

<!-- What problem does this solve? If it concerns the ALV format itself,
say which recording exposed it and what was observed. -->

## Evidence

Before anything else, state what is actually known — no requirement built
on an ungraded assumption survives review (`.agents/rules/evidence-grading.md`).

| Claim | Grade | Backing |
|---|---|---|
| [e.g. block type 3 carries `box_shaped`] | sample-verified / static-analysis-derived / UNKNOWN | [sample file, binary offset, or "nothing"] |

**UNKNOWN rows are not requirements.** They are either dropped from this
spec or turned into an explicit rejection path.

## Functional Requirements

### Acceptance Criteria (EARS)

<!-- WHEN [condition] THE SYSTEM SHALL [behavior] -->

1. **WHEN** [event/condition] **THE SYSTEM SHALL** [expected behavior].
2. **WHEN** [malformed input case] **THE SYSTEM SHALL** raise
   `ALVParseError` / `EAlvError` naming the record index and byte offset.
3. **WHEN** [ungraded path is encountered] **THE SYSTEM SHALL** raise
   `ALVUnsupportedError` and refuse, rather than approximating.

## Both implementations

State explicitly what each side does. They are co-equal; a feature landing
in only one is a deliberate decision, not an oversight.

| | Delphi | Python |
|---|---|---|
| In scope | [yes/no + why] | [yes/no + why] |
| Verified how | [manual frame comparison] | [`unittest` fixture] |

## Format surface touched

- Records/blocks: [types]
- Codecs: [0 zlib / 1 JPEG]
- Colour depths: [8-bit indexed / RGB565 / 24-bit BGR]
- Does this change what a correct parse consumes? (exact-EOF invariant)

## Non-Functional Requirements

- **Memory:** must not scale with recording length
  (`.agents/rules/streaming-pipeline.md`)
- **Platform:** Windows required if the GDI halftone palette is involved
- **External tools:** does this path need FFmpeg? Image export must not.

## Data Model

```
[Struct/dataclass definition — frozen on the Python side, plain record on
the Delphi side. Field names use the shared domain vocabulary: header,
record, region, codec, canvas, payload.]
```

## CLI surface

- New flags: [names, defaults]
- Overwrite behaviour: never without `--overwrite`
- `--help` must work with no input file

## Out of Scope

- [What will NOT be done in this spec]
