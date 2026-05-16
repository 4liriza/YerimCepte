import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/reservation_model.dart';

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
  DateTime? oturumBaslangicZamani;
  
  // Rezervasyon Özellikleri
  bool isQrScanned = false;
  DateTime? reservationStartTime; // İleri saatli rezervasyon için
  int reservationCountdown = 10 * 60; // 10 dk (Tolerans süresi saniye)
  Timer? _mainTimer;
  VoidCallback? onReservationExpired;

  int? _activeTableId;
  int? get activeTableId => _activeTableId;

  // Uygulama açılışında buluttaki durumu kontrol et
  Future<void> syncWithCloud() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final activeTable = await _firestoreService.getUserActiveTable(user.uid);
        if (activeTable != null) {
          _activeTableId = activeTable.id;
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
              await oturumuKapat();
            } else {
              _startBreakTimer();
            }
          }

          if (!isQrScanned && reservationStartTime != null) {
            _startBackgroundChecker();
          }
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Sync error: $e');
      }
    }
  }

  // İleri Tarihli/Saatli Rezervasyon
  Future<void> rezerveEt(int tableId, DateTime startTime) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.updateTableStatus(tableId, {
        'status': 'reserved',
        'currentUserId': user.uid,
        'isFull': true,
        'reservationTime': startTime,
        'breakStartTime': null,
      });

      _activeTableId = tableId;
      oturdugumMasa = 'Masa $tableId';
      isQrScanned = false;
      reservationStartTime = startTime;
      reservationCountdown = 10 * 60; // 10 dk tolerans
      _startBackgroundChecker();
      notifyListeners();
    } catch (e) {
      debugPrint('Reservation error: $e');
    }
  }

  // Anlık QR Okutma (Kütüphanedeyken Direkt) veya Rezervasyon Onayı
  Future<void> oturumuBaslat([int? tableId]) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Eğer tableId verilmemişse mevcut rezervasyonu kullanmaya çalış
    int? finalTableId = tableId ?? _activeTableId;
    
    if (finalTableId == null) return;

    try {
      await _firestoreService.updateTableStatus(finalTableId, {
        'status': 'occupied',
        'currentUserId': user.uid,
        'isFull': true,
        'reservationTime': null,
        'breakStartTime': null,
      });

      _activeTableId = finalTableId;
      oturdugumMasa = 'Masa $finalTableId';
      isQrScanned = true;
      reservationStartTime = null;
      _mainTimer?.cancel();
      kalanSure = 20 * 60; // 20 dk mola hakkı resetlenir
      moladaMi = false;
      oturumBaslangicZamani = DateTime.now();
      notifyListeners();
    } catch (e) {
      debugPrint('Session start error: $e');
    }
  }

  // Turnikeden Çıkış (Otomatik Mola) Simülasyonu
  void otomatikMolaBaslat() async {
    if (isQrScanned && !moladaMi && _activeTableId != null) {
      try {
        final now = DateTime.now();
        await _firestoreService.updateTableStatus(_activeTableId!, {
          'breakStartTime': now,
        });
        moladaMi = true;
        _startBreakTimer();
        notifyListeners();
      } catch (e) {
        debugPrint('Break start error: $e');
      }
    }
  }

  void molaBitir() async {
    if (moladaMi && _activeTableId != null) {
      try {
        await _firestoreService.updateTableStatus(_activeTableId!, {
          'breakStartTime': null,
        });
        moladaMi = false;
        kalanSure = 20 * 60; // Geri dönüldüğünde mola süresi resetlenir
        _mainTimer?.cancel();
        notifyListeners();
      } catch (e) {
        debugPrint('Break end error: $e');
      }
    }
  }


  Future<void> oturumuKapat({bool isCancelled = false}) async {
    final int? tableId = _activeTableId;
    if (tableId != null) {
      try {
        await _firestoreService.updateTableStatus(tableId, {
          'status': 'available',
          'currentUserId': null,
          'isFull': false,
          'reservationTime': null,
          'breakStartTime': null,
        });
      } catch (e) {
        debugPrint('Session close Firestore error: $e');
      }
    }
    await _oturumuKapatVePuanEkle(tableId: tableId, isCancelled: isCancelled);
  }

  Future<void> _oturumuKapatVePuanEkle({int? tableId, bool isCancelled = false}) async {
    final user = _auth.currentUser;
    if (user != null && tableId != null) {
      int kazanilanPuan = 0;
      if (oturumBaslangicZamani != null && !isCancelled) {
        kazanilanPuan = DateTime.now().difference(oturumBaslangicZamani!).inMinutes;
        if (kazanilanPuan < 0) kazanilanPuan = 0;
      }

      // Rezervasyon Kaydı Oluştur
      final record = ReservationModel(
        id: '', // Firestore auto-id
        userId: user.uid,
        tableId: tableId,
        startTime: oturumBaslangicZamani ?? reservationStartTime ?? DateTime.now(),
        endTime: DateTime.now(),
        earnedPoints: kazanilanPuan,
        status: isCancelled ? 'cancelled' : 'completed',
      );

      try {
        // Puanları güncelle
        if (kazanilanPuan > 0) {
          await _firestoreService.updateUser(user.uid, {
            'points': FieldValue.increment(kazanilanPuan),
            'totalStudyTime': FieldValue.increment(kazanilanPuan),
          });
        }
        // Geçmişe ekle
        await _firestoreService.addReservationRecord(record);
      } catch (e) {
        debugPrint('Error saving session record: $e');
      }
    }

    _activeTableId = null;
    oturdugumMasa = null;
    moladaMi = false;
    isQrScanned = false;
    reservationStartTime = null;
    oturumBaslangicZamani = null;
    _mainTimer?.cancel();
    notifyListeners();
  }

  void reset() {
    _activeTableId = null;
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
            oturumuKapat(isCancelled: true);
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
