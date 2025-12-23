import 'package:flutter/material.dart';
import 'hotel_manager_dashboard_screen.dart'; // Import the new dashboard
import 'forgot_password_screen.dart';

class HotelManagerLoginScreen extends StatefulWidget {
  const HotelManagerLoginScreen({super.key});

  @override
  State<HotelManagerLoginScreen> createState() => _HotelManagerLoginScreenState();
}

class _HotelManagerLoginScreenState extends State<HotelManagerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      // Placeholder for hotel manager authentication
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Hotel Manager login successful! Redirecting...'),
      ));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HotelManagerDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Hotel Manager Login', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel_outlined, size: 100, color: theme.colorScheme.primary),
                  const SizedBox(height: 40),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 30),
                  _buildLoginButton(),
                  const SizedBox(height: 8),
                  _buildForgotPasswordText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: theme.colorScheme.onSecondary),
      decoration: InputDecoration(
        hintText: 'Email or Manager ID',
        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179)),
        prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email or Manager ID';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: theme.colorScheme.onSecondary),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179)),
        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.primary),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildForgotPasswordText() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
        child: Text("Forgot Password?", style: TextStyle(color: Theme.of(context).colorScheme.primary.withAlpha(200))),
      ),
    );
  }
}