import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';
import '../services/database_service.dart';

/// Haber detay ekranı.
/// Seçilen haberin tüm bilgilerini gösterir, kaydetme ve
/// tarayıcıda açma işlevlerini sunar.
class DetailScreen extends StatefulWidget {
  // Gösterilecek haber makalesi
  final Article article;

  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Veritabanı servisi
  final DatabaseService _databaseService = DatabaseService();

  // Haberin kaydedilip kaydedilmediğini tutar
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    // Ekran yüklendiğinde haberin kaydedilmiş olup olmadığını kontrol et
    _checkIfSaved();
  }

  /// Haberin veritabanında kayıtlı olup olmadığını kontrol eder.
  Future<void> _checkIfSaved() async {
    if (widget.article.url == null) return;
    final saved = await _databaseService.isArticleSaved(widget.article.url!);
    if (mounted) {
      setState(() {
        _isSaved = saved;
      });
    }
  }

  /// Haberi kaydeder veya kaydedilenlerden kaldırır.
  Future<void> _toggleSave() async {
    try {
      if (_isSaved) {
        // URL'ye göre haberi bul ve sil
        // Önce kaydedilen haberleri çek, URL'ye göre eşleşeni bul
        final savedArticles = await _databaseService.getSavedArticles();
        final savedArticle = savedArticles.firstWhere(
          (a) => a.url == widget.article.url,
        );
        if (savedArticle.id != null) {
          await _databaseService.deleteArticle(savedArticle.id!);
        }
        setState(() => _isSaved = false);

        // Silme bildirim mesajı
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Haber kaydedilenlerden kaldırıldı'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Haberi veritabanına kaydet
        await _databaseService.insertArticle(widget.article);
        setState(() => _isSaved = true);

        // Kaydetme bildirim mesajı
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Haber kaydedildi'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Hata durumunda kullanıcıyı bilgilendir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İşlem sırasında hata oluştu: $e'),
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

  /// Haberin orijinal kaynağını tarayıcıda açar.
  Future<void> _openInBrowser() async {
    if (widget.article.url == null) return;
    final uri = Uri.parse(widget.article.url!);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // URL açılamadıysa kullanıcıyı bilgilendir
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bağlantı açılamadı'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarayıcı açılırken hata oluştu: $e'),
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

  /// Tarih metnini Türkçe formatta biçimlendirir.
  /// Örnek çıktı: "08 Haziran 2026, 21:30"
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Tarih bilinmiyor';
    }
    try {
      final dateTime = DateTime.parse(dateString);
      // Türkçe locale ile tarih formatlama
      final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR');
      return formatter.format(dateTime);
    } catch (e) {
      // Geçersiz tarih formatı durumunda ham veriyi göster
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final article = widget.article;

    return Scaffold(
      // Gövde içeriği
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- Üst Kısım: Görsel ve Geri Butonu ---
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(article, colorScheme),
            ),
          ),

          // --- İçerik Alanı ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kaynak adı etiketi
                  if (article.source != null && article.source!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        article.source!,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // --- Haber Başlığı ---
                  Text(
                    article.title ?? 'Başlık yok',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // --- Kaynak ve Tarih Bilgisi ---
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDate(article.publishedAt),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Ayırıcı çizgi
                  Divider(
                    color: colorScheme.outlineVariant,
                    thickness: 1,
                  ),

                  const SizedBox(height: 20),

                  // --- Haber Açıklaması ---
                  if (article.description != null &&
                      article.description!.isNotEmpty)
                    Text(
                      article.description!,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  if (article.description != null &&
                      article.description!.isNotEmpty)
                    const SizedBox(height: 16),

                  // --- Haber İçeriği ---
                  if (article.content != null && article.content!.isNotEmpty)
                    Text(
                      article.content!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.7,
                      ),
                    ),

                  // Alt butonlar için boşluk
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // --- Alt Butonlar ---
      bottomNavigationBar: _buildBottomActions(colorScheme, textTheme),
    );
  }

  /// Üstteki Hero animasyonlu haber görselini oluşturur.
  Widget _buildHeroImage(Article article, ColorScheme colorScheme) {
    return Hero(
      // Hero animasyonu için benzersiz etiket
      tag: article.url ?? '',
      child: article.imageUrl != null && article.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Image.network(
                article.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                // Görsel yüklenirken gösterilecek placeholder
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: colorScheme.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                // Görsel yüklenemezse placeholder göster
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder(colorScheme);
                },
              ),
            )
          : ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: _buildImagePlaceholder(colorScheme),
            ),
    );
  }

  /// Görsel bulunamadığında gösterilecek placeholder widget.
  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Görsel mevcut değil',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Alt kısımdaki kaydet ve haberi oku butonlarını oluşturur.
  Widget _buildBottomActions(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      // Alt çubuk dekorasyonu
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        children: [
          // --- Kaydet / Kaldır Butonu ---
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _toggleSave,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  key: ValueKey(_isSaved),
                  color: _isSaved
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              label: Text(
                _isSaved ? 'Kaydedildi' : 'Kaydet',
                style: TextStyle(
                  color: _isSaved
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: _isSaved
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // --- Haberi Oku Butonu ---
          Expanded(
            child: FilledButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_browser_rounded),
              label: const Text(
                'Haberi Oku',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
