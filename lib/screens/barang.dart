// Import package yang diperlukan
import 'package:cloud_firestore/cloud_firestore.dart'; // Digunakan untuk berinteraksi dengan Firebase Firestore (database NoSQL)
import 'package:flutter/material.dart'; // Package dasar Flutter untuk membangun UI
import 'package:warkopibadah/item.dart'; // Mengimpor definisi kelas 'Item', yang merepresentasikan data barang
import 'package:flutter_slidable/flutter_slidable.dart'; // Digunakan untuk membuat item daftar yang dapat digeser (swipe actions)
import 'package:warkopibadah/reusablecode.dart'; // Mengimpor kode atau utilitas yang dapat digunakan kembali (misalnya definisi fontbold)

// --- Konstanta Global ---
const COLLECTION_NAME = 'barang_items'; // Nama koleksi di Firebase Firestore tempat data barang disimpan
// Daftar kategori yang tersedia untuk barang, termasuk opsi 'Semua Kategori'
const List<String> kategoriList = ['Semua Kategori', 'ATK', 'Rokok', 'Pindang', 'Makanan', 'Minuman', 'Plastik', 'Lainnya'];
// Daftar kategori yang digunakan untuk filter dan input, tanpa 'Semua Kategori'
final List<String> filteredKategoriList = kategoriList.where((kategori) => kategori != 'Semua Kategori').toList();

/// Widget utama untuk layar daftar barang.
/// Merupakan [StatefulWidget] karena tampilannya akan berubah (misalnya, daftar barang diperbarui).
class BarangScreen extends StatefulWidget {
  // Konstruktor untuk BarangScreen. Key adalah parameter opsional yang membantu Flutter dalam mengidentifikasi widget.
  const BarangScreen({super.key, required this.title});

  final String title; // Judul untuk layar, biasanya ditampilkan di AppBar.

  @override
  _BarangScreenState createState() => _BarangScreenState(); // Membuat State untuk widget ini.
}

/// State terkait untuk [BarangScreen].
/// Ini mengelola data dan logika yang terkait dengan tampilan layar barang.
class _BarangScreenState extends State<BarangScreen> {
  List<Item> barangItems = []; // Daftar [Item] yang akan ditampilkan di UI. Ini diperbarui dari Firestore.
  String selectedKategori = 'Semua Kategori'; // Kategori yang saat ini dipilih untuk memfilter daftar barang.
  TextEditingController searchController = TextEditingController(); // Controller untuk input teks pencarian.
  bool isSearching = false; // Status apakah mode pencarian sedang aktif atau tidak.

  /*
  -------------------------------------------------------------------------------------------------------------
  -----------------------------------FIREBASE OPERATIONS-------------------------------------------------------
  -------------------------------------------------------------------------------------------------------------
  */

  @override
  void initState() {
    super.initState();
    fetchRecords(); // Memanggil metode untuk mengambil data awal dari Firestore saat State diinisialisasi.
    // Mendengarkan perubahan data secara real-time dari koleksi Firestore.
    // Setiap kali ada perubahan (tambah, hapus, update) di koleksi, callback ini akan dipicu.
    FirebaseFirestore.instance.collection(COLLECTION_NAME).snapshots().listen((records) {
      mapRecords(records); // Memetakan snapshot data terbaru ke dalam daftar [Item] dan memperbarui UI.
    });
  }

  /// Mengambil semua dokumen dari koleksi Firestore [COLLECTION_NAME].
  /// Ini adalah pengambilan data satu kali (bukan real-time listener).
  fetchRecords() async {
    // Mengambil snapshot dokumen dari koleksi yang ditentukan.
    var records = await FirebaseFirestore.instance.collection(COLLECTION_NAME).get();
    mapRecords(records); // Memproses dan memetakan data yang diambil.
  }

