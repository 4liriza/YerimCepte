import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firestore_service.dart';

class SessionManager extends ChangeNotifier {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String? oturdugumMasa;

  bool moladaMi = false;
  int kalanSure = 20 * 60; // 20 dakika (Mola Hakkı)
  
  // Rezervasyon Özellikleri
  bool isQrScanned = false;
  DateTime? reservationStartTime; // İleri saatli rezervasyon için
  int reservationCountdown = 10 * 60; // 10 dk (Tolerans süresi saniye)
  Timer? _mainTimer;
  VoidCallback? onReservationExpired;

  // Uygulama açılışında buluttaki durumu kontrol et
  Future<void> syncWithCloud() async {
    final user = _auth.currentUser;
    if (user != null) {
      final activeTable = await _firestoreService.getUserActiveTable(user.uid);
      if (activeTable != null) {
        oturdugumMasa = 'Masa ${activeTable.id}';
        isQrScanned = activeTable.status == 'occupied';
        reservationStartTime = activeTable.reservationTime;
        
        // Mola durumu kontrolü
        if (activeTable.breakStartTime != null) {
          moladaMi = true;
          final diff = DateTime.now().difference(activeTable.breakStartTime!);
          final elapsedSeconds = diff.inSeconds;
          kalanSure = (20 * 60) - elapsedSeconds;
          
          if (kalanSure <= 0) {
            oturumuKapat();
          } else {
            _startBreakTimer();
          }
        }

        if (!isQrScanned && reservationStartTime != null) {
          _startBackgroundChecker();
        }
        notifyListeners();
      }
    }
  }

  // İleri Tarihli/Saatli Rezervasyon
  Future<void> rezerveEt(int tableId, DateTime startTime) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestoreService.updateTableStatus(tableId, {
      'status': 'reserved',
      'currentUserId': user.uid,
      'isFull': true,
      'reservationTime': startTime,
      'breakStartTime': null,
    });

    oturdugumMasa = 'Masa $tableId';
    isQrScanned = false;
    reservationStartTime = startTime;
    reservationCountdown = 10 * 60; // 10 dk tolerans
    _startBackgroundChecker();
    notifyListeners();
  }
  
  int? get activeTableId {
    if (oturdugumMasa == null) return null;
    return int.tryParse(oturdugumMasa!.replaceAll('Masa ', ''));
  }

  // Anlık QR Okutma (Kütüphanedeyken Direkt) veya Rezervasyon Onayı
  Future<void> oturumuBaslat([int? tableId]) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Eğer tableId verilmemişse mevcut rezervasyonu kullanmaya çalış
    int? finalTableId = tableId ?? activeTableId;
    
    if (finalTableId == null) return;

    await _firestoreService.updateTableStatus(finalTableId, {
      'status': 'occupied',
      'currentUserId': user.uid,
      'isFull': true,
      'reservationTime': null,
      'breakStartTime': null,
    });

    oturdugumMasa = 'Masa $finalTableId';
    isQrScanned = true;
    reservationStartTime = null;
    _mainTimer?.cancel();
    kalanSure = 20 * 60; // 20 dk mola hakkı resetlenir
    moladaMi = false;
    notifyListeners();
  }

  // Turnikeden Çıkış (Otomatik Mola) Simülasyonu
  void otomatikMolaBaslat() async {
    if (isQrScanned && !moladaMi) {
      int? tableId = int.tryParse(oturdugumMasa!.replaceAll('Masa ', ''));
      if (tableId != null) {
        final now = DateTime.now();
        await _firestoreService.updateTableStatus(tableId, {
          'breakStartTime': now,
        });
        moladaMi = true;
        _startBreakTimer();
        notifyListeners();
      }
    }
  }

  void molaBitir() async {
    if (moladaMi) {
      int? tableId = int.tryParse(oturdugumMasa!.replaceAll('Masa ', ''));
      if (tableId != null) {
        await _firestoreService.updateTableStatus(tableId, {
          'breakStartTime': null,
        });
        moladaMi = false;
        kalanSure = 20 * 60; // Geri dönüldüğünde mola süresi resetlenir (veya istersen saklanabilir)
        _mainTimer?.cancel();
        notifyListeners();
      }
    }
  }


  void oturumuKapat() async {
    if (oturdugumMasa != null) {
      int? tableId = int.tryParse(oturdugumMasa!.replaceAll('Masa ', ''));
      if (tableId != null) {
        await _firestoreService.updateTableStatus(tableId, {
          'status': 'available',
          'currentUserId': null,
          'isFull': false,
          'reservationTime': null,
        });
      }
    }

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