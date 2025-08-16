import 'package:flutter/material.dart'; // Mengimpor paket inti Flutter untuk membangun UI

/// File ini berisi definisi [TextStyle] dan fungsi pembangun widget
/// yang dapat digunakan kembali di berbagai bagian aplikasi untuk menjaga konsistensi UI.

/// Getter untuk [TextStyle] yang digunakan secara global.
/// Menghasilkan gaya teks tebal dengan warna putih.
///
/// Penggunaan `get` daripada `final` memastikan `TextStyle` dibuat ulang
/// setiap kali diakses, yang terkadang diperlukan dalam kasus yang kompleks
/// jika `Colors.white` atau properti lain dapat berubah konteks (meskipun tidak pada kasus ini).
/// Untuk performa optimal, jika gaya tidak pernah berubah, bisa juga `final`.
TextStyle get fontbold => const TextStyle(fontWeight: FontWeight.bold, color: Colors.white);

/// Fungsi pembangun widget untuk membuat sel header tabel yang dapat digunakan kembali.
/// Sel header ini memiliki latar belakang abu-abu kebiruan, padding,
/// dan teks yang dipusatkan dengan gaya `fontbold`.
///
/// Parameter:
/// - [text]: String yang akan ditampilkan sebagai teks di dalam sel header.
///
/// Mengembalikan:
/// - Sebuah [Widget] `Container` yang dikonfigurasi sebagai sel header.
Widget buildHeaderCell(String text) {
  return Container(
    color: Colors.blueGrey[700], // Warna latar belakang sel header
    padding: const EdgeInsets.all(9.0), // Padding di sekitar konten teks
    child: Center(
      child: Text(
        text, // Teks yang akan ditampilkan
        style: fontbold, // Menggunakan gaya teks fontbold yang telah didefinisikan
      ),
    ),
  );
}

//   bisa menambahkan fungsi atau widget reusable lainnya di sini, seperti:
// - `buildTableCell(String text)`: Untuk sel data tabel biasa.
// - `showCustomSnackbar(BuildContext context, String message)`: Untuk pesan notifikasi kustom.
// - Definisi padding atau margin yang sering digunakan.