  /// Memetakan [QuerySnapshot] dari Firestore ke dalam daftar objek [Item].
  /// [records]: Snapshot data dari Firestore yang berisi dokumen-dokumen.
  mapRecords(QuerySnapshot<Map<String, dynamic>> records) {
    // Mengubah setiap dokumen dalam snapshot menjadi objek [Item].
    var _list = records.docs.map(
      (item) => Item(
        id: item.id, // ID dokumen Firestore, digunakan untuk operasi update/delete.
        name: item['name'], // Nama barang.
        hargapcs: item['hargapcs'], // Harga per unit/pcs.
        hargapak: item['hargapak'], // Harga per pak.
        kategori: item['kategori'], // Kategori barang.
        modal: item['modal'], // Modal barang.
      ),
    ).toList(); // Mengubah hasil iterasi menjadi List<Item>.

    // Memperbarui state widget dengan daftar barang yang baru.
    // Ini akan memicu pembangunan ulang (rebuild) widget UI.
    setState(() {
      barangItems = _list; // Memperbarui daftar barang utama.
    });
  }

  /// Memfilter daftar [barangItems] berdasarkan kategori yang dipilih dan teks pencarian.
  /// Mengembalikan daftar [Item] yang sudah difilter.
  List<Item> getFilteredItems() {
    List<Item> items = barangItems; // Salin daftar item agar tidak memodifikasi yang asli langsung.

    // Filter berdasarkan kategori jika bukan 'Semua Kategori'.
    if (selectedKategori != 'Semua Kategori') {
      items = items.where((item) => item.kategori == selectedKategori).toList();
    }

    // Filter berdasarkan teks pencarian jika ada input.
    if (searchController.text.isNotEmpty) {
      items = items.where((item) =>
        item.name.toLowerCase().contains(searchController.text.toLowerCase()) // Pencarian case-insensitive.
      ).toList();
    }
    return items; // Mengembalikan daftar item yang sudah difilter.
  }

  /// Mengurutkan daftar [barangItems] secara alfabetis berdasarkan nama barang.
  void sortItemsByName() {
    barangItems.sort((a, b) => a.name.compareTo(b.name)); // Menggunakan compareTo untuk pengurutan string.
  }

  /*
  -------------------------------------------------------------------------------------------------------------
  -----------------------------USER INTERFACE (UI) LAYOUT----------------------------------------------------
  -------------------------------------------------------------------------------------------------------------
  */

