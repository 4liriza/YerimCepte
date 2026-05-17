import 'package:cloud_firestore/cloud_firestore.dart';

class TableModel {
  final int id;
  final bool isFull;
  final bool hasSocket;
  final bool isSilentArea;
  final String? currentUserId;
  final String status; // available, reserved, occupied
  final DateTime? reservationTime;
  final String? nextReservationUserId;
  final DateTime? nextReservationTime;
  final List<Map<String, dynamic>> futureReservations;
  final List<String> futureReservationUserIds;
  final DateTime? breakStartTime;
  final DateTime? sessionStartTime;

  TableModel({
    required this.id,
    required this.isFull,
    required this.hasSocket,
    required this.isSilentArea,
    this.currentUserId,
    required this.status,
    this.reservationTime,
    this.nextReservationUserId,
    this.nextReservationTime,
    this.futureReservations = const [],
    this.futureReservationUserIds = const [],
    this.breakStartTime,
    this.sessionStartTime,
  });

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map['id'] ?? 0,
      isFull: map['isFull'] ?? false,
      hasSocket: map['hasSocket'] ?? false,
      isSilentArea: map['isSilentArea'] ?? false,
      currentUserId: map['currentUserId'],
      status: map['status'] ?? 'available',
      reservationTime: map['reservationTime'] != null 
          ? (map['reservationTime'] as Timestamp).toDate() 
          : null,
      nextReservationUserId: map['nextReservationUserId'],
      nextReservationTime: map['nextReservationTime'] != null 
          ? (map['nextReservationTime'] as Timestamp).toDate() 
          : null,
      futureReservations: (map['futureReservations'] as List<dynamic>?)?.map((e) {
        final m = e as Map<String, dynamic>;
        return {
          'userId': m['userId'] as String,
          'startTime': (m['startTime'] as Timestamp).toDate(),
          'endTime': m['endTime'] != null ? (m['endTime'] as Timestamp).toDate() : null, // Support endTime
        };
      }).toList() ?? [],
      futureReservationUserIds: (map['futureReservationUserIds'] as List<dynamic>?)?.cast<String>() ?? [],
      breakStartTime: map['breakStartTime'] != null 
          ? (map['breakStartTime'] as Timestamp).toDate() 
          : null,
      sessionStartTime: map['sessionStartTime'] != null 
          ? (map['sessionStartTime'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isFull': isFull,
      'hasSocket': hasSocket,
      'isSilentArea': isSilentArea,
      'currentUserId': currentUserId,
      'status': status,
      'reservationTime': reservationTime,
      'nextReservationUserId': nextReservationUserId,
      'nextReservationTime': nextReservationTime,
      'futureReservations': futureReservations.map((e) => {
        'userId': e['userId'],
        'startTime': Timestamp.fromDate(e['startTime'] as DateTime),
        'endTime': e['endTime'] != null ? Timestamp.fromDate(e['endTime'] as DateTime) : null,
      }).toList(),
      'futureReservationUserIds': futureReservationUserIds,
      'breakStartTime': breakStartTime,
      'sessionStartTime': sessionStartTime,
    };
  }
}
