class TableModel {
  final int id;
  final bool isFull;
  final bool hasSocket;
  final bool isSilentArea;
  final String? currentUserId;
  final String status; // available, reserved, occupied
  final DateTime? reservationTime;

  TableModel({
    required this.id,
    required this.isFull,
    required this.hasSocket,
    required this.isSilentArea,
    this.currentUserId,
    required this.status,
    this.reservationTime,
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
          ? (map['reservationTime'] as dynamic).toDate() 
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
    };
  }
}
