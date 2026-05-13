import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionManager extends ChangeNotifier {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? oturdugumMasa;
  bool moladaMi = false;
  int kalanSure = 20 * 60; // 20 dakika (Mola Hakkı)
  DateTime? oturumBaslangicZamani;
  
  // Rezervasyon Özellikleri
  bool isQrScanned = false;
  DateTime? reservationStartTime; // İleri saatli rezervasyon için
  int reservationCountdown = 10 * 60; // 10 dk (Tolerans süresi saniye)
  Timer? _mainTimer;
  VoidCallback? onReservationExpired;

  // İleri Tarihli/Saatli Rezervasyon
  void rezerveEt(String masaId, DateTime startTime) {
    oturdugumMasa = masaId;
    isQrScanned = false;
    reservationStartTime = startTime;
    reservationCountdown = 10 * 60; // 10 dk tolerans
    _startBackgroundChecker();
    notifyListeners();
  }
  
  // Anlık QR Okutma (Kütüphanedeyken Direkt) veya Rezervasyon Onayı
  void oturumuBaslat(String masaId) {
    oturdugumMasa = masaId;
    isQrScanned = true;
    reservationStartTime = null;
    _mainTimer?.cancel();
    kalanSure = 20 * 60; // 20 dk mola hakkı resetlenir
    moladaMi = false;
    oturumBaslangicZamani = DateTime.now();
    notifyListeners();
  }

  // Turnikeden Çıkış (Otomatik Mola) Simülasyonu
  void otomatikMolaBaslat() {
    if (isQrScanned && !moladaMi) {
      moladaMi = true;
      _startBreakTimer();
      notifyListeners();
    }
  }

  void molaBitir() {
    if (moladaMi) {
      moladaMi = false;
      notifyListeners();
    }
  }

  // Masada mısın? (Yoklama)
  void yoklamaBaslat(VoidCallback onYoklamaFailed) {
    // Test amaçlı 1 dakika sonra yoklama gelmesini simüle edebiliriz. UI tarafında yapacağız.
  }

  void oturumuKapat() {
    // BURASI ASYNC OLMALI. Lütfen alttaki oturumuKapatAsync'i kullanın veya 
    // bunu async yapıp Firebase'e yazın.
    // Wait, let's just make it async and add the logic.
    _oturumuKapatVePuanEkle();
  }

  Future<void> _oturumuKapatVePuanEkle() async {
    if (oturumBaslangicZamani != null) {
      int kazanilanPuan = DateTime.now().difference(oturumBaslangicZamani!).inMinutes;
      if (kazanilanPuan > 0) {
        String myUserId = "demo_kullanici"; // Gerçek projede auth
        DocumentReference userDoc = FirebaseFirestore.instance.collection('leaderboard_points').doc(myUserId);
        
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(userDoc);
          if (!snapshot.exists) {
            transaction.set(userDoc, {'name': 'Ben (Demo)', 'totalPoints': kazanilanPuan});
          } else {
            int mevcutPuan = (snapshot.data() as Map<String, dynamic>)['totalPoints'] ?? 0;
            transaction.update(userDoc, {'totalPoints': mevcutPuan + kazanilanPuan});
          }
        });
      }
    }

    oturdugumMasa = null;
    moladaMi = false;
    isQrScanned = false;
    reservationStartTime = null;
    oturumBaslangicZamani = null;
    _mainTimer?.cancel();
    notifyListeners();
  }

  void _startBackgroundChecker() {
    _mainTimer?.cancel();
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isQrScanned && reservationStartTime != null) {
        final now = DateTime.now();
        if (now.isAfter(reservationStartTime!)) {
          // Randevu saati gelmiş, tolerans süresi başlıyor
          if (reservationCountdown > 0) {
            reservationCountdown--;
            notifyListeners(); // UI'a süreyi güncelle
          } else {
            // Tolerans bitti, iptal et
            _mainTimer?.cancel();
            oturumuKapat();
            if (onReservationExpired != null) {
              onReservationExpired!();
            }
          }
        }
      }
    });
  }

  void _startBreakTimer() {
    _mainTimer?.cancel();
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (moladaMi && kalanSure > 0) {
        kalanSure--;
        notifyListeners();
      } else if (moladaMi && kalanSure <= 0) {
        _mainTimer?.cancel();
        oturumuKapat(); // Mola süresi bitti, eşyalar toplanacak vs.
      }
    });
  }
}