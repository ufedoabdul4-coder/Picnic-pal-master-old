import 'package:flutter/material.dart';
import 'rent_apartment_screen.dart'; // Import to use the Apartment model

class ApartmentDetailsScreen extends StatelessWidget {
  final Apartment apartment;

  const ApartmentDetailsScreen({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apartment Details',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              apartment.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                color: Colors.grey[800],
                child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apartment.title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: theme.colorScheme.onSurface.withOpacity(0.7), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          apartment.address,
                          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn(context, Icons.king_bed_outlined, '${apartment.bedrooms} Bedrooms'),
                      _buildInfoColumn(context, Icons.bathtub_outlined, '${apartment.bathrooms} Bathrooms'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '₦${apartment.price.toStringAsFixed(0)} / year',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_outlined),
                      label: const Text('Contact Agent'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 32),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16)),
      ],
    );
  }
}