import 'package:flutter/material.dart';
import 'venue_model.dart';
import 'venue_details_screen.dart'; // Corrected import path

class VenueListScreen extends StatelessWidget {
  const VenueListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Select a Venue',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockVenues.length,
        itemBuilder: (context, index) {
          final venue = mockVenues[index];
          return VenueCard(venue: venue);
        },
      ),
    );
  }
}

class VenueCard extends StatelessWidget {
  final Venue venue;

  const VenueCard({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VenueDetailsScreen(venue: venue)),
        );
      },
      child: Card(
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.2),
        margin: const EdgeInsets.only(bottom: 24.0),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        color: theme.colorScheme.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                  child: Image.asset(
                    venue.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      venue.status,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                venue.name,
                style: TextStyle(
                  color: theme.colorScheme.onSecondary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}