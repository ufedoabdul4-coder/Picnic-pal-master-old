import 'package:flutter/material.dart';

class LoginSettingsScreen extends StatefulWidget {
  const LoginSettingsScreen({super.key});

  @override
  State<LoginSettingsScreen> createState() => _LoginSettingsScreenState();
}

class _LoginSettingsScreenState extends State<LoginSettingsScreen> {
  bool _autoLoginEnabled = true; // Default value, you can load this from storage

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Login Settings', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        children: [
          _buildSectionTitle(context, 'Password'),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            title: 'Change Password',
            onTap: () {
              // Placeholder for navigation
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Change Password functionality coming soon!')));
            },
          ),
          _buildSettingsTile(
            context,
            title: 'Forgot Password',
            onTap: () {
              // Placeholder for navigation
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forgot Password functionality coming soon!')));
            },
          ),
          const SizedBox(height: 30),
          _buildSectionTitle(context, 'Preferences'),
          const SizedBox(height: 10),
          _buildSwitchTile(
            context,
            title: 'Auto-Login',
            value: _autoLoginEnabled,
            onChanged: (bool value) {
              setState(() {
                _autoLoginEnabled = value;
              });
              // In a real app, you would save this preference using shared_preferences
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auto-Login ${value ? "Enabled" : "Disabled"}')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(title, style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildSettingsTile(BuildContext context, {required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: TextStyle(color: theme.colorScheme.onSecondary)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSecondary.withAlpha(179)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, {required String title, required bool value, required ValueChanged<bool> onChanged}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(color: theme.colorScheme.onSecondary)),
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }
}