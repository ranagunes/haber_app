import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

/// NewsAPI ile iletişim kuran servis sınıfı.
/// Türkiye'deki güncel haberleri kategoriye göre çeker.
/// Eğer API anahtarı girilmemişse veya istek başarısız olursa,
/// kullanıcıya yüksek kaliteli Türkçe demo/mock haberleri sunar.
class ApiService {
  // NewsAPI ana endpoint adresi
  static const String _baseUrl = 'https://newsapi.org/v2/top-headlines';

  // API anahtarı — kendi anahtarınızı buraya girin
  // https://newsapi.org adresinden ücretsiz alabilirsiniz
  static const String _apiKey = 'BURAYA_API_KEYINIZI_GIRIN';

  /// Belirtilen kategoriye göre haberleri NewsAPI'den çeker.
  /// API anahtarı girilmemişse veya istek başarısız olursa mock verileri döndürür.
  Future<List<Article>> fetchArticles({String category = 'general'}) async {
    // API Key girilmemişse doğrudan mock verileri dön (Gecikme ve CORS hatasını önlemek için)
    if (_apiKey == 'BURAYA_API_KEYINIZI_GIRIN' || _apiKey.trim().isEmpty) {
      return _getMockArticles(category);
    }

    final String url =
        '$_baseUrl?country=tr&category=$category&apiKey=$_apiKey';

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> articlesJson = jsonData['articles'] ?? [];
        
        final List<Article> articles = articlesJson
            .map(
              (dynamic articleJson) =>
                  Article.fromJson(articleJson as Map<String, dynamic>),
            )
            .toList();

        // Eğer API'den gelen liste boşsa mock verilere düş
        if (articles.isEmpty) {
          return _getMockArticles(category);
        }
        return articles;
      } else {
        print(
          'API Hatası: Durum kodu ${response.statusCode} — ${response.reasonPhrase}. Mock verilere yönlendiriliyor...',
        );
        return _getMockArticles(category);
      }
    } catch (e) {
      print('Haberler çekilirken bir hata oluştu ($e). Mock verilere yönlendiriliyor...');
      return _getMockArticles(category);
    }
  }

  /// Kategoriye göre yüksek kaliteli Türkçe mock/demo haberleri döndürür.
  List<Article> _getMockArticles(String category) {
    final now = DateTime.now();
    final dateString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T12:00:00Z";

    switch (category) {
      case 'technology':
        return [
          Article(
            title: "Yapay Zeka Teknolojilerinde Yeni Dönem: GPT-5 Beklenenden Erken Gelebilir",
            description: "Teknoloji devleri yapay zeka alanında rekabeti kızıştırıyor. Sektör kaynaklarına göre yeni nesil yapay zeka modeli akıl yürütme becerilerinde çığır açacak.",
            content: "Yapay zeka dünyasında heyecanlı bekleyiş sürüyor. OpenAI'ın geliştirmekte olduğu GPT-5 modelinin, karmaşık matematik problemlerini çözme, bilimsel analiz yapma ve kod yazma yeteneklerinde insan seviyesine yaklaşacağı belirtiliyor. Uzmanlar, bu gelişmenin iş gücü piyasasında ve yazılım dünyasında büyük değişimlere yol açacağını öngörüyor.",
            url: "https://openai.com",
            imageUrl: "https://picsum.photos/600/400?random=11",
            source: "Teknoloji Portalı",
            publishedAt: dateString,
          ),
          Article(
            title: "Elektrikli Otomobillerde Batarya Devrimi: 5 Dakikada Şarj Olan Piller Üretildi",
            description: "Yeni geliştirilen anot teknolojisi sayesinde elektrikli araçlar, geleneksel fosil yakıtlı araçlar kadar hızlı bir şekilde şarj edilebilecek.",
            content: "Laboratuvar ortamında başarıyla test edilen yeni nesil lityum-metal bataryalar, elektrikli araçların en büyük sorunu olan şarj süresini ortadan kaldırıyor. Geliştirici şirket, bataryanın 5.000 şarj döngüsünden sonra bile kapasitesinin %95'ini koruduğunu açıkladı. Seri üretimin önümüzdeki yıl başlaması hedefleniyor.",
            url: "https://www.donanimhaber.com",
            imageUrl: "https://picsum.photos/600/400?random=12",
            source: "OtoTekno",
            publishedAt: dateString,
          ),
          Article(
            title: "Kuantum Bilgisayarlar Siber Güvenliği Tehdit mi Ediyor?",
            description: "Kuantum bilgisayarların işlem gücünün artmasıyla birlikte, mevcut şifreleme yöntemlerinin tehlikeye gireceği uyarısı yapıldı.",
            content: "Kuantum işlemciler, klasik bilgisayarların milyonlarca yılda çözebileceği şifreleme algoritmalarını saniyeler içinde kırabilir. Siber güvenlik uzmanları, devletlerin ve finans kuruluşlarının 'Kuantum Sonrası Kriptografi' (PQC) standartlarına bir an önce geçmesi gerektiğini vurguluyor.",
            url: "https://www.webtekno.com",
            imageUrl: "https://picsum.photos/600/400?random=13",
            source: "Siber Haber",
            publishedAt: dateString,
          ),
        ];

      case 'sports':
        return [
          Article(
            title: "A Milli Futbol Takımı'ndan Muhteşem Galibiyet: Euro 2026 Öncesi Büyük Moral",
            description: "Milli takımımız, hazırlık maçında karşılaştığı güçlü rakibini oynadığı üstün oyunla mağlup ederek turnuva öncesi taraftara umut verdi.",
            content: "A Milli Futbol Takımı, yeni teknik direktör yönetiminde çıktığı en ciddi sınavdan tam not aldı. Genç yıldızların sergilediği performans ve hücum hattındaki etkili organizasyonlar, turnuvada şampiyonluk adayı olduğumuzu gösterir nitelikteydi. Teknik direktör maç sonu açıklamasında: 'Gelişmeye devam ediyoruz, hedefimiz final' dedi.",
            url: "https://www.tff.org",
            imageUrl: "https://picsum.photos/600/400?random=21",
            source: "Spor Ajansı",
            publishedAt: dateString,
          ),
          Article(
            title: "Milli Atletimiz Avrupa Şampiyonası'nda Altın Madalya Kazandı!",
            description: "100 metre engelli branşında piste çıkan milli sporcumuz, harika bir derece elde ederek Türkiye'ye altın madalya getirdi.",
            content: "Avrupa Atletizm Şampiyonası'nda ülkemizi temsil eden sporcumuz, rakiplerini geride bırakarak kürsünün en üst basamağına çıktı. Kendisine ait Türkiye rekorunu da kıran şampiyon atlet, 'Bu madalyayı tüm Türkiye'ye armağan ediyorum. Şimdi hedefim Olimpiyatlar' şeklinde konuştu.",
            url: "https://www.trtspor.com.tr",
            imageUrl: "https://picsum.photos/600/400?random=22",
            source: "Atletizm Dünyası",
            publishedAt: dateString,
          ),
          Article(
            title: "EuroLeague'de Heyecan Dorukta: Temsilcimiz Final Four Yolunda Dev Adım Attı",
            description: "Çeyrek final serisinin üçüncü maçında deplasmanda galip gelen temsilcimiz, seride öne geçerek avantajı eline geçirdi.",
            content: "Müthiş bir savunma performansının sergilendiği maçta takımımız, son periyottaki etkili oyunuyla sahadan galibiyetle ayrılmayı başardı. Taraftarların yoğun ilgi gösterdiği serinin dördüncü maçı kendi evimizde oynanacak. Galibiyet halinde Final Four bileti alınmış olacak.",
            url: "https://www.euroleague.basketball",
            imageUrl: "https://picsum.photos/600/400?random=23",
            source: "Basket Dergisi",
            publishedAt: dateString,
          ),
        ];

      case 'health':
        return [
          Article(
            title: "Uzmanlar Açıkladı: Günde 8 Bardak Su İçmek Gerçekten Gerekli mi?",
            description: "Yıllardır doğru bilinen su tüketim kuralı bilimsel araştırmalarla yeniden ele alınıyor. İhtiyaç kişiden kişiye değişiyor.",
            content: "Yeni yapılan fizyolojik araştırmalar, standart 'günde en az 8 bardak su' kuralının herkes için geçerli olmadığını ortaya koydu. Vücudun su ihtiyacının yaş, kilo, fiziksel aktivite düzeyi ve iklime göre değiştiği vurgulandı. Uzmanlar, susama hissinin en güvenilir rehber olduğunu belirtiyor.",
            url: "https://www.saglik.gov.tr",
            imageUrl: "https://picsum.photos/600/400?random=31",
            source: "Sağlık Rehberi",
            publishedAt: dateString,
          ),
          Article(
            title: "Uykusuzluğun Beyin Üzerindeki Şaşırtıcı Etkileri Araştırıldı",
            description: "Kronik uykusuzluk, beynin toksinleri temizleme yeteneğini azaltarak nörolojik hastalıklara davetiye çıkarıyor.",
            content: "Uyku sırasında beyinde aktif hale gelen glymphatic sistem, gün boyunca biriken metabolik atıkları temizler. Araştırmacılar, 6 saatten az uyuyan bireylerde bu temizlik sürecinin aksadığını ve uzun vadede hafıza kaybı riskinin yükseldiğini keşfetti. Kaliteli uyku için karanlık ve serin bir oda tavsiye ediliyor.",
            url: "https://www.saglik.gov.tr",
            imageUrl: "https://picsum.photos/600/400?random=32",
            source: "Bilim ve Sağlık",
            publishedAt: dateString,
          ),
        ];

      case 'science':
        return [
          Article(
            title: "Mars Gezegeninde Sıvı Su Gölcüklerine Dair Yeni Kanıtlar Keşfedildi",
            description: "Kızıl Gezegen'in yüzey altı radar taramaları, kutup buzullarının altında sıvı halde su bulunabileceğine işaret ediyor.",
            content: "Avrupa Uzay Ajansı'nın (ESA) Mars Express uzay aracından elde edilen yeni radar verileri bilim dünyasında heyecan yarattı. Güney kutbundaki buz katmanlarının 1.5 km altında sıvı su göllerinin varlığına dair güçlü sinyaller alındı. Bu durum, Mars'ta geçmişte veya günümüzde mikroskobik yaşam ihtimalini güçlendiriyor.",
            url: "https://www.nasa.gov",
            imageUrl: "https://picsum.photos/600/400?random=41",
            source: "Uzay Bülteni",
            publishedAt: dateString,
          ),
          Article(
            title: "James Webb Teleskobu Evrenin İlk Oluşum Dönemine Ait Galaksiler Görüntüledi",
            description: "Büyük Patlama'dan sadece 300 milyon yıl sonra oluşmuş devasa galaksilerin keşfi, astrofizik teorilerini yeniden yazdırabilir.",
            content: "James Webb Uzay Teleskobu'nun derin uzay gözlemleri, evrenin erken döneminde galaksilerin sanılandan çok daha hızlı bir şekilde organize olduğunu ve büyüdüğünü gösterdi. Bilim insanları bu kadar erken dönemde bu denli parlak ve büyük galaksilerin var olmasını beklemediklerini, teorilerin güncellenmesi gerektiğini belirtiyor.",
            url: "https://webbtelescope.org",
            imageUrl: "https://picsum.photos/600/400?random=42",
            source: "Kozmos",
            publishedAt: dateString,
          ),
        ];

      case 'entertainment':
        return [
          Article(
            title: "Yılın En Çok Beklenen Bilim Kurgu Filmi Vizyonda: Seyirciden Tam Not",
            description: "Görsel efektleri ve özgün senaryosuyla dikkat çeken yapım, vizyona girdiği ilk hafta sonunda gişe rekoru kırdı.",
            content: "Ünlü yönetmenin son şaheseri olan film, sinemaseverler tarafından büyük beğeniyle karşılandı. Distopik bir gelecekte geçen insan-makine ilişkisini konu alan film, IMAX salonlarında kapalı gişe oynuyor. Sinema eleştirmenleri filme şimdiden Oscar adaylığı gözüyle bakıyor.",
            url: "https://www.beyazperde.com",
            imageUrl: "https://picsum.photos/600/400?random=51",
            source: "Kültür Sanat Ekranı",
            publishedAt: dateString,
          ),
          Article(
            title: "Uluslararası Film Festivali Ödülleri Görkemli Bir Törenle Sahiplerini Buldu",
            description: "Bu yıl 30. kez düzenlenen prestijli festivalde, en iyi film ödülü genç bir yönetmenin ilk uzun metrajlı yapımına gitti.",
            content: "Sanat dünyasının önde gelen isimlerinin katıldığı kırmızı halı töreninin ardından ödüller açıklandı. Toplumsal sorunları gerçekçi bir dille ele alan film En İyi Yönetmen ve En İyi Senaryo dahil olmak üzere toplam 4 dalda ödül alarak geceye damgasını vurdu.",
            url: "https://www.iksv.org",
            imageUrl: "https://picsum.photos/600/400?random=52",
            source: "Sinema Dünyası",
            publishedAt: dateString,
          ),
        ];

      case 'general':
      default:
        return [
          Article(
            title: "Türkiye'nin Yeni Nesil Elektrikli Otomobili Togg T10F Tanıtıldı",
            description: "Togg'un sedan gövdeli yeni akıllı cihazı T10F, şık tasarımı ve yüksek menzil seçeneğiyle resmi olarak görücüye çıktı.",
            content: "Togg, merakla beklenen yeni modeli T10F'i resmi bir lansmanla duyurdu. Fastback hatlarına sahip olan yeni model, tek şarjla 600 kilometreye varan menzil sunacak. Araç içi multimedya ekranları, gelişmiş otonom sürüş özellikleri ve yapay zeka entegrasyonuyla donatılan T10F, önümüzdeki yıl yollarda olacak.",
            url: "https://www.togg.com.tr",
            imageUrl: "https://picsum.photos/600/400?random=61",
            source: "Türkiye Gündemi",
            publishedAt: dateString,
          ),
          Article(
            title: "İstanbul Metrosunda Yeni Düzenleme: Sefer Saatleri Uzatıldı",
            description: "Büyükşehir belediyesinden yapılan açıklamaya göre hafta sonu metro hatları sabaha kadar kesintisiz hizmet verecek.",
            content: "İstanbul'da yaşayan vatandaşların ulaşım konforunu artırmak amacıyla metro hatlarının çalışma saatlerinde düzenlemeye gidildi. Cuma ve Cumartesi günleri ana metro hatları 24 saat kesintisiz çalışacak. Bu karar, özellikle gece saatlerinde seyahat eden çalışanlar ve öğrenciler tarafından memnuniyetle karşılandı.",
            url: "https://www.metro.istanbul",
            imageUrl: "https://picsum.photos/600/400?random=62",
            source: "Metropol Haber",
            publishedAt: dateString,
          ),
          Article(
            title: "Milli Eğitim Bakanlığı Yeni Müfredatı Açıkladı: Beceriler Ön Planda",
            description: "Yeni eğitim döneminden itibaren uygulanacak müfredatta teorik bilgiler azaltılarak beceri odaklı öğrenime geçiliyor.",
            content: "Eğitim sisteminde kapsamlı bir reforma gidiliyor. Bakanlık tarafından hazırlanan yeni müfredat programı, öğrencilerin ezberci eğitimden uzaklaşarak problem çözme, eleştirel düşünme ve dijital okuryazarlık gibi 21. yüzyıl becerilerini kazanmasını amaçlıyor. Pilot okullarda uygulama başarıyla tamamlandı.",
            url: "https://www.meb.gov.tr",
            imageUrl: "https://picsum.photos/600/400?random=63",
            source: "Eğitim Postası",
            publishedAt: dateString,
          ),
        ];
    }
  }
}
