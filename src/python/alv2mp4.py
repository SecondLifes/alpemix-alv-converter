#!/usr/bin/env python3
"""Stream reconstructed ALV frames to FFmpeg and create an H.264 MP4."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import traceback
from pathlib import Path

from alv_core import ALVDecoder, ALVError, ALVParser, positive_delta_median


APP_VERSION = "1.0.0"


def resolve_ffmpeg(explicit: str | None = None) -> str:
    """Find an explicit, bundled, adjacent, project, or PATH FFmpeg binary."""
    if explicit:
        explicit_path = Path(explicit).expanduser()
        if explicit_path.is_file():
            return str(explicit_path.resolve())
        discovered = shutil.which(explicit)
        if discovered:
            return discovered
        raise ALVError(f"FFmpeg executable does not exist: {explicit}")

    candidates = [
        Path(__file__).resolve().with_name("ffmpeg.exe"),
        Path(sys.executable).resolve().with_name("ffmpeg.exe"),
        Path(__file__).resolve().parent / "vendor" / "ffmpeg.exe",
    ]
    for candidate in candidates:
        if candidate.is_file():
            return str(candidate)
    discovered = shutil.which("ffmpeg")
    if discovered:
        return discovered
    raise ALVError(
        "FFmpeg was not found in the application bundle, beside the executable, "
        "or on PATH; pass --ffmpeg C:\\path\\to\\ffmpeg.exe"
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="input .alv file")
    parser.add_argument(
        "output",
        nargs="?",
        type=Path,
        help="output .mp4 file (default: input path with .mp4 suffix)",
    )
    parser.add_argument(
        "--ffmpeg",
        help="override FFmpeg executable (default: bundled FFmpeg, then PATH)",
    )
    parser.add_argument(
        "--fps", type=float, help="CFR output rate (default: 1000 / median positive delta)"
    )
    parser.add_argument("--codec", default="libx264", help="FFmpeg encoder")
    parser.add_argument("--crf", type=int, default=18, help="encoder CRF")
    parser.add_argument("--preset", default="medium", help="encoder preset")
    parser.add_argument("--pix-fmt", default="yuv420p", help="output pixel format")
    parser.add_argument("--overwrite", action="store_true", help="replace an existing output")
    parser.add_argument("--debug", action="store_true", help="show a traceback on failure")
    parser.add_argument("--version", action="version", version=f"AlvConverter {APP_VERSION}")
    return parser


def derive_fps(path: Path) -> tuple[float, float]:
    deltas: list[int] = []
    with ALVParser(path) as parser:
        for record in parser.iter_records():
            deltas.append(record.timestamp_delta_ms)
    median_ms = positive_delta_median(deltas)
    return 1000.0 / median_ms, median_ms


def convert(
    input_path: Path,
    output_path: Path,
    *,
    ffmpeg: str | None,
    fps: float | None,
    codec: str,
    crf: int,
    preset: str,
    pixel_format: str,
    overwrite: bool,
) -> tuple[int, float, float]:
    if output_path.exists() and not overwrite:
        raise ALVError(f"output exists; pass --overwrite to replace it: {output_path}")
    executable = resolve_ffmpeg(ffmpeg)
    if fps is None:
        fps, median_ms = derive_fps(input_path)
    else:
        median_ms = 1000.0 / fps if fps > 0 else 0.0
    if fps <= 0 or fps > 1000:
        raise ALVError("--fps must be greater than 0 and at most 1000")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with ALVParser(input_path) as parser:
        assert parser.header is not None
        header = parser.header
        command = [
            executable,
            "-hide_banner",
            "-y" if overwrite else "-n",
            "-f",
            "rawvideo",
            "-pixel_format",
            "rgb24",
            "-video_size",
            f"{header.width}x{header.height}",
            "-framerate",
            f"{fps:.12g}",
            "-i",
            "pipe:0",
            "-an",
            "-c:v",
            codec,
            "-preset",
            preset,
            "-crf",
            str(crf),
        ]
        if header.width % 2 or header.height % 2:
            command.extend(["-vf", "pad=ceil(iw/2)*2:ceil(ih/2)*2"])
        command.extend(["-pix_fmt", pixel_format, "-movflags", "+faststart", str(output_path)])

        try:
            process = subprocess.Popen(command, stdin=subprocess.PIPE)
        except OSError as exc:
            raise ALVError(f"cannot start FFmpeg: {exc}") from None
        assert process.stdin is not None
        decoder = ALVDecoder(header)
        emitted = 0
        timeline_ms = 0
        last_frame_bytes: bytes | None = None
        record_count = 0
        try:
            for record in parser.iter_records():
                if last_frame_bytes is not None:
                    timeline_ms += record.timestamp_delta_ms
                    target = round(timeline_ms * fps / 1000.0)
                    while emitted < target:
                        process.stdin.write(last_frame_bytes)
                        emitted += 1
                frame = decoder.apply(record)
                last_frame_bytes = frame.tobytes()
                record_count += 1
                if record_count == 1 and record.timestamp_delta_ms:
                    # There is no preceding image for the startup delay; use the
                    # first complete canvas so the recorded duration is retained.
                    timeline_ms += record.timestamp_delta_ms
                    target = round(timeline_ms * fps / 1000.0)
                    while emitted < target:
                        process.stdin.write(last_frame_bytes)
                        emitted += 1
            if last_frame_bytes is None:
                raise ALVError("recording contains no frames")
            timeline_ms += round(median_ms)
            target = max(emitted + 1, round(timeline_ms * fps / 1000.0))
            while emitted < target:
                process.stdin.write(last_frame_bytes)
                emitted += 1
            process.stdin.close()
            return_code = process.wait()
        except BrokenPipeError:
            process.stdin.close()
            return_code = process.wait()
            raise ALVError(f"FFmpeg closed its input early (exit code {return_code})") from None
        except BaseException:
            try:
                process.stdin.close()
            except OSError:
                pass
            try:
                process.terminate()
                process.wait()
            except OSError:
                pass
            raise
        if return_code != 0:
            raise ALVError(f"FFmpeg failed with exit code {return_code}")
        return emitted, fps, timeline_ms / 1000.0


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    output = args.output or args.input.with_suffix(".mp4")
    try:
        executable = resolve_ffmpeg(args.ffmpeg)
        print(f"Input:   {args.input.resolve()}")
        print(f"Output:  {output.resolve()}")
        print(f"FFmpeg:  {executable}")
        frames, fps, duration = convert(
            args.input,
            output,
            ffmpeg=executable,
            fps=args.fps,
            codec=args.codec,
            crf=args.crf,
            preset=args.preset,
            pixel_format=args.pix_fmt,
            overwrite=args.overwrite,
        )
        print(
            f"Created {output.resolve()}: {frames:,} frame(s), "
            f"{fps:.6g} fps, {duration:.3f} s"
        )
        return 0
    except (ALVError, OSError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        if args.debug:
            traceback.print_exc()
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
