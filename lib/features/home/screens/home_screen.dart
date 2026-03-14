import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';

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
    // Sayfaları build içinde tanımlayarak tema ve context hatalarını önlüyoruz
    final List<Widget> pages = [
      const MapTab(), // Harita sekmen (GridView olan kısım)
      const QrScannerScreen(), // İŞTE BURASI: Artık kamera açılacak
      const Center(child: Text('Profil ve Mola Ayarları')),

      Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            // Proje Planı: Dolu, Boş, Molada durumlarının görselleştirilmesi
            bool isFull = index < 3;
            return Container(
              decoration: BoxDecoration(
                color: isFull ? Colors.red : Colors.green, // Canlı Doluluk Haritası renkleri
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Masa ${index + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
      const Center(child: Text('QR Tarayıcı Hazırlanıyor...')),
      const Center(child: Text('Profil ve Mola Ayarları')),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('YerimCep')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Önemli: Bu özellikler 'items' listesinin dışında olmalıydı
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