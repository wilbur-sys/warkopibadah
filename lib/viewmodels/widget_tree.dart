// lib/widget_tree.dart
import 'package:flutter/material.dart';
import 'package:warkopibadah/repositories/auth_repository.dart'; // Mengimpor AuthRepository yang baru
import 'package:warkopibadah/views/login_view.dart';

import '../views/bottomnavigation.dart';

/// Widget ini bertindak sebagai "pohon widget" utama
/// yang menentukan layar mana yang harus ditampilkan kepada pengguna
/// berdasarkan status otentikasi.
class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

/// State terkait dengan [WidgetTree].
class _WidgetTreeState extends State<WidgetTree> {
  // Buat instance dari AuthRepository yang akan kita gunakan.
  final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    // StreamBuilder mendengarkan perubahan pada stream authStateChanges.
    // Stream ini berasal dari AuthRepository.
    return StreamBuilder(
      stream: _authRepository.authStateChanges,
      builder: (context, snapshot) {
        // Tampilkan indikator loading jika status koneksi masih menunggu.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika snapshot memiliki data (yaitu ada pengguna yang login),
        // tampilkan layar Home.
        if (snapshot.hasData) {
          return const BottomNavigation(); // Menggunakan BottomNavigation sebagai layar utama
        } else {
          // Jika tidak ada data pengguna, tampilkan layar LoginPage.
          return const LoginView();
        }
      },
    );
  }
}
