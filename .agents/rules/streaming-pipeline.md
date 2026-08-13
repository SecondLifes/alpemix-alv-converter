# Streaming Pipeline — canvas, timing, FFmpeg

A recording is tens of thousands of frames at desktop resolution. The
validated sample is 40,995 records at 1366×768; held as decoded RGB that
would be well over 100 GB. **Nothing accumulates.**

## One canvas, mutated in place

Keep exactly one canvas buffer: a top-down RGB24 byte array sized to the
header's `canvas_width × canvas_height`. Each record paints its region
into it; the canvas *is* the current frame. Do not keep previous frames,
do not build a frame list, do not write a temporary PNG sequence and
encode it afterwards.

Note the flip: the format stores **bottom-up** scanlines with 4-byte row
alignment (`alv-format.md`), and the canvas is **top-down** with no
padding. That conversion happens once, at the point where a decoded region
is blitted in. Getting it wrong produces a vertically mirrored or sheared
image that decodes without any error at all.

## Frames go to FFmpeg through a pipe

Write raw `rgb24` frames to FFmpeg's stdin over an anonymous pipe. No
intermediate files.

This is what keeps memory flat and disk untouched regardless of recording
length, and it is why an image-export mode is a genuinely different code
path rather than "the same thing but keeping the files": export writes
each frame and forgets it; the video path never materialises one.

Practical consequences, both learned the hard way in tools like this:

- **Read FFmpeg's stderr while writing.** A pipe whose error side is never
  drained deadlocks when the OS buffer fills — the converter appears to
  hang partway through a long recording.
- **Check the exit code and surface stderr on failure.** FFmpeg failing
  silently while frames keep being written looks like a successful
  conversion that produces an unplayable file.

## Timing: milliseconds in, constant frame rate out

ALV records carry `timestamp_delta_ms` — milliseconds since the previous
record. Video wants a constant frame rate. Converting between them is
where drift creeps in.

**Use a cumulative rounding accumulator**, not per-frame rounding. Track
the exact accumulated time and derive each output frame's index from the
running total, so rounding error never compounds. Rounding each delta
independently and summing the results lets a 40,000-record recording
finish visibly out of sync; accumulating bounds the error to roughly one
output frame for the whole file.

When no frame rate is given, derive it as `1000 / median positive
timestamp delta`. Use the **median**, not the mean: a remote session has
long idle gaps, and the mean is dominated by them. (In the validated
sample the positive median is 16 ms → 62.5 fps.)

## Image-export mode is not the video path

`--export-images DIR` writes every reconstructed record as
`frame_000001.png`, `frame_000002.png`, … It must **not** start FFmpeg or
require it to be present. Someone extracting frames should not need a
video encoder installed.

Warn about scale. A full export of the validated sample is 40,995 PNG
files and several gigabytes. Offer a limit (`--image-limit N`) and say in
the help text what a full export costs, rather than letting someone fill a
disk discovering it.

## CLI conventions

Observed across both implementations, and worth keeping consistent:

- Input path only → write the MP4 beside the input, same base name.
- **Never overwrite without `--overwrite`.** Both MP4 and PNG output.
- Encoder controls pass through: `--fps`, `--crf`, `--preset`.
- `--help` works with no input file.

The "don't overwrite by default" rule matters more than it looks: the
input is a recording someone cannot regenerate, and the natural output
name sits right next to it.
