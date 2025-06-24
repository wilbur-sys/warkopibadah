import 'package:flutter/material.dart'; // Paket inti Flutter untuk membangun UI
// import 'package:cloud_firestore/cloud_firestore.dart'; // Paket untuk Firebase Firestore (dikomentari karena tidak langsung digunakan di sini)
import 'package:warkopibadah/bottomnavigation.dart'; // Mengimpor widget BottomNavigation kustom  
// import 'widget/appbar.dart'; // Mengimpor widget AppBar kustom   (dikomentari karena tidak langsung digunakan di sini)

/// Widget [StatefulWidget] yang merepresentasikan layar ber  utama aplikasi.
/// Layar ini berfungsi sebagai wadah untuk `BottomNavigation`, yang mengelola
/// tampilan berbagai layar utama aplikasi.
class Home extends StatefulWidget {
  // Konstruktor untuk Home. Key adalah parameter opsional yang membantu Flutter dalam mengidentifikasi widget.
  // [title] diperlukan untuk judul layar, meskipun mungkin tidak secara langsung digunakan jika AppBar ditangani oleh BottomNavigation.
  const Home({super.key, required this.title});

  final String title; // Judul untuk layar, bisa digunakan di AppBar (jika ada).

  @override
  _HomeState createState() => _HomeState(); // Membuat State untuk widget ini.
}

/// State terkait dengan [Home].
/// Saat ini, state ini sangat sederhana dan hanya membangun `BottomNavigation`.
class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Body dari Scaffold adalah BottomNavigation, yang akan menangani
      // tampilan berbagai layar dan AppBar-nya sendiri.
      body: BottomNavigation(),
      // Baris berikut dikomentari karena AppBar dan BottomNavigationBar
      // sekarang dikelola di dalam widget BottomNavigation itu sendiri,
      // untuk struktur yang lebih bersih dan kohesif.
      // appBar: const MyAppBar(title: 'Warkop Ibadah'),
      // bottomNavigationBar: const BottomNavigationbar()
    );
  }
}
