import 'package:flutter/material.dart';
import '../../../core/session_manager.dart';
import 'qr_scanner_screen.dart';
import 'timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Masaya tıklama işlemi
  void _onTableTap(int tableNumber, bool isFull) {
    if (isFull) {
      // Masa doluysa ve oturan bizsek sayaca git, değilsek uyarı ver
      if (SessionManager().oturdugumMasa == 'Masa $tableNumber') {
        _onItemTapped(1); // QR sekmesine (yani artık Sayaç sekmesine) yönlendir
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu masa şu an dolu!')),
        );
      }
    } else {
      // Masa boşsa rezervasyon onay diyaloğu açabiliriz
      _showReservationDialog(tableNumber);
    }
  }

  void _showReservationDialog(int tableNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Masa $tableNumber'),
        content: const Text('Bu masayı rezerve etmek istiyor musunuz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                SessionManager().oturumuBaslat('Masa $tableNumber');
              });
              Navigator.pop(context);
              _onItemTapped(1); // Rezervasyon sonrası sayaca yönlendir
            },
            child: const Text('Rezerve Et'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // DİNAMİK SEKME YÖNETİMİ
    Widget qrSekmesi;
    // Eğer bir masada oturuyorsak kamera yerine TimerScreen'i göster
    if (SessionManager().oturdugumMasa != null) {
      qrSekmesi = const TimerScreen();
    } else {
      qrSekmesi = const QrScannerScreen();
    }

    final List<Widget> pages = [
      // 1. SEKME: HARİTA
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            int tableNum = index + 1;
            // Eğer o masada biz oturuyorsak rengi farklı olsun (mavi gibi)
            bool isMyTable = SessionManager().oturdugumMasa == 'Masa $tableNum';
            bool isFull = index < 4 || isMyTable;

            return InkWell(
              onTap: () => _onTableTap(tableNum, isFull),
              child: Container(
                decoration: BoxDecoration(
                  color: isMyTable ? Colors.blue : (isFull ? Colors.red : Colors.green),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Center(
                  child: Text('Masa $tableNum',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        ),
      ),

      // 2. SEKME: DİNAMİK QR VEYA SAYAÇ
      qrSekmesi,

      // 3. SEKME: PROFİL
      const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text('Enes Karaoğlan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Mola Durumu: Aktif Değil', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('YerimCep')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Harita'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Oturum'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}