import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warkopibadah/models/belanja_item.dart';
import 'package:warkopibadah/repositories/belanja_repository.dart';

class BelanjaViewModel extends ChangeNotifier {
  final BelanjaRepository _repository = BelanjaRepository();

  final TextEditingController searchNamaBarangController = TextEditingController();
  final List<BelanjaItem> _belanjaList = [];
  List<String> _namaBarang = [];
  bool _showForm = false;
  bool _showDetail = false;
  DateTime? _selectedDate;

  List<BelanjaItem> get belanjaList => _belanjaList;
  List<String> get namaBarang => _namaBarang;
  bool get showForm => _showForm;
  bool get showDetail => _showDetail;
  DateTime? get selectedDate => _selectedDate;

  BelanjaViewModel() {
    _fetchBarangItems();
  }

  // Mengambil data nama barang dari repository
  void _fetchBarangItems() {
    _repository.getBarangStream().listen((records) {
      _namaBarang = records.docs.map((item) => item['name'] as String).toList();
      notifyListeners();
    });
  }

  List<String> getSuggestions(String query) {
    return _namaBarang.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();
  }

  void addBelanjaItem(String nama, int jumlah, String opsi) {
    _belanjaList.add(BelanjaItem(nama: nama, jumlah: jumlah, opsi: opsi));
    notifyListeners();
  }

  void resetBelanjaList() {
    _belanjaList.clear();
    notifyListeners();
  }

  // Memanggil repository untuk mengirim data ke Firebase
  void submitToFirebase(BuildContext context) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (_belanjaList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daftar belanja kosong. Tidak ada yang dikirim.')),
      );
      return;
    }

    try {
      await _repository.submitBelanjaItems(formattedDate, _belanjaList);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil ditambahkan!')),
      );
      _belanjaList.clear();
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan data: $e')),
      );
    }
  }

  void toggleForm(bool value) {
    _showForm = value;
    if (!value) {
      searchNamaBarangController.clear();
      _belanjaList.clear();
    }
    notifyListeners();
  }

  void toggleDetail(DateTime? date) {
    _selectedDate = date;
    _showDetail = date != null;
    notifyListeners();
  }

  // Memanggil repository untuk mengambil data belanja
  Future<List<Map<String, dynamic>>> fetchBelanjaDataForDate() async {
    if (_selectedDate == null) {
      return [];
    }
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    return await _repository.fetchBelanjaDataForDate(formattedDate);
  }

  int daysInMonth(DateTime date) {
    var firstDayThisMonth = DateTime(date.year, date.month, 1);
    var firstDayNextMonth = DateTime(firstDayThisMonth.year, firstDayThisMonth.month + 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }
}
