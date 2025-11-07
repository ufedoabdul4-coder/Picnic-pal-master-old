import 'package:flutter/material.dart';
import 'login_settings_screen.dart'; // Import the new login settings screen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'Login Settings',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginSettingsScreen()));
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // Placeholder for navigation
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications page coming soon!')));
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.quiz_outlined,
            title: 'FAQ',
            onTap: () {
              // Placeholder for navigation
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('FAQ page coming soon!')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: TextStyle(color: theme.colorScheme.onSecondary)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSecondary.withAlpha(179)),
        onTap: onTap,
      ),
    );
  }
}