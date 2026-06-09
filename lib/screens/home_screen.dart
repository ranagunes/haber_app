import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../widgets/article_card.dart';
import 'detail_screen.dart';
import 'saved_screen.dart';

/// Ana sayfa ekranı.
/// Kategorilere göre haberleri listeler, pull-to-refresh destekler.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // API servisi örneği
  final ApiService _apiService = ApiService();

  // Şu anda seçili olan kategori
  String _selectedCategory = 'general';

  // Haber listesini tutan Future
  late Future<List<Article>> _articlesFuture;

  // Kullanıcıya gösterilecek kategori etiketleri ve API anahtarları
  final List<Map<String, String>> _categories = [
    {'label': 'Genel', 'value': 'general'},
    {'label': 'Teknoloji', 'value': 'technology'},
    {'label': 'Spor', 'value': 'sports'},
    {'label': 'Sağlık', 'value': 'health'},
    {'label': 'Bilim', 'value': 'science'},
    {'label': 'Eğlence', 'value': 'entertainment'},
  ];

  @override
  void initState() {
    super.initState();
    // İlk yüklemede varsayılan kategoriyle haberleri çek
    _articlesFuture = _fetchArticles();
  }

  /// Seçili kategoriye göre haberleri API'den çeker.
  Future<List<Article>> _fetchArticles() {
    return _apiService.fetchArticles(category: _selectedCategory);
  }

  /// Kategori değiştiğinde haberleri yeniden yükler.
  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _articlesFuture = _fetchArticles();
    });
  }

  /// Pull-to-refresh ile haberleri yeniler.
  Future<void> _refreshArticles() async {
    setState(() {
      _articlesFuture = _fetchArticles();
    });
    // Future'ın tamamlanmasını bekle
    await _articlesFuture;
  }

  @override
  Widget build(BuildContext context) {
    // Tema renklerine erişim
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // --- Üst Uygulama Çubuğu ---
      appBar: AppBar(
        title: Text(
          'HaberApp',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        centerTitle: false,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        // Sağ üstte kaydedilen haberlere gitme butonu
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmarks_rounded,
              color: colorScheme.onPrimary,
            ),
            tooltip: 'Kaydedilen Haberler',
            onPressed: () {
              // Kaydedilenler ekranına geçiş
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Kategori Seçim Çubuğu ---
          _buildCategoryBar(colorScheme),

          // --- Haber Listesi ---
          Expanded(
            child: _buildArticleList(colorScheme, textTheme),
          ),
        ],
      ),
    );
  }

  /// Yatay kaydırılabilir kategori seçim çubuğunu oluşturur.
  Widget _buildCategoryBar(ColorScheme colorScheme) {
    return Container(
      // Kategori çubuğu arka plan dekorasyonu
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Yatay kaydırma fizik efekti
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _categories.map((category) {
            // Kategori seçili mi kontrolü
            final isSelected = _selectedCategory == category['value'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                // Seçili duruma göre Material 3 chip görünümü
                label: Text(
                  category['label']!,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => _onCategoryChanged(category['value']!),
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainerHighest,
                checkmarkColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide.none,
                elevation: isSelected ? 2 : 0,
                pressElevation: 4,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// FutureBuilder ile haber listesini oluşturur.
  /// Yükleme, hata ve veri durumlarını yönetir.
  Widget _buildArticleList(ColorScheme colorScheme, TextTheme textTheme) {
    return FutureBuilder<List<Article>>(
      future: _articlesFuture,
      builder: (context, snapshot) {
        // --- Yükleniyor Durumu ---
        if (snapshot.connectionState == ConnectionState.waiting) {
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
                  'Haberler yükleniyor...',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        // --- Hata Durumu ---
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Haberler yüklenirken bir hata oluştu',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  // Yeniden deneme butonu
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _articlesFuture = _fetchArticles();
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Yeniden Dene'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // --- Veri Mevcut Durumu ---
        final articles = snapshot.data ?? [];

        // Haber bulunamadıysa boş durum göster
        if (articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bu kategoride haber bulunamadı',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        // Pull-to-refresh ile sarmalanmış haber listesi
        return RefreshIndicator(
          onRefresh: _refreshArticles,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: ListView.builder(
            // Kaydırma performansı için fizik ayarı
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];

              return ArticleCard(
                article: article,
                onTap: () {
                  // Habere tıklanınca detay ekranına git
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(article: article),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
