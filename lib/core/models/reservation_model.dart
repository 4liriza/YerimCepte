import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String userId;
  final int tableId;
  final DateTime startTime;
  final DateTime? endTime;
  final int earnedPoints;
  final String status; // completed, cancelled

  ReservationModel({
    required this.id,
    required this.userId,
    required this.tableId,
    required this.startTime,
    this.endTime,
    required this.earnedPoints,
    required this.status,
  });

  factory ReservationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReservationModel(
      id: id,
      userId: data['userId'] ?? '',
      tableId: data['tableId'] ?? 0,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
      earnedPoints: data['earnedPoints'] ?? 0,
      status: data['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'tableId': tableId,
      'startTime': startTime,
      'endTime': endTime,
      'earnedPoints': earnedPoints,
      'status': status,
    };
  }
}
