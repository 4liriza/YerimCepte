import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        // QR kod algılandığında tetiklenecek fonksiyon
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('Bulunan QR İçeriği: ${barcode.rawValue}');
            // Burada QR içeriğini kontrol edip masayı onaylayacağız
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Masa Onaylandı: ${barcode.rawValue}')),
            );
          }
        },
      ),
    );
  }
}