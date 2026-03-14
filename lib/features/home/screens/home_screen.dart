import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart'; // Bu dosyanın var olduğundan emin ol

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

  @override
  Widget build(BuildContext context) {
    // Sayfaları liste olarak burada tanımlıyoruz
    final List<Widget> pages = [
      // 1. SEKME: HARİTA (MapTab yerine doğrudan kodları koyduk)
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 12, // Masa sayısını biraz artıralım, kütüphane büyük görünsün :)
          itemBuilder: (context, index) {
            bool isFull = index < 4; // İlk 4 masa dolu olsun
            return Container(
              decoration: BoxDecoration(
                color: isFull ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Masa ${index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // 2. SEKME: QR TARAYICI
      const QrScannerScreen(),

      // 3. SEKME: PROFİL VE MOLA
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
      appBar: AppBar(
        title: const Text('YerimCep'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {}, // İleride mola uyarıları için
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Harita'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'QR Tarat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}