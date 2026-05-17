import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/session_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';

class QrScannerScreen extends StatefulWidget {
  final VoidCallback? onNavigateHome;
  const QrScannerScreen({super.key, this.onNavigateHome});

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

                int? tableId;
                
                // Eğer zaten bir rezervasyon varsa, herhangi bir QR kodu onay olarak kabul et
                if (SessionManager().oturdugumMasa != null) {
                  tableId = SessionManager().activeTableId;
                } else {
                  // Rezervasyon yoksa QR kodun içindeki sayıyı parse et
                  tableId = int.tryParse(code.replaceAll(RegExp(r'[^0-9]'), ''));
                  
                  // Hala null ise (kullanıcı "herhangi bir qr" dediği için) test amaçlı Masa 1'e ata
                  tableId ??= 1;
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
            bottom: 100,
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
          
          // İptal Butonu
          ListenableBuilder(
            listenable: SessionManager(),
            builder: (context, _) {
              final session = SessionManager();
              if (session.reservationStartTime != null && !session.isQrScanned) {
                return Positioned(
                  bottom: 30,
                  left: 24,
                  right: 24,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      session.oturumuKapat(isCancelled: true);
                      if (widget.onNavigateHome != null) {
                        widget.onNavigateHome!();
                      }
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text("Rezervasyonu İptal Et", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}