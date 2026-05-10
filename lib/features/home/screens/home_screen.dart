import 'package:flutter/material.dart';
import '../../../core/session_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/table_model.dart';
import '../widgets/status_card_widget.dart';
import '../widgets/filter_chip_list_widget.dart';
import '../widgets/table_grid_widget.dart';
import 'qr_scanner_screen.dart';
import 'timer_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/announcement_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _activeFilter = AppStrings.filterAll;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Uygulama açıldığında buluttaki durumu kontrol et
    SessionManager().syncWithCloud();
    
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
                  onPressed: () async {
                    final now = DateTime.now();
                    DateTime startTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                    if (startTime.isBefore(now)) {
                      startTime = startTime.add(const Duration(days: 1));
                    }
                    
                    await SessionManager().rezerveEt(tableNumber, startTime);
                    
                    if (!context.mounted) return;
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
  
  List<TableModel> _filterTables(List<TableModel> tables) {
    if (_activeFilter == AppStrings.filterAll) return tables;
    
    return tables.where((table) {
      if (_activeFilter == AppStrings.filterEmpty) return !table.isFull;
      if (_activeFilter == AppStrings.filterWithSocket) return table.hasSocket;
      if (_activeFilter == AppStrings.filterSilentArea) return table.isSilentArea;
      return true;
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
                const SizedBox(height: AppSizes.p20),
                _buildAnnouncementsSection(),

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
                  child: StreamBuilder<List<TableModel>>(
                    stream: _firestoreService.getTables(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Hata: ${snapshot.error}'));
                      }
                      final tables = snapshot.data ?? [];
                      return TableGridWidget(
                        tables: _filterTables(tables),
                        onTableTap: _onTableTap,
                      );
                    }
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

  Widget _buildAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
          child: Text(
            "Kütüphane Duyuruları",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSizes.p12),
        SizedBox(
          height: 160,
          child: StreamBuilder<List<AnnouncementModel>>(
            stream: _firestoreService.getAnnouncements(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyAnnouncement();
              }

              final announcements = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return _buildAnnouncementCard(announcements[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSizes.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.r15),
        child: Stack(
          children: [
            if (announcement.imageUrl != null)
              Positioned.fill(
                child: Image.network(
                  announcement.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 40),
                  ),
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 40),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.p12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    announcement.content,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAnnouncement() {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.r15),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: const Center(
        child: Text("Henüz duyuru bulunmuyor", style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}