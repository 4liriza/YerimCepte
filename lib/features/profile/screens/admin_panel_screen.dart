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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yönetici Paneli")),
      body: SingleChildScrollView(
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
                child: _isLoading ? const CircularProgressIndicator() : const Text("Yayınla"),
              ),
            ),
            const Divider(height: AppSizes.p48),
            const Text("Sistem Yönetimi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p16),
            ListTile(
              leading: const Icon(Icons.refresh, color: AppColors.primary),
              title: const Text("Tüm Masaları Sıfırla"),
              subtitle: const Text("Tüm masaları 'boş' durumuna getirir."),
              onTap: () {
                // Bu özellik için tüm masaları döngüye sokacak bir metod servis katmanına eklenebilir
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu özellik yakında eklenecek.")));
              },
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
    );
  }
}
