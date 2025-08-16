import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warkopibadah/viewmodels/belanja_viewmodel.dart';

class BelanjaView extends StatelessWidget {
  const BelanjaView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BelanjaViewModel>(context);
    
    DateTime now = DateTime.now();
    String monthName = DateFormat.yMMMM('id_ID').format(now);
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    int startWeekday = firstDayOfMonth.weekday % 7;
    final List<String> daysOfWeek = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return Scaffold(
      body: viewModel.showDetail
          ? _buildDetailBelanja(context, viewModel)
          : viewModel.showForm
              ? SingleChildScrollView(child: _buildForm(context, viewModel))
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: daysOfWeek.map((day) => Expanded(
                              child: Center(
                                child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            )).toList(),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                          ),
                          itemCount: viewModel.daysInMonth(now) + startWeekday,
                          itemBuilder: (context, index) {
                            if (index < startWeekday) {
                              return const Center(child: Text(''));
                            }
                            DateTime date = DateTime(now.year, now.month, index - startWeekday + 1);
                            bool isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                            return GestureDetector(
                              onTap: () => viewModel.toggleDetail(date),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat.d().format(date),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                        color: isToday ? Colors.blue : Colors.black,
                                      ),
                                    ),
                                    const Text('')
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () => viewModel.toggleForm(true),
                          child: const Icon(Icons.add),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailBelanja(BuildContext context, BelanjaViewModel viewModel) {
    return FutureBuilder(
      future: viewModel.fetchBelanjaDataForDate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          var belanjaList = snapshot.data as List<Map<String, dynamic>>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Detail Belanja ${DateFormat.yMMMMd('id_ID').format(viewModel.selectedDate!)}',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jumlah: ${item['jumlah']}'),
                            Text('Opsi: ${item['jumlahpak']}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => viewModel.toggleDetail(null),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildForm(BuildContext context, BelanjaViewModel viewModel) {
    final _formKey = GlobalKey<FormState>();
    String _namaBelanja = '';
    int _jumlah = 0;
    String _selectedOption = 'pak';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            width: 500,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('No.')),
                  DataColumn(label: Text('Nama Barang')),
                  DataColumn(label: Text('Jumlah')),
                  DataColumn(label: Text('Opsi')),
                ],
                rows: viewModel.belanjaList
                    .asMap()
                    .entries
                    .map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(Text((entry.key + 1).toString())),
                          DataCell(Text(entry.value.nama)),
                          DataCell(Text(entry.value.jumlah.toString())),
                          DataCell(Text(entry.value.opsi)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () => viewModel.resetBelanjaList(),
                  child: const Text("Reset")),
              ElevatedButton(
                onPressed: () => viewModel.submitToFirebase(context),
                child: const Text('Kirim ke Firebase'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _showAddBarangDialog(context, _formKey, _namaBelanja, _jumlah, _selectedOption),
                child: const Text("Tambah"),
              ),
              ElevatedButton(
                onPressed: () => viewModel.toggleForm(false),
                child: const Text("Kembali"),
              )
            ],
          )
        ],
      ),
    );
  }
  
  void _showAddBarangDialog(BuildContext context, GlobalKey<FormState> formKey, String namaBelanja, int jumlah, String selectedOption) {
    final viewModel = Provider.of<BelanjaViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Tambah Belanja'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    TypeAheadField<String>(
                      controller: viewModel.searchNamaBarangController,
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
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
                          title: Text(suggestion),
                        );
                      },
                      onSelected: (suggestion) {
                        dialogSetState(() {
                          namaBelanja = suggestion;
                          viewModel.searchNamaBarangController.text = namaBelanja;
                        });
                      },
                      suggestionsCallback: (pattern) async {
                        return viewModel.getSuggestions(pattern);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.number,
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
                          dialogSetState(() => jumlah = int.parse(value!)),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedOption,
                      items: ['pak', 'runtui'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        dialogSetState(() {
                          selectedOption = newValue!;
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
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      viewModel.addBelanjaItem(namaBelanja, jumlah, selectedOption);
                      Navigator.of(context).pop();
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
}