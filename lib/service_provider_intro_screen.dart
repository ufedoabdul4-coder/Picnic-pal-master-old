import 'package:flutter/material.dart';
import 'service_provider_selection_screen.dart';

class ServiceProviderIntroScreen extends StatelessWidget {
  const ServiceProviderIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Partner with Us', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.handshake_outlined, size: 60, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Grow Your Business with Picnic Pal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Join our network of trusted professionals and connect with customers looking for event services, rentals, and more.',
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.8), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Services You Can Offer:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildServiceItem(context, Icons.event_available, 'Event Planning', 'Help users organize memorable picnics and parties.'),
                  _buildServiceItem(context, Icons.apartment, 'Property Rentals', 'List apartments, venues, or party spaces.'),
                  _buildServiceItem(context, Icons.restaurant_menu, 'Catering', 'Provide food and drinks for events.'),
                  _buildServiceItem(context, Icons.camera_alt, 'Photography', 'Capture special moments for our users.'),
                  _buildServiceItem(context, Icons.music_note, 'Entertainment', 'DJs, bands, and other performers.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ServiceProviderSelectionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Become a Service Provider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, IconData icon, String title, String description) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}