import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/belanja_item.dart';

class BelanjaRepository {
  final CollectionReference _belanjaCollection = FirebaseFirestore.instance.collection('belanja_items');
  final CollectionReference _barangCollection = FirebaseFirestore.instance.collection('barang_items');

  // Mengambil stream nama barang dari Firestore
  Stream<QuerySnapshot> getBarangStream() {
    return _barangCollection.snapshots();
  }

  // Mengirim daftar belanja ke Firebase sebagai batch write
  Future<void> submitBelanjaItems(String formattedDate, List<BelanjaItem> belanjaList) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference dateDoc = _belanjaCollection.doc(formattedDate);
    CollectionReference itemsCollection = dateDoc.collection('items');

    for (var belanja in belanjaList) {
      batch.set(itemsCollection.doc(), {
        ...belanja.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // Mengambil data belanja untuk tanggal tertentu
  Future<List<Map<String, dynamic>>> fetchBelanjaDataForDate(String formattedDate) async {
    var querySnapshot = await _belanjaCollection
        .doc(formattedDate)
        .collection('items')
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
