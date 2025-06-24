import 'package:cloud_firestore/cloud_firestore.dart'; // Paket untuk Firebase Firestore (database NoSQL)
import 'package:flutter/material.dart'; // Paket inti Flutter untuk membangun UI
import 'package:intl/intl.dart'; // Paket untuk pemformatan tanggal dan waktu internasional
import 'package:firebase_core/firebase_core.dart'; // Paket untuk inisialisasi Firebase

/// Fungsi asinkron untuk menambahkan catatan pembelian baru ke koleksi 'purchases' di Firestore.
///
/// Parameter:
/// - [itemName]: Nama item yang dibeli (String).
/// - [purchaseDate]: Tanggal pembelian item (DateTime).
///
/// Data tanggal secara otomatis dikonversi ke Firestore Timestamp.
Future<void> addPurchase(String itemName, DateTime purchaseDate) async {
  try {
    await FirebaseFirestore.instance.collection('purchases').add({
      'item_name': itemName,
      'purchase_date': Timestamp.fromDate(purchaseDate), // Konversi DateTime ke Timestamp Firestore
    });
    print('Pembelian "$itemName" berhasil ditambahkan.');
  } catch (e) {
    print('Gagal menambahkan pembelian: $e'); // Tangani kesalahan saat menambahkan data
  }
}

/// Fungsi asinkron untuk mengambil daftar pembelian yang terjadi pada tanggal tertentu.
///
/// Fungsi ini melakukan kueri koleksi 'purchases' dan memfilter dokumen
/// berdasarkan bidang 'purchase_date' yang berada dalam rentang dari awal
/// hingga akhir hari yang ditentukan.
///
/// Parameter:
/// - [date]: Tanggal spesifik (DateTime) untuk mencari pembelian.
///
/// Mengembalikan:
/// - [Future<List<Map<String, dynamic>>>]: Sebuah daftar peta, di mana setiap peta
///   merepresentasikan data dokumen pembelian yang ditemukan.
Future<List<Map<String, dynamic>>> showPurchasesOnDate(DateTime date) async {
  // Tentukan awal hari (00:00:00) dari tanggal yang dipilih
  DateTime start = DateTime(date.year, date.month, date.day, 0, 0, 0);
  // Tentukan akhir hari (23:59:59) dari tanggal yang dipilih
  DateTime end = DateTime(date.year, date.month, date.day, 23, 59, 59);

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('purchases')
        .where('purchase_date', isGreaterThanOrEqualTo: Timestamp.fromDate(start)) // Kueri tanggal lebih besar atau sama dengan awal hari
        .where('purchase_date', isLessThanOrEqualTo: Timestamp.fromDate(end))     // Kueri tanggal lebih kecil atau sama dengan akhir hari
        .get();

    // Memetakan dokumen yang ditemukan ke daftar peta dan mengembalikannya
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    print('Terjadi kesalahan saat mengambil pembelian pada tanggal $date: $e');
    return []; // Mengembalikan daftar kosong jika terjadi kesalahan
  }
}

/// Widget [StatefulWidget] untuk menampilkan pembelian berdasarkan tanggal yang dipilih pengguna.
class ShowPurchasesScreen extends StatefulWidget {
  const ShowPurchasesScreen({super.key});

  @override
  _ShowPurchasesScreenState createState() => _ShowPurchasesScreenState(); // Membuat State untuk widget ini.
}

