import 'package:flutter/material.dart';
import '../models/article.dart';

/// Haber kartı widget'ı.
/// Her bir haber makalesini liste içinde göstermek için kullanılır.
class ArticleCard extends StatelessWidget {
  /// Gösterilecek haber makalesi
  final Article article;

  /// Karta tıklandığında çalışacak callback
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Kartın gölge yüksekliği
      elevation: 2,
      // Yuvarlatılmış köşeler
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // Yatay ve dikey boşluklar
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Kartın köşelerine uygun kırpma
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Tıklama olayını dışarıya ilet
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Üst Kısım: Haber Görseli ---
            _buildImage(),
            // --- Alt Kısım: Başlık, Açıklama, Kaynak ve Tarih ---
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  /// Haber görselini oluşturur.
  /// Hero animasyonu ile detay sayfasına geçişte görsel animasyonu sağlar.
  Widget _buildImage() {
    return Hero(
      // Hero animasyonu için benzersiz etiket
      tag: article.url ?? '',
      child: ClipRRect(
        // Sadece üst köşeleri yuvarla (kart içinde olduğu için)
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: article.imageUrl != null && article.imageUrl!.isNotEmpty
              ? Image.network(
                  article.imageUrl!,
                  fit: BoxFit.cover,
                  // Görsel yüklenirken gösterilecek widget
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  // Görsel yüklenemezse gösterilecek widget
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              // Görsel URL'si yoksa varsayılan yer tutucu
              : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.newspaper,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// Kartın alt kısmını (başlık, açıklama, kaynak, tarih) oluşturur.
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Haber Başlığı ---
          Text(
            article.title ?? 'Başlık yok',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // --- Haber Açıklaması ---
          Text(
            article.description ?? 'Açıklama bulunmuyor.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // --- Kaynak ve Tarih Satırı ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kaynak adı (sol taraf)
              _buildSourceChip(),
              // Yayın tarihi (sağ taraf)
              _buildDateInfo(),
            ],
          ),
        ],
      ),
    );
  }

  /// Haber kaynağını ikon ile birlikte gösterir.
  Widget _buildSourceChip() {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kaynak ikonu
          const Icon(
            Icons.source,
            size: 14,
            color: Colors.blue,
          ),
          const SizedBox(width: 4),
          // Kaynak adı metni
          Flexible(
            child: Text(
              article.source ?? 'Bilinmeyen kaynak',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Yayın tarihini ikon ile birlikte gösterir.
  Widget _buildDateInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Saat ikonu
        Icon(
          Icons.access_time,
          size: 14,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        // Tarih metni
        Text(
          _formatDate(article.publishedAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  /// Tarih string'ini kullanıcı dostu formata çevirir.
  /// Örnek: "2026-06-08T18:00:00Z" -> "08.06.2026"
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Tarih yok';
    }
    try {
      final date = DateTime.parse(dateString);
      // Gün.Ay.Yıl formatında göster
      return '${date.day.toString().padLeft(2, '0')}.'
          '${date.month.toString().padLeft(2, '0')}.'
          '${date.year}';
    } catch (e) {
      // Tarih ayrıştırılamazsa orijinal metni döndür
      return dateString;
    }
  }
}
