# Tasks: [Feature Name]

## Legend

- `[ ]` — Pending
- `[/]` — In progress
- `[x]` — Completed

## 1. Evidence

- [ ] State the grade of every format claim this feature rests on
  - [ ] sample-verified — name the recording that proved it
  - [ ] static-analysis-derived — name the binary and what was read
  - [ ] UNKNOWN — convert into an explicit rejection, not an implementation
- [ ] Update `.agents/rules/alv-format.md` if a grade actually moved, and
      `.agents/rules/evidence-grading.md`'s standing list along with it

## 2. Parse

- [ ] Add the read through the guarded surface only
      (`TAlvReader` / `SafeReader`) — no raw stream access
- [ ] Pass `Context`/`Field` so the failure message can locate itself
- [ ] Validate every size claim before allocating on it
- [ ] Confirm the parse still ends at exact EOF

## 3. Decode

- [ ] Codec dispatch stays a flat switch, not nested logic
- [ ] zlib: expanded length must equal `1 + align4(width * bpp) * height`
      exactly, not merely be large enough
- [ ] JPEG: decoded dimensions validated against the enclosing region
- [ ] Colour depth handled: 8-bit via the runtime GDI halftone palette,
      RGB565, 24-bit **BGR**

## 4. Canvas

- [ ] Region bounds validated against the canvas
- [ ] Bottom-up source scanlines converted to top-down at the one blit point
- [ ] 4-byte source row stride honoured
- [ ] Still one canvas, mutated in place — no frame list, no temp image
      sequence

## 5. Sink

- [ ] FFmpeg path: stderr drained while writing, exit code checked
- [ ] PNG export path: works with FFmpeg absent
- [ ] Never overwrite output without `--overwrite`
- [ ] Warn about scale before a full frame export

## 6. Both implementations

- [ ] Delphi: unit placement, `try..finally` on the next line, `EAlvError`
      with `CreateFmt`, XMLDoc on public methods
- [ ] Python: `alv_core` owns the format knowledge, frozen dataclasses,
      `Iterator[...]` not `list[...]`, docstrings on public API
- [ ] Domain vocabulary consistent across both (`header`, `record`,
      `region`, `codec`, `canvas`, `payload`)

## 7. Tests

- [ ] Python `unittest`, fixtures built **in-process** — no `.alv` file
      required to run the suite
- [ ] A success case
- [ ] A truncation case — locating `ALVParseError`, not a bare `struct.error`
- [ ] A corrupt-payload case
- [ ] **A refusal case** — an ungraded path raises `ALVUnsupportedError`,
      distinct from `ALVParseError`
- [ ] Run it: `python -m unittest discover -s tests -v`

## 8. Delphi verification

- [ ] Export frames from both implementations for the same input and
      compare:
      `bin\AlvConverter.exe in.alv --export-images out_d --image-limit 10`
      / `python alv_extract.py in.alv out_p --limit 10`
- [ ] Report it as **manual verification**, never as "tests pass"
- [ ] Say explicitly what could not be verified in this environment and why

## 9. Documentation and review

- [ ] README "Known limits" updated if a path is implemented from static
      analysis alone — both language versions, same turn
- [ ] `docs/proje-haritasi.md` updated if a file was added, removed or
      renamed
- [ ] `CHANGELOG.md` names every added/removed/renamed path, same commit
- [ ] `/review` against `.specify/constitution.md`
