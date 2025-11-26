import 'package:flutter/material.dart';
import 'venue_list_screen.dart'; // To navigate to the venue list

class EventTypeScreen extends StatelessWidget {
  const EventTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // A hardcoded list of event types for the user to choose from
    final List<Map<String, dynamic>> eventTypes = [
      {'name': 'Picnic', 'icon': Icons.park_outlined},
      {'name': 'Birthday Party', 'icon': Icons.cake_outlined},
      {'name': 'Wedding', 'icon': Icons.favorite_border},
      {'name': 'Corporate Event', 'icon': Icons.business_center_outlined},
      {'name': 'Family Reunion', 'icon': Icons.group_outlined},
      {'name': 'Other', 'icon': Icons.more_horiz_outlined},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Choose Event Type', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        itemCount: eventTypes.length,
        itemBuilder: (context, index) {
          final eventType = eventTypes[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(eventType['icon'] as IconData, color: theme.colorScheme.primary, size: 28),
              title: Text(
                eventType['name'] as String,
                style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSecondary.withAlpha(179)),
              onTap: () {
                // After selecting an event type, navigate to the venue list screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VenueListScreen()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}