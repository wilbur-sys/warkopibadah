import 'package:flutter/material.dart'; // Paket inti Flutter untuk membangun UI
import 'package:firebase_auth/firebase_auth.dart'; // Paket untuk otentikasi Firebase (mengakses objek User)
import 'package:warkopibadah/auth.dart'; // Mengimpor kelas 'Auth' kustom   untuk operasi otentikasi

/// Widget [StatefulWidget] untuk menampilkan layar profil pengguna.
/// Layar ini menampilkan informasi pengguna (misalnya, email) dan tombol keluar.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({ super.key });

  @override
  _ProfileScreenState createState() => _ProfileScreenState(); // Membuat State untuk widget ini.
}

/// State terkait dengan [ProfileScreen].
/// Ini mengelola informasi pengguna dan logika untuk keluar (sign out).
class _ProfileScreenState extends State<ProfileScreen> {

  // Mendapatkan objek pengguna saat ini dari instance Auth().
  // Objek User akan null jika tidak ada pengguna yang masuk.
  final User? user = Auth().currentUser;

  /// Fungsi asinkron untuk melakukan proses keluar (sign out) dari Firebase.
  /// Setelah keluar, pengguna akan diarahkan ke layar otentikasi.
  Future<void> signOut() async {
    try {
      await Auth().signOut(); // Memanggil metode signOut dari kelas Auth
    } catch (e) {
      // Tangani kesalahan jika proses keluar gagal (misalnya, masalah koneksi)
      print("Error saat keluar: $e");
      //   bisa menampilkan Snackbar atau AlertDialog kepada pengguna di sini
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal keluar: $e')),
      );
    }
  }

  /// Widget pembangun untuk menampilkan ID pengguna (email).
  /// Menampilkan email pengguna jika tersedia, jika tidak, menampilkan 'Email Pengguna'.
  Widget _userId() {
    return Text(
      user?.email ?? 'Email Pengguna', // Menggunakan operator null-aware dan coalescing null
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Menambahkan gaya teks
    );
  }

  /// Widget pembangun untuk tombol keluar (Sign Out).
  /// Saat ditekan, tombol ini akan memanggil fungsi `signOut()`.
  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut, // Menghubungkan onPressed dengan fungsi signOut
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Warna latar belakang tombol merah
        foregroundColor: Colors.white, // Warna teks tombol putih
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // Padding tombol
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Sudut tombol membulat
        ),
      ),
      child: const Text(
        'Keluar', // Teks tombol dalam Bahasa Indonesia
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'), // Judul AppBar dalam Bahasa Indonesia
        backgroundColor: Colors.blueAccent, // Warna latar belakang AppBar
        foregroundColor: Colors.white, // Warna teks di AppBar
      ),
      body: Container(
        height: double.infinity, // Tinggi kontainer mengisi seluruh ruang vertikal yang tersedia
        width: double.infinity, // Lebar kontainer mengisi seluruh ruang horizontal yang tersedia
        padding: const EdgeInsets.all(20), // Padding di sekitar konten kontainer
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan children secara horizontal
          mainAxisAlignment: MainAxisAlignment.center, // Pusatkan children secara vertikal
          children: <Widget>[
            const Icon(
              Icons.person_outline, // Ikon profil
              size: 80, // Ukuran ikon
              color: Colors.blueAccent, // Warna ikon
            ),
            const SizedBox(height: 20), // Spasi vertikal
            _userId(), // Menampilkan email pengguna
            const SizedBox(height: 30), // Spasi vertikal
            _signOutButton(), // Menampilkan tombol keluar
          ],
        ),
      ),
    );
  }
}
