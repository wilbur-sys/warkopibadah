import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warkopibadah/models/harga_beli_barang_item.dart';

// Nama koleksi untuk bon toko dan kategori
const CATEGORY_COLLECTION_NAME = 'categories';
const BONTOKO_COLLECTION_NAME = 'bontoko_items';

/// Repository untuk mengelola interaksi dengan Firestore untuk item bon toko dan kategori.
/// Repository ini bertanggung jawab untuk operasi data (CRUD) dan streaming data.
class HargaBeliBarangRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mendapatkan stream dari semua item bon toko dari Firestore.
  /// Ini memungkinkan UI untuk mendengarkan perubahan data secara real-time.
  Stream<QuerySnapshot<Map<String, dynamic>>> getBonTokoItemsStream() {
    return _firestore.collection(BONTOKO_COLLECTION_NAME).snapshots();
  }

  /// Mendapatkan stream dari semua kategori dari Firestore.
  /// Ini memungkinkan UI untuk mendapatkan daftar kategori terbaru.
  Stream<QuerySnapshot<Map<String, dynamic>>> getCategoriesStream() {
    return _firestore.collection(CATEGORY_COLLECTION_NAME).snapshots();
  }

  /// Menambah item baru ke koleksi `bontoko_items` di Firestore.
  Future<void> addItem(BonTokoItem item) async {
    try {
      await _firestore.collection(BONTOKO_COLLECTION_NAME).add({
        'jumlah': item.jumlah,
        'isi': item.isi,
        'nama': item.nama,
        'kategori': item.kategori,
        'harga': item.harga,
        'lastupdate': Timestamp.fromDate(item.lastupdate),
      });
    } catch (e) {
      // Menangani error dan mencetaknya, tetapi tidak menampilkannya di UI.
      // Error akan ditangani oleh ViewModel.
      print('Gagal menambahkan item: $e');
      rethrow; // Melemparkan kembali error agar dapat ditangkap oleh ViewModel
    }
  }

  /// Memperbarui data item yang sudah ada di Firestore.
  Future<void> updateItem(BonTokoItem item) async {
    try {
      await _firestore.collection(BONTOKO_COLLECTION_NAME).doc(item.id).update({
        'jumlah': item.jumlah,
        'isi': item.isi,
        'nama': item.nama,
        'kategori': item.kategori,
        'harga': item.harga,
        'lastupdate': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Gagal memperbarui item: $e');
      rethrow;
    }
  }

  /// Menghapus item dari koleksi Firestore berdasarkan ID.
  Future<void> deleteItem(String id) async {
    try {
      await _firestore.collection(BONTOKO_COLLECTION_NAME).doc(id).delete();
    } catch (e) {
      print('Gagal menghapus item: $e');
      rethrow;
    }
  }
}
