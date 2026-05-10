import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/user_model.dart';
import '../widgets/avatar_picker_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await FirestoreService().updateUser(widget.user.uid, {
        'name': _nameController.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil başarıyla güncellendi!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profili Düzenle"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AvatarPickerDialog(
                      onAvatarSelected: (url) {
                        FirestoreService().updateUser(widget.user.uid, {'profileImage': url});
                        setState(() {
                          // Yerel olarak da güncelleme görüntüsü verelim (UI anlık tepki versin)
                        });
                      },
                    ),
                  );
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary,
                      backgroundImage: widget.user.profileImage != null ? NetworkImage(widget.user.profileImage!) : null,
                      child: widget.user.profileImage == null 
                        ? const Icon(Icons.person, size: 80, color: Colors.white)
                        : null,
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppColors.primaryDark,
                        radius: 20,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p40),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Ad Soyad",
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            TextField(
              controller: TextEditingController(text: widget.user.email),
              enabled: false,
              decoration: InputDecoration(
                labelText: "E-posta (Değiştirilemez)",
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Değişiklikleri Kaydet", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
