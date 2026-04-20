import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;

  const EditProfileScreen({super.key, required this.initialName, required this.initialEmail});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _profileImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _emailController.text = widget.initialEmail;
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path_${user.id}');
    if (mounted) {
      setState(() {
        if (imagePath != null && File(imagePath).existsSync()) {
          _profileImage = File(imagePath);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;

        // Update Supabase - This ensures the change persists and is visible on ProfileScreen
        await Supabase.instance.client.from('profiles').update({
          'full_name': _nameController.text,
          'first_name': _nameController.text.split(' ').first,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);

        // Update local preferences as a cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameController.text);
        
        if (_profileImage != null) {
          await prefs.setString('profile_image_path_${user.id}', _profileImage!.path);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
          );
          // Pop with 'true' to signal the profile screen to reload data via its .then() block
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImagePicker(theme),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: theme.colorScheme.onSecondary),
                      decoration: _buildInputDecoration(theme, 'Full Name', Icons.person_outline),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: theme.colorScheme.onSecondary),
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true, // Make the email field read-only
                      decoration: _buildInputDecoration(theme, 'Email Address', Icons.email_outlined),
                      // Removed validator as the field is now read-only
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImagePicker(ThemeData theme) {
    return GestureDetector(
      onTap: _pickProfileImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _profileImage != null ? FileImage(_profileImage!) as ImageProvider : const AssetImage("assets/images/profile.jpg"),
            backgroundColor: theme.colorScheme.secondary,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
              child: Icon(Icons.edit, color: theme.colorScheme.onPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(ThemeData theme, String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179)),
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
      filled: true,
      fillColor: theme.colorScheme.secondary,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }
}