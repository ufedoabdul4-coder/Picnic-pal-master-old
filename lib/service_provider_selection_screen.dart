import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'apartment_manager_dashboard_screen.dart';
import 'hotel_manager_dashboard_screen.dart';

class ServiceProviderSelectionScreen extends StatelessWidget {
  const ServiceProviderSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
    await prefs.setBool('has_seen_provider_prompt', true);
    await prefs.setBool('is_service_provider', true);

    // Update Supabase profile so this persists across devices
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.from('profiles').update({'role': role}).eq('id', user.id);
      } catch (e) {
        debugPrint("Error updating role in Supabase: $e");
      }
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Role switched to $role")),
    );

    if (role == 'Apartment Manager') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ApartmentManagerDashboardScreen()),
        (route) => false,
      );
    } else if (role == 'Hotel Manager') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HotelManagerDashboardScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Select Your Service',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: Center(
        child: SizedBox(
          height: screenHeight * 0.6,
          width: screenWidth,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Top of the triangle
              Positioned(
                top: screenHeight * 0.05,
                child: _buildServiceBall(
                  context,
                  icon: Icons.celebration_outlined,
                  label: 'Event Planner',
                  onTap: () => _selectRole(context, 'Event Planner'),
                ),
              ),
              // Middle row
              Positioned(
                top: screenHeight * 0.25,
                left: screenWidth * 0.1,
                child: _buildServiceBall(
                  context,
                  icon: Icons.hotel_outlined,
                  label: 'Hotel Manager',
                  onTap: () => _selectRole(context, 'Hotel Manager'),
                ),
              ),
              Positioned(
                top: screenHeight * 0.25,
                right: screenWidth * 0.1,
                child: _buildServiceBall(
                  context,
                  icon: Icons.apartment_outlined,
                  label: 'Apartment Manager',
                  onTap: () => _selectRole(context, 'Apartment Manager'),
                ),
              ),
              // Bottom row
              Positioned(
                bottom: screenHeight * 0.05,
                left: screenWidth * 0.25,
                child: _buildServiceBall(
                  context,
                  icon: Icons.security,
                  label: 'Hire security',
                  onTap: () => _selectRole(context, 'Security'),
                ),
              ),
              Positioned(
                bottom: screenHeight * 0.05,
                right: screenWidth * 0.3,
                child: _buildServiceBall(
                  context,
                  icon: Icons.more_horiz_outlined,
                  label: 'More',
                  onTap: () {
                    // TODO: Navigate to a general services page
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("More services coming soon!")));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceBall(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primary,
            child: Icon(icon, size: 30, color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}