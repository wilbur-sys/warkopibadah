// Import package yang diperlukan
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:warkopibadah/item.dart';
import 'package:warkopibadah/reusablecode.dart';

// --- Konstanta Global ---
const COLLECTION_NAME = 'barang_items';
// Nama koleksi baru untuk menyimpan kategori secara dinamis
const CATEGORY_COLLECTION_NAME = 'categories';

/// Widget utama untuk layar daftar barang.
class BarangScreen extends StatefulWidget {
  const BarangScreen({super.key, required this.title});

  final String title;

  @override
  _BarangScreenState createState() => _BarangScreenState();
}

/// State terkait untuk [BarangScreen].
class _BarangScreenState extends State<BarangScreen> {
  // Daftar item barang yang diambil dari Firestore
  List<Item> barangItems = [];
  // Daftar kategori yang diambil secara dinamis dari Firestore
  List<String> _categories = [];
  String selectedKategori = 'Semua Kategori';
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  /*
  -------------------------------------------------------------------------------------------------------------
  -----------------------------------FIREBASE OPERATIONS-------------------------------------------------------
  -------------------------------------------------------------------------------------------------------------
  */

  @override
  void initState() {
    super.initState();
    // Panggil metode untuk mengambil data dan mendengarkan perubahan
    _setupFirestoreListeners();
  }

  /// Mengatur listener real-time untuk barang dan kategori dari Firestore.
  void _setupFirestoreListeners() {
    // Listener untuk koleksi barang
    FirebaseFirestore.instance.collection(COLLECTION_NAME).snapshots().listen((records) {
      mapRecords(records);
    });

    // Listener untuk koleksi kategori
    FirebaseFirestore.instance.collection(CATEGORY_COLLECTION_NAME).snapshots().listen((records) {
      _mapCategories(records);
    });
  }

  /// Memetakan [QuerySnapshot] dari koleksi kategori ke dalam daftar string.
  /// [records]: Snapshot data dari koleksi `categories`.
  void _mapCategories(QuerySnapshot<Map<String, dynamic>> records) {
    var categoryList = records.docs.map(
      (doc) => doc['name'].toString(),
    ).toList();
    // Urutkan kategori secara alfabetis
    categoryList.sort();

    setState(() {
      _categories = categoryList;
      // Atur ulang filter kategori jika kategori yang dipilih sudah tidak ada
      if (!(_categories.contains(selectedKategori) || selectedKategori == 'Semua Kategori')) {
        selectedKategori = 'Semua Kategori';
      }
    });
  }

  /// Memetakan [QuerySnapshot] dari Firestore ke dalam daftar objek [Item].
  /// [records]: Snapshot data dari koleksi `barang_items`.
  void mapRecords(QuerySnapshot<Map<String, dynamic>> records) {
    var _list = records.docs.map(
      (item) => Item(
        id: item.id,
        name: item['name'],
        hargapcs: item['hargapcs'],
        hargapak: item['hargapak'],
        kategori: item['kategori'],
        modal: item['modal'],
      ),
    ).toList();

    setState(() {
      barangItems = _list;
    });
  }

  /// Menambah kategori baru ke koleksi `categories` di Firestore.
  void _addCategory(String name) {
    FirebaseFirestore.instance.collection(CATEGORY_COLLECTION_NAME).add({
      'name': name,
    });
  }

  /// Menambah item baru ke koleksi `barang_items` di Firestore.
  void addItem(String name, String hargapcs, String hargapak, String kategori, String modal) {
    var item = Item(id: '', name: name, hargapcs: hargapcs, hargapak: hargapak, kategori: kategori, modal: modal);
    FirebaseFirestore.instance.collection(COLLECTION_NAME).add(item.toJson());
  }

  /// Memperbarui data item yang sudah ada di Firestore.
  void updateItem(String id, String name, String hargapcs, String hargapak, String kategori, String modal) {
    FirebaseFirestore.instance.collection(COLLECTION_NAME).doc(id).update(
      {
        "name": name,
        "hargapcs": hargapcs,
        "hargapak": hargapak,
        "kategori": kategori,
        "modal": modal,
      }
    );
  }

  /// Menghapus item dari koleksi Firestore berdasarkan ID.
  void deleteItem(String id) {
    FirebaseFirestore.instance.collection(COLLECTION_NAME).doc(id).delete();
  }

