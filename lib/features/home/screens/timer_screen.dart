import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // Mola süresi sabitimiz (15 dakika)
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
        // SÜRE BİTTİĞİNDE: Sayacı durdur ve masayı boşalt
        _timer?.cancel();
        _masaBosalt();
      }
    });
  }

  // Molayı Bitir (Döndüm) tuşuna basıldığında
  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isMolaActive = false;
      _remainingSeconds = molaSuresi; // Süreyi tekrar 15 dakikaya resetle
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Moladan döndünüz, süreniz yenilendi.')),
    );
  }

  // Süre dolduğunda otomatik çalışan fonksiyon
  void _masaBosalt() {
    if (!mounted) return;

    // Kullanıcıya bilgi ver
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mola süreniz doldu! Masanız otomatik boşaltıldı.'),
        backgroundColor: Colors.red,
      ),
    );

    // Ana sayfaya (Haritaya) geri gönder
    Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text("Masa Durumu")),
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
                    value: _remainingSeconds / molaSuresi,
                    strokeWidth: 10,
                    // Moladayken turuncu, değilken yeşil
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