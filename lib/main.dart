import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';

/// Uygulamanın başlangıç noktası.
/// Flutter motor bağlantısını başlatır ve uygulamayı çalıştırır.
void main() async {
  // Widget bağlantısının başlatıldığından emin ol
  // (async işlemler veya plugin'ler için gerekli)
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatlama desteğini başlat
  await initializeDateFormatting('tr_TR', null);

  runApp(const HaberApp());
}

/// HaberApp - Ana uygulama widget'ı.
/// Material Design 3 tema sistemi ile açık ve koyu tema desteği sunar.
class HaberApp extends StatelessWidget {
  const HaberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Uygulama başlığı
      title: 'HaberApp',

      // Sağ üst köşedeki debug bandını gizle
      debugShowCheckedModeBanner: false,

      // --- Açık Tema Ayarları ---
      theme: ThemeData(
        // Material Design 3 kullan
        useMaterial3: true,
        // Koyu mavi seed renkten renk şeması oluştur
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Koyu mavi
          brightness: Brightness.light,
        ),
      ),

      // --- Koyu Tema Ayarları ---
      darkTheme: ThemeData(
        // Material Design 3 kullan
        useMaterial3: true,
        // Aynı seed renk ile koyu tema renk şeması oluştur
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Koyu mavi
          brightness: Brightness.dark,
        ),
      ),

      // Sistem ayarına göre açık/koyu tema arasında otomatik geçiş yap
      themeMode: ThemeMode.system,

      // Ana ekranı başlat
      home: const HomeScreen(),
    );
  }
}
