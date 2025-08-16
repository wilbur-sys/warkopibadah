class BelanjaItem {
  final String nama;
  final int jumlah;
  final String opsi;

  BelanjaItem({
    required this.nama,
    required this.jumlah,
    required this.opsi,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': nama,
      'jumlah': jumlah,
      'jumlahpak': opsi,
    };
  }
}