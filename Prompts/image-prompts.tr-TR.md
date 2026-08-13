# AI Görsel Prompt'ları — README Banner'ları

Bu kit'in `README.md` / `README.tr-TR.md`'si için üç banner görseli.
Herhangi bir yetenekli görsel modeliyle (Nano Banana Pro, Midjourney v7,
Flux, GPT-Image vb.) **geniş 16:9 banner oranında** üret, PNG olarak
`docs/images/` altına kaydet (`overview.png`, `core-features.png`,
`design-philosophy.png` — aşırı büyük çıktıyı önce küçült; kit içinde bu
işe özel bir script bulunmaz, elindeki herhangi bir görsel aracını kullan).
`README.md`/`README.tr-TR.md`'deki görsel etiketleri **açık** gelir —
dosyalar yerine iner inmez resimler görünür.

Bu dosya **kendi başına yeterlidir** — miras alınacak paylaşılan bir
temel prompt yok. Her spec-kit tamamen kendine ait bir görsel dünyaya
sahiptir.

> **Not:** Prompt metinlerinin kendisi bilinçli olarak İngilizce
> bırakılır — görsel üretim modelleri İngilizce'de daha tutarlı sonuç
> veriyor. Yalnızca çevresindeki açıklama metni Türkçedir.

## Sanat yönü — "The Cylinder Archive" (Silindir Arşivi)

Bu kitin felsefesi *yeniden kur, derecelendir, tahmin etmeyi reddet*: kayıt,
kimsenin anahtarını yayımlamadığı bir ortamda duruyor; onu okumanın dürüst
tek yolu amaca özel bir okuyucu yapmak ve hangi oluklara güvendiğini açıkça
işaretlemek. Dünya, eskimiş kayıt silindirlerinin tek ve kesintisiz geçişle
okunduğu, lamba ışıklı sıcak bir konservasyon odası — hiçbir yerde ekran,
robot, maskot ya da dijital parıltı yok; her alet mekanik, pirinç ve el yapımı.

- **Dünya:** a conservation bench in an archive room. Wax and shellac
  recording cylinders stand upright in a rack; one turns slowly on a
  brass mandrel under a hand-built reading arm. Ledger cards, calipers,
  a sealed sample jar, and three small labelled trays of styli sit within
  reach. Dust hangs in the lamplight.
- **Palet:** shellac black, aged brass and warm oxblood, lit by amber
  lamplight against bone-white paper. Deliberately no blue, no cyan, no
  cold light of any kind.
- **Stil:** warm painterly still-life, chiaroscuro lighting, fine
  mechanical detail — the look of a museum conservation photograph
  rendered as an oil study.
- **Tutarlılık:** üç görsel de aynı odayı, paleti ve ışığı paylaşır; her biri
  farklı bir çekim tipi ve kamera açısı kullanır.

## Negatif Prompt (her üretime yapıştırın)

```
text, letters, readable words, numbers, logos, watermark, low quality,
blurry, humans, faces, hands, robots, mascots, screens, monitors, LEDs,
digital displays, holograms, blue light, cyan, neon, sci-fi, ice, snow,
looms, textiles, ships, temples, different art style between images
```

## Görsel 1 — Genel Bakış (`docs/images/overview.png`)

**Yer:** README'nin en üstü, başlık/rozetlerin altı.
**Çekim:** geniş tanıtım çekimi, tezgâhın tamamına hafif yüksekten
üç-çeyrek bakış.

**Prompt (İngilizce kalır — çevrilmez):**
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

## Görsel 2 — Temel Özellikler (`docs/images/core-features.png`)

**Yer:** "Temel Kurallar" bölümünün üstü.
**Çekim:** tepeden düz yerleşim, doğrudan tezgâh yüzeyine bakış.

**Prompt (İngilizce kalır — çevrilmez):**
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

## Görsel 3 — Tasarım ve Felsefe (`docs/images/design-philosophy.png`)

**Yer:** "Tasarım ve Felsefe" bölümünün üstü.
**Çekim:** dramatik alçak açılı makro, kamera neredeyse tezgâh yüzeyi
hizasında, çok sığ alan derinliği.

**Prompt (İngilizce kalır — çevrilmez):**
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
