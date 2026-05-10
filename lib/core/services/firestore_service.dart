import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/table_model.dart';
import '../models/user_model.dart';
import '../models/announcement_model.dart';
import '../models/reservation_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tüm masaları canlı (stream) olarak getir
  Stream<List<TableModel>> getTables() {
    return _firestore.collection('tables').orderBy('id').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TableModel.fromMap(doc.data())).toList();
    });
  }

  // Masa durumunu güncelle (Rezerve et, oturumu aç, mola baslat vb.)
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

  // Kullanıcı verilerini canlı takip et
  Stream<UserModel?> streamUser(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  // Kullanıcı verilerini bir kez getir
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // Yeni kullanıcı dökümanı oluştur
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  // Duyuruları getir
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _firestore.collection('announcements').orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AnnouncementModel.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  // En yüksek puanlı 10 kullanıcıyı getir (Liderlik Tablosu)
  Stream<List<UserModel>> getTopUsers() {
    return _firestore.collection('users').orderBy('points', descending: true).limit(10).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  // Kullanıcı bilgilerini güncelle (Profil düzenleme)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Rezervasyon geçmişini getir
  Stream<List<ReservationModel>> getReservationHistory(String userId) {
    return _firestore
        .collection('reservations_history')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReservationModel.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  // Admin: Yeni duyuru ekle
  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    await _firestore.collection('announcements').add({
      'title': announcement.title,
      'content': announcement.content,
      'date': Timestamp.fromDate(announcement.date),
      'imageUrl': announcement.imageUrl,
    });
  }

  // Admin: Duyuru sil
  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
  }

  // Admin: Yeni masa ekle
  Future<void> addTable(TableModel table) async {
    await _firestore.collection('tables').add(table.toMap());
  }

  // Rezervasyon Kaydı Ekle (Oturum bittiğinde çağrılır)
  Future<void> addReservationRecord(ReservationModel record) async {
    await _firestore.collection('reservations_history').add(record.toFirestore());
  }
}
