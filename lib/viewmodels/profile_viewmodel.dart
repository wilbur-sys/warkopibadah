// lib/viewmodels/profile_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

/// ProfileViewModel bertanggung jawab untuk mengelola logika
/// dan state untuk ProfileScreen.
/// Ia berkomunikasi dengan AuthRepository untuk melakukan sign out.
class ProfileViewModel with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  /// Mengakses objek pengguna saat ini melalui repositori.
  /// Ini adalah cara yang lebih bersih daripada memanggil FirebaseAuth langsung.
  User? get currentUser => _authRepository.currentUser;

  /// Melakukan proses keluar (sign out) pengguna.
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } on Exception catch (e) {
      // Menangani error jika ada, dan menyampaikannya ke UI.
      // Anda bisa menambahkan logika state error di sini jika diperlukan.
      print("Error saat keluar: $e");
    }
  }
}
