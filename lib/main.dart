import 'package:firebase_core/firebase_core.dart'; // Mengimpor paket Firebase Core untuk inisialisasi Firebase
import 'package:flutter/material.dart'; // Mengimpor paket inti Flutter untuk membangun UI
import 'package:warkopibadah/firebase_options.dart'; // Mengimpor file konfigurasi Firebase yang dihasilkan
import 'widget_tree.dart'; // Mengimpor widget WidgetTree, yang menangani logika otentikasi dan navigasi
import 'package:intl/date_symbol_data_local.dart'; // Mengimpor pustaka intl untuk inisialisasi data simbol tanggal lokal

/// Fungsi utama aplikasi Flutter.
/// Fungsi ini adalah titik masuk pertama saat aplikasi dijalankan.
/// Ini bertanggung jawab untuk inisialisasi layanan-layanan penting
/// sebelum aplikasi UI dimulai.
void main() async {
  // Memastikan bahwa semua binding widget Flutter telah diinisialisasi.
  // Ini diperlukan sebelum memanggil metode yang membutuhkan binding seperti Firebase.initializeApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data simbol tanggal untuk lokal 'id_ID' (Bahasa Indonesia).
  // Ini penting agar pemformatan tanggal di seluruh aplikasi (misalnya, di intl.DateFormat)
  // sesuai dengan st r Bahasa Indonesia.
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Firebase.
  // Menggunakan DefaultFirebaseOptions.currentPlatform untuk secara otomatis
  // memuat konfigurasi Firebase yang benar berdasarkan platform yang sedang berjalan.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Menjalankan aplikasi Flutter dengan widget MyApp sebagai akar.
  // const MyApp() digunakan untuk performa yang lebih baik karena widget tidak akan berubah.
  runApp(const MyApp());
}

/// Widget akar dari aplikasi Flutter.
/// Ini adalah [StatelessWidget] karena tidak memiliki state yang dapat berubah secara internal.
/// Ini mengatur tema aplikasi dan menetapkan [WidgetTree] sebagai layar ber .
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Judul aplikasi yang akan ditampilkan di pengelola tugas perangkat atau browser web.
      title: 'Aplikasi Manajemen WarungKopi Ibadah', // Mengubah judul aplikasi
      // Debug banner dihilangkan untuk tampilan yang lebih bersih di mode debug.
      debugShowCheckedModeBanner: false,
      // Mengatur tema visual aplikasi.
      theme: ThemeData(
        // Menentukan ColorScheme dari seed color. Ini akan menghasilkan palet warna Material Design 3.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent), // Mengubah seedColor menjadi biru
        useMaterial3: true, // Mengaktifkan Material Design 3
        appBarTheme: const AppBarTheme( // Tema untuk semua AppBar di aplikasi
          backgroundColor: Colors.white, // Latar belakang AppBar putih
          foregroundColor: Colors.black, // Warna ikon dan teks di AppBar hitam
          elevation: 0.5, // Sedikit bayangan di bawah AppBar
        ),
      ),
      // Menetapkan WidgetTree sebagai layar ber  (home) aplikasi.
      // WidgetTree bertanggung jawab untuk mengarahkan pengguna ke halaman login atau home
      // berdasarkan status otentikasi mereka.
      home: const WidgetTree(),
    );
  }
}
