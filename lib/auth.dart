import 'package:firebase_auth/firebase_auth.dart'; // Mengimpor paket Firebase Authentication

/// Kelas [Auth] menyediakan layanan untuk mengelola otentikasi pengguna
/// menggunakan Firebase Authentication. Kelas ini membungkus fungsionalitas
/// FirebaseAuth untuk memudahkan interaksi dengan sistem otentikasi.
class Auth {
  // Instance tunggal dari FirebaseAuth, digunakan untuk berinteraksi dengan layanan otentikasi.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Getter untuk mendapatkan objek [User] yang sedang login saat ini.
  /// Mengembalikan `null` jika tidak ada pengguna yang sedang login.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Getter untuk mendapatkan [Stream] perubahan status otentikasi.
  /// Ini memancarkan objek [User] setiap kali status login berubah (masuk, keluar, registrasi).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Metode asinkron untuk masuk (sign in) pengguna dengan email dan kata sandi.
  ///
  /// Parameter:
  /// - [email]: Alamat email pengguna.
  /// - [password]: Kata sandi pengguna.
  ///
  /// Melemparkan [FirebaseAuthException] jika otentikasi gagal (misalnya, kredensial salah).
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Memanggil metode signInWithEmailAndPassword dari instance FirebaseAuth.
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Metode asinkron untuk membuat pengguna baru dengan email dan kata sandi.
  ///
  /// Parameter:
  /// - [email]: Alamat email pengguna baru.
  /// - [password]: Kata sandi untuk pengguna baru.
  ///
  /// Melemparkan [FirebaseAuthException] jika pembuatan pengguna gagal (misalnya, email sudah digunakan).
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Memanggil metode createUserWithEmailAndPassword dari instance FirebaseAuth.
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Metode asinkron untuk keluar (sign out) pengguna yang sedang login.
  ///
  /// Setelah metode ini selesai, `currentUser` akan menjadi `null` dan
  /// `authStateChanges` akan memancarkan event `null`.
  Future<void> signOut() async {
    // Memanggil metode signOut dari instance FirebaseAuth.
    await _firebaseAuth.signOut();
  }
}
