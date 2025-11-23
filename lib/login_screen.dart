import 'package:flutter/material.dart';
import 'main.dart'; // To navigate to MainScreen
import 'vendor_login_screen.dart'; // Import the new vendor login screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _logoScaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
  }

  void _login() {
    // Validate the form before proceeding
    if (_formKey.currentState?.validate() ?? false) {
      // In a real app, you would add authentication logic here.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // This is a placeholder for your custom logo.
                  // You can replace this `_buildLogo()` widget with your own Image asset.
                  _buildLogo(),
                  const SizedBox(height: 40),

                  // Email Field
                  _buildEmailField(),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildPasswordField(),
                  const SizedBox(height: 30),

                  // Login Button
                  _buildLoginButton(),
                  const SizedBox(height: 20),

                  // Sign Up Text
                  _buildSignUpText(),
                  const SizedBox(height: 10),

                  // Vendor Login
                  _buildVendorLoginText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final theme = Theme.of(context);
    return Column(
      children: [
        ScaleTransition(
          scale: _logoScaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(38),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset(
              'assets/picnic_basket_logo.png', // Make sure this path is correct
              height: 120, // You can adjust this size
              errorBuilder: (context, error, stackTrace) {
                // Fallback in case the image fails to load, showing the original icon.
                return Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Fallback color now uses the theme
                    color: theme.colorScheme.surface,
                  ),
                  child: Icon(
                    Icons.shopping_basket_outlined,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Picnic Pal",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: theme.colorScheme.onSecondary),
      decoration: InputDecoration(
        hintText: 'Email',
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

  Widget _buildSignUpText() {
    return TextButton(
      onPressed: () { /* Placeholder for sign-up navigation */ },
      child: Text("Don't have an account? Sign Up", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(179))),
    );
  }

  Widget _buildVendorLoginText() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VendorLoginScreen()),
        );
      },
      child: Text("Are you a vendor? Login here", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
    );
  }
}