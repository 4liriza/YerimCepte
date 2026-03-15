import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int molaSuresi = 15 * 60;
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
        _oturumKapat(mesaj: 'Mola süreniz doldu!', renk: Colors.red);
      }
    });
  }

  void _oturumKapat({required String mesaj, Color renk = Colors.green}) {
    _timer?.cancel();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: renk),
    );

    // Uygulamayı ana sayfaya güvenle döndürür
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Masa Oturumu"),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () => _oturumKapat(mesaj: 'Oturum sonlandırıldı.'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Masa A-12', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            // SÜRE BURADA GÖRÜNÜYOR:
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _remainingSeconds / molaSuresi,
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
              onPressed: _isMolaActive
                  ? () => _oturumKapat(mesaj: 'Moladan döndünüz, yeriniz korundu.')
                  : _startTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMolaActive ? Colors.green : Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(_isMolaActive ? 'Masaya Döndüm' : 'Molaya Çık'),
            ),
          ],
        ),
      ),
    );
  }
}