import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert'; // Import for utf8 and base64Encode
import 'package:http/http.dart' as http;
import 'verify_email_screen.dart'; // Import the new verify email screen

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _changeEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final newEmail = _emailController.text.trim();

      // Generate a verification code
      final verificationCode = generateVerificationCode();

      // Store the new email and verification code temporarily
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('new_email', newEmail);
      await prefs.setString('verification_code', verificationCode);

      // Send verification email
      final bool emailSent = await sendVerificationEmail(newEmail, verificationCode);

      if (emailSent) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A verification email has been sent to your new email address.'), backgroundColor: Colors.green),
          );
        }

        // Navigate to the verification screen
        Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyEmailScreen()));


      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send verification email. Please try again.'), backgroundColor: Colors.red),
          );
        }
      }

      setState(() => _isLoading = false);
    }
  }

  String generateVerificationCode() {
    final random = Random();
    return String.fromCharCodes(List.generate(6, (index) => random.nextInt(26) + 65)); // 6-digit random code
  }

  Future<bool> sendVerificationEmail(String newEmail, String verificationCode) async {
    // Replace with your actual email sending logic
    // This is a placeholder and will not actually send emails
    const String apiKey = 'YOUR_EMAIL_API_KEY'; // Replace with your actual API key
    const String domain = 'YOUR_EMAIL_DOMAIN'; // Replace with your actual domain

    final url = Uri.parse('https://api.mailgun.net/v3/$domain/messages');
    final basicAuth = 'Basic ${base64Encode(utf8.encode('api:$apiKey'))}';

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': basicAuth},
        body: {
          'from': 'PicnicPal <mailgun@$domain>',
          'to': newEmail,
          'subject': 'Verify your email address',
          'text': 'Please verify your email address by using the following code: $verificationCode',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Email sending failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Email sending error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Change Email', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: theme.colorScheme.onSecondary),
                decoration: InputDecoration(
                  hintText: 'New Email Address',
                  hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179)),
                  prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                  filled: true,
                  fillColor: theme.colorScheme.secondary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changeEmail,
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
                      : const Text('Change Email', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}