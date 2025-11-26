import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final storedCode = prefs.getString('verification_code');
    final newEmail = prefs.getString('new_email');

    if (_codeController.text == storedCode && newEmail != null) {
      // Update the user's email
      await prefs.setString('user_email', newEmail);

      // Clear temporary values
      await prefs.remove('new_email');
      await prefs.remove('verification_code');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email changed successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // Go back to settings
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid verification code. Please try again.'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Verify Email', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: theme.colorScheme.onSecondary),
              decoration: InputDecoration(
                hintText: 'Verification Code',
                hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179)),
                prefixIcon: Icon(Icons.security_outlined, color: theme.colorScheme.primary),
                filled: true,
                fillColor: theme.colorScheme.secondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2),
                      )
                    : const Text('Verify Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}