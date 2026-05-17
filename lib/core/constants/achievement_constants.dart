import 'package:flutter/material.dart';
import 'app_colors.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class AchievementConstants {
  static const String odakUstasiId = 'odak_ustasi';
  static const String erkenKalkanId = 'erken_kalkan';
  static const String kutuphaneKurduId = 'kutuphane_kurdu';
  static const String geceKusuId = 'gece_kusu';
  static const String ilkGunId = 'ilk_gun';

  static const List<Achievement> achievements = [
    Achievement(
      id: ilkGunId,
      title: 'İlk Gün',
      description: 'İlk kütüphane oturumunu başlatarak bu başarımı kazanabilirsin.',
      icon: Icons.celebration,
      color: Colors.orange,
    ),
    Achievement(
      id: odakUstasiId,
      title: 'Odak Ustası',
      description: 'Ara vermeden 3 saat çalışarak bu başarımı kazanabilirsin.',
      icon: Icons.center_focus_strong,
      color: AppColors.success,
    ),
    Achievement(
      id: erkenKalkanId,
      title: 'Erken Kalkan',
      description: 'Saat 06:00 ile 08:00 arasında bir çalışma oturumu başlatarak bu başarımı kazanabilirsin.',
      icon: Icons.wb_sunny,
      color: AppColors.warning,
    ),
    Achievement(
      id: kutuphaneKurduId,
      title: 'Kütüphane Kurdu',
      description: 'Üst üste 7 gün boyunca çalışma oturumu açarak bu başarımı kazanabilirsin.',
      icon: Icons.library_books,
      color: AppColors.primary,
    ),
    Achievement(
      id: geceKusuId,
      title: 'Gece Kuşu',
      description: 'Saat 00:00 ile 03:00 arasında çalışarak bu başarımı kazanabilirsin.',
      icon: Icons.nights_stay,
      color: Colors.deepPurple,
    ),
  ];
}
