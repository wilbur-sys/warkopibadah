import 'dart:convert'; // Mengimpor pustaka 'dart:convert' untuk pengolahan JSON

/// File ini mendefinisikan model data untuk 'Item',
/// yang merepresentasikan sebuah item barang di aplikasi.
/// Ini juga menyediakan fungsi utilitas untuk konversi antara objek Dart dan format JSON.

/// Fungsi utilitas untuk membuat objek [Item] dari string JSON.
///
/// Parameter:
/// - [str]: String JSON yang berisi data item.
///
/// Mengembalikan:
/// - Sebuah instance [Item] yang dibuat dari data JSON.
Item itemFromJson(String str) => Item.fromJson(json.decode(str));

/// Fungsi utilitas untuk mengubah objek [Item] menjadi string JSON.
///
/// Parameter:
/// - [data]: Objek [Item] yang akan diubah.
///
/// Mengembalikan:
/// - Sebuah string JSON yang merepresentasikan data item.
String itemToJson(Item data) => json.encode(data.toJson());

/// Kelas [Item] merepresentasikan sebuah barang dengan properti
/// seperti ID, nama, harga per unit (pcs), harga per paket (pak),
/// kategori, modal, dan ID pengguna terkait (opsional).
class Item {
  String id; // ID unik untuk dokumen item di Firestore atau sumber data lainnya
  String name; // Nama barang
  String hargapcs; // Harga barang per unit/pcs
  String hargapak; // Harga barang per paket/pak
  String? kategori; // Kategori barang (opsional, bisa null)
  String? modal; // Harga modal barang (opsional, bisa null)
  String? userId; // ID pengguna yang terkait dengan item ini (opsional, bisa null)

  /// Konstruktor untuk membuat instance [Item].
  ///
  /// Properti [id], [name], [hargapcs], [hargapak] wajib diisi.
  /// Properti [kategori], [modal], [userId] bersifat opsional dan bisa null.
  Item({
    required this.id,
    required this.name,
    required this.hargapcs,
    required this.hargapak,
    this.kategori,
    this.modal,
    this.userId,
  });

  /// Factory method untuk membuat objek [Item] dari [Map<String, dynamic>]
  /// (biasanya dari data JSON yang didekode atau dokumen Firestore).
  ///
  /// Parameter:
  /// - [json]: Sebuah peta yang berisi pasangan kunci-nilai data item.
  ///
  /// Mengembalikan:
  /// - Sebuah instance [Item] yang dibuat dari data peta.
  ///
  /// Catatan: Operator `??` digunakan untuk memberikan nilai default
  /// jika kunci tidak ada atau nilainya null, untuk properti opsional
  /// atau properti string yang diharapkan tidak null.
  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"] ?? '', // Mengambil ID barang, default ke string kosong jika null
        name: json["name"] ?? '', // Mengambil nama barang, default ke string kosong jika null
        hargapcs: json["hargapcs"] ?? '', // Mengambil harga per pcs, default ke string kosong jika null
        hargapak: json["hargapak"] ?? '', // Mengambil harga per pak, default ke string kosong jika null
        kategori: json["kategori"], // Kategori barang (opsional, biarkan null jika tidak ada)
        modal: json["modal"], // Modal barang (opsional, biarkan null jika tidak ada)
        userId: json["userId"], // ID pengguna (opsional, biarkan null jika tidak ada)
      );

  /// Mengonversi instance [Item] ini menjadi [Map<String, dynamic>]
  /// yang cocok untuk disimpan di Firestore atau di-encode ke JSON.
  ///
  /// Mengembalikan:
  /// - Sebuah peta yang merepresentasikan data item.
  ///
  /// Catatan: Operator `??` digunakan untuk memberikan nilai default (string kosong)
  /// untuk properti opsional yang mungkin null, memastikan bahwa JSON tidak
  /// memiliki nilai null eksplisit jika tidak diinginkan.
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "hargapcs": hargapcs,
        "hargapak": hargapak,
        "kategori": kategori ?? '', // Jika kategori null, gunakan string kosong
        "modal": modal ?? '', // Jika modal null, gunakan string kosong
        "userId": userId ?? '', // Jika userId null, gunakan string kosong
      };
}
