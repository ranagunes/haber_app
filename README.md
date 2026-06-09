# HaberApp - Flutter Haber Uygulaması

📰 Güncel haberleri listeleyen, detaylarını gösteren ve kullanıcının beğendiği haberleri kaydedebileceği modern bir Flutter haber uygulaması.

## 📱 Özellikler

- **Güncel Haberler**: NewsAPI üzerinden Türkiye gündemini takip edin
- **Kategori Filtreleme**: Genel, Teknoloji, Spor, Sağlık, Bilim, Eğlence kategorileri
- **Haber Detay**: Haberin detayını görüntüleyin, kaynağa gidin
- **Haber Kaydetme**: Beğendiğiniz haberleri yerel veritabanına kaydedin
- **Modern Tasarım**: Material Design 3 ile şık ve kullanıcı dostu arayüz

## 🛠️ Kullanılan Teknolojiler

| Teknoloji | Açıklama |
|-----------|----------|
| Flutter | Cross-platform mobil uygulama framework'ü |
| Dart | Programlama dili |
| NewsAPI | Haber verisi sağlayan REST API |
| SharedPreferences | Yerel kalıcı veri depolama (veri yönetimi) |
| HTTP | API istekleri |
| url_launcher | Harici bağlantıları açma |

## 📂 Proje Yapısı

```
haber_app/
├── lib/
│   ├── main.dart                    # Uygulama giriş noktası
│   ├── models/
│   │   └── article.dart             # Haber veri modeli
│   ├── services/
│   │   ├── api_service.dart         # NewsAPI servis sınıfı
│   │   └── database_service.dart    # Yerel kalıcı veri depolama işlemleri
│   ├── screens/
│   │   ├── home_screen.dart         # Ana sayfa ekranı
│   │   ├── detail_screen.dart       # Haber detay ekranı
│   │   └── saved_screen.dart        # Kaydedilen haberler ekranı
│   └── widgets/
│       └── article_card.dart        # Haber kartı bileşeni
└── pubspec.yaml                     # Proje bağımlılıkları
```

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (3.7.0 veya üzeri)
- Dart SDK
- Android Studio veya VS Code
- Bir Android emülatör veya fiziksel cihaz

### Adımlar

1. **Repoyu klonlayın:**
   ```bash
   git clone <REPO_URL>
   cd haber_app
   ```

2. **API anahtarını ayarlayın:**
   - [newsapi.org](https://newsapi.org) adresinden ücretsiz bir API anahtarı alın
   - `lib/services/api_service.dart` dosyasını açın
   - `BURAYA_API_KEYINIZI_GIRIN` yazan yeri kendi API anahtarınızla değiştirin

3. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

4. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

## 📸 Ekranlar

### Ana Sayfa
- Kategorilere göre filtrelenen haber listesi
- Pull-to-refresh ile yenileme
- Modern kart tasarımı

### Haber Detay
- Büyük haber görseli
- Başlık, kaynak ve tarih bilgileri
- Haber içeriği
- Kaydet ve Haberi Oku butonları

### Kaydedilen Haberler
- Yerel depolama (SharedPreferences) üzerinden kaydedilen haberlerin listelenmesi
- Sola kaydırarak silme özelliği
- Boş durum gösterimi

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.
