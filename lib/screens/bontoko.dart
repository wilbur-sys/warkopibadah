import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:warkopibadah/bontokoitem.dart';
import 'package:warkopibadah/reusablecode.dart';

class Bontoko extends StatefulWidget {
  const Bontoko({super.key});

  @override
  _BontokoState createState() => _BontokoState();
}

class _BontokoState extends State<Bontoko> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'bontoko_items';

  List<String> kategoriList = [
    'Semua Kategori', 'ATK', 'Rokok', 'Pindang', 'Makanan', 'Minuman', 'Plastik', 'Lainnya'
  ];
  String selectedKategori = 'Semua Kategori';
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection(_collectionName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          List<BonTokoItem> bonTokoItems = snapshot.data!.docs.map((item) {
            return BonTokoItem(
              id: item.id,
              jumlah: item['jumlah']?.toString() ?? '0',
              isi: item['isi'] ?? '',
              nama: item['nama'] ?? '',
              kategori: item['kategori'] ?? '',
              harga: item['harga']?.toString() ?? '0',
              lastupdate: parseTimestamp(item['lastupdate']),
            );
          }).where((item) {
            final searchMatch = item.nama.toLowerCase().contains(searchController.text.toLowerCase());
            final kategoriMatch = selectedKategori == 'Semua Kategori' || item.kategori == selectedKategori;
            return searchMatch && kategoriMatch;
          }).toList();


          return CustomScrollView(
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
                      kategoriDropdownWidget(),
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
                    final item = bonTokoItems[index];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) => deleteItem(item.id),
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
                          0: FlexColumnWidth(0.5),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(0.8),
                          3: FlexColumnWidth(2.0),
                          4: FlexColumnWidth(1.5),
                          5: FlexColumnWidth(0.8),
                        },
                        border: TableBorder(
                          bottom: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        children: [
                          TableRow(
                            children: [
                              tableCell((index + 1).toString()),
                              tableCell(item.jumlah),
                              tableCell(item.isi),
                              tableCell(item.nama),
                              tableCell(item.harga),
                              tableCell(DateFormat('d MMM yyyy', 'id_ID').format(item.lastupdate)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: bonTokoItems.length,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }


Widget kategoriDropdownWidget() => DropdownButtonHideUnderline(
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
            items: kategoriList.map((String kategori) {
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
            2: FlexColumnWidth(0.8),
            3: FlexColumnWidth(1.9),
            4: FlexColumnWidth(1.4),
            5: FlexColumnWidth(0.9),
          },
          children: [
            TableRow(
              children: [
                buildHeaderCell("No"),
                buildHeaderCell("Jumlah"),
                buildHeaderCell("Isi"),
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
          content: const Text('  yakin ingin menghapus item ini?'),
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

    List<String> currencies = [
      "Rokok",
      "Makanan",
      "Minuman",
      "Pindang",
      "ATK",
      "Plastik",
      "Lainnya",
    ];

    String currentSelectedKategori = currencies.isNotEmpty ? currencies[0] : '';

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
                  DropdownButtonFormField<String>(
                    value: currentSelectedKategori,
                    onChanged: (String? newValue) {
                      setState(() {
                        currentSelectedKategori = newValue ?? currencies[0];
                      });
                    },
                    items: currencies.map((String value) {
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
                  ),
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

  Future<void> addItem(String jumlah, String isi, String nama, String harga, String kategori, DateTime lastupdate) async {
    try {
      await _firestore.collection(_collectionName).add({
        'jumlah': jumlah,
        'isi': isi,
        'nama': nama,
        'kategori': kategori,
        'harga': harga,
        'lastupdate': Timestamp.fromDate(lastupdate),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan item: $e')),
      );
    }
  }

  void showUpdateDialog(String id, String jumlah, String isi, String nama, String harga, String kategori) {
    var jumlahController = TextEditingController(text: jumlah);
    var isiController = TextEditingController(text: isi);
    var namaController = TextEditingController(text: nama);
    var hargaController = TextEditingController(text: harga);

    List<String> currencies = [
      "Rokok",
      "Makanan",
      "Minuman",
      "Pindang",
      "ATK",
      "Plastik",
      "Lainnya",
    ];

    String currentSelectedKategori = currencies.contains(kategori) ? kategori : currencies[0];

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
                  DropdownButtonFormField<String>(
                    value: currentSelectedKategori,
                    onChanged: (String? newValue) {
                      setState(() {
                        currentSelectedKategori = newValue ?? currencies[0];
                      });
                    },
                    items: currencies.map((String value) {
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
                  ),
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

  Future<void> updateItem(String id, String jumlah, String isi, String nama, String harga, String kategori) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'jumlah': jumlah,
        'isi': isi,
        'nama': nama,
        'kategori': kategori,
        'harga': harga,
        'lastupdate': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui item: $e')),
      );
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus item: $e')),
      );
    }
  }
}