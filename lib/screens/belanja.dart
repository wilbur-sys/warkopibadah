import 'package:cloud_firestore/cloud_firestore.dart'; // Paket untuk Firebase Firestore (database NoSQL)
import 'package:flutter/material.dart'; // Paket inti Flutter untuk membangun UI
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Paket untuk input teks autocomplete
import 'package:intl/intl.dart'; // Paket untuk pemformatan tanggal dan waktu

// Nama koleksi Firestore yang digunakan untuk menyimpan data barang untuk saran autocomplete
const COLLECTION_NAME = 'barang_items';

/// Widget utama untuk layar belanja.
/// Ini adalah [StatefulWidget] karena UI-nya akan berubah (misalnya, menampilkan formulir, detail, atau interaksi kalender).
class BelanjaScreen extends StatefulWidget {
  const BelanjaScreen({super.key});

  @override
  _BelanjaScreenState createState() => _BelanjaScreenState(); // Membuat State untuk widget ini.
}

/// State terkait dengan [BelanjaScreen].
/// Ini mengelola data dan logika yang terkait dengan tampilan layar belanja.
class _BelanjaScreenState extends State<BelanjaScreen> {
  // Hari-hari dalam seminggu yang ditampilkan di kisi kalender
  final List<String> daysOfWeek = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  bool showForm = false; // Status untuk menunjukkan atau menyembunyikan formulir penambahan barang belanja
  final _formKey = GlobalKey<FormState>(); // GlobalKey untuk mengakses status formulir secara global
  String _namaBelanja = ''; // Variabel untuk menyimpan nama barang belanja dari input pengguna
  int _jumlah = 0; // Variabel untuk menyimpan jumlah barang belanja dari input pengguna
  final List<Map<String, dynamic>> _belanjaList = []; // Daftar untuk menyimpan item daftar belanja yang akan ditampilkan di DataTable
  List<String> _namaBarang = []; // Daftar untuk menyimpan nama barang dari Firestore untuk saran pelengkapan otomatis
  final TextEditingController searchNamaBarangController = TextEditingController(); // Controller untuk bidang pencarian nama barang
  bool showDetail = false; // Status untuk menampilkan atau menyembunyikan detail belanja
  DateTime? selectedDate; // Variabel untuk menyimpan tanggal yang dipilih untuk detail belanja
  String _selectedOption = 'pak'; // Variabel untuk menyimpan nilai dropdown yang dipilih ('pak' atau 'runtui')

  @override
  void initState() {
    super.initState();
    // Panggil fetchRecords() saat initState() dipanggil untuk mengambil data barang dari Firestore
    fetchRecords();
    // Berlangganan perubahan data real-time dari Firestore menggunakan snapshots()
    // Ini akan memicu mapRecords setiap kali ada perubahan di koleksi 'barang_items'
    FirebaseFirestore.instance.collection(COLLECTION_NAME).snapshots().listen((records) {
      mapRecords(records); // Panggil mapRecords() untuk memetakan data Firestore ke _namaBarang
    });
  }

  /// Fungsi untuk mengambil data barang dari Firestore secara asynchronous.
  fetchRecords() async {
    var records = await FirebaseFirestore.instance.collection(COLLECTION_NAME).get();
    mapRecords(records); // Panggil mapRecords() untuk memetakan data Firestore ke _namaBarang
  }

  /// Fungsi untuk memetakan data dari Firestore QuerySnapshot ke dalam [_namaBarang].
  /// [records]: QuerySnapshot yang berisi dokumen dari Firestore.
  mapRecords(QuerySnapshot<Map<String, dynamic>> records) {
    // Mengambil nilai 'name' dari setiap dokumen dan mengubahnya menjadi daftar string.
    var list = records.docs.map((item) => item['name'] as String).toList();
    setState(() {
      _namaBarang = list; // Perbarui _namaBarang dengan data yang diambil dari Firestore
    });
  }

