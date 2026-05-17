import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lütfen tüm alanları doldurunuz.'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    if (!email.toLowerCase().endsWith('.edu') && !email.toLowerCase().endsWith('.edu.tr')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sadece üniversite e-posta adresleri (.edu veya .edu.tr) ile kayıt olabilirsiniz.'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Firestore'da kullanıcı dökümanı oluştur
        final newUser = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          points: 0,
          totalStudyTime: 0,
        );
        await FirestoreService().createUser(newUser);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? 'Kayıt olurken bir hata oluştu'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person_add_alt_1_rounded, size: AppSizes.iconExtraLarge, color: AppColors.primary),
                  const SizedBox(height: AppSizes.p16),
                  const Text(
                    "Hesap Oluştur",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: -1),
                  ),
                  const SizedBox(height: AppSizes.p48),
                  _buildTextField(controller: _nameController, label: "Ad Soyad", icon: Icons.person_outline),
                  const SizedBox(height: AppSizes.p16),
                  _buildTextField(controller: _emailController, label: AppStrings.emailHint, icon: Icons.email_outlined),
                  const SizedBox(height: AppSizes.p16),
                  _buildTextField(controller: _passwordController, label: AppStrings.passwordHint, icon: Icons.lock_outline, isPassword: true),
                  const SizedBox(height: AppSizes.p32),
                  _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                          elevation: 5,
                          shadowColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        child: const Text("Kayıt Ol", style: TextStyle(fontSize: 18)),
                      ),
                  const SizedBox(height: AppSizes.p24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
                    child: const Text("Zaten hesabın var mı? Giriş Yap", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.r15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.r15), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.p20),
        ),
      ),
    );
  }
}
