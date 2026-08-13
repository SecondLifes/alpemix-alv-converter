# Proje Haritası — Blank Spec-Kit Scaffold

> Bu dosya, kitin altındaki her dosya/klasörün **ne işe yaradığını, ne olduğunu ve ne olmadığını** açıklar. Amaç: yeni birinin (insan ya da AI) kaynağı tek tek açmadan, sadece bu haritadan yönünü bulabilmesi. Bu kit, `template-builder` skill'inin yeni bir spec-kit inşa ederken kopyaladığı **boş (dil/stack-bağımsız) scaffold**'dur — belirli bir dile/stack'e özgü içerik yok, sadece mimari/mekanizma var.
>
> **Güncel kalması nasıl sağlanıyor:** `template-builder`, bu scaffold'dan bir kopya çıkarıp doldururken, `.agents/rules/`, `.agents/commands/` veya `.agents/skills/` altına bir şey eklenip/çıkarılınca bu dosyanın kopyası da aynı turda elle güncellenmelidir (bkz. `.agents/rules/sync-workflow.md`). `tools/generate-ai-configs.ps1`, her çalıştığında `.agents/` altındaki her dosyanın burada adı geçip geçmediğini kontrol edip eksik olanları **uyarı olarak** yazdırır — ama açıklamayı otomatik yazmaz, sadece unutulmadığını garanti eder.

## Bu kit nedir, ne değildir

**Nedir:** Herhangi bir dil/stack için AI asistanlarına (Claude Code, Cursor, Codex CLI, GitHub Copilot, Gemini/Antigravity, Kiro) verilecek bir **davranış/kural şablonunun boş iskeleti**dir — çoklu-araç senkron mimarisi, klasör yapısı ve mekanizmalar hazır; dile/stack'e özgü kurallar, skill'ler ve örnekler henüz doldurulmamıştır.

**Ne değildir:**
- Çalıştırılabilir bir kütüphane/framework değildir — herhangi bir gerçek projeye bağımlılığı yoktur.
- Belirli bir dile/stack'e özgü içerik içermez — bu, `template-builder`'ın mülakat sonucunda dolduracağı kısımdır.

## Mimari — tek cümlede

Kuralların, komutların ve becerilerin (skills) **gerçek içeriği sadece `.agents/` altında yaşar**; `.claude/`, `.cursor/` klasörlerindeki kural dosyaları oradan **otomatik üretilir** (elle düzenlenmez). Nedeni ve mekanizması: [.agents/rules/sync-workflow.md](../.agents/rules/sync-workflow.md).

---

## Kök dosyalar

