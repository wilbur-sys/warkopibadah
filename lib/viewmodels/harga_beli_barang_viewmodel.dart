import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warkopibadah/models/harga_beli_barang_item.dart';
import 'package:warkopibadah/repositories/harga_beli_barang_repository.dart';

/// ViewModel untuk mengelola state dan logika bisnis Harga Beli Barang.
/// Ini menyediakan data ke UI dan mengelola interaksi pengguna.
class HargaBeliBarangViewModel extends ChangeNotifier {
  final HargaBeliBarangRepository _repository = HargaBeliBarangRepository();

  // State
  List<BonTokoItem> _bonTokoItems = [];
  List<String> _categories = [];
  String _selectedKategori = 'Semua Kategori';
  String _searchQuery = '';
  bool _isSearching = false;

  // Getter untuk mengakses state dari luar ViewModel
  List<BonTokoItem> get bonTokoItems => _bonTokoItems;
  List<String> get categories => _categories;
  String get selectedKategori => _selectedKategori;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  // Daftar item yang sudah difilter dan dicari
  List<BonTokoItem> get filteredItems {
    return _bonTokoItems.where((item) {
      final searchMatch = item.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      final kategoriMatch = _selectedKategori == 'Semua Kategori' || item.kategori == _selectedKategori;
      return searchMatch && kategoriMatch;
    }).toList();
  }

  // Daftar kategori dengan tambahan "Semua Kategori" untuk dropdown
  List<String> get displayKategoriList => ['Semua Kategori', ..._categories];

  /// Konstruktor ViewModel. Mengatur listener Firestore saat diinisialisasi.
  HargaBeliBarangViewModel() {
    _setupFirestoreListeners();
  }

  /// Mengatur listener real-time untuk bon toko dan kategori.
  void _setupFirestoreListeners() {
    // Listener untuk koleksi bon toko
    _repository.getBonTokoItemsStream().listen((records) {
      _mapBonTokoItems(records);
    });

    // Listener untuk koleksi kategori
    _repository.getCategoriesStream().listen((records) {
      _mapCategories(records);
    });
  }

  /// Memetakan [QuerySnapshot] dari koleksi bon toko ke dalam daftar objek [BonTokoItem].
  void _mapBonTokoItems(QuerySnapshot<Map<String, dynamic>> records) {
    _bonTokoItems = records.docs.map((item) {
      return BonTokoItem(
        id: item.id,
        jumlah: item['jumlah']?.toString() ?? '0',
        isi: item['isi'] ?? '',
        nama: item['nama'] ?? '',
        kategori: item['kategori'] ?? '',
        harga: item['harga']?.toString() ?? '0',
        lastupdate: _parseTimestamp(item['lastupdate']),
      );
    }).toList();
    notifyListeners();
  }

  /// Memetakan [QuerySnapshot] dari koleksi kategori ke dalam daftar string.
  void _mapCategories(QuerySnapshot<Map<String, dynamic>> records) {
    _categories = records.docs.map((doc) => doc['name'].toString()).toList();
    _categories.sort();
    if (!(_categories.contains(_selectedKategori) || _selectedKategori == 'Semua Kategori')) {
      _selectedKategori = 'Semua Kategori';
    }
    notifyListeners();
  }

  /// Mengubah nilai selectedKategori.
  void setSelectedKategori(String? newValue) {
    if (newValue != null) {
      _selectedKategori = newValue;
      notifyListeners();
    }
  }

  /// Mengubah query pencarian.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Mengubah status pencarian.
  void toggleSearching() {
    _isSearching = !_isSearching;
    _searchQuery = ''; // Reset query saat mode pencarian dimatikan
    notifyListeners();
  }

  /// Menambah item baru ke Firestore melalui repository.
  Future<void> addItem(String jumlah, String isi, String nama, String harga, String kategori) async {
    try {
      final newItem = BonTokoItem(
        id: '', // ID akan dihasilkan oleh Firestore
        jumlah: jumlah,
        isi: isi,
        nama: nama,
        kategori: kategori,
        harga: harga,
        lastupdate: DateTime.now(),
      );
      await _repository.addItem(newItem);
    } catch (e) {
      // Anda bisa menangani error di sini, misalnya dengan logging
      print('Error ViewModel: $e');
    }
  }

  /// Memperbarui item yang sudah ada melalui repository.
  Future<void> updateItem(String id, String jumlah, String isi, String nama, String harga, String kategori) async {
    try {
      final updatedItem = BonTokoItem(
        id: id,
        jumlah: jumlah,
        isi: isi,
        nama: nama,
        kategori: kategori,
        harga: harga,
        lastupdate: DateTime.now(), // Waktu update diset di sini
      );
      await _repository.updateItem(updatedItem);
    } catch (e) {
      print('Error ViewModel: $e');
    }
  }

  /// Menghapus item melalui repository.
  Future<void> deleteItem(String id) async {
    try {
      await _repository.deleteItem(id);
    } catch (e) {
      print('Error ViewModel: $e');
    }
  }

  /// Mengubah Timestamp Firestore menjadi DateTime
  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else {
      return DateTime.now();
    }
  }
}
