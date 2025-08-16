// lib/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AuthRepository bertanggung jawab atas semua interaksi dengan
/// Firebase Authentication dan penyimpanan lokal (SharedPreferences).
/// Ini memusatkan logika otentikasi dan penyimpanan data.
class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Getter untuk mendapatkan objek pengguna yang sedang login saat ini.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream yang menyediakan status otentikasi pengguna saat ini.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Metode asinkron untuk masuk pengguna dengan email dan kata sandi.
  /// Melemparkan exception jika otentikasi gagal.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      // Panggil fungsi untuk menyimpan atau menghapus kredensial
      await _manageRememberMe(email, password, rememberMe);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Metode asinkron untuk mendaftar pengguna baru.
  /// Melemparkan exception jika pendaftaran gagal.
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Metode asinkron untuk keluar pengguna.
  Future<void> signOut() async {
    // Hapus kredensial dari SharedPreferences saat keluar
    // BUG FIX: Baris ini dikomentari agar "Ingat Saya" berfungsi.
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('email');
    // await prefs.remove('password');
    await _firebaseAuth.signOut();
  }

  /// Mengelola penyimpanan kredensial "ingat saya".
  Future<void> _manageRememberMe(String email, String password, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  /// Mengambil kredensial yang tersimpan dari SharedPreferences.
  Future<Map<String, String>> getRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final password = prefs.getString('password') ?? '';
    return {'email': email, 'password': password};
  }
}
