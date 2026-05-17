import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/announcement_model.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addAnnouncement() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final newAnnouncement = AnnouncementModel(
      id: '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: DateTime.now(),
    );

    await FirestoreService().addAnnouncement(newAnnouncement);
    _titleController.clear();
    _contentController.clear();
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Duyuru yayınlandı!")));
    }
  }

  Future<void> _resetAllTables() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Emin misiniz?"),
        content: const Text("Tüm aktif oturumlar sonlandırılacak ve gelecek tüm rezervasyonlar iptal edilecek. Bu işlem geri alınamaz."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("Sıfırla"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await FirestoreService().resetAllTables();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tüm masalar başarıyla sıfırlandı.")));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata oluştu: $e"), backgroundColor: AppColors.error));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yönetici Paneli")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Yeni Duyuru Yayınla", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSizes.p16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Başlık", border: OutlineInputBorder()),
                ),
                const SizedBox(height: AppSizes.p12),
                TextField(
                  controller: _contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "İçerik", border: OutlineInputBorder()),
                ),
                const SizedBox(height: AppSizes.p16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addAnnouncement,
                    child: const Text("Yayınla"),
                  ),
                ),
                const Divider(height: AppSizes.p48),
                const Text("Sistem Yönetimi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSizes.p16),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppColors.primary),
                  title: const Text("Tüm Masaları Sıfırla"),
                  subtitle: const Text("Tüm masaları 'boş' durumuna getirir."),
                  onTap: _isLoading ? null : _resetAllTables,
                ),
                ListTile(
                  leading: const Icon(Icons.add_box_outlined, color: AppColors.success),
                  title: const Text("Yeni Masa Ekle"),
                  onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masa eklendi (Simülasyon).")));
                  },
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
