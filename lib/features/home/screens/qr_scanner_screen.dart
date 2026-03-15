import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/session_manager.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // Üst üste okumayı engelleyen kilit mekanizması
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masa QR Kodunu Taratın')),
      body: MobileScanner(
        onDetect: (capture) {
          if (isProcessing) return;

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            setState(() {
              isProcessing = true; // Kilidi kapat
            });

            final String code = barcodes.first.rawValue ?? "Masa-1";
            debugPrint('QR Okundu: $code');

            SessionManager().oturumuBaslat(code);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Giriş Başarılı: $code'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
      ),
    );
  }
}