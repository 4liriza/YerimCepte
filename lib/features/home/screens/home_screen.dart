import 'package:flutter/material.dart';
import '../../../core/session_manager.dart';
import 'qr_scanner_screen.dart';
import 'timer_screen.dart';
import '../../profile/screens/profile_screen.dart';

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

  // --- YARDIMCI WIDGET'LAR (Hepsi State sınıfının içinde olmalı) ---

  Widget _buildStatusCard() {
    bool isAtTable = SessionManager().oturdugumMasa != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Merhaba, Enes 👋",
              style: TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 10),
          if (isAtTable)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_seat, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${SessionManager().oturdugumMasa} rezerve edildi.",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _onItemTapped(1),
                    style: TextButton.styleFrom(backgroundColor: Colors.white24),
                    child:
                    const Text("Yönet", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          else
            const Text(
              "Henüz bir yer seçmedin.\nHadi çalışmaya başlayalım!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.withOpacity(0.2),
      ),
    );
  }

  void _onTableTap(int tableNumber, bool isFull) {
    if (isFull) {
      if (SessionManager().oturdugumMasa == 'Masa $tableNumber') {
        _onItemTapped(1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu masa şu an dolu!')),
        );
      }
    } else {
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
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                SessionManager().oturumuBaslat('Masa $tableNumber');
              });
              Navigator.pop(context);
              _onItemTapped(1);
            },
            child: const Text('Rezerve Et'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget qrSekmesi = SessionManager().oturdugumMasa != null
        ? const TimerScreen()
        : const QrScannerScreen();

    final List<Widget> pages = [
      // --- 1. SEKME: HARİTA ---
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text("Masa Filtrele",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterChip("Hepsi", true),
                  _filterChip("Boşlar", false),
                  _filterChip("Prizliler", false),
                  _filterChip("Sessiz Alan", false),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text("Kat Planı",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  int tableNum = index + 1;
                  bool isMyTable =
                      SessionManager().oturdugumMasa == 'Masa $tableNum';
                  bool isFull = index < 4 || isMyTable;

                  return InkWell(
                    onTap: () => _onTableTap(tableNum, isFull),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isMyTable
                            ? Colors.blue
                            : (isFull ? Colors.red : Colors.green),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Center(
                        child: Text('Masa $tableNum',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      qrSekmesi,
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('YerimCep'), elevation: 0),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Harita'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'Oturum'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}