  /// Fungsi untuk memberikan saran nama barang berdasarkan kueri pencarian.
  /// [query]: String input pengguna.
  /// Mengembalikan daftar nama barang yang cocok yang berisi `query`.
  List<String> suggestions(String query) {
    return _namaBarang.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String monthName = DateFormat.yMMMM().format(now); // Format bulan dan tahun saat ini (misalnya, "Juni 2025")
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1); // Hari pertama bulan saat ini
    // Hitung hari kerja dari hari pertama bulan (0 untuk Minggu, 6 untuk Sabtu).
    // Modulo 7 memastikan hasilnya antara 0-6.
    int startWeekday = firstDayOfMonth.weekday % 7;

    return Scaffold(
      body: showDetail
          ? _buildDetailBelanja() // Tampilkan detail belanja jika showDetail true
          : showForm
              ? SingleChildScrollView(
                  child: _buildForm(), // Tampilkan formulir belanja jika showForm true
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          monthName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Baris yang menampilkan nama-nama hari dalam seminggu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: daysOfWeek.map((day) => Expanded(
                                  child: Center(
                                    child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                )).toList(),
                      ),
                      const SizedBox(height: 10),
                      // GridView untuk menampilkan hari-hari kalender
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7, // 7 kolom untuk 7 hari dalam seminggu
                          ),
                          itemCount: daysInMonth(now) + startWeekday, // Total item: hari dalam sebulan + sel kosong di awal
                          itemBuilder: (context, index) {
                            if (index < startWeekday) {
                              // Jika indeks kurang dari startWeekday, render sel kosong
                              return const Center(child: Text(''));
                            }
                            // Hitung tanggal untuk sel saat ini
                            DateTime date = DateTime(now.year, now.month, index - startWeekday + 1);
                            // Periksa apakah tanggal saat ini adalah hari ini
                            bool isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                            return GestureDetector(
                              onTap: () => _showDetailBelanja(date), // Mengetuk tanggal akan menampilkan detail belanjanya
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start, // Sejajarkan teks ke atas
                                  children: [
                                    Text(
                                      DateFormat.d().format(date), // Tampilkan nomor hari
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                        color: isToday ? Colors.blue : Colors.black,
                                      ),
                                    ),
                                    const Text('') // Placeholder untuk informasi tambahan di bawah tanggal
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tombol aksi mengambang untuk menambahkan item belanja (awalnya ditampilkan)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showForm = true; // Tampilkan formulir saat tombol ditekan
                            });
                          },
                          child: const Icon(Icons.add),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  /// Widget untuk membangun tampilan detail belanja untuk tanggal yang dipilih.
  Widget _buildDetailBelanja() {
    return FutureBuilder(
      // Ambil data belanja dari Firestore untuk tanggal yang dipilih
      future: _fetchBelanjaData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Tampilkan indikator loading
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Tampilkan pesan error
        } else {
          var belanjaList = snapshot.data as List<Map<String, dynamic>>; // Ubah data snapshot ke daftar peta
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Detail Belanja ${DateFormat.yMMMMd().format(selectedDate!)}', // Tampilkan tanggal yang diformat
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: belanjaList.length,
                    itemBuilder: (context, index) {
                      var item = belanjaList[index];
                      return ListTile(
                        title: Text(item['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Sejajarkan konten subtitle ke awal
                          children: [
                            Text('Jumlah: ${item['jumlah']}'), // Tampilkan kuantitas
                            Text('Opsi: ${item['jumlahpak']}'), // Tampilkan opsi (pak/runtui)
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showDetail = false; // Kembali ke tampilan kalender utama
                      selectedDate = null; // Reset tanggal yang dipilih
                    });
                  },
                  child: const Text('Kembali'), // Tombol kembali
                ),
              ],
            ),
          );
        }
      },
    );
  }

  /// Mengambil data belanja dari Firestore untuk tanggal yang saat ini dipilih.
  /// Data disimpan di bawah `belanja_items/{tanggal_terformat}/items`.
  Future<List<Map<String, dynamic>>> _fetchBelanjaData() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!); // Format tanggal yang dipilih sebagai 'YYYY-MM-DD'
    var querySnapshot = await FirebaseFirestore.instance
        .collection('belanja_items')
        .doc(formattedDate) // Akses dokumen untuk tanggal tertentu
        .collection('items') // Akses subkoleksi item untuk tanggal tersebut
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList(); // Memetakan dokumen ke daftar peta
  }

  /// Widget untuk membangun formulir penambahan item belanja.
  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Tampilkan daftar belanja saat ini di DataTable
          SizedBox(
            height: 300, // Tinggi tetap untuk DataTable
            width: 500, // Lebar tetap untuk DataTable
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('No.')), // Kolom untuk nomor urut
                  DataColumn(label: Text('Nama Barang')), // Kolom untuk nama barang
                  DataColumn(label: Text('Jumlah')), // Kolom untuk jumlah
                  DataColumn(label: Text('Opsi')), // Kolom untuk opsi (pak/runtui)
                ],
                rows: _belanjaList
                    .asMap()
                    .entries
                    .map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(Text((entry.key + 1).toString())), // Sel untuk nomor urut
                          DataCell(Text(entry.value['nama'])), // Sel untuk nama barang
                          DataCell(Text(entry.value['jumlah'].toString())), // Sel untuk jumlah
                          DataCell(Text(entry.value['opsi'])), // Sel untuk opsi
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Baris untuk tombol "Reset" dan "Kirim ke Firebase"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribusikan tombol secara merata
            children: [
              ElevatedButton(onPressed: () {
                setState(() {
                  _belanjaList.clear(); // Tombol untuk menghapus semua item dari _belanjaList
                });
              }, child: const Text("Reset")),
              ElevatedButton(
                onPressed: () {
                  submitToFirebase(); // Tombol untuk mengirimkan data belanja ke Firebase
                },
                child: const Text('Kirim ke Firebase'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Baris untuk tombol "Tambah" dan "Kembali"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribusikan tombol secara merata
            children: [
              ElevatedButton(
                  onPressed: _showAddBarangDialog, // Tombol untuk menampilkan dialog penambahan item belanja
                  child: const Text("Tambah")),
              ElevatedButton(onPressed: () {
                setState(() {
                  showForm = false; // Tombol untuk kembali ke tampilan kalender utama dari formulir
                  searchNamaBarangController.clear(); // Bersihkan bidang pencarian saat kembali
                  _belanjaList.clear(); // Bersihkan daftar lokal saat kembali ke tampilan kalender
                });
              }, child: const Text("Kembali"))
            ],
          )
        ],
      ),
    );
  }

  /// Menampilkan dialog untuk menambahkan item belanja baru.
  void _showAddBarangDialog() async {
    // Reset controller dan opsi yang dipilih sebelum menampilkan dialog
    searchNamaBarangController.clear();
    _namaBelanja = ''; // Bersihkan pilihan sebelumnya
    _jumlah = 0; // Reset kuantitas
    _selectedOption = 'pak'; // Reset opsi ke default

    await showDialog(
      context: context,
      builder: (context) {
        // Menggunakan StatefulBuilder agar dialog dapat memperbarui state-nya sendiri (misalnya dropdown)
        return StatefulBuilder(
          builder: (context, dialogSetState) { // Gunakan dialogSetState untuk menghindari konflik dengan setState utama
            return AlertDialog(
              title: const Text('Tambah Belanja'),
              content: Form(
                key: _formKey, // Kaitkan formulir dengan GlobalKey
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Buat kolom menempati ruang vertikal minimal
                  children: [
                    const SizedBox(height: 10),
                    // TypeAheadField untuk memberikan saran nama barang berdasarkan input pengguna
                    TypeAheadField<String>( // Tentukan tipe generik untuk TypeAheadField
                      controller: searchNamaBarangController,
                      builder: (context, controller, focusNode){
                        return TextField(
                          controller: controller, // Gunakan controller yang disediakan oleh builder
                          focusNode: focusNode,
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nama Barang',
                          ),
                        );
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion), // Tampilkan saran
                        );
                      },
                      onSelected: (suggestion) {
                        dialogSetState(() { // Gunakan dialogSetState untuk memperbarui UI di dalam dialog
                          _namaBelanja = suggestion; // Perbarui _namaBelanja dengan pilihan pengguna
                          searchNamaBarangController.text = _namaBelanja; // Perbarui controller untuk bidang pencarian
                        });
                      },
                      suggestionsCallback: (pattern) async {
                        // Callback untuk mengambil saran nama barang dari Firestore berdasarkan pola pencarian
                        // Menggunakan `isGreaterThanOrEqualTo` dan `isLessThanOrEqualTo` untuk kueri rentang
                        // '\uf8ff' adalah karakter Unicode yang tinggi untuk memastikan pencarian "starts with"
                        final suggestions = await FirebaseFirestore.instance.collection('barang_items')
                            .where('name', isGreaterThanOrEqualTo: pattern)
                            .where('name', isLessThanOrEqualTo: pattern + '\uf8ff')
                            .get();
                        return suggestions.docs.map((doc) => doc['name'] as String).toList(); // Pastikan tipenya String
                      },
                    ),
                    const SizedBox(height: 10),
                    // TextFormField untuk memasukkan jumlah item belanja
                    TextFormField(
                      keyboardType: TextInputType.number, // Atur tipe keyboard ke angka
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Jumlah harus berupa angka';
                        }
                        return null;
                      },
                      onSaved: (value) =>
                          dialogSetState(() => _jumlah = int.parse(value!)), // Simpan kuantitas dari input pengguna
                    ),
                    const SizedBox(height: 10),
                    // DropdownButtonFormField untuk memilih opsi unit ('pak' atau 'runtui')
                    DropdownButtonFormField<String>(
                      value: _selectedOption,
                      items: ['pak', 'runtui'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        dialogSetState(() { // Gunakan dialogSetState untuk memperbarui UI di dalam dialog
                          _selectedOption = newValue!; // Perbarui opsi yang dipilih
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Opsi',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tombol untuk membatalkan dialog
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save(); // Validasi dan simpan data dari formulir
                      setState(() { // Gunakan setState utama untuk memperbarui _belanjaList di luar dialog
                        _belanjaList.add({
                          'nama': _namaBelanja,
                          'jumlah': _jumlah,
                          'opsi': _selectedOption
                        }); // Tambahkan item belanja ke _belanjaList
                      });
                      Navigator.of(context).pop(); // Tutup dialog
                    }
                  },
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Fungsi untuk mengirimkan data daftar belanja ke Firestore.
  /// Setiap item ditambahkan sebagai sub-dokumen di bawah dokumen tanggal tertentu.
  void submitToFirebase() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Format tanggal saat ini
    CollectionReference belanjaCollection = FirebaseFirestore.instance.collection('belanja_items');

    for (var belanja in _belanjaList) {
      belanjaCollection
          .doc(formattedDate) // ID dokumen adalah tanggal
          .collection('items') // Subkoleksi 'items'
          .add({
            'name': belanja['nama'],
            'jumlah': belanja['jumlah'],
            'jumlahpak': belanja['opsi'], // Menggunakan 'opsi' dari daftar lokal
            'timestamp': FieldValue.serverTimestamp(), // Timestamp server Firestore
          })
          .then((value) {
            // Tampilkan Snackbar ketika data berhasil ditambahkan
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data berhasil ditambahkan!'),
              ),
            );
            // Bersihkan daftar lokal setelah pengiriman berhasil untuk menghindari duplikasi
            setState(() {
              _belanjaList.clear();
            });
          })
          .catchError((error) {
            // Tampilkan Snackbar ketika terjadi kesalahan
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal menambahkan data: $error'),
              ),
            );
          });
    }
  }

  void _showDetailBelanja(DateTime date) {
  setState(() {
    selectedDate = date; // Simpan tanggal yang dipilih
    showDetail = true; // Tampilkan detail belanja
  });
}

  /// Fungsi untuk menghitung jumlah hari dalam bulan yang diberikan.
  /// [date]: Tanggal dalam bulan untuk menghitung hari.
  /// Mengembalikan jumlah hari dalam bulan tersebut.
  int daysInMonth(DateTime date) {
    var firstDayThisMonth = DateTime(date.year, date.month, 1);
    var firstDayNextMonth = DateTime(firstDayThisMonth.year, firstDayThisMonth.month + 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }
}
