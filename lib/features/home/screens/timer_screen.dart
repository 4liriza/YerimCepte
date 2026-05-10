import 'package:flutter/material.dart';
import '../../../core/session_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SessionManager(),
      builder: (context, child) {
        final session = SessionManager();
        double progress = session.kalanSure / (20 * 60);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.timer_outlined, size: 80, color: AppColors.primary),
                const SizedBox(height: AppSizes.p24),
                Text(
                  session.moladaMi ? AppStrings.timerBreakTitle : AppStrings.timerActiveTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.p48),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 15,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            session.moladaMi ? AppColors.warning : AppColors.primary,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(session.kalanSure),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: session.moladaMi ? AppColors.warning : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Kalan Mola Hakkı",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.p48),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (session.moladaMi) {
                            session.molaBitir();
                          } else {
                            session.otomatikMolaBaslat();
                          }
                        },
                        icon: Icon(session.moladaMi ? Icons.play_arrow : Icons.pause),
                        label: Text(session.moladaMi ? "Molayı Bitir" : "Mola Ver (20 dk)"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                          backgroundColor: session.moladaMi ? AppColors.success : AppColors.warning,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showExitConfirmDialog(context);
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text(AppStrings.endSessionButton),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p24),
                // Test Simülasyon Butonu
                OutlinedButton.icon(
                  onPressed: () {
                    session.otomatikMolaBaslat();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Turnikeden Çıkış Algılandı! Otomatik Mola Başladı."))
                    );
                  },
                  icon: const Icon(Icons.directions_walk),
                  label: const Text("TEST: Turnikeden Çıkışı Simüle Et"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showExitConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oturumu Sonlandır', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(AppStrings.endSessionConfirm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancelButton, style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              SessionManager().oturumuKapat();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
            ),
            child: const Text('Evet, Ayrılıyorum'),
          ),
        ],
      ),
    );
  }
}