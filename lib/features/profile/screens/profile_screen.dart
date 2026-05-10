import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/session_manager.dart';
import '../../../core/models/user_model.dart';

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
          return const Center(child: Text("Kullanıcı verisi bulunamadı."));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil Header
              Container(
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
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(width: AppSizes.p20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
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
                    // Günlük Seri (Streak) - Şimdilik statik kalabilir veya veriye bağlanabilir
                    Container(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSizes.r15),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.local_fire_department, color: AppColors.warning),
                          Text("7 Gün", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    _buildStatCard("Kazanılan Puan", "${user.points} XP", Icons.star_rounded),
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Henüz veri yok."));
                  }

                  final topUsers = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topUsers.length,
                    itemBuilder: (context, index) {
                      final topUser = topUsers[index];
                      bool isMe = topUser.uid == user.uid; 
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isMe ? AppColors.primary : Colors.grey.shade200,
                          child: Text("${index + 1}", style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                        ),
                        title: Text(
                          topUser.name, 
                          style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
                        ),
                        subtitle: Text("Seviye ${(topUser.points / 500).floor() + 1}"),
                        trailing: Text(
                          "${topUser.points} XP", 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        tileColor: isMe ? AppColors.primary.withValues(alpha: 0.1) : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
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
