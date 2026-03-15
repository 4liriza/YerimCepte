import 'dart:async';

class SessionManager {
  // Singleton yapısı (Her yerden aynı veriye ulaşmak için)
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? oturdugumMasa; // Null ise masada değilim
  bool moladaMi = false;
  int kalanSure = 15 * 60;

  void oturumuBaslat(String masaId) {
    oturdugumMasa = masaId;
    moladaMi = false;
    kalanSure = 15 * 60;
  }

  void oturumuKapat() {
    oturdugumMasa = null;
    moladaMi = false;
  }
}