import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

/// SharedPreferences tabanlı yerel veri depolama servis sınıfı.
/// Singleton tasarım deseni kullanılarak tek bir örnek üzerinden çalışır.
/// Hem mobil hem web platformlarında çalışarak kaydedilen haberlerin
/// uygulama kapatılıp açılsa bile kalıcı olmasını sağlar.
class DatabaseService {
  // Singleton örneği — uygulama boyunca tek bir DatabaseService nesnesi kullanılır
  static final DatabaseService _instance = DatabaseService._internal();

  // SharedPreferences anahtarı
  static const String _keySavedArticles = 'saved_articles';

  /// Factory constructor — her çağrıda aynı singleton örneğini döndürür.
  factory DatabaseService() {
    return _instance;
  }

  /// Özel dahili yapıcı metot — dışarıdan yeni örnek oluşturulmasını engeller.
  DatabaseService._internal();

  /// Kayıtlı haberleri SharedPreferences'tan okur.
  Future<List<Article>> _loadArticles() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_keySavedArticles);
      if (jsonString == null) return [];

      final List<dynamic> decoded = json.decode(jsonString);
      return decoded
          .map((item) => Article.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Haberler yüklenirken hata oluştu: $e');
      return [];
    }
  }

  /// Haber listesini SharedPreferences'a kaydeder.
  Future<void> _saveArticles(List<Article> articles) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        articles.map((article) => article.toMap()).toList(),
      );
      await prefs.setString(_keySavedArticles, jsonString);
    } catch (e) {
      print('Haberler kaydedilirken hata oluştu: $e');
    }
  }

  /// Bir haberi veritabanına kaydeder.
  /// [article] parametresi kaydedilecek haber nesnesini alır.
  Future<void> insertArticle(Article article) async {
    final List<Article> savedArticles = await _loadArticles();

    // Aynı URL'ye sahip haber zaten kaydedilmişse tekrar ekleme
    final alreadyExists = savedArticles.any((a) => a.url == article.url);
    if (alreadyExists) return;

    // Yeni haber için benzersiz bir ID bul (en büyük ID + 1)
    int maxId = 0;
    for (var a in savedArticles) {
      if (a.id != null && a.id! > maxId) {
        maxId = a.id!;
      }
    }
    final int newId = maxId + 1;

    // Yeni bir Article nesnesi oluştur (ID ekleyerek)
    final savedArticle = Article(
      id: newId,
      title: article.title,
      description: article.description,
      content: article.content,
      url: article.url,
      imageUrl: article.imageUrl,
      source: article.source,
      publishedAt: article.publishedAt,
    );

    savedArticles.add(savedArticle);
    await _saveArticles(savedArticles);
  }

  /// Kaydedilmiş tüm haberleri getirir.
  /// En son kaydedilen haber en üstte olacak şekilde sıralanır.
  Future<List<Article>> getSavedArticles() async {
    final List<Article> savedArticles = await _loadArticles();
    // Ters sırada döndür (son eklenen en üstte)
    return List.from(savedArticles.reversed);
  }

  /// Belirtilen ID'ye sahip haberi siler.
  /// [id] parametresi silinecek haberin birincil anahtarıdır.
  Future<void> deleteArticle(int id) async {
    final List<Article> savedArticles = await _loadArticles();
    savedArticles.removeWhere((article) => article.id == id);
    await _saveArticles(savedArticles);
  }

  /// Belirtilen URL'ye sahip haberin daha önce kaydedilip kaydedilmediğini kontrol eder.
  /// [url] parametresi kontrol edilecek haber URL'sidir.
  /// Kayıtlıysa true, değilse false döndürür.
  Future<bool> isArticleSaved(String url) async {
    final List<Article> savedArticles = await _loadArticles();
    return savedArticles.any((article) => article.url == url);
  }
}
