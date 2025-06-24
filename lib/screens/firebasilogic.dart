import 'package:flutter/material.dart'; // Paket inti Flutter untuk membangun UI (digunakan untuk TextStyle, dll.)
import 'package:warkopibadah/item.dart'; // Mengimpor definisi kelas 'Item' (meskipun tidak langsung digunakan di snippet ini, mungkin untuk penggunaan lain)
import 'package:cloud_firestore/cloud_firestore.dart'; // Paket untuk Firebase Firestore (database NoSQL)

// Nama koleksi Firestore yang umum digunakan untuk menyimpan data barang
// Didefinisikan di sini agar dapat digunakan kembali di berbagai bagian aplikasi.
const COLLECTION_NAME = 'barang_items';

// Definisi TextStyle yang umum digunakan untuk teks tebal di aplikasi.
// Ini adalah contoh 'reusablecode' yang baik.
const TextStyle fontbold = TextStyle(
  fontWeight: FontWeight.bold, // Membuat teks menjadi tebal
  color: Colors.black, // Warna teks hitam
);

/// Fungsi asynchronous untuk mengambil item belanja dari Firestore berdasarkan tanggal tertentu.
///
/// Fungsi ini mengakses subkoleksi 'items' di dalam dokumen yang diidentifikasi oleh `date`
/// di koleksi 'belanja_items'. Hasilnya kemudian dicetak ke konsol.
///
/// Parameter:
/// - [date]: String yang merepresentasikan tanggal (misalnya, 'YYYY-MM-DD')
///           yang digunakan sebagai ID dokumen di koleksi 'belanja_items'.
///
/// Contoh Penggunaan:
/// ```dart
/// fetchItemsByDate('2023-10-26');
/// ```
void fetchItemsByDate(String date) {
  FirebaseFirestore.instance
      .collection('belanja_items') // Mengakses koleksi utama 'belanja_items'
      .doc(date) // Mengakses dokumen spesifik berdasarkan tanggal
      .collection('items') // Mengakses subkoleksi 'items' di dalam dokumen tanggal
      .get() // Mengambil semua dokumen dari subkoleksi
      .then((QuerySnapshot querySnapshot) { // Ketika data berhasil diambil
    if (querySnapshot.docs.isEmpty) {
      // Cetak pesan jika tidak ada data ditemukan untuk tanggal tersebut
      print('Tidak ada item belanja ditemukan untuk tanggal: $date');
    } else {
      // Iterasi melalui setiap dokumen yang diambil
      for (var doc in querySnapshot.docs) {
        // Cetak data dari setiap dokumen ke konsol
        print('Data item belanja: ${doc.data()}');
      }
    }
  })
  .catchError((error) {
    // Tangani kesalahan jika pengambilan data gagal
    print('Terjadi kesalahan saat mengambil item belanja untuk $date: $error');
  });
}

// Catatan: Jika ada fungsi atau widget lain yang sering digunakan di seluruh aplikasi,
//   dapat menambahkannya di file ini. Contohnya bisa berupa:
// - Fungsi untuk menampilkan Snackbar kustom.
// - Widget Card kustom.
// - Fungsi konversi format mata uang, dll.
