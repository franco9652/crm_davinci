import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1926), // Fondo oscuro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Avatar & User Info Card
            _buildUserCard(),
            const SizedBox(height: 20),
            // Settings Section
            _buildSectionTitle('Settings'),
            _buildSettingsItem(Icons.language, 'Language', 'Eng (US)'),
            _buildSettingsItem(Icons.attach_money, 'Currency', 'USD'),
            _buildSettingsItem(Icons.notifications, 'Notifications', '3 Items'),
            _buildSettingsItem(Icons.security, 'Security', '2FA'),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 350 ,
                child: Divider(
                  color: Color(0xffBDBEC0),
                ),
              ),
            ),
            // Support Section
            _buildSectionTitle('Support'),
            _buildSupportItem(
                Icons.help_outline, 'Frequently Asked Questions', 'FAQ\'s'),
            _buildSupportItem(
                Icons.chat_bubble_outline, 'Customer Helpdesk', 'Chat'),
            const SizedBox(height: 30),
            // Logout Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Acción para cerrar sesión
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget para la tarjeta del usuario (Avatar y Datos)
  Widget _buildUserCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF323438), // Color de fondo del contenedor
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      AssetImage('assets/avatar.png'), // Imagen del avatar
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Change avatar',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Donald Dunn',
                  style: TextStyle(
                      color: Color(0xffBDBEC0),
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Edit Name',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                  ),
                ),
              ],
            ),
            Divider(),
            const SizedBox(height: 10),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Faculon@gmail.com',
                      style: TextStyle(
                          color: Color(0xffBDBEC0),
                          fontWeight: FontWeight.w400,
                          fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '**************',
                      style: TextStyle(
                          color: Color(0xffBDBEC0),
                          fontWeight: FontWeight.w400,
                          fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Change password',
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para título de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget para ítems de configuración
  Widget _buildSettingsItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF323438),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }

  // Widget para ítems de soporte
  Widget _buildSupportItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF323438),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }
}
