# 📰 HaberApp - Mobil Programlama Dersi Proje Raporu

## 1. Proje Bilgileri

| Bilgi | Detay |
|-------|-------|
| **Proje Adı** | HaberApp - Flutter Haber Uygulaması |
| **Platform** | Android |
| **Geliştirme Ortamı** | Flutter / Dart |
| **GitHub Linki** | [BURAYA_GITHUB_LINKINIZI_GIRIN] |

---

## 2. Proje Açıklaması

HaberApp, güncel haberleri kategorilere göre listeleyen, detaylarını gösteren ve kullanıcının beğendiği haberleri yerel veritabanına kaydedebileceği modern bir mobil uygulamadır. Uygulama, NewsAPI.org üzerinden gerçek zamanlı haber verisi çekerek kullanıcıya güncel bir deneyim sunar.

---

## 3. Kullanılan Teknolojiler

| Teknoloji | Kullanım Amacı |
|-----------|----------------|
| **Flutter 3.7+** | Cross-platform mobil uygulama geliştirme framework'ü |
| **Dart** | Flutter'ın programlama dili |
| **NewsAPI.org** | Dış servis entegrasyonu - REST API ile güncel haber verisi |
| **SharedPreferences** | Yerel veri depolama - Kaydedilen haberlerin saklanması |
| **HTTP paketi** | API isteklerinin yapılması |
| **url_launcher** | Harici haber bağlantılarını tarayıcıda açma |
| **Material Design 3** | Modern ve kullanıcı dostu arayüz tasarımı |

---

## 4. Uygulama Ekranları

### 4.1. Ana Sayfa (HomeScreen)
- Kategorilere göre haber listeleme (Genel, Teknoloji, Spor, Sağlık, Bilim, Eğlence)
- Yatay kaydırılabilir kategori filtreleme butonları
- Pull-to-refresh ile haberleri yenileme
- Haber kartları ile görsel, başlık, açıklama, kaynak ve tarih bilgileri

### 4.2. Haber Detay (DetailScreen)
- Büyük haber görseli (Hero animasyonu ile)
- Detaylı haber içeriği
- Haberi kaydetme/kaldırma butonu
- Haber kaynağını tarayıcıda açma butonu

### 4.3. Kaydedilen Haberler (SavedScreen)
- SharedPreferences yerel depolama alanından kaydedilmiş haberlerin listelenmesi
- Sola kaydırarak silme özelliği (Dismissible widget)
- Boş durum gösterimi

---

## 5. Teknik Gereksinimlerin Karşılanması

| Gereksinim | Durum | Açıklama |
|------------|-------|----------|
| En az 3 ekran | ✅ | Ana Sayfa, Haber Detay, Kaydedilen Haberler |
| Veritabanı kullanımı | ✅ | SharedPreferences ile yerel veri depolama / veritabanı |
| API entegrasyonu | ✅ | NewsAPI.org REST API |
| Modern UI/UX | ✅ | Material Design 3, kart tasarımı, animasyonlar |
| Kod düzeni | ✅ | Yorum satırlı, modüler klasör yapısı |

---

## 6. Proje Yapısı

```
haber_app/
├── lib/
│   ├── main.dart                    # Uygulama giriş noktası ve tema
│   ├── models/
│   │   └── article.dart             # Haber veri modeli
│   ├── services/
│   │   ├── api_service.dart         # NewsAPI servis sınıfı
│   │   └── database_service.dart    # SharedPreferences veritabanı işlemleri
│   ├── screens/
│   │   ├── home_screen.dart         # Ana sayfa ekranı
│   │   ├── detail_screen.dart       # Haber detay ekranı
│   │   └── saved_screen.dart        # Kaydedilen haberler ekranı
│   └── widgets/
│       └── article_card.dart        # Yeniden kullanılabilir haber kartı
├── pubspec.yaml                     # Proje bağımlılıkları
└── README.md                        # Proje dokümantasyonu
```

---

## 7. Kurulum ve Çalıştırma

1. Flutter SDK yüklü olmalıdır (3.7.0+)
2. Proje klonlanır: `git clone <REPO_URL>`
3. `lib/services/api_service.dart` dosyasında API anahtarı güncellenir
4. Bağımlılıklar yüklenir: `flutter pub get`
5. Uygulama çalıştırılır: `flutter run`

---

## 8. Sonuç

HaberApp projesi, mobil programlama dersinin tüm gereksinimlerini karşılayan, modern tasarım standartlarına uygun, temiz ve okunabilir kodla geliştirilmiş bir Flutter uygulamasıdır. Uygulama, dış servis entegrasyonu (NewsAPI), yerel kalıcı veri depolama (SharedPreferences) ve kullanıcı dostu arayüz tasarımı ile kapsamlı bir mobil uygulama deneyimi sunmaktadır.
