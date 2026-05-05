import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profil Kısmı (İsim-Soyisim, Fotoğraf, Unvan ve Düzenle Butonu)
            _buildProfileSection(context),
            const SizedBox(height: 30),
            // Başarımlarım Kısmı
            _buildAchievementsSection(context),
            // Ayarlar Kısmı
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Profil Fotoğrafı
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor,
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // TODO: Profil fotoğrafı değiştirme eklenecek
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // İsim Soyisim
          const Text(
            'İsim Soyisim',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Görünen Unvan
          const Text(
            'Unvan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          // Profili Düzenle Butonu
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Profili düzenleme modülü / sayfası açılacak
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'Profili Düzenle',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
        ),
        title: const Text(
          'Başarımlarım',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          // TODO: Başarımlarım ekranına yönlendirme
        },
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.settings, color: Colors.blueGrey, size: 28),
        ),
        title: const Text(
          'Ayarlar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          // TODO: Ayarlar ekranına yönlendirme
        },
      ),
    );
  }
}