/// State terkait dengan [ShowPurchasesScreen].
/// Ini mengelola tanggal yang dipilih oleh pengguna dan daftar pembelian yang diambil.
class _ShowPurchasesScreenState extends State<ShowPurchasesScreen> {
  late DateTime _selectedDate; // Variabel untuk menyimpan tanggal yang dipilih, diinisialisasi di initState.
  List<Map<String, dynamic>> _purchases = []; // Daftar untuk menyimpan data pembelian yang ditampilkan.

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Inisialisasi tanggal yang dipilih dengan tanggal saat ini.
    _fetchPurchases(); // Ambil pembelian untuk tanggal awal saat widget pertama kali dibuat.
  }

  /// Fungsi asinkron untuk menampilkan pemilih tanggal kepada pengguna.
  /// Setelah tanggal dipilih, `_selectedDate` diperbarui dan `_fetchPurchases()` dipanggil.
  /// Parameter:
  /// - [context]: Konteks pembangunan widget.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Tanggal awal pemilih tanggal adalah tanggal yang saat ini dipilih
      firstDate: DateTime(2000), // Tanggal paling awal yang bisa dipilih
      lastDate: DateTime(2101), // Tanggal paling akhir yang bisa dipilih
    );
    // Perbarui state jika tanggal dipilih dan berbeda dari tanggal sebelumnya
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Perbarui tanggal yang dipilih
      });
      _fetchPurchases(); // Ambil pembelian untuk tanggal yang baru dipilih
    }
  }

  /// Fungsi asinkron untuk mengambil data pembelian dari Firestore
  /// menggunakan tanggal yang saat ini dipilih (`_selectedDate`).
  Future<void> _fetchPurchases() async {
    // Set state untuk menunjukkan loading atau mengosongkan daftar sebelum mengambil data baru
    setState(() {
      _purchases = []; // Kosongkan daftar untuk menunjukkan data sedang dimuat atau diperbarui
    });
    try {
      List<Map<String, dynamic>> purchases = await showPurchasesOnDate(_selectedDate);
      setState(() {
        _purchases = purchases; // Perbarui daftar pembelian dengan data yang diambil
      });
    } catch (e) {
      // Tampilkan pesan kesalahan kepada pengguna jika pengambilan data gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil pembelian: $e')),
      );
      setState(() {
        _purchases = []; // Kosongkan daftar jika terjadi kesalahan
      });
    }
  }

  /// Memformat objek DateTime ke string dalam format 'YYYY-MM-DD'.
  /// Parameter:
  /// - [date]: Objek DateTime yang akan diformat.
  /// Mengembalikan:
  /// - [String]: Tanggal yang diformat.
  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tampilkan Pembelian'), // Judul AppBar
        backgroundColor: Colors.blueAccent, // Warna latar belakang AppBar
        foregroundColor: Colors.white, // Warna teks di AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding di sekitar konten body
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    // Tampilkan pesan berdasarkan apakah tanggal telah dipilih
                    _selectedDate == null
                        ? 'Tanggal Belum Dipilih!'
                        : 'Pembelian pada tanggal ${_formatDate(_selectedDate)}:',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context), // Panggil pemilih tanggal saat tombol ditekan
                  child: const Text('Pilih Tanggal'), // Teks tombol
                ),
              ],
            ),
            const SizedBox(height: 20), // Spasi vertikal
            Expanded(
              // Menampilkan daftar pembelian menggunakan ListView.builder
              child: _purchases.isEmpty && _selectedDate != null
                  ? const Center(child: Text('Tidak ada pembelian pada tanggal ini.')) // Pesan jika tidak ada pembelian
                  : ListView.builder(
                      itemCount: _purchases.length,
                      itemBuilder: (context, index) {
                        final purchase = _purchases[index];
                        // Mengonversi Timestamp Firestore kembali ke DateTime untuk ditampilkan
                        final purchaseDateTime = (purchase['purchase_date'] as Timestamp).toDate();
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Text(
                              purchase['item_name'] ?? 'Nama Item Tidak Diketahui', // Nama item
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Tanggal: ${_formatDate(purchaseDateTime)}', // Tanggal pembelian
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            //   bisa menambahkan detail lain atau aksi di sini
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fungsi utama untuk menjalankan aplikasi Flutter.
/// Memastikan inisialisasi Firebase sebelum menjalankan aplikasi.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Memastikan binding Flutter diinisialisasi
  await Firebase.initializeApp(); // Inisialisasi Firebase

  runApp(
    MaterialApp(
      title: 'Aplikasi Pembelian', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Skema warna aplikasi
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ShowPurchasesScreen(), // Menetapkan ShowPurchasesScreen sebagai layar awal
    ),
  );
}
