import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final int points;
  final int totalStudyTime;
  final int? currentTableId;
  final String? profileImage;
  final bool isAdmin;
  final List<String> achievements;
  final DateTime? lastSessionDate;
  final int consecutiveDays;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.points,
    required this.totalStudyTime,
    this.currentTableId,
    this.profileImage,
    this.isAdmin = false,
    this.achievements = const [],
    this.lastSessionDate,
    this.consecutiveDays = 0,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? 'İsimsiz Kullanıcı',
      email: data['email'] ?? '',
      points: data['points'] ?? 0,
      totalStudyTime: data['totalStudyTime'] ?? 0,
      currentTableId: data['currentTableId'],
      profileImage: data['profileImage'],
      isAdmin: data['isAdmin'] ?? false,
      achievements: List<String>.from(data['achievements'] ?? []),
      lastSessionDate: data['lastSessionDate'] != null ? (data['lastSessionDate'] as Timestamp).toDate() : null,
      consecutiveDays: data['consecutiveDays'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'points': points,
      'totalStudyTime': totalStudyTime,
      'currentTableId': currentTableId,
      'profileImage': profileImage,
      'isAdmin': isAdmin,
      'achievements': achievements,
      'lastSessionDate': lastSessionDate != null ? Timestamp.fromDate(lastSessionDate!) : null,
      'consecutiveDays': consecutiveDays,
    };
  }
}
