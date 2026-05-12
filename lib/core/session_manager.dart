import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionManager {
  // Singleton yapısı (Her yerden aynı veriye ulaşmak için)
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? oturdugumMasa; // Null ise masada değilim
  bool moladaMi = false;
  int kalanSure = 15 * 60;
  DateTime? oturumBaslangicZamani;

  void oturumuBaslat(String masaId) {
    oturdugumMasa = masaId;
    moladaMi = false;
    kalanSure = 15 * 60;
    oturumBaslangicZamani = DateTime.now();
  }

  Future<void> oturumuKapat() async {
    if (oturumBaslangicZamani != null) {
      int kazanilanPuan = DateTime.now().difference(oturumBaslangicZamani!).inMinutes;
      
      if (kazanilanPuan > 0) {
        // Firebase'e puanı ekle (Demo için sabit bir kullanıcı ID'si varsayıyoruz)
        String myUserId = "demo_kullanici"; // Gerçek projede Firebase Auth UID kullanılacak
        
        DocumentReference userDoc = FirebaseFirestore.instance.collection('leaderboard_points').doc(myUserId);
        
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(userDoc);
          if (!snapshot.exists) {
            transaction.set(userDoc, {
              'name': 'Ben (Demo)',
              'totalPoints': kazanilanPuan,
            });
          } else {
            int mevcutPuan = (snapshot.data() as Map<String, dynamic>)['totalPoints'] ?? 0;
            transaction.update(userDoc, {'totalPoints': mevcutPuan + kazanilanPuan});
          }
        });
      }
    }

    oturdugumMasa = null;
    moladaMi = false;
    oturumBaslangicZamani = null;
  }
}