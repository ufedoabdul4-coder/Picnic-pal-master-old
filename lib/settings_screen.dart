import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'change_email_screen.dart'; // Import the new change email screen
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
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: theme.colorScheme.secondary,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 16, color: theme.colorScheme.primary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
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
            icon: Icons.email_outlined,
            title: 'Change Email',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeEmailScreen()));
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
          _buildSettingsTile(
            context,
            icon: Icons.cancel_presentation_outlined,
            title: 'Stop Being a Service Provider',
            onTap: () => _confirmRemoveServiceProvider(context),
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

  Future<void> _confirmRemoveServiceProvider(BuildContext context) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogTheme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: dialogTheme.colorScheme.surface,
          title: Text('Stop Being a Service Provider?', style: TextStyle(color: dialogTheme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
          content: Text('This will remove your service provider access and return your account to a regular user.', style: TextStyle(color: dialogTheme.colorScheme.onSurface.withOpacity(0.8))),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: dialogTheme.colorScheme.onSurface.withOpacity(0.7))),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Yes, remove', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          await Supabase.instance.client.from('profiles').update({'role': 'user'}).eq('id', user.id);
        } catch (e) {
          debugPrint('Failed to update Supabase role: $e');
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_service_provider', false);
      await prefs.setString('user_role', 'user');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service provider status removed.')),
      );
    }
  }
}
