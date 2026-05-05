import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/session_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int molaSuresi = 10;
  int _remainingSeconds = molaSuresi;
  Timer? _timer;
  bool _isMolaActive = false;

  void _startTimer() {
    setState(() => _isMolaActive = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _oturumKapat(mesaj: AppStrings.timerEndedMessage, renk: AppColors.error);
      }
    });
  }

  void _oturumKapat({required String mesaj, Color renk = AppColors.success}) {
    _timer?.cancel();
    SessionManager().oturumuKapat();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: renk),
    );

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? tableName = SessionManager().oturdugumMasa ?? "Masa";
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.timerScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: AppColors.error),
            onPressed: () => _oturumKapat(mesaj: AppStrings.sessionEndedMessage),
            tooltip: 'Oturumu Kapat',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.r20),
              ),
              child: Text(
                tableName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 60),

            // SÜRE BURADA GÖRÜNÜYOR:
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: _remainingSeconds / molaSuresi,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    color: _isMolaActive ? AppColors.warning : AppColors.success,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w800,
                        color: _isMolaActive ? AppColors.warning : AppColors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (_isMolaActive)
                      const Text(
                        "Mola Süresi",
                        style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 60),
            ElevatedButton.icon(
              onPressed: _isMolaActive
                  ? () => _oturumKapat(mesaj: AppStrings.backFromBreakMessage)
                  : _startTimer,
              icon: Icon(_isMolaActive ? Icons.check_circle_outline : Icons.coffee_rounded),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMolaActive ? AppColors.success : AppColors.warning,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p40, vertical: AppSizes.p20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r30)),
                elevation: 8,
                shadowColor: (_isMolaActive ? AppColors.success : AppColors.warning).withOpacity(0.5),
              ),
              label: Text(
                _isMolaActive ? AppStrings.returnToTableButton : AppStrings.takeBreakButton,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}