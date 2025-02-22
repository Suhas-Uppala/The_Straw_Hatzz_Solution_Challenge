import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection(
            'App Preferences',
            [
              _buildSettingTile(
                'Notifications',
                'Manage notification preferences',
                Icons.notifications_outlined,
                Colors.blue,
                () {},
              ),
              _buildSettingTile(
                'Dark Mode',
                'Toggle dark/light theme',
                Icons.dark_mode_outlined,
                Colors.purple,
                () {},
              ),
              _buildSettingTile(
                'Language',
                'Change app language',
                Icons.language,
                Colors.green,
                () {},
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSection(
            'Privacy & Security',
            [
              _buildSettingTile(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip_outlined,
                Colors.orange,
                () {},
              ),
              _buildSettingTile(
                'Terms of Service',
                'View terms of service',
                Icons.description_outlined,
                Colors.teal,
                () {},
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSection(
            'Support',
            [
              _buildSettingTile(
                'Help Center',
                'Get help and support',
                Icons.help_outline,
                Colors.amber,
                () {},
              ),
              _buildSettingTile(
                'Contact Us',
                'Reach out to our team',
                Icons.mail_outline,
                Colors.red,
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(color: Colors.white)),
        subtitle: Text(subtitle,
            style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
      ),
    );
  }
}
