import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enes K.",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Seviye 5 • Çalışkan Öğrenci",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Günlük Seri (Streak)
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
                _buildStatCard("Toplam Süre", "24 Saat", Icons.timer),
                const SizedBox(width: AppSizes.p12),
                _buildStatCard("Kazanılan Puan", "1200 XP", Icons.star_rounded),
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('leaderboard_points')
                .orderBy('totalPoints', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.p20),
                    child: Text('Henüz çalışan öğrenci yok.\nİlk sen ol!'),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Bilinmeyen Öğrenci';
                  final points = data['totalPoints'] ?? 0;
                  bool isMe = name == "Ben (Demo)"; // Şimdilik isme göre kendimizi anlıyoruz

                  Color rankColor;
                  FontWeight fontWeight = FontWeight.bold;
                  
                  if (index == 0) {
                    rankColor = const Color(0xFFFFD700); // Altın
                  } else if (index == 1) {
                    rankColor = const Color(0xFFC0C0C0); // Gümüş
                  } else if (index == 2) {
                    rankColor = const Color(0xFFCD7F32); // Bronz
                  } else {
                    rankColor = Colors.grey.shade600; // Gri
                    fontWeight = FontWeight.normal;
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMe ? AppColors.primary : rankColor.withValues(alpha: 0.2),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isMe ? Colors.white : rankColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        color: isMe ? Colors.black : rankColor,
                        fontWeight: isMe ? FontWeight.bold : fontWeight,
                        fontSize: index < 3 ? 18 : 16,
                      ),
                    ),
                    trailing: Text(
                      '$points dk',
                      style: TextStyle(
                        color: isMe ? AppColors.primary : rankColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    tileColor: isMe ? AppColors.primary.withValues(alpha: 0.1) : null,
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSizes.p32),
        ],
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
