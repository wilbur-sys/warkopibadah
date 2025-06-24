import 'dart:convert'; // Mengimpor pustaka 'dart:convert' untuk encoding/decoding JSON
import 'package:cloud_firestore/cloud_firestore.dart'; // Mengimpor pustaka Firestore untuk tipe data Timestamp

/// File ini mendefinisikan model data untuk 'BonTokoItem',
/// yang merepresentasikan sebuah item barang di aplikasi.
/// Ini juga menyediakan fungsi utilitas untuk konversi antara objek Dart dan format JSON.

/// Fungsi utilitas untuk membuat objek [BonTokoItem] dari string JSON.
///
/// Parameter:
/// - [str]: String JSON yang berisi data item.
///
/// Mengembalikan:
/// - Sebuah instance [BonTokoItem] yang dibuat dari data JSON.
BonTokoItem itemFromJson(String str) => BonTokoItem.fromJson(json.decode(str));

/// Fungsi utilitas untuk mengubah objek [BonTokoItem] menjadi string JSON.
///
/// Parameter:
/// - [data]: Objek [BonTokoItem] yang akan diubah.
///
/// Mengembalikan:
/// - Sebuah string JSON yang merepresentasikan data item.
String itemToJson(BonTokoItem data) => json.encode(data.toJson());

/// Kelas [BonTokoItem] merepresentasikan sebuah item barang
/// dengan properti seperti ID, jumlah, isi, nama, kategori, harga,
/// dan waktu terakhir diperbarui.
class BonTokoItem {
  String id; // ID unik untuk dokumen item di Firestore
  String jumlah; // Jumlah item (misalnya, '10' unit)
  String isi; // Deskripsi isi item (misalnya, 'pcs', 'pak')
  String nama; // Nama item barang
  String kategori; // Kategori item (misalnya, 'Rokok', 'Makanan')
  String harga; // Harga item (misalnya, 'Rp 15000')
  DateTime lastupdate; // Waktu terakhir item diperbarui

  /// Konstruktor untuk membuat instance [BonTokoItem].
  BonTokoItem({
    required this.id,
    required this.jumlah,
    required this.isi,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.lastupdate,
  });

  /// Mengonversi instance [BonTokoItem] ini menjadi [Map<String, dynamic>]
  /// yang cocok untuk disimpan di Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Menyertakan ID item
      'jumlah': jumlah,
      'isi': isi,
      'nama': nama,
      'kategori': kategori,
      'harga': harga,
      'lastupdate': Timestamp.fromDate(lastupdate), // Menyimpan DateTime sebagai Timestamp Firestore
    };
  }

  /// Membuat instance [BonTokoItem] dari [Map<String, dynamic>] (biasanya dari Firestore atau JSON).
  ///
  /// Parameter:
  /// - [json]: Sebuah peta yang berisi data item.
  ///
  /// Mengembalikan:
  /// - Sebuah instance [BonTokoItem] yang dibuat dari data peta.
  factory BonTokoItem.fromJson(Map<String, dynamic> json) {
    return BonTokoItem(
      id: json['id'] ?? '', // Mengambil ID item, default ke string kosong jika null
      jumlah: json['jumlah'] ?? '0', // Mengambil jumlah, default ke '0' jika null
      isi: json['isi'] ?? '', // Mengambil isi, default ke string kosong jika null
      nama: json['nama'] ?? '', // Mengambil nama, default ke string kosong jika null
      kategori: json['kategori'] ?? '', // Mengambil kategori, default ke string kosong jika null
      harga: json['harga'] ?? '0', // Mengambil harga, default ke '0' jika null
      // Mengonversi Timestamp Firestore kembali ke DateTime.
      // Jika 'lastupdate' null atau bukan Timestamp, default ke waktu sekarang.
      lastupdate: (json['lastupdate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
