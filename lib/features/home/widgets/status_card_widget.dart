import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/session_manager.dart';

class StatusCardWidget extends StatelessWidget {
  final bool isAtTable;
  final String? tableName;
  final bool isQrScanned;
  final int reservationCountdown;
  final VoidCallback onManageTap;

  const StatusCardWidget({
    super.key,
    required this.isAtTable,
    this.tableName,
    required this.isQrScanned,
    required this.reservationCountdown,
    required this.onManageTap,
  });

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String statusText = "";
    Color statusColor = AppColors.primary;
    
    if (isAtTable) {
      if (isQrScanned) {
        statusText = "Masadasınız - İyi Çalışmalar!";
      } else {
        final startTime = SessionManager().reservationStartTime;
        if (startTime != null) {
          final now = DateTime.now();
          if (now.isBefore(startTime)) {
            // Henüz saati gelmedi
            statusText = "Rezerve: ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
            statusColor = Colors.orange;
          } else {
            // Saati geldi, tolerans işliyor
            statusText = "Lütfen QR Okutun! Kalan Süre: ${_formatTime(reservationCountdown)}";
            statusColor = AppColors.warning;
          }
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.r30),
          bottomRight: Radius.circular(AppSizes.r30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x334F46E5),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "${AppStrings.welcomePrefix}, Öğrenci 👋",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.p12),
          if (isAtTable)
            Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSizes.r15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                    child: Icon(
                      isQrScanned ? Icons.event_seat : Icons.timer_outlined, 
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$tableName",
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: isQrScanned ? AppColors.textLight : statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onManageTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                      ),
                    ),
                    child: const Text(AppStrings.manageButtonText),
                  )
                ],
              ),
            )
          else
            const Text(
              AppStrings.noTableMessage,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }
}
