/// Haber (Article) veri modeli.
/// NewsAPI'den gelen JSON formatına uygun olarak tasarlanmıştır.
/// Veritabanı işlemleri için [id] alanı da içerir.
class Article {
  // Veritabanı birincil anahtarı (otomatik artan)
  final int? id;

  // Haber başlığı
  final String? title;

  // Haberin kısa açıklaması
  final String? description;

  // Haberin tam içeriği
  final String? content;

  // Haberin orijinal URL adresi
  final String? url;

  // Haber görseli URL adresi
  final String? imageUrl;

  // Haberin kaynağı (örn: "CNN Türk")
  final String? source;

  // Haberin yayınlanma tarihi (ISO 8601 formatında)
  final String? publishedAt;

  /// Article sınıfının yapıcı metodu.
  /// Tüm alanlar opsiyoneldir (nullable).
  const Article({
    this.id,
    this.title,
    this.description,
    this.content,
    this.url,
    this.imageUrl,
    this.source,
    this.publishedAt,
  });

  /// NewsAPI'den gelen JSON verisinden Article nesnesi oluşturur.
  ///
  /// NewsAPI yanıt formatı:
  /// ```json
  /// {
  ///   "source": {"id": null, "name": "Kaynak Adı"},
  ///   "title": "Başlık",
  ///   "description": "Açıklama",
  ///   "url": "https://...",
  ///   "urlToImage": "https://...",
  ///   "publishedAt": "2024-01-01T00:00:00Z",
  ///   "content": "İçerik..."
  /// }
  /// ```
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      // "source" alanı iç içe bir nesne olduğu için "name" anahtarını alıyoruz
      source: json['source'] != null ? json['source']['name'] as String? : null,
      title: json['title'] as String?,
      description: json['description'] as String?,
      content: json['content'] as String?,
      url: json['url'] as String?,
      // NewsAPI'de görsel URL alanı "urlToImage" olarak geliyor
      imageUrl: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String?,
    );
  }

  /// Veritabanından okunan Map verisinden Article nesnesi oluşturur.
  /// Sütun isimleri veritabanı tablo yapısına uygun şekilde eşleştirilir.
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as int?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      content: map['content'] as String?,
      url: map['url'] as String?,
      // Veritabanında "image_url" olarak saklanıyor
      imageUrl: map['image_url'] as String?,
      source: map['source'] as String?,
      // Veritabanında "published_at" olarak saklanıyor
      publishedAt: map['published_at'] as String?,
    );
  }

  /// Article nesnesini veritabanına kaydetmek için Map'e dönüştürür.
  /// [id] alanı otomatik artan olduğu için Map'e dahil edilmez.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      // Veritabanı sütun adı snake_case formatında
      'image_url': imageUrl,
      'source': source,
      'published_at': publishedAt,
    };
  }

  /// Article nesnesini JSON (Map) formatına dönüştürür.
  /// NewsAPI formatına uygun çıktı üretir.
  Map<String, dynamic> toJson() {
    return {
      'source': {'id': null, 'name': source},
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'urlToImage': imageUrl,
      'publishedAt': publishedAt,
    };
  }

  /// Nesnenin okunabilir metin temsilini döndürür (hata ayıklama için).
  @override
  String toString() {
    return 'Article(id: $id, title: $title, source: $source)';
  }
}
