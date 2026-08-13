# AI Image Prompts — README Banners

Three banner images for this kit's `README.md` / `README.tr-TR.md`.
Generate with any capable image model (Nano Banana Pro, Midjourney v7,
Flux, GPT-Image, etc.) at a **wide 16:9 banner aspect ratio**, save as
PNG under `docs/images/` (`overview.png`, `core-features.png`,
`design-philosophy.png` — shrink oversized model output first; no
bundled script for this in a kit, use whatever image tool is at hand).
The `README.md`/`README.tr-TR.md` image tags ship **uncommented** — the
pictures appear as soon as the files land.

This file is **self-contained** — there is no shared base prompt to
inherit from. Every spec-kit owns a completely distinct visual world.

## Art direction — "The Cylinder Archive"

This kit's philosophy is *reconstruct, grade, and refuse to guess*: a
recording exists on a medium nobody published a key for, and the only
honest way to read it is to build a purpose-made reader and mark clearly
which grooves you trust. The world is a warm, lamp-lit conservation room
where obsolete recording cylinders are read one continuous pass at a time
— there are no screens, no robots, no mascots and no digital glow
anywhere; every instrument is mechanical, brass and hand-made.

- **World:** a conservation bench in an archive room. Wax and shellac
  recording cylinders stand upright in a rack; one turns slowly on a
  brass mandrel under a hand-built reading arm. Ledger cards, calipers,
  a sealed sample jar, and three small labelled trays of styli sit within
  reach. Dust hangs in the lamplight.
- **Palette:** shellac black, aged brass and warm oxblood, lit by amber
  lamplight against bone-white paper. Deliberately no blue, no cyan, no
  cold light of any kind.
- **Style:** warm painterly still-life, chiaroscuro lighting, fine
  mechanical detail — the look of a museum conservation photograph
  rendered as an oil study.
- **Consistency:** all three images share this same room, palette and
  light; each uses a different shot type and camera angle.

## Negative Prompt (paste into every generation)

```
text, letters, readable words, numbers, logos, watermark, low quality,
blurry, humans, faces, hands, robots, mascots, screens, monitors, LEDs,
digital displays, holograms, blue light, cyan, neon, sci-fi, ice, snow,
looms, textiles, ships, temples, different art style between images
```

## Image 1 — Overview (`docs/images/overview.png`)

**Slot:** top of the README, under the title/badges.
**Shot:** wide establishing shot, slightly elevated three-quarter view of
the whole bench.

**Prompt:**
```
A warm lamp-lit archive conservation bench seen in a wide three-quarter
view from slightly above. On the left, a tall rack holds a dozen upright
black shellac recording cylinders, each one sealed and unlabelled. At the
centre, a single cylinder turns slowly on a polished brass mandrel beneath
a delicate hand-built reading arm, its fine stylus tracking one continuous
unbroken groove from the very start of the cylinder — the groove visibly
spirals without a single break or restart point. To the right, an open
ledger of blank cream cards, brass calipers, and three shallow trays of
styli. Dust drifts through the amber lamplight. Shellac black, aged brass
and warm oxblood against bone-white paper, chiaroscuro oil-study
rendering, fine mechanical detail, no digital light of any kind. Wide 16:9
banner composition, highly detailed.
```

## Image 2 — Core Features (`docs/images/core-features.png`)

**Slot:** top of the "Key Guidelines" / core-features section.
**Shot:** overhead flat-lay, straight down onto the bench surface.

**Prompt:**
```
An overhead flat-lay of a brass-and-leather archive conservation bench,
shot straight down in warm amber lamplight. Five distinct objects are laid
out on bone-white paper, each clearly separated and distinct in
silhouette: (1) three small shallow trays of styli, the first tray full
and gleaming, the second half-empty, the third empty and covered by a
small hinged brass lid that is closed and latched shut — evidence grading,
where the unproven tray stays closed rather than being guessed at; (2) a
pair of brass calipers resting across a cylinder, measuring its diameter
before any stylus is lowered — every read bounded before it happens; (3) a
long unbroken paper ribbon spooling off the edge of the bench and away,
never coiling or piling up on the surface — streaming, never accumulating;
(4) a fine brass ruler laid against a stack of paper whose sheets are
aligned to an exact repeating step, one sheet deliberately offset and
casting a visible shadow — row alignment and scanline order; (5) a small
sealed glass jar holding a single dark shard, tagged with a plain blank
card and set apart from the working tools — a third-party artefact
recorded and never opened. Shellac black, aged brass and warm oxblood on
bone-white paper, painterly still-life, no text anywhere, no digital
light. Wide 16:9 banner composition, highly detailed.
```

## Image 3 — Design & Philosophy (`docs/images/design-philosophy.png`)

**Slot:** top of the "Design & Philosophy" section.
**Shot:** dramatic low-angle macro, camera almost level with the bench
surface, extremely shallow depth of field.

**Prompt:**
```
An extreme low-angle macro, camera nearly level with the bench surface and
very shallow depth of field. A hand-built brass reading arm is held
deliberately raised and still, its fine stylus hovering a few millimetres
above a black shellac cylinder and not touching it. The cylinder's surface
directly beneath the stylus is visibly damaged and unreadable — the groove
there dissolves into a rough, ambiguous band. Beside the cylinder, a small
brass tray of styli sits with its lid closed and latched. A single amber
lamp rakes across the scene from the left, catching the raised stylus and
the intact grooves further along the cylinder in sharp light, while the
damaged band stays in shadow. Nothing is in motion; the restraint is the
subject. Shellac black, aged brass and warm oxblood, chiaroscuro oil-study
rendering, no text, no digital light, no human figures. Wide 16:9 banner
composition, highly detailed.
```
