import 'package:firebase_core/firebase_core.dart'; // Mengimpor paket Firebase Core untuk inisialisasi Firebase
import 'package:flutter/material.dart'; // Mengimpor paket inti Flutter untuk membangun UI
import 'package:provider/provider.dart'; // Import paket provider untuk state management
import 'package:warkopibadah/firebase_options.dart'; // Mengimpor file konfigurasi Firebase yang dihasilkan
import 'package:warkopibadah/viewmodels/harga_jual_barang_viewmodel.dart'; // Import ViewModel yang dibutuhkan
import 'viewmodels/belanja_viewmodel.dart';
import 'viewmodels/harga_beli_barang_viewmodel.dart';
import 'viewmodels/widget_tree.dart'; // Mengimpor widget WidgetTree, yang menangani logika otentikasi dan navigasi
import 'package:intl/date_symbol_data_local.dart'; // Mengimpor pustaka intl untuk inisialisasi data simbol tanggal lokal

/// Fungsi utama aplikasi Flutter.
/// Fungsi ini adalah titik masuk pertama saat aplikasi dijalankan.
/// Ini bertanggung jawab untuk inisialisasi layanan-layanan penting
/// sebelum aplikasi UI dimulai.
void main() async {
  // Memastikan bahwa semua binding widget Flutter telah diinisialisasi.
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data simbol tanggal untuk lokal 'id_ID' (Bahasa Indonesia).
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Menjalankan aplikasi Flutter dengan widget MyApp sebagai akar.
  // MyApp sekarang dibungkus dengan MultiProvider untuk menyediakan semua
  // ViewModel yang dibutuhkan oleh aplikasi.
  runApp(const MyApp());
}

/// Widget akar dari aplikasi Flutter.
/// Ini adalah [StatelessWidget] karena tidak memiliki state yang dapat berubah secara internal.
/// Ini mengatur tema aplikasi dan menetapkan [WidgetTree] sebagai layar utama.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membungkus seluruh aplikasi dengan MultiProvider agar semua widget di bawahnya
    // dapat mengakses ViewModel yang disediakan.
    return MultiProvider(
      providers: [
        // Menyediakan HargaJualBarangViewModel di tingkat teratas agar
        // dapat diakses oleh HargaJualBarangView dan widget lainnya.
        ChangeNotifierProvider(create: (_) => HargaJualBarangViewModel()),
        ChangeNotifierProvider(create: (_) => HargaBeliBarangViewModel()),
        ChangeNotifierProvider(create: (_) => BelanjaViewModel()),
        // Tambahkan Provider untuk ViewModel lain di sini jika diperlukan.
      ],
      child: MaterialApp(
        // Judul aplikasi yang akan ditampilkan di pengelola tugas perangkat atau browser web.
        title: 'Aplikasi Manajemen WarungKopi Ibadah',
        // Debug banner dihilangkan untuk tampilan yang lebih bersih di mode debug.
        debugShowCheckedModeBanner: false,
        // Mengatur tema visual aplikasi.
        theme: ThemeData(
          // Menentukan ColorScheme dari seed color.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
          ),
        ),
        // Menetapkan WidgetTree sebagai layar beranda (home) aplikasi.
        home: const WidgetTree(),
      ),
    );
  }
}
