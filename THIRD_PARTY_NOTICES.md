# Third-Party Notices

This project distributes software written by others. `.agents/rules/third-party-licensing.md`
requires that every vendored binary be recorded here with its provenance and a
checksum, because "we bundle FFmpeg" is not enough information for anyone
auditing what they are about to run: FFmpeg builds differ in exactly the way
that matters, and the hash is what makes the answer checkable rather than
merely stated.

## FFmpeg

| | |
|---|---|
| Project | [ffmpeg.org](https://ffmpeg.org/) |
| Version | 9.0.1 Essentials Build |
| Build source | [gyan.dev/ffmpeg/builds](https://www.gyan.dev/ffmpeg/builds/) |
| Licence | **GPLv3** — the build's configuration includes GPLv3 components and `libx264` |
| Licence text shipped | `FFMPEG_LICENSE.txt`, in the same folder as the executable |

**SHA-256 of the `ffmpeg.exe` actually shipped in the v0.1.0 release archive:**

```
72A489ECCD008C2EC2C0A5856C5C75BC3D8BBFA90166C4566865C246445E6AA3
```

The upstream download archive it was extracted from was recorded during the
original format analysis as beginning `49A73BDF`. **Only that prefix is on
record** — the full value was not preserved, and it is written here as a
prefix rather than reconstructed, per this project's own evidence discipline
(`.agents/rules/evidence-grading.md`).

FFmpeg is **not embedded** in either converter. It ships as its own
replaceable file beside them, which keeps its identity and licence visible and
lets it be swapped or updated without rebuilding anything. Both executables
locate it in their own folder at runtime.

### When this binary is updated

1. Replace the file.
2. Recompute the SHA-256 and update it above.
3. Re-check the build configuration — an upstream default can move a build
   between licence classes between releases.
4. Replace `FFMPEG_LICENSE.txt` if it changed.
5. Record the version change in `CHANGELOG.md`.

A stale hash is worse than no hash: it asserts an integrity check that no
longer holds.

## Release archive contents — v0.1.0

`AlvConverter-0.1.0.zip`, SHA-256
`72DB49AF5DD8378E985505EA88DEF22BF113573811611EE16A9EFDE929C58D88`:

| File | SHA-256 | Origin |
|---|---|---|
| `ffmpeg.exe` | `72A489EC…6AA3` | third party, GPLv3, see above |
| `FFMPEG_LICENSE.txt` | `8CEB4B9E…B903` | third party, ships with FFmpeg |
| `AlvConverter.exe` | `C9A2C43D…72CC` | this project, Delphi build |
| `AlvConverter-Python.exe` | `AAD88CC3…85D3` | this project, PyInstaller one-file |

Both converters require `ffmpeg.exe` to be present in the same folder for MP4
output. Neither needs it for PNG frame export.

## Python runtime dependencies

Bundled inside `AlvConverter-Python.exe` by PyInstaller:

| Component | Licence |
|---|---|
| CPython | Python Software Foundation License |
| [Pillow](https://python-pillow.org/) | MIT-CMU |
| PyInstaller bootloader | GPLv2+ **with the bootloader exception**, which is what permits distributing this executable under this project's own licence |

## Analysed but not distributed

The vendor executables read during the reconstruction of the ALV format are
**not** redistributed here and are not present in this repository. They were
read statically; they were never launched
(`.agents/rules/evidence-grading.md`). No Alpemix code, binary or recording is
included in this project.

## This project's own licence

Apache-2.0 — see `LICENSE`. Bundling GPL-licensed FFmpeg as a separate
executable invoked as a subprocess is a different arrangement from linking GPL
code into the program. That is recorded here as what is shipped and how; it is
deliberately not restated as settled legal advice, and the interpretation is
left to whoever is qualified to give it.
