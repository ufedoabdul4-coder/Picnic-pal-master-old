import 'package:flutter/material.dart';

class EventPlannerSignUpScreen extends StatefulWidget {
  const EventPlannerSignUpScreen({super.key});

  @override
  State<EventPlannerSignUpScreen> createState() => _EventPlannerSignUpScreenState();
}

class _EventPlannerSignUpScreenState extends State<EventPlannerSignUpScreen> {
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      // Placeholder for event planner registration logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Planner account created successfully! Please log in.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Planner Registration', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
                  Icon(Icons.store_mall_directory_outlined, size: 80, color: theme.colorScheme.primary),
                  const SizedBox(height: 30),
                  _buildBusinessNameField(),
                  const SizedBox(height: 20),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPhoneField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 30),
                  _buildSignUpButton(),
                  const SizedBox(height: 20),
                  _buildLoginText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessNameField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _businessNameController,
      style: TextStyle(color: theme.colorScheme.onSecondary),
      decoration: InputDecoration(
        hintText: 'Business Name',
        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179)),
        prefixIcon: Icon(Icons.business_center_outlined, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter your business name' : null,
    );
  }

  Widget _buildEmailField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: theme.colorScheme.onSecondary),
      decoration: InputDecoration(
        hintText: 'Business Email',
        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179)),
        prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your business email';
        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Please enter a valid email address';
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: theme.colorScheme.onSecondary),
      decoration: InputDecoration(
        hintText: 'Phone Number',
        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179)),
        prefixIcon: Icon(Icons.phone_outlined, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter your phone number' : null,
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
        if (value == null || value.isEmpty) return 'Please enter a password';
        if (value.length < 6) return 'Password must be at least 6 characters long';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      style: TextStyle(color: theme.colorScheme.onSecondary),
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179)),
        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.primary),
          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
        ),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please confirm your password';
        if (value != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginText() {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text("Already have a planner account? Login", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(179))),
    );
  }
}