| Dosya | Ne işe yarar |
|---|---|
| `AGENTS.md` | Codex CLI, Cursor, GitHub Copilot, Gemini/Antigravity ve Kiro'nun **doğrudan okuduğu** evrensel kural özeti. Bu kitte tamamen doldurulmuş — ALV format kuralları, iki dilin konvansiyonları, kanıt disiplini. **Elle yazılır, script'ten üretilmez.** |
| `README.md` | İnsan okuyucu için proje tanıtımı, kurulum (Quick Start), kit yapısının genel görünümü. Aynı şekilde placeholder'lı. Başlığı `{spec-kits-name}` — İngilizce, template-builder mülakatında kullanıcı ile kararlaştırılıp onaylanan tek isim (ayrı bir Türkçe başlık yok, README.tr-TR.md da aynı ismi kullanır). |
| `GEMINI.md` | Gemini CLI'ın giriş noktası. Gemini CLI bağlamını `GEMINI.md` hiyerarşisinden kurar (`~/.gemini/GEMINI.md`, sonra cwd'den kök'e kadar) — `.gemini/rules/project-rules.md`'yi kendiliğinden **okumaz**. Bu dosya içerik çoğaltmaz, `@./.gemini/rules/project-rules.md` ile onu import eder; böylece o dosya düzenlendiği tek yer olarak kalır. |
| `CHANGELOG.md` | Sürüm geçmişi (Keep a Changelog + SemVer). `settings.json`'daki `current_version` ile git tag listesi çeliştiğinde hakem odur (bkz. `.agents/rules/kit-settings.md`). `[Unreleased]` altında biriktirilir; yayında başlık sürüm numarasına çevrilir, `settings.json` aynı commit'te güncellenir, sonra annotated tag atılır. |
| `settings.json` | Bu kitin kendi çalışma-zamanı ayarları — commit'lenir. Şu an sadece `versioning.current_version` (semver) tutuyor; şema `.agents/rules/kit-settings.md`'de. |
| `README.tr-TR.md` | `README.md`'nin birebir Türkçe karşılığı — aynı bölüm sırası, aynı `{spec-kits-name}` başlığı (çevrilmez). template-builder ikisini paralel doldurur (Step 12). Dosya adı nokta-ayraçlı (`README.tr-TR.md`), alt çizgili değil — `CONTRIBUTING.tr-TR.md`/`SECURITY.tr-TR.md` ile aynı kalıp. |
| `LICENSE` | Apache License 2.0. Dosyanın sonundaki APPENDIX bölümünde `Copyright {{YEAR}} {{COPYRIGHT_HOLDER}}` token'lı — template-builder bu iki token'ı workspace kökündeki `template-vars.json`'dan okuyup gerçek değerle değiştirir (bkz. o dosyanın kendi `$comment` alanı). Apache-2.0'ın kendisi (TERMS AND CONDITIONS gövdesi) hiç değiştirilmez, sadece appendix'teki copyright satırı token'lı. |
| `CODE_OF_CONDUCT.md` | Contributor Covenant v1.4 — standart, dil-agnostik metin. **Türkçe çevirisi kasıtlı olarak yok** (referans projede de yoktu — davranış kuralları genelde tek dilde tutulur, hukuki netlik için). İletişim e-postası doldurulmuş. |
| `CONTRIBUTING.md` / `CONTRIBUTING.tr-TR.md` | "Contributing to {spec-kits-name}" — hata bildirimi, PR süreci, teknik standartlara (AGENTS.md'ye referansla) işaret. README.tr-TR.md gibi paralel çift. |
| `SECURITY.md` / `SECURITY.tr-TR.md` | Güvenlik açığı bildirme süreci — Supported Versions tablosu `:white_check_mark:`/`:x:` kullanır. README.tr-TR.md gibi paralel çift. |
| `.gitignore` | Genel (dil-agnostik) git-ignore kuralları — node_modules, .venv, .env, log/temp dosyaları vb. Stack-özgü derleme çıktısı desenleri template-builder tarafından eklenir. |
| `.cursorignore` | Cursor'un indekslemeyeceği yollar — `.agents/`, `tools/` gibi önemli yollar burada asla dışlanmaz. |

## `.agents/` — Tek Kaynak (Single Source of Truth)

Bu klasör kitin **kalbi**dir. Yeni bir kural/komut/skill eklerken/düzenlerken HER ZAMAN burada çalışılır.

### `.agents/rules/` — 13 dosya

| Dosya | Konu |
|---|---|
| `sync-workflow.md` | **Önce bunu oku.** Bu mimarinin nasıl çalıştığı, `.agents` değişince ne yapılması gerektiği. Dil-agnostik, bu yüzden boş scaffold'da tek hayatta kalan kural dosyası budur. |
| `kit-settings.md` | Kit kökündeki `settings.json`'ın şeması ve kullanım kuralları (versiyon bilgisi, Golden Rule 7'nin etiketleme adımı buradan okur/yazar). |
| `analysis-output.md` | Bundle'lanmış `rad-prompt-studio`'nun üç master prompt'unun ortak girdi-çözümleme ve çıktı-adlandırma kuralı: hedef nasıl belirlenir, rapor nereye hangi adla yazılır (`%ProgramData%\rad\analysis\{repo}\{hedef}\{ai}_v{n}.md`), ve düzeltilen bulguların raporu ne zaman silinir. Bu dosya olmadan üç prompt da çıktı yolunu çözemez. |
| `local-machine-registry.md` | Tek, makine geneli `.rad` hub'ı (`%ProgramData%\rad`): tek bir `settings.json` (root + kits + kisisel ayarlar birlikte), ortak kurallar/skiller/analiz hepsi workspace'in kendi `share\` klasorune canli link. Baska bir kite kendi `settings.json`'daki `references` ile ad uzerinden referans verme (yol asla hardcode edilmez), ortak kurallari canli okuma, ve kurulu kutuphane kaynagini tahmin yerine dogrudan okuma kurallari burada. |

Bu kitin kendi konu kuralları — hepsi kaynak projenin gerçek kodundan ve
`alv_format.md` belgesinden gözlemlendi, hiçbiri varsayım değil:

| Dosya | Konu |
|---|---|
| `alv-format.md` | ALV konteynerin kendisi: dosya başlığı, kayıt zarfı, blok tipleri 1-4, codec 0 (zlib) ve 1 (JPEG), Delphi `TDateTime`/`ShortString` çözme, **alt-üst tarama satırları + 4-byte satır hizalaması**, renk derinliği kodları ve 8-bit'in GDI halftone paletinden gelmesi. Her ifade kanıt derecesiyle birlikte. |
| `evidence-grading.md` | **Bu kitin omurgası.** Örnekle-doğrulanmış / statik-analizden-çıkarılmış / UNKNOWN üçlüsü, hangi blok tipinin hangi kovada olduğu, ve derecelendirilmemiş bir yolu *tahmin etmek yerine reddetme* kuralı. Gözlemlemediğin bir nedeni de iddia etme. |
| `defensive-parsing.md` | Her okumayı önce sınırla; her hata kayıt no + byte offset + beklenen/kalan taşısın; dosyadan okunan boyutlar iddiadır, tahsis etmeden doğrula; güvenlik tavanları adlandırılmış sabit ve *bizim*, formatın değil; **tam EOF** tek bütünlük sinyali. |
| `streaming-pipeline.md` | Tek canvas yerinde değiştirilir, kareler FFmpeg'e `rgb24` olarak pipe edilir, hiçbir şey biriktirilmez. ms zamanlamanın kümülatif yuvarlama akümülatörüyle sabit kare hızına dönüştürülmesi; kare hızı yokken **medyan** deltadan türetilmesi. Görüntü dışa aktarma ayrı yol — FFmpeg gerektirmez. |
| `delphi-conventions.md` | Noktalı unit isimleri (`Alv.Core`), `T`/`E`/`F` önekleri, veri için `record`, sahipsiz her `.Create` sonrası `try..finally`, tek `EAlvError` kökü, `{$POINTERMATH}` kapsamı, RTL+WinAPI dışında bağımlılık yok. |
| `python-conventions.md` | `snake_case` modüller, `ALV` önekli sınıf/istisnalar, frozen dataclass, üç seviyeli istisna ağacı, `SafeReader`, açık little-endian `struct`, generator'lerle akış. **Lint yapılandırması olmadığı açıkça yazılı.** |
| `testing.md` | Python `unittest` + **sentetik** fixture'lar (örnek binary gerektirmez); reddetme davranışının da test edilmesi; **Delphi tarafında otomatik test olmadığının dürüstçe belirtilmesi** ve doğrulamanın çapraz-implementasyon kare karşılaştırmasıyla yapılması. |
| `third-party-licensing.md` | Vendor'lanan binary'nin kaynağı, iki SHA-256'sı, build yapılandırmasının lisans sınıfı (GPLv3 + `libx264`); lisans metni binary'nin yanında; Delphi'nin `RCDATA` kullanmama kararının neden kasıtlı olduğu; güncelleme prosedürü. |
| `input-resolution.md` | Hangi `.alv` üzerinde çalışıldığının çözümlenmesi: istekteki açık yol > `src/`'de duran > kullanıcıya sor. Birden fazlaysa numaralı liste sun, asla en yenisini seçme. Çıktı `--overwrite` olmadan asla üzerine yazmaz. |

### `.agents/commands/` — 1 dosya

| Dosya | Ne işe yarar |
|---|---|
| `review.md` | `/review` slash-komutunun kaynağı — git diff'i proje kurallarına göre incelet. Bu kitte ALV'ye özgü inceleme sözleşmesiyle doldurulmuş: kanıt derecesi belirtilmiş mi, her okuma sınırlı mı, piksel tuzakları (alt-üst tarama, 4-byte hizalama, GDI paleti) gözetilmiş mi. |

### `.agents/skills/` — şu an 4 klasör (boş scaffold hâli)

Skill'ler, rules'tan farklı olarak **otomatik yüklenmez** — AI, konuyla ilgili bir istek geldiğinde ilgili `SKILL.md`'yi kendisi seçip okur (progressive disclosure). Her skill'in kendi klasöründe `SKILL.md` (giriş noktası) ve bazılarında `references/` (derin referans) bulunur — 250-350 satırı aşan tek-parça `SKILL.md` kabul edilmez, `references/*.md`'ye bölünmelidir.

Dört skill de workspace'in kendi `.claude/skills/`'inden bundle edilir; her template bunlarla doğar. Dördü de **birebir (byte-identical) aynadır** — master'lar zaten konumdan bağımsız yazıldığı için ("bu workspace", göreli `references/` yolları) hiçbirinin taşınabilirlik için yeniden yazılmış bir varyantı yoktur; master'dan **farklı olan bir kopya tanımı gereği bayattır**, asla "bilerek farklı" değildir (bkz. `rad-template-builder/SKILL.md` Step 5 ve Step 11'in bayatlık kontrolü). Aynı zamanda **statik kopyadır** — master güncellenince otomatik yansımaz; Step 11 her birini `diff` ile master'a karşı kontrol eder ve farklı olanı tümüyle tazeler.

| Klasör | Ne işe yarar |
|---|---|
| `rad-skill-finder/` | Workspace'in kendi `.claude/skills/rad-skill-finder/`'ının birebir aynası — bu projenin kendi `.agents/skills/`'ını, `npx skills` ekosistemini, GitHub awesome-list'lerini ve web'i arar; sıfırdan yazmadan önce ilgili bir skill olup olmadığını kontrol eder. |
| `python/` | Workspace'in kendi `.claude/skills/python/`'unun birebir kopyası (workspace'e özgü içerik yok) — performans/test/tasarım-deseni odaklı genel Python mühendislik skill'i. Stack'in kendisi Python olmasa bile, AI iş sırasında yardımcı script yazarken (veri işleme, doğrulama, tek seferlik otomasyon) bunu kullanır. |
| `rad-prompt-studio/` | Workspace'in kendi `.claude/skills/rad-prompt-studio/`'sunun birebir aynası — beş uzmanlık merceğini (Prompt Engineer & Analyst, Repo Auditor, DevOps/Config Engineer, Systems Forensics Analyst, Context Engineer) aynı anda üstlenip yeni prompt tasarlar, bu projenin kendi prompt/rule/skill/sync-mimarisi içeriğini analiz eder (tekil veya toplu) ve zorunlu analiz-onay akışıyla herhangi bir dosyayı güvenle düzenler. Beş mercek `references/` altında **beş ayrı dosyadır** (`prompt-engineer-analyst.md`, `repo-auditor.md`, `devops-config-engineer.md`, `systems-forensics-analyst.md`, `context-engineer.md`); `references/prompts/`'da üç master prompt (analiz/değerlendirme/düzenleme), `references/design/`'da prompt desen kataloğu bulunur — dış dosyaya bağımlılık yok. |
| `rad-web-scraping/` | Workspace'in kendi `.claude/skills/rad-web-scraping/`'inin birebir kopyası (workspace'e özgü içerik yok) — genel web scraping / yapılandırılmış veri çıkarma skill'i. Hangi kaynağı (API > gömülü JSON > DOM en son) ve hangi aracı (crawl4AI, ScrapeGraphAI, düz HTTP, Playwright) seçeceğine karar verir; `references/tool-selection.md` doğrulanmış araç kıyası, `references/discovery-and-extraction-patterns.md` keşif/çıkarma desenlerini içerir. |

Bunun dışındaki skill'ler template-builder tarafından, `rad-skill-finder` ile bulunan ve kullanıcı onayından geçen skill'lerle doldurulur.

---

## Araç-özel adaptörler

Bu klasörlerin çoğu **üretilmiş** (generated) içerik barındırır — kaynağı `.agents/`'tır, elle düzenlenmez.

| Klasör/Dosya | Durum | Ne işe yarar |
|---|---|---|
| `.claude/CLAUDE.md` | Elle yazılır | Claude Code'un otomatik okuduğu kök talimat — proje özeti + `.agents/` mimarisine yönlendirme. Bu kitte doldurulmuş. |
| `.claude/settings.json` | Elle yazılır | İzin ayarları — `permissions.allow` (generator komutu ön-onaylı) ve `permissions.deny` (`.env`/`.key`/`.pem`/`.pfx`/`.p12` okumaları engelli). Şema `Tool(specifier)` biçiminde; uydurma `allowCommands`/`denyPaths` anahtarları Claude Code tarafından sessizce yok sayılıyordu. |
| `.claude/rules/*.md` | ⚙️ **Üretilmiş** | `.agents/rules/`'ın birebir kopyası — Claude Code'un native olarak buradan okuduğu format. |
| `.claude/skills/<skill-adı>` | ⚙️ **Üretilmiş link** | `.agents/skills/<skill-adı>`'a işaret eden junction (Windows) / symlink. Claude Code skill'leri **sadece** `.claude/skills/` altında keşfeder; `.agents/skills/` onun keşif konumlarından biri değil. İçerik değil, link — `.gitignore`'da, commit'lenmez, klonlandıktan sonra generator yeniden üretir. |
| `.claude/commands/review.md` | ⚙️ **Üretilmiş** | `.agents/commands/review.md`'nin kopyası — `/review` komutu. |
| `.claude/commands/<skill-adı>.md` | ⚙️ **Üretilmiş** | Her `.agents/skills/*` klasörü için otomatik üretilen ince komut sarmalayıcısı — skill'i doğal-dil eşleşmesine güvenmeden, deterministik şekilde ilk adımından başlatır. Sadece Claude Code'da var. |
| `.cursor/rules/*.mdc` | ⚙️ **Üretilmiş** | `.agents/rules/`'ın Cursor formatındaki kopyası. |
| `.gemini/rules/project-rules.md` | Elle yazılır | Gemini/Antigravity için `AGENTS.md`'ye benzer, Gemini'ye özel kısa özet. Bu kitte doldurulmuş. |
| `.github/copilot-instructions.md` | Elle yazılır | GitHub Copilot'un workspace'e enjekte ettiği ön-prompt; `AGENTS.md`'ye referans verir, tekrar etmez. Bu kitte doldurulmuş. |
| `.kiro/steering/*.md` (4 dosya: `product.md`, `tech.md`, `structure.md`, `frameworks.md`) | Elle yazılır | Kiro AI'nin "steering" (yönlendirme) dokümanları — kural değil, daha çok "proje bağlamı" niteliğinde, bu yüzden `.agents/` senkron şemasının dışında tutuluyor. Bu kitte doldurulmuş. |
| `.specify/*.md` (4 şablon) | Elle yazılır | Spec-driven geliştirme şablonları (`constitution.md`, `spec-template.md`, `plan-template.md`, `tasks-template.md`) — büyük bir özellik eklerken kod yazmadan önce doldurulması önerilen, opsiyonel şablonlar. Çoğu zaten dil-agnostik; birkaçında stack-özgü yer tutucu kalmamış. |
| `.vscode/settings.json` | Elle yazılır | VS Code'un `files.exclude`/`search.exclude` ayarları — şu an sadece genel (OS/dependency) desenler var, stack-özgü derleme çıktıları template-builder tarafından eklenir. |

## `tools/`

| Dosya | Ne işe yarar |
|---|---|
| `register.bat` | Bu kiti makine-geneli `.rad` registry'sine kaydeder — kendi kayıt mantığını taşımaz, sadece hub kökündeki symlink üzerinden workspace'in kendi `rad.ps1`'ini `-Action Register` ile çağırır. Hub kurulu değilse sadece "Hub kurulu değil." der, durur. `-Name` ile farklı ad, `-Unregister` ile kayıt silme. Kit taşınınca/yeniden klonlanınca tekrar çalıştırılmalı. |
| `verify-kit.ps1` | Mekanik tutarlılık kapısı, `.github/workflows/verify.yml`'ın çalıştırdığı script'in aynısı — yerelde de `pwsh tools/verify-kit.ps1` ile çalışır. Kontroller: generator drift (üretilmiş kopyalar commit'lenenden farklı mı), `.cursor/rules` altındaki her dosya `.mdc` mi, `.claude/skills/` her skill için giriş taşıyor mu, her `SKILL.md`'nin frontmatter'ı geçerli mi, doldurulmamış şablon işareti kalmış mı, README'nin gömdüğü görseller diskte var mı, `LICENSE` duruyor mu. |
| `generate-ai-configs.ps1` | `.agents/rules` ve `.agents/commands`'ı okuyup `.claude/rules` (`.md`) ve `.cursor/rules`'a (`.mdc` — Cursor bu klasörde `.md`'yi yok sayar) kopyalayan, ayrıca her `.agents/skills/*` için `.claude/skills/` altına link üreten PowerShell script. Ayrıca `.agents/skills/*` altındaki her klasör için `.claude/commands/<skill-adı>.md` adında ince bir komut sarmalayıcısı üretir — isim bir hand-authored komutla çakışırsa o skill için üretim atlanır ve uyarı basılır. `.agents/rules`, `.agents/commands` altında bir dosya eklenip/silinip/değiştirildiğinde VEYA `.agents/skills` altına bir skill eklenip/kaldırıldığında çalıştırılması **zorunludur** (bkz. `sync-workflow.md`). Dil/stack-agnostik — hiçbir değişiklik gerektirmez. |

## `docs/`

| Dosya | Ne işe yarar |
|---|---|
| `proje-haritasi.md` | Bu dosya. |
| `alpemix-alv-converter-analysis.md` | Kit tamamlandığında çalıştırılan beş-mercek self-audit raporu: mekanik geçitlerin sonucu ve bulunan/düzeltilen kusurlar. |
| `ai-ignore-strategy.md` | Hangi dosyaların AI bağlamından hariç tutulacağı/tutulmayacağı stratejisi (`.gitignore`, `.cursorignore`, `.vscode/settings.json` ile ilişkisi). |

## `examples/`

Şu an sadece kendi amacını açıklayan bir `README.md` içeriyor — `src/` ve `docs/images/` ile aynı gerekçe: boş klasör git'te izlenmediği için bu dosya klasörün taze bir clone'da da var olmasını garanti eder (bu dosya olmadan `examples/` sessizce kaybolur, ama `AGENTS.md`/`.github/copilot-instructions.md`/`docs/ai-ignore-strategy.md` onu hâlâ "her zaman bağlama al" listesinde tutar — kite ölü referans olarak miras kalır). Derlenebilir/örnek kaynak kodu — kural dosyalarındaki kısa kod parçacıklarının aksine, burada **tam çalışan örnekler** olması beklenir. AI, bir desenin gerçek uygulamasını görmek istediğinde buraya bakar. template-builder, mülakat sonucunda stack'e özgü örnekleri buraya ekler.

## `src/`

Bu projenin **varsayılan çalışma/çıktı kökü** — kullanıcı başka bir yer belirtmedikçe, AI'nin ürettiği gerçek teslim edilebilirler (script, modül, ne istendiyse) buraya yazılır. `examples/`'dan farkı: `examples/` küratörlü referans içerik, `src/` ise gerçek üretilen iş. Şu an sadece kendi amacını açıklayan bir `README.md` içeriyor — boş klasör git'te izlenmediği için bu dosya aynı zamanda klasörün var olmasını garanti ediyor. `AGENTS.md`'nin "Working Directory" bölümüne bakın.