  /*
  -------------------------------------------------------------------------------------------------------------
  -----------------------------USER INTERFACE (UI) LAYOUT----------------------------------------------------
  -------------------------------------------------------------------------------------------------------------
  */

  /// Memfilter daftar barang berdasarkan kategori dan pencarian.
  List<Item> getFilteredItems() {
    List<Item> items = barangItems;
    if (selectedKategori != 'Semua Kategori') {
      items = items.where((item) => item.kategori == selectedKategori).toList();
    }
    if (searchController.text.isNotEmpty) {
      items = items.where((item) =>
        item.name.toLowerCase().contains(searchController.text.toLowerCase())
      ).toList();
    }
    return items;
  }

  /// Mengurutkan daftar barang secara alfabetis.
  void sortItemsByName() {
    barangItems.sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    sortItemsByName();
    List<Item> filteredItems = getFilteredItems();
    // Tambahkan 'Semua Kategori' ke daftar kategori yang akan ditampilkan di dropdown filter
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
                  DropdownButtonHideUnderline(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: selectedKategori,
                        hint: const Text('Pilih Kategori'),
                        isDense: true,
                        isExpanded: false,
                        items: displayKategoriList.map<DropdownMenuItem<String>>((String kategori) {
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
                  ),
                  // Tombol untuk menambah kategori baru
                  IconButton(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.category),
                  ),
                  // Tombol untuk mengaktifkan/menonaktifkan mode pencarian
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSearching = !isSearching;
                        if (!isSearching) {
                          searchController.clear();
                        }
                      });
                    },
                    icon: Icon(isSearching ? Icons.close : Icons.search),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                alignment: Alignment.center,
                color: Colors.blueGrey[700],
                child: Column(
                  children: [
                    if (isSearching)
                      SingleChildScrollView(
                        child: TextField(
                          controller: searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Cari barang...',
                            hintStyle: TextStyle(color: Colors.white70),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    if (!isSearching)
                      Table(
                        columnWidths: const {
                          0: FixedColumnWidth(50.0),
                          1: FlexColumnWidth(1.0),
                          2: FlexColumnWidth(1.0),
                          3: FlexColumnWidth(1.0),
                        },
                        border: TableBorder.all(
                          color: Colors.blueGrey[800]!,
                          width: 0.5,
                        ),
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text("No", style: fontbold.copyWith(color: Colors.white)),
                                  ),
                                ),
                              ),
                              TableCell(child: Center(
                                child: Padding(padding: const EdgeInsets.all(9.0),
                                  child: Text("Nama\nBarang", style: fontbold.copyWith(color: Colors.white)),
                                ),
                              )),
                              TableCell(child: Center(
                                child: Padding(padding: const EdgeInsets.all(9.0),
                                  child: Text("Harga\nJual/pcs", style: fontbold.copyWith(color: Colors.white)),
                                ),
                              )),
                              TableCell(child: Center(
                                child: Padding(padding: const EdgeInsets.all(9.0),
                                  child: Text("Harga\nJual/pak", style: fontbold.copyWith(color: Colors.white)),
                                ),
                              )),
                            ]
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index){
                var item = filteredItems[index];
                return Slidable(
                  key: ValueKey(item.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context){
                          deleteItem(item.id);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        spacing: 8,
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          showUpdateDialog(item.id, item.name, item.hargapcs, item.hargapak, item.kategori ?? '', item.modal ?? '');
                        },
                        backgroundColor: Colors.yellow[800]!,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                      ),
                      SlidableAction(
                        onPressed: null,
                        backgroundColor: Colors.blue[700]!,
                        foregroundColor: Colors.white,
                        label: 'Modal: ${item.modal}',
                        spacing: 8,
                      )
                    ]
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(50.0),
                      1: FlexColumnWidth(1.0),
                      2: FlexColumnWidth(1.0),
                      3: FlexColumnWidth(1.0),
                    },
                    border: const TableBorder(
                      horizontalInside: BorderSide.none,
                      verticalInside: BorderSide.none,
                      top: BorderSide(width: 0.5, color: Colors.grey),
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none,
                    ),
                    children: [
                      TableRow(
                        children: [
                          TableCell(child: Center(child: Padding(padding: const EdgeInsets.all( 7.0), child: Text((index + 1).toString()),))),
                          TableCell(child: Align(alignment:Alignment.centerLeft, child: Padding(padding: const EdgeInsets.all(7.0), child: Text(item.name),))),
                          TableCell(child: Center(child: Padding(padding: const EdgeInsets.all(7.0), child: Text(item.hargapcs),))),
                          TableCell(child: Center(child: Padding(padding: const EdgeInsets.all(7.0), child: Text(item.hargapak),))),
                        ],
                      ),
                    ],
                  ),
                );
              },
              childCount: filteredItems.length
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Menampilkan dialog untuk menambahkan kategori baru.
  void _showAddCategoryDialog() {
    var categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Tambah Kategori Baru', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        var name = categoryController.text.trim();
                        if (name.isNotEmpty) {
                          _addCategory(name);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  /// Menampilkan dialog untuk menambahkan item barang baru.
  showAddDialog() {
    var nameController = TextEditingController();
    var hargapcsController = TextEditingController();
    var hargapakController = TextEditingController();
    var modalController = TextEditingController();
    
    // Gunakan daftar kategori yang dinamis dari Firestore
    List<String> filteredKategoriList = _categories;

    String _currentSelectedKategori = filteredKategoriList.isNotEmpty ? filteredKategoriList[0] : '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text('Detail Barang', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        labelText: 'Nama Barang',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hargapcsController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        labelText: 'Harga Barang / pcs',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hargapakController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        labelText: 'Harga Barang / pak',
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Dropdown untuk memilih Kategori.
                    if (filteredKategoriList.isNotEmpty) // Tampilkan dropdown hanya jika ada kategori
                      FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Pilih Kategori',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            isEmpty: _currentSelectedKategori == '',
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _currentSelectedKategori.isNotEmpty ? _currentSelectedKategori : null,
                                isDense: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _currentSelectedKategori = newValue ?? filteredKategoriList[0];
                                    state.didChange(newValue);
                                  });
                                },
                                items: filteredKategoriList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      )
                    else 
                      const Text('Tidak ada kategori. Tambahkan kategori terlebih dahulu.', style: TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: modalController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        labelText: 'Harga Modal',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        var name = nameController.text.trim();
                        var hargapcs = hargapcsController.text.trim();
                        var hargapak = hargapakController.text.trim();
                        var modal = modalController.text.trim();
                        addItem(name, hargapcs, hargapak, _currentSelectedKategori, modal);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Menampilkan dialog untuk memperbarui detail item barang yang sudah ada.
  showUpdateDialog(String id, String currentName, String currentHargapcs, String currentHargapak, String currentKategori, String currentModal) {
    var nameController = TextEditingController(text: currentName);
    var hargapcsController = TextEditingController(text: currentHargapcs);
    var hargapakController = TextEditingController(text: currentHargapak);
    var modalController = TextEditingController(text: currentModal);

    String _currentSelectedValue = currentKategori;
    List<String> filteredKategoriList = _categories;

    showDialog(context: context, builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Center(child: Text('Item Detail', style: TextStyle(fontSize: 20))),
                    ],
                  ),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Barang')),
                  TextField(controller: hargapcsController, decoration: const InputDecoration(labelText: 'Harga Barang / pcs')),
                  TextField(controller: hargapakController, decoration: const InputDecoration(labelText: 'Harga Barang / pak')),
                  const SizedBox(height: 10),
                  if (filteredKategoriList.isNotEmpty)
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                          ),
                          isEmpty: _currentSelectedValue == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _currentSelectedValue.isNotEmpty ? _currentSelectedValue : null,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _currentSelectedValue = newValue ?? '';
                                  state.didChange(newValue);
                                });
                              },
                              items: filteredKategoriList.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    const Text('Tidak ada kategori. Tambahkan kategori terlebih dahulu.', style: TextStyle(fontStyle: FontStyle.italic)),
                  TextField(controller: modalController, decoration: const InputDecoration(labelText: 'Modal')),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        var name = nameController.text.trim();
                        var hargapcs = hargapcsController.text.trim();
                        var hargapak = hargapakController.text.trim();
                        var kategori = _currentSelectedValue;
                        var modal = modalController.text.trim();

                        updateItem(id, name, hargapcs, hargapak, kategori, modal);
                        Navigator.pop(context);
                      },
                      child: const Text('Update Data'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
