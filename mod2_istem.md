# Talimat: Mod 2 "Eriyen Maskeler"

Önceki üç kararını onaylıyorum:
1. Kutbu aynalayıp %72 yüksekliğe taşıman (tohuma göre yatay aynalama dahil),
2. Omur küçülme oranını φ^(-1/8) yapman,
3. Paleti sarı ve altın-beyaz ile tamamlaman.

Masaüstündeki ruh_katmanlari.wl ana sürümdür. Downloads'taki kopyaya dokunma. Bu dosya dışında hiçbir dosyayı değiştirme.

## Bölüm 11: Mod 2 "Eriyen Maskeler" (hayalet yüzler, akan yağlıboya)

Bölüm 9'daki araçları (titrekFirca vb.) ve mevcut traceStrokes, palColor, finish fonksiyonlarını yeniden kullan. Hiçbir resmi kopyalama; özellikleri prosedürel üret.

### Görsel özellikler
- Pembe-lila-sarı pastel, sisli bir zemin; kenarlarda koyu mor (patlıcan) girdaplar.
- 3-5 adet asit yeşili / turkuaz hayalet maske: düzensiz, yamuk yüz silüetleri. Gözler ve ağız koyu mor ince yarıklar. Biri koyu mor ve tek mavi gözlü olsun.
- Maskeler aşağı doğru eriyip akıyor: alt kenarlarından uzun dikey damlalar ve sürüntüler iniyor.
- Fırça izleri yumuşak, yağlıboya gibi sürülmüş; keskin çizgi yok.

### Teknik uygulama
- Maske şekli: r(θ) = r0 (1 + Σ a_k Sin[kθ + φ_k]) ile gürültüyle bozulmuş kapalı eğri, alt kısmı biraz uzatılmış.
- Göz ve ağız: ince, eğik, hafif asimetrik koyu elipsler ya da kısa kalın fırça yayları.
- Erime: maskenin alt yarısından başlayan noktaları aşağı yönde (negatif y) + hafif akış alanı yönünde traceStrokes ile takip ettir; kalın, saydam, yeşil-turkuaz damla izleri çiz.
- Maske merkezleri altın spiral üzerinde; boyutları sırayla φ'ye bölünerek küçülsün; en büyüğü kutba yakın olsun.
- "smear" son işlemi: görüntüyü düşük frekanslı bir gürültü vektör alanına göre birkaç piksel kaydır (ImageTransformation ya da ImageData üzerinde yer değiştirme), sonra dikey yönlü hafif hareket bulanıklığı uygula (ImageConvolve ile dikey çizgi çekirdeği).
- Yeni palet "PastelRuh": patlıcan moru, lila, toz pembe, şeftali, tereyağı sarısı, asit yeşili, turkuaz.

### Yapı
- Fonksiyon: eriyenMaskeler[tohum, palet, yoğunluk, kılavuz]; Graphics döndürsün, finish ve smear ile kullanılabilsin.
- Ayarlar ayrı değişkenlerde: maskeOnizleme (0.35 yoğunluk, 600 px) ve maskeHQ (1.4, 3000 px), Mod 1'deki gibi.
- 2 örnek çıktı, 1 altın oran kılavuzu görünümü ve yorum içinde baskı kalitesinde dışa aktarma.

## Ortak stüdyo ve dokümantasyon
- Tek bir ortak Manipulate stüdyosu: mod seçimi (Ruh Katmanları / Işık Kafesi / Eriyen Maskeler), tohum, palet, yoğunluk, kılavuz, önizleme, Kaydet (3000 px, Masaüstü). Ayrı stüdyolar varsa bunda birleştir.
- Dosya başındaki "ALTIN ORAN NEREDE?" açıklamasını iki yeni modu da kapsayacak şekilde güncelle. Mod 1'deki aynalama ve φ^(-1/8) kararlarını da oraya kısaca yaz.

## Kontrol
- Mathematica'yı çalıştıramıyorsan bitirince parantez dengesini ve her Module içindeki noktalı virgülleri satır satır kontrol et.
- Mathematica 12 uyumlu kal; sürüme bağlı fonksiyon kullanma.
- Sonunda neyi eklediğini kısa bir özetle bildir.
