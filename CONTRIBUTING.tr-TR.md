# Alpemix ALV Converter'na Katkıda Bulunma

Katkıda bulunmayı düşündüğünüz için teşekkürler! Bu kiti herkes için daha iyi hale getirenler tam olarak sizin gibi insanlar.

Bu projeye katılarak [Davranış Kuralları](CODE_OF_CONDUCT.md)'na uymayı kabul etmiş olursunuz.

## Nasıl Katkıda Bulunabilirim?

### Hata Bildirimi

* Hatanın daha önce bildirilip bildirilmediğini görmek için [issue tracker](https://github.com/SecondLifes/alpemix-alv-converter/issues)'ı kontrol edin.
* Bildirilmemişse yeni bir issue açın. Sorunu net bir şekilde tanımlayın ve tekrar üretme adımlarını ekleyin.

### İyileştirme Önerileri

* `enhancement` etiketiyle bir issue açın.
* Bunun bu kitin çoğu kullanıcısı için neden faydalı olacağını açıklayın.

### Pull Request'ler

1. Depoyu fork'layın.
2. Özelliğiniz veya hata düzeltmeniz için yeni bir branch oluşturun.
3. Değişikliklerinizi uygulayın.
4. `AGENTS.md` ve `.agents/rules/*.md`'deki konvansiyonlara uyun (projenin geri kalanıyla tutarlı).
5. Değişikliğinizi gerçekten çalıştırarak/uygulayarak doğrulayın — sadece okuyarak doğru olduğunu iddia etmek yerine `.agents/skills/*/references/verification-checklist.md`'ye (veya bu stack'in eşdeğerine) bakın.
6. `main` branch'ini hedefleyen bir Pull Request gönderin.

## Teknik Standartlar

Bu kitin kendi konvansiyonları katkılar için teknik standarttır — aynı
kuralların iki kopyası arasında sapma olmaması için burada tekrarlanmıyor.
Delphi ve Python'in isimlendirme, hata yönetimi ve mimari
konvansiyonları için `AGENTS.md`'nin "Main Guidelines" bölümüne bakın.

Mevcut bir şeyi düzeltmek yerine yeni bir yetenek eklemek için:

1. **Kural** → `.agents/rules/konu-adin.md`, sonra `.claude/rules/` ve `.cursor/rules/`'ı yeniden üretmek için `pwsh tools/generate-ai-configs.ps1` çalıştırın — bu iki klasörü **elle düzenlemeyin**, bir sonraki çalıştırmada üzerine yazılır.
2. **Skill** → `.agents/skills/skill-adiniz/SKILL.md` (tek kopya, düzenlendiği tek yer — üretilecek içerik yok, ama Claude Code'un hem `.claude/skills/skill-adiniz` linkini — bu olmadan skill'i hiç keşfedemez — hem de eşleşen `/skill-adiniz` komut sarmalayıcısını alması için sonrasında `pwsh tools/generate-ai-configs.ps1` çalıştırın).
3. **Referans** → `AGENTS.md`'de (ve framework/veritabanı-özelse `.gemini/rules/project-rules.md`'de, mevcut girdilerle tutarlı şekilde) ve `docs/proje-haritasi.md`'de bahsedin.

### Test

* Değişiklikleri gerçekten uygulayarak/çalıştırarak doğrulayın — bu kitin kendi doğrulama yaklaşımı için `AGENTS.md`'nin Project Stack bölümündeki "Tests" girdisine bakın.

## İletişim

* Hatalar, sorular ve öneriler için [issue tracker](https://github.com/SecondLifes/alpemix-alv-converter/issues)'ı kullanın.
* Tüm katkıda bulunanlara ve yöneticilere saygı gösterin — bkz. [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
