import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'timer_screen.dart'; // Önemli: TimerScreen'i tanıması için bu şart!

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;

          // Eğer en az bir barkod/QR bulunduysa
          if (barcodes.isNotEmpty) {
            final String code = barcodes.first.rawValue ?? "Bilinmeyen Masa";

            debugPrint('QR Okundu: $code');

            // Kullanıcıyı yeni ekrana yönlendiriyoruz
            // pushReplacement kullanıyoruz ki 'geri' basınca tekrar kamera açılmasın
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TimerScreen(),
              ),
            );

            // Başarı mesajı gösterelim
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Giriş Başarılı: $code'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}