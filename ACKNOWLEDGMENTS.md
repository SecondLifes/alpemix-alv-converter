# 🙏 Acknowledgments

**Alpemix ALV Converter AI Spec-Kit** stands on the shoulders of the open-source
projects, commercial tools, and communities below. This page exists to
credit them explicitly — not just link to them once in a README aside.

> Note: GitHub doesn't have a dedicated "Acknowledgments" tab the way it
> does for Security (via `SECURITY.md`) — this file earns its visibility
> by being linked from the README's badge row and index instead.

## 📖 Open Source

| Project | What it's used for here | License |
|---|---|---|
| [FFmpeg](https://ffmpeg.org/) | Encodes the reconstructed frames to MP4. Vendored as a build from [gyan.dev](https://www.gyan.dev/ffmpeg/builds/); the provenance and hash discipline this kit teaches is written around it | GPLv3 (this build; see `THIRD_PARTY_NOTICES` discipline in `third-party-licensing.md`) |
| [Pillow](https://python-pillow.org/) | Decodes codec-1 JPEG payloads and writes PNG frames in the Python implementation | MIT-CMU |
| [zlib](https://zlib.net/) | Codec-0 payloads are zlib streams; the defensive size-validation rule exists around them | zlib |
| [PyInstaller](https://pyinstaller.org/) | One-file packaging of the Python build, bundling Python and Pillow | GPLv2+ with a bootloader exception |
| [x264](https://www.videolan.org/developers/x264.html) | Present in the vendored FFmpeg build, and the reason its licence class is GPLv3 — the exact case `third-party-licensing.md` is written about | GPLv2+ |

## 💼 Commercial

| Product/Vendor | What it's used for here | Notes |
|---|---|---|
| [Alpemix](https://www.alpemix.com/) | The remote-support product whose `.alv` session-recording format this kit is entirely about. The format is undocumented; every rule here describes it as reconstructed by static analysis and sample validation, not from a vendor specification | No affiliation or endorsement. The vendor binaries were read statically and never executed; none are redistributed here |
| [Embarcadero RAD Studio / Delphi](https://www.embarcadero.com/products/delphi) | The Delphi implementation targets RAD Studio 37.0; VCL bitmap behaviour (`pf8bit`, `CreateHalftonePalette`) is what makes the 8-bit palette rule necessary | Commercial licence required to build the Delphi side; the Python side needs none |

## 📚 References & Inspiration

Style guides, official documentation, and prior art consulted while
building this kit's rules and conventions (not dependencies — just
sources of guidance):

- No published specification exists for the ALV format. The format
  documentation these rules rest on was produced by static analysis of the
  vendor's own player and converter binaries, validated against a real
  recording parsed end to end. Those binaries were read, never executed —
  see `.agents/rules/evidence-grading.md`.

## 👥 Project Contributors

People who have contributed to this kit itself (its rules, skills, and
conventions — not the upstream projects credited above). Populated from
the workspace's own `template-vars.json` (`contributors` field) at
template-creation time; add new contributors here as they join.

- baspinar99@gmail.com
- emr.pov@gmail.com
- re.baspinar@gmail.com

---

*If this kit uses something not credited here, please open an issue —
omissions are oversights, not deliberate.*
