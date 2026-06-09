import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/database_service.dart';
import '../widgets/article_card.dart';
import 'detail_screen.dart';

/// Kaydedilen haberler ekranı.
/// Kullanıcının kaydettiği haberleri listeler,
/// sola kaydırarak silme ve detay görüntüleme işlevlerini sunar.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  // Veritabanı servisi
  final DatabaseService _databaseService = DatabaseService();

  // Kaydedilen haber listesi
  List<Article> _savedArticles = [];

  // Yükleme durumu kontrolü
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Ekran açıldığında kaydedilen haberleri yükle
    _loadSavedArticles();
  }

  /// Veritabanından kaydedilen haberleri çeker.
  Future<void> _loadSavedArticles() async {
    setState(() => _isLoading = true);

    try {
      final articles = await _databaseService.getSavedArticles();
      setState(() {
        _savedArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Hata durumunda kullanıcıyı bilgilendir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Haberler yüklenirken hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  /// Bir haberi kaydedilenlerden siler.
  Future<void> _deleteArticle(Article article, int index) async {
    try {
      if (article.id != null) {
        await _databaseService.deleteArticle(article.id!);
      }

      setState(() {
        _savedArticles.removeAt(index);
      });

      // Silme bildirim mesajı ve geri alma seçeneği
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Haber kaydedilenlerden silindi'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Geri Al',
              textColor: Theme.of(context).colorScheme.onSecondary,
              onPressed: () async {
                // Silinen haberi tekrar kaydet
                await _databaseService.insertArticle(article);
                _loadSavedArticles();
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme işlemi başarısız: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // --- Üst Uygulama Çubuğu ---
      appBar: AppBar(
        title: Text(
          'Kaydedilen Haberler',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),

      // --- Gövde İçeriği ---
      body: _buildBody(colorScheme, textTheme),
    );
  }

  /// Ekran gövdesini duruma göre oluşturur.
  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    // Yükleniyor durumu
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Kaydedilen haberler yükleniyor...',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Liste boş durumu
    if (_savedArticles.isEmpty) {
      return _buildEmptyState(colorScheme, textTheme);
    }

    // Haber listesi
    return _buildArticleList(colorScheme);
  }

  /// Liste boş olduğunda gösterilecek bilgilendirme ekranı.
  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Boş durum ikonu
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 72,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            // Bilgilendirme başlığı
            Text(
              'Henüz kaydedilmiş haber yok',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Bilgilendirme açıklaması
            Text(
              'Beğendiğiniz haberleri kaydedin,\nburada görüntüleyin.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Kaydedilen haberlerin listesini oluşturur.
  /// Dismissible widget ile sola kaydırarak silme desteği sağlar.
  Widget _buildArticleList(ColorScheme colorScheme) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: _savedArticles.length,
      itemBuilder: (context, index) {
        final article = _savedArticles[index];

        return Dismissible(
          // Her haber için benzersiz anahtar
          key: Key(article.url ?? index.toString()),
          // Sadece sola (sağdan sola) kaydırma
          direction: DismissDirection.endToStart,
          // Kaydırma arka planı - kırmızı silme gösterimi
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.onError,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sil',
                  style: TextStyle(
                    color: colorScheme.onError,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Silme onayı
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Haberi Sil'),
                content: const Text(
                  'Bu haberi kaydedilenlerden silmek istediğinize emin misiniz?',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('İptal'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    child: const Text('Sil'),
                  ),
                ],
              ),
            );
          },
          // Kaydırma tamamlandığında silme işlemini gerçekleştir
          onDismissed: (_) => _deleteArticle(article, index),
          child: ArticleCard(
            article: article,
            onTap: () {
              // Detay ekranına git, geri dönüşte listeyi yenile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(article: article),
                ),
              ).then((_) {
                // DetailScreen'den dönüldüğünde listeyi güncelle
                // (kullanıcı detay ekranında haberi silmiş olabilir)
                _loadSavedArticles();
              });
            },
          ),
        );
      },
    );
  }
}
