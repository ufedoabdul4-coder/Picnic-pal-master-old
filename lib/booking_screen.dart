import 'package:flutter/material.dart';
import 'rent_apartment_screen.dart'; // Import the Apartment model

class BookingScreen extends StatelessWidget {
  final Apartment apartment;

  const BookingScreen({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Book ${apartment.title}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apartment: ${apartment.title}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${apartment.address}',
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: \$${apartment.price}/night',
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.8)),
            ),
            const SizedBox(height: 24),
            // Here you would add your booking form, date pickers, payment integration, etc.
            Center(
              child: Text(
                'Booking functionality will be implemented here!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}