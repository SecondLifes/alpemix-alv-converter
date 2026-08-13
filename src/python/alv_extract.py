#!/usr/bin/env python3
"""Incrementally reconstruct ALV frames and save PNG images."""

from __future__ import annotations

import argparse
import sys
import traceback
from pathlib import Path

from alv_core import ALVDecoder, ALVError, ALVParser


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="input .alv file")
    parser.add_argument("output_dir", type=Path, help="directory for PNG frames")
    parser.add_argument("--limit", type=int, default=None, help="decode at most N records")
    parser.add_argument(
        "--every", type=int, default=1, help="save every Nth reconstructed record"
    )
    parser.add_argument(
        "--no-first-ten",
        action="store_true",
        help="do not also save records 1-10 under first10/",
    )
    parser.add_argument("--debug", action="store_true", help="show a traceback on failure")
    return parser


def extract(
    input_path: Path,
    output_dir: Path,
    *,
    limit: int | None,
    every: int,
    first_ten: bool,
) -> tuple[int, int]:
    if every < 1:
        raise ALVError("--every must be at least 1")
    output_dir.mkdir(parents=True, exist_ok=True)
    first_dir = output_dir / "first10"
    if first_ten:
        first_dir.mkdir(parents=True, exist_ok=True)
    decoded = 0
    saved = 0
    with ALVParser(input_path) as parser:
        assert parser.header is not None
        decoder = ALVDecoder(parser.header)
        for record in parser.iter_records():
            frame = decoder.apply(record)
            decoded += 1
            filename = f"frame_{record.index:06d}.png"
            if record.index % every == 0:
                frame.save(output_dir / filename, format="PNG")
                saved += 1
            if first_ten and record.index <= 10:
                frame.save(first_dir / filename, format="PNG")
            if limit is not None and decoded >= limit:
                break
    return decoded, saved


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        decoded, saved = extract(
            args.input,
            args.output_dir,
            limit=args.limit,
            every=args.every,
            first_ten=not args.no_first_ten,
        )
        print(f"Decoded {decoded:,} record(s); saved {saved:,} selected PNG frame(s).")
        if not args.no_first_ten:
            print(f"First ten: {(args.output_dir / 'first10').resolve()}")
        return 0
    except (ALVError, OSError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        if args.debug:
            traceback.print_exc()
        return 2


if __name__ == "__main__":
    raise SystemExit(main())

