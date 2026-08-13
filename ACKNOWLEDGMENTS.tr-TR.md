# 🙏 Teşekkürler

**Alpemix ALV Converter AI Spec-Kit**, aşağıdaki açık kaynak projelere, ticari
araçlara ve topluluklara dayanıyor. Bu sayfa onları açıkça takdir etmek
için var — sadece README'nin bir köşesinde tek bir linkle geçiştirmek
yerine.

> Not: GitHub'ın `SECURITY.md` için yaptığı gibi ayrı bir "Acknowledgments"
> sekmesi yok — bu dosya görünürlüğünü README'nin rozet satırından ve
> indeksinden link verilerek kazanıyor.

## 📖 Açık Kaynak

| Proje | Burada ne için kullanıldı | Lisans |
|---|---|---|
| [FFmpeg](https://ffmpeg.org/) | Yeniden oluşturulan kareleri MP4'e kodlar. Vendor'lanan build [gyan.dev](https://www.gyan.dev/ffmpeg/builds/)'den; bu kitin öğrettiği provenance ve hash disiplini onun etrafında yazıldı | GPLv3 (bu build; bkz. `third-party-licensing.md`) |
| [Pillow](https://python-pillow.org/) | Python implementasyonunda codec-1 JPEG yüklerini çözer ve PNG kareleri yazar | MIT-CMU |
| [zlib](https://zlib.net/) | Codec-0 yükleri zlib akışıdır; savunmacı boyut doğrulama kuralı bunun etrafında kuruludur | zlib |
| [PyInstaller](https://pyinstaller.org/) | Python build'inin tek dosya paketlemesi — Python, Pillow ve FFmpeg birlikte | GPLv2+ (bootloader istisnasıyla) |
| [x264](https://www.videolan.org/developers/x264.html) | Vendor'lanan FFmpeg build'inde mevcut ve lisans sınıfının GPLv3 olmasının sebebi — `third-party-licensing.md` tam bu vakayı anlatır | GPLv2+ |

## 💼 Ticari

| Ürün/Sağlayıcı | Burada ne için kullanıldı | Notlar |
|---|---|---|
| [Alpemix](https://www.alpemix.com/) | Bu kitin tamamen konusu olan `.alv` oturum-kaydı formatının sahibi uzaktan destek ürünü. Format belgesizdir; buradaki her kural onu statik analiz ve örnek doğrulamasıyla yeniden kurulmuş hâliyle anlatır, satıcı spesifikasyonundan değil | Herhangi bir bağlantı ya da onay yoktur. Satıcı binary'leri statik okundu, hiç çalıştırılmadı; hiçbiri burada yeniden dağıtılmıyor |
| [Embarcadero RAD Studio / Delphi](https://www.embarcadero.com/products/delphi) | Delphi implementasyonu RAD Studio 37.0'ı hedefler; 8-bit palet kuralını zorunlu kılan şey VCL bitmap davranışıdır (`pf8bit`, `CreateHalftonePalette`) | Delphi tarafını derlemek ticari lisans gerektirir; Python tarafı gerektirmez |

## 📚 Referanslar ve İlham Kaynakları

Bu kitin kural ve konvansiyonlarını oluştururken danışılan stil
kılavuzları, resmi dokümantasyon ve önceki çalışmalar (bağımlılık değil —
sadece rehberlik kaynakları):

- ALV formatı için yayımlanmış bir spesifikasyon yoktur. Bu kuralların
  dayandığı format belgesi, satıcının kendi oynatıcı ve converter
  binary'lerinin statik analiziyle üretildi ve gerçek bir kayıt baştan sona
  ayrıştırılarak doğrulandı. O binary'ler okundu, hiç çalıştırılmadı —
  bkz. `.agents/rules/evidence-grading.md`.

## 👥 Proje Katkıda Bulunanları

Bu kitin kendisine (yukarıda teşekkür edilen upstream projelere değil,
bu kitin kurallarına/skill'lerine/konvansiyonlarına) katkıda bulunan
kişiler. Template oluşturulurken workspace'in kendi `template-vars.json`
dosyasındaki `contributors` alanından doldurulur; yeni katkıda bulunanlar
katıldıkça buraya eklenir.

- baspinar99@gmail.com
- emr.pov@gmail.com
- re.baspinar@gmail.com

---

*Bu kit burada teşekkür edilmemiş bir şey kullanıyorsa lütfen bir issue
açın — eksiklikler kasıtlı değil, gözden kaçmadır.*
