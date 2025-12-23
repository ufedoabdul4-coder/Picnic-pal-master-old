import 'package:flutter/material.dart';
import 'event_planner_login_screen.dart'; // Placeholder screen
import 'hotel_manager_login_screen.dart';
import 'hire_security_login_screen.dart';
import 'apartment_manager_login_screen.dart';

class ServiceProviderSelectionScreen extends StatelessWidget {
  const ServiceProviderSelectionScreen({super.key});

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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventPlannerLoginScreen())),
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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HotelManagerLoginScreen())),
                ),
              ),
              Positioned(
                top: screenHeight * 0.25,
                right: screenWidth * 0.1,
                child: _buildServiceBall(
                  context,
                  icon: Icons.apartment_outlined,
                  label: 'Apartment Manager',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApartmentManagerLoginScreen())),
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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HireSecurityLoginScreen())),
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