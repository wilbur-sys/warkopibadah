import 'package:flutter/foundation.dart';
import '../models/harga_jual_barang_item.dart';
import '../repositories/barang_repository.dart';

class HargaJualBarangViewModel with ChangeNotifier {
  final BarangRepository _repository = BarangRepository();

  // State
  List<Item> _items = [];
  List<String> _categories = [];
  String _selectedKategori = 'Semua Kategori';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Item> get items => _items;
  List<String> get categories => _categories;
  String get selectedKategori => _selectedKategori;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HargaJualBarangViewModel() {
    _setupFirestoreListeners();
  }

  /// Mendengarkan perubahan data dari repository secara real-time.
  void _setupFirestoreListeners() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _repository.getBarangItems().listen(
      (data) {
        _items = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = "Gagal memuat item: $e";
        _isLoading = false;
        notifyListeners();
      },
    );

    _repository.getCategories().listen(
      (data) {
        _categories = data;
        // Memastikan kategori yang dipilih masih ada setelah update
        if (!_categories.contains(_selectedKategori) && _selectedKategori != 'Semua Kategori') {
          _selectedKategori = 'Semua Kategori';
        }
        notifyListeners();
      },
      onError: (e) {
        _error = "Gagal memuat kategori: $e";
        notifyListeners();
      },
    );
  }

  /// Mengupdate kategori yang dipilih oleh pengguna.
  void updateSelectedKategori(String? newValue) {
    if (newValue != null) {
      _selectedKategori = newValue;
      notifyListeners();
    }
  }

  /// Mengupdate query pencarian.
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Mengembalikan daftar item yang sudah difilter dan diurutkan.
  List<Item> get filteredAndSortedItems {
    List<Item> filteredItems = _items;

    // Filter berdasarkan kategori
    if (_selectedKategori != 'Semua Kategori') {
      filteredItems = filteredItems.where((item) => item.kategori == _selectedKategori).toList();
    }

    // Filter berdasarkan pencarian
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Urutkan berdasarkan nama
    filteredItems.sort((a, b) => a.name.compareTo(b.name));

    return filteredItems;
  }

  // Metode untuk interaksi dengan repository
  Future<void> addItem(Item item) async {
    await _repository.addItem(item);
  }

  Future<void> updateItem(String id, Item item) async {
    await _repository.updateItem(id, item);
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
  }

  Future<void> addCategory(String name) async {
    await _repository.addCategory(name);
  }
}
