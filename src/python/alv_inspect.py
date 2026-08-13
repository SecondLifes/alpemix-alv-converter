#!/usr/bin/env python3
"""Inspect and fully validate an Alpemix ALV file without loading it at once."""

from __future__ import annotations

import argparse
import collections
import statistics
import sys
import traceback
from pathlib import Path

from alv_core import (
    ALVError,
    ALVParser,
    codec_name,
    record_regions,
    validate_region,
)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="input .alv file")
    parser.add_argument(
        "--summary-only", action="store_true", help="omit one-line record listings"
    )
    parser.add_argument(
        "--max-records",
        type=int,
        default=None,
        help="stop after this many records (disables full-EOF validation)",
    )
    parser.add_argument("--debug", action="store_true", help="show a traceback on failure")
    return parser


def inspect(path: Path, *, summary_only: bool, max_records: int | None) -> None:
    counts: collections.Counter[tuple[int, int]] = collections.Counter()
    type_counts: collections.Counter[int] = collections.Counter()
    box_counts: collections.Counter[tuple[int, bool]] = collections.Counter()
    deltas: list[int] = []
    embedded_count = 0
    last_end = 0
    with ALVParser(path) as parser:
        assert parser.header is not None and parser.reader is not None
        header = parser.header
        print(f"File: {path.resolve()}")
        print(f"Size: {path.stat().st_size:,} bytes")
        print(
            f"Header: prologue={header.prologue} version={header.version} "
            f"payload={header.header_payload_length} records_offset=0x{header.records_offset:X}"
        )
        print(
            f"Canvas: {header.width}x{header.height} "
            f"color_depth_code={header.color_depth_code} background={header.background_color}"
        )
        print(
            "Recorded at: "
            + (header.recorded_at.isoformat(sep=" ") if header.recorded_at else "invalid")
            + f" (TDateTime={header.recorded_at_tdatetime:.12f})"
        )
        for index, value in enumerate(header.strings, 1):
            print(f"String {index}: {value!r}")
        if header.trailing_header_bytes:
            print(f"Trailing header bytes: {header.trailing_header_bytes.hex()}")

        for record in parser.iter_records():
            type_counts[record.block_type] += 1
            counts[(record.block_type, record.codec)] += 1
            deltas.append(record.timestamp_delta_ms)
            if record.box_shaped is not None:
                box_counts[(record.block_type, record.box_shaped)] += 1
            regions = record_regions(record, header)
            embedded_count += len(regions) if record.block_type == 2 else 0
            for region in regions:
                validate_region(region, header)
            if not summary_only:
                if record.block_type in (3, 4):
                    geometry = (
                        f" xywh={record.x},{record.y},{record.width},{record.height}"
                        f" box={int(bool(record.box_shaped))}"
                    )
                elif record.block_type == 2:
                    geometry = f" embedded_regions={len(regions)}"
                else:
                    geometry = " full_frame=1"
                print(
                    f"#{record.index:06d} off=0x{record.offset:08X} "
                    f"dt={record.timestamp_delta_ms:4d}ms type={record.block_type} "
                    f"codec={record.codec}:{codec_name(record.codec)} "
                    f"payload={len(record.payload):7d}{geometry}"
                )
            last_end = record.end_offset
            if max_records is not None and record.index >= max_records:
                break

        complete = max_records is None or parser.reader.remaining() == 0
        print("\nSummary")
        print(f"Records: {sum(type_counts.values()):,}")
        print("Types: " + ", ".join(f"{key}={value:,}" for key, value in sorted(type_counts.items())))
        print(
            "Type/codec: "
            + ", ".join(
                f"{block_type}/{codec_name(codec)}={value:,}"
                for (block_type, codec), value in sorted(counts.items())
            )
        )
        if box_counts:
            print(
                "Box flags: "
                + ", ".join(
                    f"type{block_type}/box{int(flag)}={value:,}"
                    for (block_type, flag), value in sorted(box_counts.items())
                )
            )
        print(f"Embedded type-2 regions: {embedded_count:,}")
        print(f"Timestamp sum: {sum(deltas):,} ms ({sum(deltas) / 1000:.3f} s)")
        positive = [value for value in deltas if value > 0]
        if positive:
            print(
                f"Positive deltas: {len(positive):,}; min={min(positive)} ms; "
                f"median={statistics.median(positive):g} ms; max={max(positive)} ms"
            )
        if complete:
            print(
                f"EOF: exact at 0x{parser.reader.absolute_offset():X}; "
                f"remaining={parser.reader.remaining()} (no footer/index observed)"
            )
        else:
            print(
                f"Stopped at 0x{last_end:X}; {parser.reader.remaining():,} byte(s) not inspected"
            )


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        inspect(args.input, summary_only=args.summary_only, max_records=args.max_records)
        return 0
    except ALVError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        if args.debug:
            traceback.print_exc()
        return 2
    except OSError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        if args.debug:
            traceback.print_exc()
        return 2


if __name__ == "__main__":
    raise SystemExit(main())

