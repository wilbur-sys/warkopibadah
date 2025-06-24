import 'package:flutter/material.dart'; // Paket inti Flutter untuk membangun UI
import 'screens/barang.dart'; // Mengimpor layar Daftar Barang (Harga Jual Barang)
import 'screens/belanja.dart'; // Mengimpor layar Daftar Belanja
import 'screens/bontoko.dart'; // Mengimpor layar BonToko (Harga Beli Barang)
import 'screens/profile.dart'; // Mengimpor layar Profil Pengguna

/// Widget [StatefulWidget] yang mengimplementasikan navigasi bilah bawah (BottomNavigationBar).
/// Ini mengelola layar yang sedang aktif dan judul AppBar berdasarkan pilihan pengguna.
class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  _BottomNavigationState createState() => _BottomNavigationState(); // Membuat State untuk widget ini.
}

/// State terkait dengan [BottomNavigation].
/// Ini mengelola indeks item yang dipilih, daftar widget layar, dan judul AppBar yang sesuai.
class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0; // Indeks item yang saat ini dipilih di BottomNavigationBar

  // Daftar widget layar yang akan ditampilkan saat item BottomNavigationBar dipilih.
  // Urutan di sini harus sesuai dengan urutan item di BottomNavigationBar.
  final List<Widget> _children = [
    const BarangScreen(title: 'Daftar Barang'), // Layar untuk menampilkan harga jual barang
    const Bontoko(), // Layar untuk menampilkan harga beli barang (BonToko)
    const BelanjaScreen(), // Layar untuk daftar belanja
    const ProfileScreen(), // Layar untuk profil pengguna
  ];

  // Daftar judul AppBar yang sesuai dengan setiap layar di `_children`.
  final List<String> _appBarTitles = [
    'Harga Jual Barang',
    'Harga Beli Barang',
    'Daftar Belanja',
    'Profil Pengguna', // Mengubah 'User' menjadi 'Profil Pengguna'
  ];

  // Gaya teks untuk judul AppBar.
  final TextStyle appBarTextStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black, // Menambahkan warna teks agar terlihat jelas di AppBar putih
  );

  /// Callback yang dipanggil saat pengguna mengetuk item di BottomNavigationBar.
  /// Memperbarui `_currentIndex` dan memicu rebuild widget.
  ///
  /// Parameter:
  /// - [index]: Indeks item yang ditekan.
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Perbarui indeks saat ini
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Menampilkan judul AppBar berdasarkan `_currentIndex`
        title: Center(
          child: Text(
            _appBarTitles[_currentIndex],
            style: appBarTextStyle,
          ),
        ),
        backgroundColor: Colors.white, // Warna latar belakang AppBar
        elevation: 0.5, // Sedikit bayangan di bawah AppBar
      ),
      body: IndexedStack(
        // Menggunakan IndexedStack untuk mempertahankan state layar saat beralih tab.
        // Hanya layar dengan `index` yang cocok dengan `_currentIndex` yang aktif.
        index: _currentIndex,
        children: _children, // Daftar widget layar
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Memastikan semua item terlihat dan ukurannya tetap
        backgroundColor: Colors.blueGrey[700], // Warna latar belakang BottomNavigationBar
        selectedItemColor: Colors.white, // Warna ikon dan label item yang dipilih
        unselectedItemColor: Colors.blueGrey[300], // Warna ikon dan label item yang tidak dipilih (diperbaiki agar lebih terlihat)
        onTap: onTabTapped, // Menghubungkan onTap dengan fungsi callback
        currentIndex: _currentIndex, // Menetapkan item yang saat ini dipilih
        showSelectedLabels: true, // Tampilkan label untuk item yang dipilih (diubah menjadi true untuk kejelasan)
        showUnselectedLabels: true, // Tampilkan label untuk item yang tidak dipilih (diubah menjadi true untuk kejelasan)
        iconSize: 28, // Ukuran ikon
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // Gaya label untuk item yang dipilih
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal), // Gaya label untuk item yang tidak dipilih
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store), // Ikon untuk Harga Jual Barang
            label: 'Jual', // Label singkat untuk BottomNavigationBar
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.price_check), // Ikon untuk Harga Beli Barang
            label: 'Beli', // Label singkat untuk BottomNavigationBar
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), // Ikon untuk Daftar Belanja
            label: 'Belanja', // Label singkat untuk BottomNavigationBar
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Ikon untuk Profil Pengguna (diubah menjadi Icons.person)
            label: 'Profil', // Label singkat untuk BottomNavigationBar
          ),
        ],
      ),
    );
  }
}
