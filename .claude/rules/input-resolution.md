# Input Resolution — which recording am I working on?

This kit's work always operates on a specific `.alv` file. Resolve which
one in this order, and **never guess**.

## 1. An explicit path in the request wins

If the request names a file — `"D:\alv\kayit.alv dosyasını mp4 yap"`,
`"analyze C:\recordings\session.alv"` — use exactly that path, in place.

It is not copied into `src/` first, and it overrides anything staged
there. Reading a recording where it already sits is both faster and safer:
these files run to tens of megabytes, and duplicating one to satisfy a
convention wastes disk and creates a second copy that can drift from the
original.

## 2. Otherwise, use what is staged in `src/`

With no path in the request, look in `src/` for `.alv` files — the staging
area only; `src/delphi/` and `src/python/` hold source code, not recordings.

- Exactly one → use it, and say which file was picked.
- More than one → **list them as a numbered pick-list and ask.** Do not
  take the newest, the largest, or the first alphabetically. Two
  recordings in a folder usually means two different problems.

## 3. If `src/` is empty, ask

Ask which recording to work on. Never treat an empty `src/` as "nothing to
do" and never invent a path. An empty staging folder means the question
has not been answered yet, not that the answer is no.

## Say which file you used

Whichever tier resolved it, name the resolved path in the response before
reporting any result. A conversion report that does not say what it
converted cannot be checked — and with an ambiguous `src/`, "it worked" is
worthless if it worked on the wrong recording.

## Output paths follow the same care

- No output path given → write beside the input, same base name.
- **Never overwrite without `--overwrite`.** The input is a recording
  nobody can regenerate, and the default output name sits right next to
  it (`streaming-pipeline.md`).
- Frame export goes to a directory, and a full export is tens of thousands
  of files. Warn about the size before starting one, and offer the limit.

## `src/` is two things — know which one you are looking at

`src/delphi/` and `src/python/` are the converter's own **committed source**.
Nothing in this rule applies to them; they are not staged input and are never
treated as work product to be overwritten.

Everything else under `src/` is the staging area: the recording currently
being worked on, and the default location for anything the kit generates.
`src/bin/` (build output, release archive) and `src/temp/` (build scratch) are
gitignored, and so is any `*.alv`.

The staging area is not an archive. Do not accumulate recordings there, and do
not treat a leftover file from a previous session as the current input without
confirming — that is exactly the case tier 2's pick-list exists for.
