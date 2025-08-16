import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:warkopibadah/models/harga_beli_barang_item.dart';
import 'package:warkopibadah/viewmodels/harga_beli_barang_viewmodel.dart';

/// Widget yang menampilkan layar Harga Beli Barang (BonToko).
/// Ini adalah sebuah StatelessWidget yang berinteraksi dengan HargaBeliBarangViewModel
/// melalui Provider untuk mendapatkan dan memanipulasi data.
class HargaBeliBarangView extends StatelessWidget {
  const HargaBeliBarangView({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer untuk mendengarkan perubahan pada ViewModel
    return Consumer<HargaBeliBarangViewModel>(
      builder: (context, viewModel, child) {
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
                      // Dropdown kategori yang kini menggunakan data dari ViewModel
                      _kategoriDropdownWidget(viewModel),
                      IconButton(
                        onPressed: () {
                          viewModel.toggleSearching();
                        },
                        icon: Icon(
                            viewModel.isSearching ? Icons.close : Icons.search),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: viewModel.isSearching
                      ? _searchBarWidget(viewModel)
                      : _tableHeaderWidget(),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final item = viewModel.filteredItems[index];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) =>
                                _showDeleteConfirmationDialog(
                                    context, viewModel, item),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            spacing: 8,
                          ),
                          SlidableAction(
                            onPressed: (context) =>
                                _showUpdateDialog(context, viewModel, item),
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
                        },
                        border: const TableBorder(
                          bottom: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        children: [
                          TableRow(
                            children: [
                              _tableCell((index + 1).toString()),
                              _tableCell(' ${item.jumlah} ${item.isi}'),
                              _tableCell(item.nama),
                              _tableCell(item.harga),
                              _tableCell(DateFormat('d/MM/yy', 'id_ID')
                                  .format(item.lastupdate)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: viewModel.filteredItems.length,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDialog(context, viewModel),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  // Widget dropdown kategori kini menerima ViewModel
  Widget _kategoriDropdownWidget(HargaBeliBarangViewModel viewModel) =>
      DropdownButtonHideUnderline(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: viewModel.selectedKategori,
            hint: const Text('Pilih Kategori'),
            isDense: true,
            isExpanded: false,
            items: viewModel.displayKategoriList.map((String kategori) {
              return DropdownMenuItem<String>(
                value: kategori,
                child: Text(kategori),
              );
            }).toList(),
            onChanged: (String? newValue) {
              viewModel.setSelectedKategori(newValue);
            },
          ),
        ),
      );

  Widget _searchBarWidget(HargaBeliBarangViewModel viewModel) => Container(
        alignment: Alignment.center,
        color: Colors.blueGrey[700],
        child: TextField(
          onChanged: (value) {
            viewModel.setSearchQuery(value);
          },
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Cari barang...',
            hintStyle: TextStyle(color: Colors.white70),
            contentPadding: EdgeInsets.all(10),
            border: InputBorder.none,
          ),
        ),
      );

  Widget _tableHeaderWidget() => Container(
        alignment: Alignment.center,
        color: Colors.blueGrey[700],
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(0.5),
          },
          children: [
            TableRow(
              children: [
                _buildHeaderCell("No"),
                _buildHeaderCell("Jumlah"),
                _buildHeaderCell("Nama"),
                _buildHeaderCell("Harga"),
                _buildHeaderCell("Time"),
              ],
            ),
          ],
        ),
      );

  Widget _buildHeaderCell(String text) => Padding(
        padding: const EdgeInsets.all(9.0),
        child: Text(
          text,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );

  Widget _tableCell(String text) => TableCell(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Text(text),
          ),
        ),
      );

  void _showDeleteConfirmationDialog(BuildContext context,
      HargaBeliBarangViewModel viewModel, BonTokoItem item) {
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
                viewModel.deleteItem(item.id);
                Navigator.of(context).pop();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(
      BuildContext context, HargaBeliBarangViewModel viewModel) {
    var jumlahController = TextEditingController();
    var isiController = TextEditingController();
    var namaController = TextEditingController();
    var hargaController = TextEditingController();

    String currentSelectedKategori =
        viewModel.categories.isNotEmpty ? viewModel.categories[0] : '';

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
                  if (viewModel.categories.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: currentSelectedKategori,
                      onChanged: (String? newValue) {
                        setState(() {
                          currentSelectedKategori =
                              newValue ?? viewModel.categories[0];
                        });
                      },
                      items: viewModel.categories.map((String value) {
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
                    const Text(
                        'Tidak ada kategori. Tambahkan kategori terlebih dahulu.'),
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
                    if (jumlahController.text.isEmpty ||
                        namaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Jumlah dan Nama harus diisi')),
                      );
                      return;
                    }
                    viewModel.addItem(
                      jumlahController.text.trim(),
                      isiController.text.trim(),
                      namaController.text.trim(),
                      hargaController.text.trim(),
                      currentSelectedKategori,
                    );
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

  void _showUpdateDialog(BuildContext context,
      HargaBeliBarangViewModel viewModel, BonTokoItem item) {
    var jumlahController = TextEditingController(text: item.jumlah);
    var isiController = TextEditingController(text: item.isi);
    var namaController = TextEditingController(text: item.nama);
    var hargaController = TextEditingController(text: item.harga);

    String currentSelectedKategori =
        viewModel.categories.contains(item.kategori)
            ? item.kategori
            : (viewModel.categories.isNotEmpty ? viewModel.categories[0] : '');

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
                  if (viewModel.categories.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: currentSelectedKategori,
                      onChanged: (String? newValue) {
                        setState(() {
                          currentSelectedKategori =
                              newValue ?? viewModel.categories[0];
                        });
                      },
                      items: viewModel.categories.map((String value) {
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
                    const Text(
                        'Tidak ada kategori. Tambahkan kategori terlebih dahulu.'),
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
                    if (jumlahController.text.isEmpty ||
                        namaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Jumlah dan Nama harus diisi')),
                      );
                      return;
                    }
                    viewModel.updateItem(
                      item.id,
                      jumlahController.text.trim(),
                      isiController.text.trim(),
                      namaController.text.trim(),
                      hargaController.text.trim(),
                      currentSelectedKategori,
                    );
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
