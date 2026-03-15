import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/session_manager.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // 1. Üst üste okumayı engelleyen kilit mekanizması
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kamera açıldığında kullanıcıya rehberlik eden bir yazı ekleyelim
      appBar: AppBar(title: const Text('Masa QR Kodunu Taratın')),
      body: MobileScanner(
        onDetect: (capture) {
          // Eğer zaten bir kod işleniyorsa, yenisini görmezden gel
          if (isProcessing) return;

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            setState(() {
              isProcessing = true; // Kilidi kapat
            });

            final String code = barcodes.first.rawValue ?? "Masa-1";
            debugPrint('QR Okundu: $code');

            // 2. Hafızaya kaydet: Uygulama artık masada olduğumuzu biliyor
            SessionManager().oturumuBaslat(code);

            // 3. Başarı mesajı
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Giriş Başarılı: $code'),
                backgroundColor: Colors.green,
              ),
            );

            // 4. Sayfayı yenilemek için ana ekrana yönlendir
            // SessionManager dolu olduğu için HomeScreen otomatik olarak TimerScreen'i gösterecek
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
      ),
    );
  }
}