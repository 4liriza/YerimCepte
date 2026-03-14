import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // Mola süresi: 15 dakika (saniye cinsinden)
  int _remainingSeconds = 15 * 60;
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
        _stopTimer();
        // Süre bittiğinde yapılacak işlem (Masa boşaltılacak)
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isMolaActive = false);
  }

  // Saniyeyi Dakika:Saniye formatına çeviren yardımcı fonksiyon
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel(); // Bellek sızıntısını önlemek için önemli
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Masa A-12', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _remainingSeconds / (15 * 60), // İlerleme çubuğu
                    strokeWidth: 10,
                    color: _isMolaActive ? Colors.orange : Colors.green,
                  ),
                ),
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isMolaActive ? _stopTimer : _startTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMolaActive ? Colors.red : Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(_isMolaActive ? 'Molayı Bitir (Döndüm)' : 'Molaya Çık'),
            ),
          ],
        ),
      ),
    );
  }
}