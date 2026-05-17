import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/session_manager.dart';
import '../../../core/models/reservation_model.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = SessionManager().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Geçmiş Rezervasyonlarım"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: Text("Giriş yapmalısınız."))
          : StreamBuilder<List<ReservationModel>>(
              stream: FirestoreService().getReservationHistory(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyHistory();
                }

                final history = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(history[index]);
                  },
                );
              },
            ),
    );
  }

  Widget _buildHistoryCard(ReservationModel record) {
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm').format(record.startTime);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.p16),
        leading: Container(
          padding: const EdgeInsets.all(AppSizes.p12),
          decoration: BoxDecoration(
            color: record.status == 'completed' ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            record.status == 'completed' ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: record.status == 'completed' ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text("Masa ${record.tableId}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(dateStr, style: const TextStyle(color: AppColors.textSecondary)),
            if (record.earnedPoints > 0)
              Text("+${record.earnedPoints} XP Kazanıldı", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Text(
          record.status == 'completed' ? "Tamamlandı" : "İptal Edildi",
          style: TextStyle(
            color: record.status == 'completed' ? AppColors.success : AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: AppColors.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text("Henüz bir rezervasyon geçmişin yok.", style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
