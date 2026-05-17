import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    }).handleError((error) {
      debugPrint('Error fetching tables: $error');
      return <TableModel>[];
    });
  }

  // Masa durumunu güncelle (Rezerve et, oturumu aç, mola baslat vb.)
  Future<void> updateTableStatus(int tableId, Map<String, dynamic> data) async {
    try {
      final query = await _firestore.collection('tables').where('id', isEqualTo: tableId).get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update(data);
      }
    } catch (e) {
      debugPrint('Error updating table status: $e');
      rethrow;
    }
  }

  // Kullanıcının aktif bir rezervasyonu olup olmadığını kontrol et
  Future<TableModel?> getUserActiveTable(String userId) async {
    try {
      final query = await _firestore
          .collection('tables')
          .where('currentUserId', isEqualTo: userId)
          .get();
      
      if (query.docs.isNotEmpty) {
        return TableModel.fromMap(query.docs.first.data());
      }
    } catch (e) {
      debugPrint('Error getting user active table: $e');
    }
    return null;
  }

  // Kullanıcı verilerini canlı takip et
  Stream<UserModel?> streamUser(String userId) {
    if (userId.isEmpty) return Stream.value(null);
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromFirestore(snapshot.data()!, snapshot.id);
      }
      return null;
    }).handleError((error) {
      debugPrint('Error streaming user: $error');
      return null;
    });
  }

  // Kullanıcı verilerini bir kez getir
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('Error getting user: $e');
    }
    return null;
  }

  // Yeni kullanıcı dökümanı oluştur
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  // Duyuruları getir
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _firestore.collection('announcements').orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AnnouncementModel.fromFirestore(doc.data(), doc.id)).toList();
    }).handleError((error) {
      debugPrint('Error fetching announcements: $error');
      return <AnnouncementModel>[];
    });
  }

  // En yüksek puanlı 10 kullanıcıyı getir (Liderlik Tablosu)
  Stream<List<UserModel>> getTopUsers() {
    return _firestore.collection('users').orderBy('points', descending: true).limit(10).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc.data(), doc.id)).toList();
    }).handleError((error) {
      debugPrint('Error fetching top users: $error');
      return <UserModel>[];
    });
  }

  // Kullanıcı bilgilerini güncelle (Profil düzenleme, puan ekleme vb.)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  // Başarım kilidini aç
  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'achievements': FieldValue.arrayUnion([achievementId]),
      });
    } catch (e) {
      debugPrint('Error unlocking achievement: $e');
    }
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
    }).handleError((error) {
      debugPrint('Error fetching reservation history: $error');
      return <ReservationModel>[];
    });
  }

  // Admin: Yeni duyuru ekle
  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    try {
      await _firestore.collection('announcements').add({
        'title': announcement.title,
        'content': announcement.content,
        'date': Timestamp.fromDate(announcement.date),
        'imageUrl': announcement.imageUrl,
      });
    } catch (e) {
      debugPrint('Error adding announcement: $e');
      rethrow;
    }
  }

  // Admin: Duyuru sil
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection('announcements').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
      rethrow;
    }
  }

  // Admin: Yeni masa ekle
  Future<void> addTable(TableModel table) async {
    try {
      await _firestore.collection('tables').add(table.toMap());
    } catch (e) {
      debugPrint('Error adding table: $e');
      rethrow;
    }
  }

  // Rezervasyon Kaydı Ekle (Oturum bittiğinde çağrılır)
  Future<void> addReservationRecord(ReservationModel record) async {
    try {
      await _firestore.collection('reservations_history').add(record.toFirestore());
    } catch (e) {
      debugPrint('Error adding reservation record: $e');
      rethrow;
    }
  }
}

