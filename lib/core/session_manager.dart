import 'dart:async';
import 'package:flutter/material.dart';

class SessionManager extends ChangeNotifier {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? oturdugumMasa;
  bool moladaMi = false;
  int kalanSure = 20 * 60; // 20 dakika (Mola Hakkı)
  
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
    oturdugumMasa = null;
    moladaMi = false;
    isQrScanned = false;
    reservationStartTime = null;
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