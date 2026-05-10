import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/table_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tüm masaları canlı (stream) olarak getir
  Stream<List<TableModel>> getTables() {
    return _firestore.collection('tables').orderBy('id').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TableModel.fromMap(doc.data())).toList();
    });
  }

  // Masa durumunu güncelle (Rezerve et, oturumu aç vb.)
  Future<void> updateTableStatus(int tableId, Map<String, dynamic> data) async {
    final query = await _firestore.collection('tables').where('id', isEqualTo: tableId).get();
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(data);
    }
  }

  // Kullanıcının aktif bir rezervasyonu olup olmadığını kontrol et
  Future<TableModel?> getUserActiveTable(String userId) async {
    final query = await _firestore
        .collection('tables')
        .where('currentUserId', isEqualTo: userId)
        .get();
    
    if (query.docs.isNotEmpty) {
      return TableModel.fromMap(query.docs.first.data());
    }
    return null;
  }
}
