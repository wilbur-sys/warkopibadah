import 'package:flutter/material.dart'; // Paket inti Flutter untuk membangun UI
import 'package:warkopibadah/home.dart'; // Mengimpor widget Home (layar ber  setelah login)
import 'package:warkopibadah/login.dart'; // Mengimpor widget LoginPage (layar otentikasi)
import 'auth.dart'; // Mengimpor kelas Auth kustom   untuk memantau status otentikasi

/// Widget [StatefulWidget] ini bertindak sebagai "pohon widget" utama
/// yang menentukan layar mana yang harus ditampilkan kepada pengguna.
/// Ini memantau status otentikasi pengguna dan mengarahkan mereka
/// ke [Home] jika sudah masuk, atau ke [LoginPage] jika belum.
class WidgetTree extends StatefulWidget {
  const WidgetTree({ super.key });

  @override
  _WidgetTreeState createState() => _WidgetTreeState(); // Membuat State untuk widget ini.
}

/// State terkait dengan [WidgetTree].
/// Ini mengelola aliran UI berdasarkan status otentikasi pengguna.
class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    // StreamBuilder mendengarkan perubahan pada stream `authStateChanges` dari kelas Auth.
    // Stream ini memancarkan objek User setiap kali status otentikasi berubah (login/logout).
    return StreamBuilder(
      stream: Auth().authStateChanges, // Mendengarkan perubahan status otentikasi
      builder: (context, snapshot) {
        // Tampilkan indikator loading jika status otentikasi masih menunggu.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Jika `snapshot.hasData` adalah true, berarti ada pengguna yang masuk.
        // Tampilkan layar Home.
        if (snapshot.hasData) {
          return const Home(title: 'Warkop Ibadah'); // Arahkan ke Home Screen
        } else {
          // Jika tidak ada data pengguna (null), berarti tidak ada pengguna yang masuk.
          // Tampilkan layar LoginPage.
          return const LoginPage(); // Arahkan ke Login Page
        }
      },
    );
  }
}
