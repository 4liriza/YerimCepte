import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/session_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              if (isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String code = barcodes.first.rawValue ?? "";
                debugPrint('QR Okundu: $code');

                // Örn: QR içeriği "1" veya "Masa 1" olabilir.
                // Biz sadece sayı kısmını almaya çalışalım.
                final int? tableId = int.tryParse(code.replaceAll(RegExp(r'[^0-9]'), ''));

                if (tableId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Geçersiz QR kod.')),
                  );
                  return;
                }

                setState(() {
                  isProcessing = true;
                });

                // Anlık rezervasyon veya mevcut rezervasyon onayı
                await SessionManager().oturumuBaslat(tableId);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${AppStrings.qrLoginSuccess} Masa $tableId'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
                  ),
                );
              }
            },
          ),
          
          // QR Scan Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 4),
                borderRadius: BorderRadius.circular(AppSizes.r20),
                color: Colors.transparent,
              ),
              child: isProcessing 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : null,
            ),
          ),
          
          // Helper Text
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppSizes.r20),
                ),
                child: const Text(
                  "Kamerayı masadaki QR koda hizalayın",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}