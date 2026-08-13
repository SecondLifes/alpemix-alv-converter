# 🚀 Alpemix ALV Converter AI Spec-Kit

<div align="center">

**Belgesiz bir ikili formatı Delphi ve Python ile okuma işini Yapay Zeka ile en üst seviyeye taşımak için kural, *skill* ve *steering*'lerden oluşan bir ekosistem.**

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![GitHub Copilot](https://img.shields.io/badge/GitHub%20Copilot-Ready-blue?logo=github)](https://github.com/features/copilot)
[![Cursor](https://img.shields.io/badge/Cursor-Rules-purple)](https://cursor.sh)
[![Claude](https://img.shields.io/badge/Claude-Code-brown?logo=anthropic)](https://claude.ai)
[![Gemini](https://img.shields.io/badge/Gemini-Skills-orange?logo=google)](https://gemini.google.com)
[![Kiro](https://img.shields.io/badge/Kiro-Steering-teal)](https://kiro.dev)
[![Qwen](https://img.shields.io/badge/Qwen-AGENTS.md-purple)](https://chat.qwen.ai)
[![Kimi](https://img.shields.io/badge/Kimi-AGENTS.md-lightgrey)](https://kimi.moonshot.cn)

*[🇬🇧 English](README.md) · [Katkıda Bulunma](CONTRIBUTING.tr-TR.md) · [Davranış Kuralları](CODE_OF_CONDUCT.md) · [Güvenlik](SECURITY.tr-TR.md) · [Teşekkürler](ACKNOWLEDGMENTS.tr-TR.md)*

![Genel Bakış](docs/images/overview.png)

</div>

## 📋 İçindekiler

- [Bu proje nedir?](#-bu-proje-nedir)
- [Neden kullanmalı?](#-neden-kullanmalı)
- [Desteklenen AI Araçları](#-desteklenen-ai-araçları)
- [AI'ya Öğretilen Ana Kurallar](#-aiya-öğretilen-ana-kurallar)
- [Desteklenen Framework'ler](#️-desteklenen-frameworkler-ve-kütüphaneler)
- [Kit Yapısı](#-kit-yapısı)
- [Ön Koşullar](#-ön-koşullar)
- [Hızlı Başlangıç](#-hızlı-başlangıç)
- [İyi Uygulama Örnekleri](#-iyi-uygulama-örnekleri)
- [Bilinen Sınırlar](#⚠️-bilinen-sınırlar)
- [Tasarım ve Felsefe](#-tasarım-ve-felsefe)
- [Teşekkürler](#-teşekkürler)
- [Katkıda Bulunma](#-katkıda-bulunma)

---

## 💡 Bu proje nedir?

**Alpemix ALV Converter AI Spec-Kit**, bir kod framework'ü değil — favori yapay zeka aracın için bir **davranış kuralları** setidir. Asistana bu converter üzerinde şu niteliklerle çalışmayı "öğretir":

- ✅ **Dürüst** — her format iddiası kanıt derecesini taşır; kanıtlanmamış bir yol tahmin edilmez, reddedilir
- ✅ **Savunmacı** — her okuma gerçekleşmeden önce sınırlanır, her hata kayıt no ve byte offset'ini söyler, her handle serbest bırakılır
- ✅ **Test edilebilir** — Python `unittest`, bellek içinde üretilen sentetik kayıtlarla; suite'i çalıştırmak için tescilli örnek dosya gerekmez
- ✅ **Akışkan** — tek canvas yerinde değiştirilir, kareler doğrudan FFmpeg'e pipe edilir; bellek kayıt uzunluğuyla büyümez

> Bu kit olmadan, belgesiz bir format için okuyucu yazan bir AI hiç görmediği blok tiplerini kendinden emin bir şekilde uygular — ve açılan, oynayan, ama kimsenin fark edemeyeceği şekilde yanlış bir video üretir.

---

## 🤔 Neden kullanmalı?

| Spec-Kit Olmadan | Spec-Kit İle |
|---|---|
| AI hiç görmediği bir blok tipini uygular | Derecelendirilmemiş yollar adıyla reddedilir, yaklaştırılmaz |
| Stream, handle ve GDI paleti sızdırılır | Sahipsiz her kaynak bir sonraki satırda `try..finally` / `with` alır |
| Kareler bellek dolana kadar biriktirilir | Tek canvas yerinde, kareler doğrudan FFmpeg'e pipe edilir |
| Tarama satırları yukarıdan aşağı, hizalama yok sayılır | Alt-üst sıra ve 4-byte stride tek blit noktasında uygulanır |
| Dosyadan okunan `u32` uzunluk doğrudan tahsise gider | Bildirilen boyutlar tahsis öncesi doğrulanır |

---

## 🤖 Desteklenen AI Araçları

| Araç | Yapılandırma Dosyası | Nasıl Çalışır |
|---|---|---|
| **GitHub Copilot** | `.github/copilot-instructions.md` | Workspace/Chat'e enjekte edilen ön-prompt |
| **Cursor** | `.cursor/rules/*.mdc` (üretilmiş) | Bağlama göre yüklenen kurallar |
| **Claude Code** | `.claude/` (kurallar, komutlar ve skill linkleri üretilmiş) | Bağlama göre kurallar; skill'ler `.claude/skills/` üzerinden keşfedilir |
| **Codex CLI** | `AGENTS.md` | Doğrudan okur, özel klasöre gerek yok |
| **Google Gemini / Antigravity** | `GEMINI.md` (kök) → `.gemini/rules/project-rules.md`'yi import eder | Gemini CLI `GEMINI.md` hiyerarşisini yükler; `.gemini/rules/`'ı kendiliğinden okumaz |
| **Kiro AI** | `.kiro/steering/*.md` | Stack ve mimari kısıtlamaları |
| **Qwen / Kimi** | `AGENTS.md` (manuel) | Native otomatik keşif yok — yukarıdaki araçların aksine, `AGENTS.md`'yi elle göstermeniz gerekir |
| **Herhangi bir AI** | `AGENTS.md` | Evrensel kurallar (proje kökü) |
| **Yukarıdakilerin hepsi** | `.agents/skills/*/SKILL.md` | Paylaşımlı skill'ler — tek düzenlenebilir kopya, araç başına çoğaltılmaz |

> Kurallar ve komutların tek kaynağı `.agents/rules/` ve `.agents/commands/`'tır;
> `.claude/rules`, `.cursor/rules` (`.mdc` olarak), `.claude/commands` ve
> `.claude/skills/` linkleri oradan `tools/generate-ai-configs.ps1` ile üretilir —
> bkz. `.agents/rules/sync-workflow.md`. Klonladıktan sonra bu script'i bir kez
> çalıştırın: skill linkleri makineye özeldir ve bilerek commit'lenmez, dolayısıyla
> çalıştırmadan Claude Code hiçbir skill bulamaz.

---

## 🌟 AI'ya Öğretilen Ana Kurallar

![Temel Özellikler](docs/images/core-features.png)

### Kanıt disiplini

Format hakkındaki her ifade ne kadar bilindiğini söyler —
**örnekle-doğrulanmış**, **statik-analizden-çıkarılmış** ya da
**UNKNOWN** — ve UNKNOWN bir yol yaklaştırılmaz, reddedilir:

```pascal
// Tip 5-8 ve 255 oynatıcıda var, ama hiçbir örnek layout'unu kanıtlamıyor.
// Adıyla reddet; yaklaştırma.
raise EAlvError.CreateFmt('record %d: block type %d is not supported',
  [Rec.Index, Rec.BlockType]);
```

### Savunmacı ayrıştırma

Önce sınırla, sonra oku. Her hata kendini konumlandırır:

```pascal
raise EAlvError.CreateFmt(
  '%s: truncated %s at +0x%x; expected %d, remaining %d',
  [Context, Field, Offset, Expected, Remaining]);
```

Doğru bir ayrıştırma dosyayı **tam EOF**'a kadar tüketir — formatta footer,
checksum ya da indeks olmadığı için bütün-dosya bütünlüğünün tek sinyali budur.

### Akış, biriktirme değil

Tek canvas yerinde değiştirilir; kareler FFmpeg'e `rgb24` olarak pipe edilir.
Bir kayıt masaüstü çözünürlüğünde on binlerce karedir, dolayısıyla bellek
kayıt uzunluğuyla büyümemelidir — ve hiçbir şey geçici görüntü dizisi olarak
diske yazılmaz.

### İki dil, her biri kendi idiomunda

```pascal
TAlvReader = class            // Delphi: T/E/F önekleri, noktalı unit'ler
```
```python
@dataclass(frozen=True)       # Python: snake_case modül, ALV önekli sınıf
class ALVHeader: ...
```

Ortak olan tek şey alan sözlüğü — `header`, `record`, `region`, `codec`,
`canvas`, `payload` — böylece bir implementasyona göre yazılmış kural
diğerine karşı da doğru okunur.

---

## 🛠️ Desteklenen Framework'ler ve Kütüphaneler

| Framework/Kütüphane | Alan | Dahil Edilen Kurallar |
|---|---|---|
| FFmpeg | MP4 kodlama | Kareler `rgb24` olarak pipe edilir; yazarken stderr boşaltılır, exit code kontrol edilir |
| Pillow 12.x | JPEG çözme, PNG yazma (Python) | Çözülen boyutlar kapsayan bölgeye karşı doğrulanır |
| zlib | Codec-0 yükleri | Genişlemiş boyut hem tavana hem beklenen tam bitmap uzunluğuna karşı kontrol edilir |
| Windows GDI | 8-bit halftone paleti (Delphi) | Çalışma zamanında alınır — asla sabit tablo değil |
| PyInstaller | Tek dosya Windows EXE | Python ve Pillow'u paketler; FFmpeg lisans metniyle birlikte çalıştırılabılirin yanında ayrı dosya olarak kalır |

---

## 📂 Kit Yapısı

```
[proje-adı]-spec-kit/
│
├── AGENTS.md                        # 🌐 Evrensel kurallar (Codex, Copilot, Kiro, Antigravity, Gemini)
│
├── .agents/                         # 📦 TEK KAYNAK — sadece burada düzenle
│   ├── rules/                       # Konu-özel kurallar (konu başına bir dosya)
│   │   └── sync-workflow.md         # Bu çoklu-araç kurulumunun senkron mantığı — önce bunu oku
│   ├── commands/
│   │   └── review.md                # Slash-komut kaynağı: /review
│   └── skills/                      # Talep üzerine yüklenen skill'ler (klasör başına SKILL.md) — tek düzenlenebilir
│       │                             # kopya; Claude Code bunlara üretilen .claude/skills/ linkleriyle ulaşır
│       ├── rad-skill-finder/        # Bundle — sıfırdan yazmadan önce mevcut skill'leri arar
│       ├── python/              # Bundle — AI'nin burada çalışırken yazdığı yardımcı script'ler için
│       ├── rad-prompt-studio/       # Bundle — beş-mercek prompt tasarımı/analiz/düzenleme
│       └── rad-web-scraping/        # Bundle — web scraping / yapılandırılmış veri çıkarma (araç seçimi, keşif önceliği)
│                                     # (stack'e özgü skill'ler burada, stack doldurulurken eklenir — bkz. Step 7/8)
│
├── GEMINI.md                        # 🌐 Gemini CLI giriş noktası — .gemini/rules/project-rules.md'yi import eder
├── CHANGELOG.md                     # Sürüm geçmişi; settings.json ile git tag'leri çelişirse hakem
│
├── tools/
│   ├── generate-ai-configs.ps1      # .claude/rules, .cursor/rules (.mdc), .claude/commands ve
│   │                                 # .claude/skills linklerini .agents/'tan yeniden üretir —
│   │                                 # .agents/ altında değişiklikten sonra ve klonladıktan sonra bir kez çalıştır
│   └── verify-kit.ps1               # Mekanik tutarlılık kapısı — CI'ın çalıştırdığı kontrollerin aynısı
│
├── .claude/
│   ├── CLAUDE.md                    # 🧠 Claude için ana sistem prompt'u
│   ├── settings.json                # İzin ayarları
│   ├── commands/                    # ⚙️ .agents/commands'tan ÜRETİLMİŞ — elle düzenleme
│   │   └── review.md
│   ├── rules/                       # ⚙️ .agents/rules'tan ÜRETİLMİŞ — elle düzenleme
│   └── skills/                      # ⚙️ .agents/skills'e ÜRETİLMİŞ linkler — gitignore'lu, içerik değil
│
├── .github/
│   ├── copilot-instructions.md      # 🤖 GitHub Copilot ön-prompt'u (elle yazılır, AGENTS.md'ye referans verir)
│   └── workflows/
│       └── verify.yml               # CI: push ve PR'da tools/verify-kit.ps1 çalıştırır
│
├── .cursor/
│   └── rules/                       # ⚙️ .agents/rules'tan *.mdc olarak ÜRETİLMİŞ — elle düzenleme
│
├── .gemini/
│   └── rules/
│       └── project-rules.md         # Elle yazılan özet, AGENTS.md ile aynı rolde ama Gemini'ye özel
│
├── .kiro/
│   └── steering/
│       ├── product.md               # Ürün vizyonu
│       ├── tech.md                  # Teknoloji yığını
│       ├── structure.md             # Katman mimarisi
│       └── frameworks.md            # Framework rehberleri
│
├── .specify/                        # AI-destekli spec şablonları
│   ├── constitution.md              # Proje anayasası ve kısıtlar
│   ├── plan-template.md             # Uygulama planı şablonu
│   ├── spec-template.md             # Özellik spesifikasyonu şablonu
│   └── tasks-template.md            # Görev kırılımı şablonu
│
├── docs/
│   ├── proje-haritasi.md            # "Her dosya ne işe yarar" haritası (insan-odaklı)
│   └── ai-ignore-strategy.md        # AI bağlam dahil etme/hariç tutma stratejisi
│
└── examples/                        # Tam, derlenebilir örnek kod
                                      # (boş — stack doldurulurken buraya gerçek örnekler eklenir)
```

---

## 🔧 Ön Koşullar

- **PowerShell 7+ (`pwsh`)** — `tools/generate-ai-configs.ps1`'i çalıştırmak için gerekli.
- **Node.js / `npx`** — sadece paketlenmiş `rad-skill-finder` skill'inin
  birincil arama yolu (`npx skills find <konu>`) için gerekli. Kitin
  kendisini kullanmak için şart değil; yoksa `rad-skill-finder` web-tabanlı
  arama adımlarına düşer — bkz. `.agents/skills/rad-skill-finder/SKILL.md`.
- **Windows** — tesadüfi değil, zorunlu: tam 8-bit çözme Windows GDI halftone paletine bağlı
- **RAD Studio / Delphi 37.0** — Delphi implementasyonunu derlemek için (Python tarafını kullanmak için gerekmez)
- **Python 3.11+** ve Pillow — Python implementasyonu için
- **FFmpeg** — MP4 çıktısı için; çalıştırılabilirin yanında vendor'lanmış ya da `PATH`'te

---

## ⚡ Hızlı Başlangıç

### 1. Kiti klonla veya indir

```bash
git clone https://github.com/SecondLifes/alpemix-alv-converter
```

### 2. Projenin köküne kopyala

```
ProjeniZ/
├── src/                             # staging: .alv buraya bırakılır; üretilen çıktı buraya iner
├── AGENTS.md          ← kökten kopyala
├── .agents/            ← klasörü kopyala (tek kaynak: kurallar, komutlar, skill'ler)
├── tools/               ← klasörü kopyala (generate-ai-configs.ps1)
├── .claude/            ← klasörü kopyala (üretilmiş kurallar/komutlar zaten dahil)
├── .github/             ← klasörü kopyala
├── .cursor/            ← klasörü kopyala (üretilmiş kurallar zaten dahil)
├── .gemini/             ← klasörü kopyala
├── .kiro/               ← klasörü kopyala
└── .specify/            ← klasörü kopyala (opsiyonel — spec şablonları)
```

`.agents/rules/` veya `.agents/commands/` altında sonradan bir dosya
ekler/düzenlersen, proje kökünden `pwsh tools/generate-ai-configs.ps1`
komutunu yeniden çalıştırarak `.claude/rules`, `.cursor/rules` ve
`.claude/commands`'ı tazele.

### 3. AI kuralları otomatik devralır

- **Claude Code** — `.claude/CLAUDE.md`'yi uygular, `.claude/rules/*.md`'yi (üretilmiş) ve `.agents/skills/*/SKILL.md`'yi doğrudan okur
- **Cursor** — `.cursor/rules/*.mdc`'yi (üretilmiş) bağlama göre otomatik okur
- **Codex CLI** — proje kökündeki `AGENTS.md`'yi, artı `.agents/skills/*/SKILL.md`'yi okur
- **GitHub Copilot** — workspace'teki `.github/copilot-instructions.md`'yi, artı `.agents/skills/*/SKILL.md`'yi okur
- **Antigravity / Gemini** — `.gemini/rules/project-rules.md`'yi, artı `.agents/skills/*/SKILL.md`'yi okur
- **Kiro** — `.kiro/steering/*.md`'yi sabit ürün bağlamı olarak okur

> **Ek yapılandırma gerekmez.** Projeyi aç, tercih ettiğin AI'yı kullan ve farkı gör.

---

## 💡 İyi Uygulama Örnekleri

Bu kit çalıştırılabilir örnek program içermez: converter'ın kendi Delphi ve
Python kaynakları kendi projesinde yaşıyor ve buradaki işlenmiş bir örnek
gerçek bir `.alv` kaydı gerektirirdi — o da tescilli ve commit edilemez.
`examples/` klasörünün işi, bir kuralı gösteren küçük ve kendi başına yeterli
parçalar: sınırlı bir okuma yardımcısı, sentetik fixture kurucusu — yazıldıkça
eklenir.

---

## ⚠️ Bilinen Sınırlar

`.agents/rules/evidence-grading.md` bu bölümü zorunlu kılar: bu araca
kaydını emanet edip etmeyeceğine karar veren biri, hangi kısmın
kanıtlandığını hangisinin çıkarım olduğunu bilmek zorundadır. README daha
güçlü görünsün diye bunu kaldırmak aracı zayıflatır.

| Alan | Durum |
|---|---|
| Blok tipleri 2, 3, 4 · codec 0 (zlib) ve 1 (JPEG) · 8-bit indeksli çözme | **Örnekle doğrulanmış** — gerçek bir kayıt baştan sona ayrıştırıldı |
| Blok tipi 1 · RGB565 ve 24-bit BGR renk yolları | **Statik analizden çıkarılmış** — oynatıcının kendi yolu izlenerek uygulandı, ama hiçbir örnek bunları çalıştırmıyor |
| Blok tipi 3 ile 4'ün farkı · `box_shaped`'in anlamı · tip 5-8 ve 255'in layout'u | **UNKNOWN** — adıyla reddedilir, asla yaklaştırılmaz |

Kanıtla değil yapıyla ilgili ek sınırlar:

- Tam 8-bit çıktı için **Windows zorunludur** — palet, çalışma zamanında
  alınan Windows GDI halftone paletidir.
- **Delphi tarafında otomatik test yoktur.** Doğrulama, dışa aktarılan
  karelerin Python implementasyonuyla karşılaştırılmasıdır; bu elle
  yapılan bir doğrulamadır ve öyle raporlanır — asla "testler geçti"
  diye değil.
- **Formatta keyframe yoktur**, dolayısıyla kayıtlar paralel çözülemez ve
  araya atlanamaz; ortada oluşan bir ayrıştırma hatası sonrasındaki her
  şey için ölümcüldür.
- **Ses, imleç veya girdi kaydı gözlemlenmedi.** Ya yoktur ya da karelere
  zaten çizilmiştir. İki okuma da kanıtla tutarlı, bu yüzden hiçbiri
  iddia edilmiyor.

---

## 🎯 Tasarım ve Felsefe

![Tasarım ve Felsefe](docs/images/design-philosophy.png)

**Yeniden kur, derecelendir, tahmin etmeyi reddet.**

<!--
Doğdu," "İnşa Yoluyla Doğruluk," "Kasıtlı Olarak Sıradan" — bu kitin
optimize ettiği tek, taviz verilmez değeri gerçekten yakalayan ne ise.]**

Bu kit tek bir asimetri yüzünden var. Bir girdiyi reddeden converter,
kullanıcısına bir destek konuşmasına mal olur. Belgesiz bir yapıyı *tahmin
eden* converter ise ona açılan, oynayan ve sessizce yanlış olan bir dosyaya
mal olur — ne kendisinin ne de sonraki hiç kimsenin fark etme imkânı vardır.
Bu iki başarısızlık kıyaslanabilir değildir; bu yüzden buradaki kurallar
bilerek dengesizdir: her okumayı sınırla, bildirilen her boyutu doğrula, her
iddiayı arkasındaki kanıtla etiketle, ve kanıt bittiğinde ara değer üretmek
yerine dur. Format, satıcının kendi binary'lerinin statik okunması ve gerçek
bir kaydın baştan sona doğrulanmasıyla yeniden kuruldu; bu yolla
kurulamayanlar bilinmiyor olarak yazıldı ve kodda reddediliyor, sessizce
doldurulmuyor.

---

## 🚫 AI Ignore / Bağlam Kontrol Listesi

Bu proje, AI ajanlarının neyi indeksleyip bağlam olarak kullanacağını kontrol eden çok katmanlı bir strateji uygular. PR göndermeden önce:

- [ ] Yeni bir alt-projenin build çıktı klasörleri `.gitignore`'da kapsanıyor
- [ ] `.cursorignore` yeni ağır/binary yolları içeriyor
- [ ] Temel talimat dosyaları (`AGENTS.md`, kurallar, skill'ler, örnekler) **DIŞLANMAMIŞ**
- [ ] `.vscode/settings.json` dışlamaları yeni artifact türleri için güncel
- [ ] Hiçbir sır (`*.key`, `*.pfx`, `.env`) commit edilmemiş veya referans verilmemiş

> Tam gerekçe ve bakım rehberi için [docs/ai-ignore-strategy.md](docs/ai-ignore-strategy.md)'ye bak.

---

## 🙏 Teşekkürler

Bu kitin üzerine inşa edildiği açık kaynak projeler, ticari araçlar ve
referanslar için [ACKNOWLEDGMENTS.tr-TR.md](ACKNOWLEDGMENTS.tr-TR.md)'ye bakın.

---

## 🤝 Katkıda Bulunma

Pull Request'ler memnuniyetle karşılanır! Tam rehber (hata bildirimi, PR
süreci, teknik standartlar) için [CONTRIBUTING.tr-TR.md](CONTRIBUTING.tr-TR.md)'ye,
topluluk beklentileri için [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)'ye bakın.
Bunun yerine bir güvenlik açığı mı buldunuz? [SECURITY.tr-TR.md](SECURITY.tr-TR.md)'ye
bakın — bunun için herkese açık bir issue açmayın.

Kısa versiyon — favori framework'ün/kütüphanen için AI rehberi gerekiyorsa ekle:

1. **Kural** → `.agents/rules/framework-adin.md`, sonra `.claude/rules/` ve `.cursor/rules/`'ı yeniden üretmek için `pwsh tools/generate-ai-configs.ps1` çalıştır — bu iki klasörü **elle düzenleme**, bir sonraki çalıştırmada üzerine yazılır.
2. **Skill** → `.agents/skills/framework-adin/SKILL.md` (tek kopya, düzenlendiği tek yer — üretilecek içerik yok, ama Claude Code'un hem `.claude/skills/framework-adin` linkini — bu olmadan skill'i hiç keşfedemez — hem de eşleşen `/framework-adin` komut sarmalayıcısını alması için sonrasında `pwsh tools/generate-ai-configs.ps1` çalıştır).
3. **Referans** → `AGENTS.md`'de (ve framework/veritabanı-özelse `.gemini/rules/project-rules.md`'de, mevcut girdilerle tutarlı şekilde) bahset.

### Nasıl katkıda bulunulur

```bash
# Fork'la ve klonla
git fork https://github.com/SecondLifes/alpemix-alv-converter
git clone https://github.com/<hesabin>/alpemix-alv-converter.git

# Açıklayıcı bir branch oluştur
git checkout -b feat/bir-sey-ekle

# Commit ve Pull Request
git commit -m "feat: bir sey ekle"
git push origin feat/bir-sey-ekle
```

---

## 🗣️ Kullanabileceğiniz AI Komutları

**Bu kit'in kendisini** çalışma klasörü olarak herhangi bir desteklenen AI CLI ile açın (Claude Code, Codex, Gemini/Antigravity, Cursor) — aşağıdaki komutlar, pakete gömülü `rad-prompt-studio` skill'i ve kit'in kendi `AGENTS.md`'si üzerinden yerel çalışır:

| Siz derseniz | Ne olur |
|---|---|
| `Sistemi analiz et` | Bu kit'in kendi sistem katmanını analiz eder (`.agents/skills/`, `.agents/rules/`, `.agents/commands/`, `AGENTS.md`, `.claude/CLAUDE.md`) — `examples/`, `docs/`, `src/`, `tools/` siz istemedikçe kapsam dışıdır. Rapor kit'in kendi `analysis/result/{ai}_v{n}.md` klasörüne düşer — yerel bir çalışma dosyasıdır, bilerek gitignore'lanmıştır; uygulanan düzeltmelerin kalıcı kaydı git geçmişi + issue'lar + CHANGELOG'dur. |
| `Değerlendir` | `analysis/result/` içindeki mevcut raporları güncel içerikle karşılaştırıp not verir (`STILL_VALID`/`STALE`/`REFUTED`...), düzeltme listesini sunar ve onayınızı bekler. |
| `Düzelt: <hedef>` | Onay-kapılı düzenleme: analiz → eski raporların değerlendirmesi → açık onayınız → düzenleme. Düzenlenen dosya paylaşılan gömülü bir skill (`rad-*`) ise ve bu kit, üst AI-Spec-Kits-Maker workspace'inin içindeyse, aynı düzeltme üstteki master kopyaya da uygulanır — iki taraf hep güncel kalır. |
| `<konu> için skill var mı?` | Gömülü `rad-skill-finder` yerel → `npx skills` ekosistemi → dizinler → web sırasıyla arar; onayınız olmadan asla kurulum yapmaz. |

---

<div align="center">

Belgesiz bir formatı okumak zorunda kalan herkes için ❤️ ile yapıldı.

*[🇬🇧 English](README.md) · [Katkıda Bulunma](CONTRIBUTING.tr-TR.md) · [Davranış Kuralları](CODE_OF_CONDUCT.md) · [Güvenlik](SECURITY.tr-TR.md) · [Teşekkürler](ACKNOWLEDGMENTS.tr-TR.md) · [Lisans](LICENSE)*

*Bu kit sana yardımcı olduysa, repoya bir ⭐ bırak!*

</div>
