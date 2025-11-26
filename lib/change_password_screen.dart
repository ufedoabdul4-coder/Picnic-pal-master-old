import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      // In a real app, you would add logic here to:
      // 1. Verify the current password against the stored one.
      // 2. If correct, update the password in your backend/storage.
      await Future.delayed(const Duration(seconds: 1)); // Simulate network call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Change Password', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(
                context: context,
                controller: _currentPasswordController,
                hintText: 'Current Password',
                isVisible: _isCurrentPasswordVisible,
                onToggleVisibility: () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                context: context,
                controller: _newPasswordController,
                hintText: 'New Password',
                isVisible: _isNewPasswordVisible,
                onToggleVisibility: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                context: context,
                controller: _confirmPasswordController,
                hintText: 'Confirm New Password',
                isVisible: _isConfirmPasswordVisible,
                onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2))
                      : const Text('Save Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: TextStyle(color: theme.colorScheme.onSecondary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179)),
        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.primary),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: validator ?? (value) => (value == null || value.isEmpty) ? 'This field cannot be empty' : null,
    );
  }
}