class UserModel {
  final String uid;
  final String name;
  final String email;
  final int points;
  final int totalStudyTime;
  final int? currentTableId;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.points,
    required this.totalStudyTime,
    this.currentTableId,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? 'İsimsiz Kullanıcı',
      email: data['email'] ?? '',
      points: data['points'] ?? 0,
      totalStudyTime: data['totalStudyTime'] ?? 0,
      currentTableId: data['currentTableId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'points': points,
      'totalStudyTime': totalStudyTime,
      'currentTableId': currentTableId,
    };
  }
}
