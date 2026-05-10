import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String? imageUrl;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl,
  });

  factory AnnouncementModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AnnouncementModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
    );
  }
}
