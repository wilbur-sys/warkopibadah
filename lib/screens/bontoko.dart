import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:warkopibadah/bontokoitem.dart';
import 'package:warkopibadah/reusablecode.dart';

// Nama koleksi untuk bon toko dan kategori
const CATEGORY_COLLECTION_NAME = 'categories';
const BONTOKO_COLLECTION_NAME = 'bontoko_items';

class Bontoko extends StatefulWidget {
  const Bontoko({super.key});

  @override
  _BontokoState createState() => _BontokoState();
}

class _BontokoState extends State<Bontoko> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Daftar kategori yang akan diisi dari Firestore
  List<String> _categories = [];
  String selectedKategori = 'Semua Kategori';
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  // Daftar item bon toko yang akan diisi dari Firestore
  List<BonTokoItem> bonTokoItems = [];

  // Timestamp parser
  DateTime parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp == null) {
      return DateTime.now();
    } else {
      throw ArgumentError('Invalid timestamp');
    }
  }

  @override
  void initState() {
    super.initState();
    // Panggil metode untuk mengambil data dan mendengarkan perubahan
    _setupFirestoreListeners();
  }

  /// Mengatur listener real-time untuk bon toko dan kategori dari Firestore.
  void _setupFirestoreListeners() {
    // Listener untuk koleksi bon toko
    _firestore.collection(BONTOKO_COLLECTION_NAME).snapshots().listen((records) {
      _mapBonTokoItems(records);
    });

    // Listener untuk koleksi kategori
    _firestore.collection(CATEGORY_COLLECTION_NAME).snapshots().listen((records) {
      _mapCategories(records);
    });
  }

  /// Memetakan [QuerySnapshot] dari koleksi bon toko ke dalam daftar objek [BonTokoItem].
  void _mapBonTokoItems(QuerySnapshot<Map<String, dynamic>> records) {
    var _list = records.docs.map((item) {
      return BonTokoItem(
        id: item.id,
        jumlah: item['jumlah']?.toString() ?? '0',
        isi: item['isi'] ?? '',
        nama: item['nama'] ?? '',
        kategori: item['kategori'] ?? '',
        harga: item['harga']?.toString() ?? '0',
        lastupdate: parseTimestamp(item['lastupdate']),
      );
    }).toList();

    setState(() {
      bonTokoItems = _list;
    });
  }

  /// Memetakan [QuerySnapshot] dari koleksi kategori ke dalam daftar string.
  void _mapCategories(QuerySnapshot<Map<String, dynamic>> records) {
    var categoryList = records.docs.map(
      (doc) => doc['name'].toString(),
    ).toList();
    categoryList.sort(); // Urutkan kategori secara alfabetis

    setState(() {
      _categories = categoryList;
      // Atur ulang filter kategori jika kategori yang dipilih sudah tidak ada
      if (!(_categories.contains(selectedKategori) || selectedKategori == 'Semua Kategori')) {
        selectedKategori = 'Semua Kategori';
      }
    });
  }

  /// Menambah item baru ke koleksi `bontoko_items` di Firestore.
  Future<void> addItem(String jumlah, String isi, String nama, String harga, String kategori, DateTime lastupdate) async {
    try {
      await _firestore.collection(BONTOKO_COLLECTION_NAME).add({
        'jumlah': jumlah,
        'isi': isi,
        'nama': nama,
        'kategori': kategori,
        'harga': harga,
        'lastupdate': Timestamp.fromDate(lastupdate),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan item: $e')),
        );
      }
    }
  }

  /// Memperbarui data item yang sudah ada di Firestore.
  Future<void> updateItem(String id, String jumlah, String isi, String nama, String harga, String kategori) async {
    try {
      await _firestore.collection(BONTOKO_COLLECTION_NAME).doc(id).update({
        'jumlah': jumlah,
        'isi': isi,
        'nama': nama,
        'kategori': kategori,
        'harga': harga,
        'lastupdate': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui item: $e')),
        );
      }
    }
  }

  /// Menghapus item dari koleksi Firestore berdasarkan ID.
  Future<void> deleteItem(String id) async {
    try {
      await _firestore.collection(BONTOKO_COLLECTION_NAME).doc(id).delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BonTokoItem> filteredItems = bonTokoItems.where((item) {
      final searchMatch = item.nama.toLowerCase().contains(searchController.text.toLowerCase());
      final kategoriMatch = selectedKategori == 'Semua Kategori' || item.kategori == selectedKategori;
      return searchMatch && kategoriMatch;
    }).toList();

    // Tambahkan 'Semua Kategori' di awal daftar untuk filter
    List<String> displayKategoriList = ['Semua Kategori', ..._categories];

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            elevation: 0,
            forceElevated: true,
            backgroundColor: Colors.white,
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Widget dropdown kategori kini menggunakan data dari _categories
                  kategoriDropdownWidget(displayKategoriList),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSearching = !isSearching;
                        if (!isSearching) searchController.clear();
                      });
                    },
                    icon: Icon(isSearching ? Icons.close : Icons.search),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: isSearching ? searchBarWidget() : tableHeaderWidget(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final item = filteredItems[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _showDeleteConfirmationDialog(item),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        spacing: 8,
                      ),
                      SlidableAction(
                        onPressed: (context) => showUpdateDialog(item.id, item.jumlah, item.isi, item.nama, item.harga, item.kategori),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        spacing: 8,
                      ),
                    ],
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(0.7),
                      1: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(2.0),
                      4: FlexColumnWidth(1.5),
                      5: FlexColumnWidth(0.8),
                    },
                    border: const TableBorder(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    children: [
                      TableRow(
                        children: [
                          tableCell((index + 1).toString()),
                          tableCell(' ${item.jumlah} ${item.isi}'),
                          tableCell(item.nama),
                          tableCell(item.harga),
                          tableCell(DateFormat('d/MMM/yy', 'id_ID').format(item.lastupdate)),
                        ],
                      ),
                    ],
                  ),
                );
              },
              childCount: filteredItems.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget dropdown kategori kini menerima daftar kategori sebagai parameter
  Widget kategoriDropdownWidget(List<String> categories) => DropdownButtonHideUnderline(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: selectedKategori,
        hint: const Text('Pilih Kategori'),
        isDense: true,
        isExpanded: false,
        items: categories.map((String kategori) {
          return DropdownMenuItem<String>(
            value: kategori,
            child: Text(kategori),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedKategori = newValue!;
          });
        },
      ),
    ),
  );

  Widget searchBarWidget() => Container(
    alignment: Alignment.center,
    color: Colors.blueGrey[700],
    child: TextField(
      controller: searchController,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Cari barang...',
        hintStyle: TextStyle(color: Colors.white70),
        contentPadding: EdgeInsets.all(10),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        setState(() {});
      },
    ),
  );

  Widget tableHeaderWidget() => Container(
    alignment: Alignment.center,
    color: Colors.blueGrey[700],
    child: Table(
      columnWidths: const {
        0: FlexColumnWidth(0.7),
        1: FlexColumnWidth(1.3),
        3: FlexColumnWidth(1.9),
        4: FlexColumnWidth(1.4),
        5: FlexColumnWidth(0.9),
      },
      children: [
        TableRow(
          children: [
            buildHeaderCell("No"),
            buildHeaderCell("Jumlah"),
            buildHeaderCell("Nama"),
            buildHeaderCell("Harga"),
            buildHeaderCell("Time"),
          ],
        ),
      ],
    ),
  );

  Widget buildHeaderCell(String text) => Padding(
    padding: const EdgeInsets.all(9.0),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      textAlign: TextAlign.center,
    ),
  );

  Widget tableCell(String text) => TableCell(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Text(text),
      ),
    ),
  );

  void _showDeleteConfirmationDialog(BonTokoItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus ${item.nama}?'),
          content: const Text('Yakin ingin menghapus item ini?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteItem(item.id);
                Navigator.of(context).pop();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void showAddDialog() {
    var jumlahController = TextEditingController();
    var isiController = TextEditingController();
    var namaController = TextEditingController();
    var hargaController = TextEditingController();

    // Menggunakan daftar kategori yang dinamis dari state
    List<String> dynamicCategories = _categories;

    String currentSelectedKategori = dynamicCategories.isNotEmpty ? dynamicCategories[0] : '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Detail Barang'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: jumlahController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      labelText: 'Jumlah',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: isiController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      labelText: 'Isi',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      labelText: 'Nama',
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (dynamicCategories.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: currentSelectedKategori,
                      onChanged: (String? newValue) {
                        setState(() {
                          currentSelectedKategori = newValue ?? dynamicCategories[0];
                        });
                      },
                      items: dynamicCategories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        labelText: 'Pilih Kategori',
                      ),
                    )
                  else
                    const Text('Tidak ada kategori. Tambahkan kategori terlebih dahulu.'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: hargaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      labelText: 'Harga',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (jumlahController.text.isEmpty || namaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jumlah dan Nama harus diisi')),
                      );
                      return;
                    }
                    var jumlah = jumlahController.text.trim();
                    var isi = isiController.text.trim();
                    var nama = namaController.text.trim();
                    var kategori = currentSelectedKategori;
                    var harga = hargaController.text.trim();
                    var lastupdate = DateTime.now();
                    addItem(jumlah, isi, nama, harga, kategori, lastupdate);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Simpan'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showUpdateDialog(String id, String jumlah, String isi, String nama, String harga, String kategori) {
    var jumlahController = TextEditingController(text: jumlah);
    var isiController = TextEditingController(text: isi);
    var namaController = TextEditingController(text: nama);
    var hargaController = TextEditingController(text: harga);

    List<String> dynamicCategories = _categories;

    String currentSelectedKategori = dynamicCategories.contains(kategori) ? kategori : (dynamicCategories.isNotEmpty ? dynamicCategories[0] : '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Barang'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: jumlahController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      labelText: 'Jumlah',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: isiController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      labelText: 'Isi',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      labelText: 'Nama',
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (dynamicCategories.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: currentSelectedKategori,
                      onChanged: (String? newValue) {
                        setState(() {
                          currentSelectedKategori = newValue ?? dynamicCategories[0];
                        });
                      },
                      items: dynamicCategories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        labelText: 'Pilih Kategori',
                      ),
                    )
                  else
                    const Text('Tidak ada kategori. Tambahkan kategori terlebih dahulu.'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: hargaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      labelText: 'Harga',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (jumlahController.text.isEmpty || namaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jumlah dan Nama harus diisi')),
                      );
                      return;
                    }
                    var jumlah = jumlahController.text.trim();
                    var isi = isiController.text.trim();
                    var nama = namaController.text.trim();
                    var kategori = currentSelectedKategori;
                    var harga = hargaController.text.trim();
                    updateItem(id, jumlah, isi, nama, harga, kategori);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
