import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/harga_jual_barang_item.dart';

const String BARANG_COLLECTION = 'barang_items';
const String CATEGORY_COLLECTION = 'categories';

class BarangRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Mengambil stream dari semua item barang.
  /// Data akan diperbarui secara real-time saat ada perubahan di Firestore.
  Stream<List<Item>> getBarangItems() {
    return _db.collection(BARANG_COLLECTION).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Menggunakan id dari dokumen untuk membuat objek Item
        final data = doc.data();
        data['id'] = doc.id;
        return Item.fromJson(data);
      }).toList();
    });
  }

  /// Mengambil stream dari semua kategori.
  /// Data akan diperbarui secara real-time.
  Stream<List<String>> getCategories() {
    return _db.collection(CATEGORY_COLLECTION).snapshots().map((snapshot) {
      final categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
      categories.sort();
      return categories;
    });
  }

  /// Menambahkan item barang baru.
  Future<void> addItem(Item item) {
    return _db.collection(BARANG_COLLECTION).add(item.toJson());
  }

  /// Memperbarui item barang yang sudah ada.
  Future<void> updateItem(String id, Item item) {
    return _db.collection(BARANG_COLLECTION).doc(id).update(item.toJson());
  }

  /// Menghapus item barang.
  Future<void> deleteItem(String id) {
    return _db.collection(BARANG_COLLECTION).doc(id).delete();
  }

  /// Menambahkan kategori baru.
  Future<void> addCategory(String name) {
    return _db.collection(CATEGORY_COLLECTION).add({'name': name});
  }
}
