import 'package:flutter/material.dart';
import '../../../core/session_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../widgets/status_card_widget.dart';
import '../widgets/filter_chip_list_widget.dart';
import '../widgets/table_grid_widget.dart';
import 'qr_scanner_screen.dart';
import 'timer_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _activeFilter = AppStrings.filterAll;
  
  final List<Map<String, dynamic>> _allTables = List.generate(12, (index) {
    return {
      'id': index + 1,
      'isFull': index < 3,
      'hasSocket': index % 2 == 0,
      'isSilentArea': index >= 6,
    };
  });

  @override
  void initState() {
    super.initState();
    SessionManager().onReservationExpired = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rezervasyon süreniz (10 dk tolerans) doldu. Masanız boşa çıkarıldı.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    };
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onTableTap(int tableNumber, bool isFull) {
    if (isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu masa dolu.'), backgroundColor: AppColors.error),
      );
    } else {
      _showReservationDialog(tableNumber);
    }
  }

  void _showReservationDialog(int tableNumber) {
    showDialog(
      context: context,
      builder: (context) {
        TimeOfDay selectedTime = TimeOfDay.now();
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Masa $tableNumber Rezerve Et', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Kütüphaneye ne zaman geleceksiniz? Geldiğinizde QR okutmayı unutmayın."),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Seçilen Saat: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setStateDialog(() => selectedTime = time);
                          }
                        },
                        child: Text(selectedTime.format(context), style: const TextStyle(fontSize: 18, color: AppColors.primary)),
                      ),
                    ],
                  )
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppStrings.cancelButton, style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    DateTime startTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                    // Eğer seçilen saat geçmişse, yarına rezerve ediyordur
                    if (startTime.isBefore(now)) {
                      startTime = startTime.add(const Duration(days: 1));
                    }
                    
                    SessionManager().rezerveEt('Masa $tableNumber', startTime);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rezervasyon başarıyla oluşturuldu!")));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
                  ),
                  child: const Text("Rezerve Et"),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  List<Map<String, dynamic>> _getFilteredTables() {
    return _allTables.map((table) {
      bool pass = true;
      if (_activeFilter == AppStrings.filterEmpty && table['isFull']) pass = false;
      if (_activeFilter == AppStrings.filterWithSocket && !table['hasSocket']) pass = false;
      if (_activeFilter == AppStrings.filterSilentArea && !table['isSilentArea']) pass = false;
      return {...table, 'isPassive': !pass};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SessionManager(),
      builder: (context, child) {
        bool isAtTable = SessionManager().oturdugumMasa != null;
        
        Widget qrSekmesi = isAtTable 
            ? (SessionManager().isQrScanned ? const TimerScreen() : const QrScannerScreen()) 
            : const QrScannerScreen();

        final List<Widget> pages = [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusCardWidget(
                  isAtTable: isAtTable,
                  tableName: SessionManager().oturdugumMasa,
                  isQrScanned: SessionManager().isQrScanned,
                  reservationCountdown: SessionManager().reservationCountdown,
                  onManageTap: () => _onItemTapped(1),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p20, AppSizes.p16, AppSizes.p12),
                  child: Text(
                    AppStrings.tableFilterTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                FilterChipListWidget(
                  activeFilter: _activeFilter,
                  onFilterChanged: (filter) => setState(() => _activeFilter = filter),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p12),
                  child: Text(
                    AppStrings.floorPlanTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  child: TableGridWidget(
                    tables: _getFilteredTables(),
                    onTableTap: _onTableTap,
                  ),
                ),
                const SizedBox(height: AppSizes.p32),
              ],
            ),
          ),
          qrSekmesi,
          const ProfileScreen(),
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(AppStrings.appName),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
              )
            ],
          ),
          body: pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            backgroundColor: Colors.white,
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: AppStrings.navMap),
              BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: AppStrings.navSession),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: AppStrings.navProfile),
            ],
          ),
        );
      }
    );
  }
}