  @override
  Widget build(BuildContext context) {
    sortItemsByName(); // Pastikan daftar barang selalu diurutkan sebelum ditampilkan.
    List<Item> filteredItems = getFilteredItems(); // Dapatkan item yang sudah difilter untuk ditampilkan.

    return Scaffold(
      body: CustomScrollView( // Digunakan untuk efek AppBar yang dapat digulir dan fleksibel.
        slivers: <Widget>[
          SliverAppBar(
            pinned: true, // AppBar tetap terlihat di bagian atas saat menggulir.
            elevation: 0, // Menghilangkan bayangan di bawah AppBar.
            forceElevated: true, // Memaksa AppBar untuk memiliki elevasi (meskipun 0) saat digulir.
            backgroundColor: Colors.white, // Warna latar belakang AppBar.
            title: Center( // Mengatur judul di tengah AppBar.
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Mengatur elemen di baris ke awal.
                children: [
                  // Dropdown untuk memilih kategori. Dibungkus dengan DropdownButtonHideUnderline
                  // untuk menghilangkan garis bawah default.
                  DropdownButtonHideUnderline(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45), // Border di sekitar dropdown.
                        borderRadius: BorderRadius.circular(12), // Sudut border yang membulat.
                      ),
                      child: DropdownButton<String>(
                        value: selectedKategori, // Nilai yang saat ini dipilih.
                        hint: const Text('Pilih Kategori'), // Teks petunjuk.
                        isDense: true, // Membuat dropdown lebih ringkas secara vertikal.
                        isExpanded: false, // Tidak memperluas dropdown untuk mengisi lebar.
                        items: kategoriList.map<DropdownMenuItem<String>>((String kategori) {
                          return DropdownMenuItem<String>(
                            value: kategori,
                            child: Text(kategori),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          // Dipanggil ketika pengguna memilih item baru dari dropdown.
                          setState(() {
                            selectedKategori = newValue!; // Perbarui kategori yang dipilih.
                          });
                        },
                      ),
                    ),
                  ),

                  // Tombol ikon untuk mengaktifkan/menonaktifkan mode pencarian.
                  IconButton(
                    onPressed: (){
                      setState(() {
                        isSearching = !isSearching; // Toggle status pencarian.
                        if (!isSearching) {
                          searchController.clear(); // Hapus teks pencarian saat menutup mode pencarian.
                        }
                      });
                    },
                    icon: Icon(isSearching ? Icons.close : Icons.search), // Ganti ikon berdasarkan status pencarian.
                  ),
                ],
              ),
            ),
            // Widget di bagian bawah AppBar.
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50), // Tinggi yang diinginkan untuk bagian bawah AppBar.
              child: Container(
                alignment: Alignment.center,
                color: Colors.blueGrey[700], // Warna latar belakang bagian bawah AppBar.
                child: Column(
                  children: [
                    // TextField untuk pencarian, hanya terlihat jika isSearching true.
                    if(isSearching)
                    SingleChildScrollView( // Memastikan TextField bisa digulir jika teksnya panjang (jarang terjadi pada search bar).
                      child: TextField(
                        controller: searchController, // Mengikat TextField ke searchController.
                        style: const TextStyle(color: Colors.white), // Gaya teks input.
                        decoration: const InputDecoration(
                          hintText: 'Cari barang...', // Teks petunjuk di TextField.
                          hintStyle: TextStyle(color: Colors.white70), // Gaya teks petunjuk.
                          // Batas input dihilangkan untuk tampilan yang lebih bersih di AppBar.
                        ),
                        onChanged: (value) {
                          // Dipanggil setiap kali teks input berubah.
                          // Memicu setState untuk memperbarui daftar barang yang difilter.
                          setState(() {});
                        },
                      ),
                    ),
                    // Header tabel untuk daftar barang, hanya terlihat jika isSearching false.
                    if(!isSearching)
                    Table(
                      columnWidths: const {
                        0: FixedColumnWidth(50.0), // Lebar tetap untuk kolom "No".
                        1: FlexColumnWidth(1.0), // Lebar fleksibel untuk kolom lainnya.
                        2: FlexColumnWidth(1.0),
                        3: FlexColumnWidth(1.0),
                      },
                      border: TableBorder.all(
                        color: Colors.blueGrey[800]!, // Warna border untuk semua sisi.
                        width: 0.5, // Ketebalan border.
                      ),
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text("No", style: fontbold.copyWith(color: Colors.white)), // Menggunakan fontbold dari reusablecode.dart.
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
              )
            ),
          ),
          // Daftar barang yang dapat digulir dan ditampilkan sebagai SliverList.
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index){
                var item = filteredItems[index]; // Ambil item pada indeks saat ini.
                return Slidable( // Widget yang memungkinkan penggeseran item untuk menampilkan aksi.
                  key: ValueKey(item.id), // Key unik untuk setiap Slidable item, penting untuk performa dan identifikasi.
                  endActionPane: ActionPane( // Aksi yang muncul saat menggeser dari kanan.
                    motion: const ScrollMotion(), // Efek gerakan saat menggeser.
                    children: [
                      SlidableAction(
                        onPressed: (context){
                          deleteItem(item.id); // Panggil metode untuk menghapus item.
                        },
                        backgroundColor: Colors.red, // Warna latar belakang aksi delete.
                        foregroundColor: Colors.white, // Warna ikon/teks.
                        icon: Icons.delete, // Ikon delete.
                        // label: 'Delete', // Label teks.
                        spacing: 8, // Jarak antar aksi.
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          // Panggil dialog update saat aksi edit ditekan.
                          showUpdateDialog(item.id, item.name, item.hargapcs, item.hargapak, item.kategori ?? '', item.modal ?? '');
                        },
                        backgroundColor: Colors.yellow[800]!, // Warna latar belakang aksi edit.
                        foregroundColor: Colors.white,
                        icon: Icons.edit, // Ikon edit.
                        // label: 'Edit',
                        // spacing: 8,
                      ),
                      SlidableAction(
                        onPressed: null, // Aksi ini tidak dapat ditekan (hanya menampilkan info).
                        backgroundColor: Colors.blue[700]!, // Warna latar belakang untuk menampilkan modal.
                        foregroundColor: Colors.white,
                        label: 'Modal: ${item.modal}', // Tampilkan nilai modal sebagai label.
                        spacing: 8,
                      )
                    ]
                  ),
                  child: Table( // Tampilan detail item dalam bentuk tabel.
                    columnWidths: const {
                      0: FixedColumnWidth(50.0), // Lebar tetap untuk nomor.
                      1: FlexColumnWidth(1.0),
                      2: FlexColumnWidth(1.0),
                      3: FlexColumnWidth(1.0),
                    },
                    border: const TableBorder(
                      horizontalInside: BorderSide.none, // Tidak ada border horizontal di dalam.
                      verticalInside: BorderSide.none, // Tidak ada border vertikal di dalam.
                      top: BorderSide(width: 0.5, color: Colors.grey), // Border atas tipis untuk setiap baris.
                      bottom: BorderSide.none, // Tidak ada border bawah.
                      left: BorderSide.none, // Tidak ada border kiri.
                      right: BorderSide.none, // Tidak ada border kanan.
                    ),
                    children: [
                      TableRow(
                        children: [
                          TableCell(child: Center(child: Padding(padding: const EdgeInsets.all( 7.0), child: Text((index + 1).toString()),))), // Nomor urut item.
                          TableCell(child: Align(alignment:Alignment.centerLeft, child: Padding(padding: const EdgeInsets.all(7.0), child: Text(item.name),))), // Nama barang.
                          TableCell(child: Center(child: Padding(padding: const EdgeInsets.all(7.0), child: Text(item.hargapcs),))), // Harga per pcs.
                          TableCell(child: Center(child: Padding(padding: const EdgeInsets.all(7.0), child: Text(item.hargapak),))), // Harga per pak.
                        ],
                      ),
                    ],
                  ),
                );
              },
              childCount: filteredItems.length // Jumlah item yang akan dibangun dalam daftar.
            )
          )
        ],
      ),
      // Tombol aksi mengambang untuk menambahkan barang baru.
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog, // Panggil metode untuk menampilkan dialog tambah barang.
        child: const Icon(Icons.add), // Ikon tambah.
      ),
    );
  }

  /*
  -------------------------------------------------------------------------------------------------------------
  --------------------------------------------APPLICATION LOGIC------------------------------------------------
  -------------------------------------------------------------------------------------------------------------
  */

  /// Menampilkan dialog untuk menambahkan item barang baru.
  showAddDialog() {
    // Inisialisasi controller untuk input teks pada dialog.
    var nameController = TextEditingController();
    var hargapcsController = TextEditingController();
    var hargapakController = TextEditingController();
    var modalController = TextEditingController();

    // Daftar kategori yang tersedia untuk dipilih di dropdown dialog.
    var _currencies = [
      "Rokok", "Makanan", "Minuman", "Pindang", "ATK", "Plastik", "Lainnya",
    ];

    String _currentSelectedKategori = _currencies[0]; // Inisialisasi dropdown dengan kategori pertama.

    showDialog(
      context: context,
      builder: (context) {
        // Menggunakan StatefulBuilder agar dialog dapat memperbarui state-nya sendiri (misalnya dropdown).
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Membuat kolom sekecil mungkin sesuai kontennya.
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Membentang elemen secara horizontal.
                  children: [
                    const Center(
                      child: Text('Detail Barang', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(height: 20),
                    // TextField untuk input Nama Barang.
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
                    // TextField untuk input Harga Barang / pcs.
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
                    // TextField untuk input Harga Barang / pak.
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
                              value: _currentSelectedKategori,
                              isDense: true,
                              onChanged: (String? newValue) {
                                // Memperbarui state dialog saat kategori berubah.
                                setState(() {
                                  _currentSelectedKategori = newValue ?? _currencies[0]; // Tangani nilai null.
                                  state.didChange(newValue);
                                });
                              },
                              items: _currencies.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    // TextField untuk input Harga Modal.
                    TextField(
                      controller: modalController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        labelText: 'Harga Modal',
                      ),
                    ),
                    // Tombol untuk menyimpan data barang baru.
                    ElevatedButton(
                      onPressed: () {
                        // Ambil nilai dari setiap controller dan bersihkan spasi ekstra.
                        var name = nameController.text.trim();
                        var hargapcs = hargapcsController.text.trim();
                        var hargapak = hargapakController.text.trim();
                        var modal = modalController.text.trim();
                        // Panggil metode untuk menambahkan item ke Firestore.
                        addItem(name, hargapcs, hargapak, _currentSelectedKategori, modal);
                        Navigator.of(context).pop(); // Tutup dialog setelah menambahkan barang.
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
  /// [id]: ID dokumen item di Firestore.
  /// [currentName], [currentHargapcs], [currentHargapak], [currentKategori], [currentModal]: Nilai item saat ini.
  showUpdateDialog(String id, String currentName, String currentHargapcs, String currentHargapak, String currentKategori, String currentModal) {
    // Inisialisasi controller dengan nilai-nilai item yang ada saat ini.
    var nameController = TextEditingController(text: currentName);
    var hargapcsController = TextEditingController(text: currentHargapcs);
    var hargapakController = TextEditingController(text: currentHargapak);
    var modalController = TextEditingController(text: currentModal); // Pastikan modalController diinisialisasi dengan currentModal

    // Inisialisasi kategori yang dipilih dengan nilai kategori saat ini.
    String _currentSelectedValue = currentKategori;

    showDialog(context: context, builder: (context) {
      // Menggunakan StatefulBuilder agar dialog dapat memperbarui state-nya sendiri (misalnya dropdown).
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
                  // TextField untuk Nama Barang.
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Barang')),
                  // TextField untuk Harga Barang / pcs.
                  TextField(controller: hargapcsController, decoration: const InputDecoration(labelText: 'Harga Barang / pcs')),
                  // TextField untuk Harga Barang / pak.
                  TextField(controller: hargapakController, decoration: const InputDecoration(labelText: 'Harga Barang / pak')),
                  const SizedBox(height: 10),
                  // Dropdown untuk memilih Kategori.
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
                            value: _currentSelectedValue,
                            isDense: true,
                            onChanged: (String? newValue) {
                              // Memperbarui state dialog saat kategori berubah.
                              setState(() {
                                _currentSelectedValue = newValue ?? ''; // Tangani nilai null jika diperlukan.
                                state.didChange(newValue);
                              });
                            },
                            items: filteredKategoriList.map((String value) { // Menggunakan filteredKategoriList
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  // TextField untuk Modal.
                  TextField(controller: modalController, decoration: const InputDecoration(labelText: 'Modal')),
                  const SizedBox(height: 10),
                  // Tombol untuk memperbarui data.
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Ambil nilai terbaru dari controller.
                        var name = nameController.text.trim();
                        var hargapcs = hargapcsController.text.trim();
                        var hargapak = hargapakController.text.trim();
                        var kategori = _currentSelectedValue; // Ambil kategori yang dipilih dari dropdown.
                        var modal = modalController.text.trim();

                        // Panggil metode untuk memperbarui item di Firestore.
                        updateItem(id, name, hargapcs, hargapak, kategori, modal);
                        Navigator.pop(context); // Menutup dialog setelah memperbarui.
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

  /// Menambahkan item baru ke koleksi Firestore.
  /// [name], [hargapcs], [hargapak], [kategori], [modal]: Data item yang akan ditambahkan.
  addItem(String name, String hargapcs, String hargapak, String kategori, String modal) {
    // Buat objek Item baru. ID akan otomatis dihasilkan oleh Firestore.
    var item = Item(id: 'id', name: name, hargapcs: hargapcs, hargapak: hargapak, kategori: kategori, modal: modal);
    // Tambahkan item ke koleksi Firestore.
    FirebaseFirestore.instance.collection(COLLECTION_NAME).add(item.toJson());
  }

  /// Memperbarui data item yang sudah ada di Firestore.
  /// [id]: ID dokumen item yang akan diperbarui.
  /// [name], [hargapcs], [hargapak], [kategori], [modal]: Data item yang diperbarui.
  updateItem(String id, String name, String hargapcs, String hargapak, String kategori, String modal) {
    // Perbarui dokumen dengan ID yang sesuai di koleksi Firestore.
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
  /// [id]: ID dokumen item yang akan dihapus.
  deleteItem(String id) {
    // Hapus dokumen dengan ID yang sesuai dari koleksi Firestore.
    FirebaseFirestore.instance.collection(COLLECTION_NAME).doc(id).delete();
  }
}
