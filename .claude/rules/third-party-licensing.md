# Third-Party Binaries and Licensing

This project ships someone else's compiled software. FFmpeg does the
encoding, and how it is bundled is a licensing decision before it is a
packaging one.

## Record provenance, not just presence

For every vendored binary, record:

- the upstream project and the **exact build** used
- where that build came from
- the **SHA-256 of the executable** actually shipped
- the SHA-256 of the archive it was extracted from
- what the build's configuration includes that affects licensing

The current entry, in `THIRD_PARTY_NOTICES.md`:

> FFmpeg 9.0.1 Essentials Build from Gyan.dev — project `ffmpeg.org`,
> build source `gyan.dev/ffmpeg/builds/`, executable SHA-256 `72A489EC…`,
> archive SHA-256 `49A73BDF…`, configuration includes **GPLv3 components
> and `libx264`**.

"We bundle FFmpeg" is not enough. FFmpeg builds differ in exactly the way
that matters: an LGPL build and a GPL build carry different obligations,
and `libx264` is the usual reason a build is GPL. Someone auditing this
tool needs to know which one is in the box, and the hash is what makes the
answer checkable rather than merely stated.

## Ship the licence text with the binary

`FFMPEG_LICENSE.txt` travels **beside the executable** and is embedded in
the one-file bundle. It is not a link, not a reference in a README.

## Two bundling strategies, both deliberate

| | Delphi build | Python build |
|---|---|---|
| Layout | `AlvConverter.exe` + `ffmpeg.exe` side by side | PyInstaller one-file, FFmpeg embedded |
| Requirement | both files stay in the same directory | none |

The Delphi build **deliberately does not embed FFmpeg as `RCDATA`.** Both
READMEs say so explicitly, because it looks like an oversight otherwise and
someone will helpfully "fix" it. Keeping the binary as a separate,
replaceable file keeps its identity and licence visible, and lets it be
swapped or updated without rebuilding the converter.

The Python build embeds it because a one-file EXE is the whole point of
that artifact — and it therefore also embeds the licence text.

Whichever strategy applies, the obligation is identical: **the licence
travels with the binary.** Neither is "the correct one"; they are two
answers to a distribution question, and both are documented as choices.

## The tool's own licence

This kit is Apache-2.0 (`LICENSE`). Bundling GPL-licensed FFmpeg as a
separate executable invoked as a subprocess is a different arrangement from
linking GPL code into the program. Do not restate that as settled legal
advice inside this repository — record what is shipped and how, keep
`THIRD_PARTY_NOTICES.md` accurate, and leave the interpretation to whoever
is qualified to give it.

## Analysed binaries are not shipped binaries

The vendor executables that were reverse-engineered to reconstruct the
format are **not** redistributed here, and must never be committed to this
repository. They were read; they were not launched (`evidence-grading.md`)
and they are not shipped. Their hashes appear in the format notes purely so
a future reader can confirm which build the analysis describes.

## When updating a vendored binary

1. Replace the file.
2. Recompute **both** SHA-256 values and update `THIRD_PARTY_NOTICES.md`.
3. Re-check the build configuration — an upstream default can change the
   licence class between releases.
4. Replace the shipped licence text if it changed.
5. Record the version change in `CHANGELOG.md`.

A stale hash is worse than no hash: it asserts an integrity check that no
longer holds.
