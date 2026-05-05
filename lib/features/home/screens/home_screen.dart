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

  void _onTableTap(int tableNumber, bool isFull) {
    if (isFull) {
      if (SessionManager().oturdugumMasa == 'Masa $tableNumber') {
        _onItemTapped(1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.tableFullMessage),
            backgroundColor: AppColors.error,
          ),
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
        title: Text('Masa $tableNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(AppStrings.reserveConfirmTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancelButton, style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                SessionManager().oturumuBaslat('Masa $tableNumber');
              });
              Navigator.pop(context);
              _onItemTapped(1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
            ),
            child: const Text(AppStrings.reserveButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAtTable = SessionManager().oturdugumMasa != null;

    Widget qrSekmesi = isAtTable ? const TimerScreen() : const QrScannerScreen();

    final List<Widget> pages = [
      // --- 1. SEKME: HARİTA ---
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusCardWidget(
              isAtTable: isAtTable,
              tableName: SessionManager().oturdugumMasa,
              onManageTap: () => _onItemTapped(1),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p20, AppSizes.p16, AppSizes.p12),
              child: Text(
                AppStrings.tableFilterTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const FilterChipListWidget(),
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p12),
              child: Text(
                AppStrings.floorPlanTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: TableGridWidget(onTableTap: _onTableTap),
            ),
            const SizedBox(height: AppSizes.p32),
          ],
        ),
      ),
      qrSekmesi,
      const Center(child: Text('Profil Sekmesi')),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
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
}