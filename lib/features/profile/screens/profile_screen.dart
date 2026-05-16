import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/session_manager.dart';
import '../../../core/models/user_model.dart';
import 'history_screen.dart';
import 'edit_profile_screen.dart';
import 'admin_panel_screen.dart';
import '../widgets/avatar_picker_dialog.dart';
import '../../../core/constants/avatar_constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = SessionManager().currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text("Lütfen giriş yapın."));
    }

    return StreamBuilder<UserModel?>(
      stream: FirestoreService().streamUser(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Hata: ${snapshot.error}"));
        }

        final user = snapshot.data;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off_rounded, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                const Text("Kullanıcı verisi bulunamadı.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Profilinizi oluşturarak puan kazanmaya başlayabilirsiniz."),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final authUser = auth.FirebaseAuth.instance.currentUser;
                    if (authUser != null) {
                      final newUser = UserModel(
                        uid: authUser.uid,
                        name: authUser.displayName ?? 'Yeni Kullanıcı',
                        email: authUser.email ?? '',
                        points: 0,
                        totalStudyTime: 0,
                        profileImage: AvatarConstants.defaultAvatar,
                      );
                      await FirestoreService().createUser(newUser);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text("Profilimi Oluştur", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil Header
              LayoutBuilder(
                builder: (context, constraints) {
                  double avatarRadius = constraints.maxWidth > 600 ? 50 : 40;
                  return Container(
                    padding: const EdgeInsets.all(AppSizes.p24),
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppSizes.r30),
                        bottomRight: Radius.circular(AppSizes.r30),
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AvatarPickerDialog(
                                onAvatarSelected: (url) {
                                  FirestoreService().updateUser(user.uid, {'profileImage': url});
                                },
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: avatarRadius,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
                                child: user.profileImage == null 
                                  ? Icon(Icons.person, size: avatarRadius + 10, color: Colors.white)
                                  : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, size: 16, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.p20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: constraints.maxWidth > 600 ? 28 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "XP: ${user.points} • Seviye ${ (user.points / 500).floor() + 1 }",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p8),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSizes.r15),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.local_fire_department, color: AppColors.warning, size: 20),
                              Text("7 Gün", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
              
              const SizedBox(height: AppSizes.p24),

              // Haftalık İstatistikler
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: Text("Haftalık İstatistikler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: AppSizes.p12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: Row(
                  children: [
                    _buildStatCard("Toplam Süre", "${user.totalStudyTime} Saat", Icons.timer),
                    const SizedBox(width: AppSizes.p12),
                    _buildStatCard("Puan", "${user.points} XP", Icons.star_rounded),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.p24),

              // Menü Öğeleri
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: Column(
                  children: [
                    _buildMenuTile(
                      context, 
                      "Rezervasyon Geçmişi", 
                      Icons.history_rounded, 
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    _buildMenuTile(
                      context, 
                      "Profili Düzenle", 
                      Icons.edit_outlined, 
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(user: user))),
                    ),
                    if (user.isAdmin) ...[
                      const SizedBox(height: AppSizes.p12),
                      _buildMenuTile(
                        context, 
                        "Yönetici Paneli", 
                        Icons.admin_panel_settings_outlined, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen())),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.p32),

              // Rozetler
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: Text("Kazanılan Rozetler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: AppSizes.p12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  children: [
                    _buildBadge("Odak Ustası", Icons.center_focus_strong, AppColors.success),
                    _buildBadge("Erken Kalkan", Icons.wb_sunny, AppColors.warning),
                    _buildBadge("Kütüphane Kurdu", Icons.library_books, AppColors.primary),
                    _buildBadge("Gece Kuşu", Icons.nights_stay, Colors.deepPurple),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.p32),

              // Liderlik Tablosu
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: Text("Haftanın Liderleri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: AppSizes.p12),
              StreamBuilder<List<UserModel>>(
                stream: FirestoreService().getTopUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSizes.p20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final topUsers = snapshot.data;
                  if (topUsers == null || topUsers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSizes.p20),
                      child: Center(
                        child: Text(
                          'Henüz çalışan öğrenci yok.\nİlk sen ol!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topUsers.length,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                    itemBuilder: (context, index) {
                      final topUser = topUsers[index];
                      bool isMe = topUser.uid == user.uid;

                      Color rankColor;
                      if (index == 0) {
                        rankColor = const Color(0xFFFFD700); // Altın
                      } else if (index == 1) {
                        rankColor = const Color(0xFFC0C0C0); // Gümüş
                      } else if (index == 2) {
                        rankColor = const Color(0xFFCD7F32); // Bronz
                      } else {
                        rankColor = AppColors.textSecondary;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSizes.p8),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text("${index + 1}.", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: index < 3 ? rankColor : AppColors.textSecondary,
                                )),
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isMe ? AppColors.primary.withValues(alpha: 0.2) : Colors.grey.shade200,
                                backgroundImage: topUser.profileImage != null ? NetworkImage(topUser.profileImage!) : null,
                                child: topUser.profileImage == null ? const Icon(Icons.person, size: 20) : null,
                              ),
                            ],
                          ),
                          title: Text(
                            topUser.name, 
                            style: TextStyle(
                              fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                              fontSize: index < 3 ? 18 : 16,
                            ),
                          ),
                          subtitle: Text("Seviye ${(topUser.points / 500).floor() + 1}"),
                          trailing: Text(
                            "${topUser.points} XP", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: isMe ? AppColors.primary : rankColor
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppSizes.p32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.r15),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 30),
            const SizedBox(height: AppSizes.p12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSizes.p12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.r15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
