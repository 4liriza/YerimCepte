import 'package:flutter/material.dart';
import '../../../core/session_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/firestore_service.dart';
import '../widgets/status_card_widget.dart';
import 'qr_scanner_screen.dart';
import 'timer_screen.dart';
import 'library_map_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../core/models/user_model.dart';
import '../../../core/models/announcement_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Sayfa 0: Ana Ekran
          RefreshIndicator(
            onRefresh: () async => SessionManager().syncWithCloud(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Karşılama ve Durum Kartı
                  StreamBuilder<UserModel?>(
                    stream: _firestoreService.streamUser(auth.FirebaseAuth.instance.currentUser?.uid ?? ''),
                    builder: (context, snapshot) {
                      final userName = snapshot.data?.name ?? 'Kullanıcı';
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Hoş geldin,",
                              style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              userName,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                  
                  ListenableBuilder(
                    listenable: SessionManager(),
                    builder: (context, _) => StatusCardWidget(
                      isAtTable: SessionManager().oturdugumMasa != null,
                      tableName: SessionManager().oturdugumMasa,
                      isQrScanned: SessionManager().isQrScanned,
                      reservationCountdown: SessionManager().reservationCountdown,
                      onManageTap: () => _onItemTapped(1),
                    ),
                  ),

                  const SizedBox(height: AppSizes.p24),

                  // Hızlı Rezervasyon Butonu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryMapScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.p24),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppSizes.r20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Çalışmaya Başla!",
                                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Hemen bir masa rezerve et",
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.p32),
                  _buildAnnouncementsSection(),
                  
                  const SizedBox(height: AppSizes.p48),
                ],
              ),
            ),
          ),

          // Sayfa 1: QR / Timer
          ListenableBuilder(
            listenable: SessionManager(),
            builder: (context, _) {
              bool isAtTableInternal = SessionManager().oturdugumMasa != null;
              if (isAtTableInternal) {
                return SessionManager().isQrScanned ? const TimerScreen() : const QrScannerScreen();
              } else {
                return const QrScannerScreen();
              }
            }
          ),

          // Sayfa 2: Profil
          const ProfileScreen(),
        ],
      ),
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