import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Liderlik Tablosu'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Profil Üst Bölümü
          Container(
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Ben (Demo)',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Kütüphane Temsilcisi',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Liderlik Tablosu Başlığı
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '🏅 Liderlik Tablosu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(),
          // Firebase'den Verileri Çekme
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('leaderboard_points')
                  .orderBy('totalPoints', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Henüz çalışan öğrenci yok.\nİlk sen ol!'),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Bilinmeyen Öğrenci';
                    final points = data['totalPoints'] ?? 0;

                    // Rank Stilleri: 1. Altın, 2. Gümüş, 3. Bronz, Diğerleri Gri
                    Color rankColor;
                    FontWeight fontWeight = FontWeight.bold;
                    
                    if (index == 0) {
                      rankColor = const Color(0xFFFFD700); // Altın
                    } else if (index == 1) {
                      rankColor = const Color(0xFFC0C0C0); // Gümüş
                    } else if (index == 2) {
                      rankColor = const Color(0xFFCD7F32); // Bronz
                    } else {
                      rankColor = Colors.grey.shade600; // Gri
                      fontWeight = FontWeight.normal;
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: rankColor.withOpacity(0.2),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: rankColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: rankColor,
                          fontWeight: fontWeight,
                          fontSize: index < 3 ? 18 : 16,
                        ),
                      ),
                      trailing: Text(
                        '$points dk',
                        style: TextStyle(
                          color: rankColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
