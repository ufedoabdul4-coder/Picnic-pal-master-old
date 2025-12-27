import 'package:flutter/material.dart';
import 'event_subtype_screen.dart'; // Import the new subtype screen
import 'venue_list_screen.dart';

class EventTypeScreen extends StatelessWidget {
  const EventTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // A hardcoded list of event types for the user to choose from
    final List<Map<String, dynamic>> eventTypes = [
      {'name': 'Picnic', 'icon': Icons.park_outlined, 'hasSubtypes': true},
      {'name': 'Barbecue', 'icon': Icons.outdoor_grill_outlined, 'hasSubtypes': true},
      {'name': 'Party', 'icon': Icons.cake_outlined, 'hasSubtypes': true},
      {'name': 'Wedding', 'icon': Icons.favorite_border, 'hasSubtypes': false},
      {'name': 'Corporate Event', 'icon': Icons.business_center_outlined, 'hasSubtypes': false},
      {'name': 'Casual outing', 'icon': Icons.people_outlined, 'hasSubtypes': true},
      {'name': 'Other', 'icon': Icons.more_horiz_outlined, 'hasSubtypes': false},
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
                final String eventName = eventType['name'] as String;
                final bool hasSubtypes = eventType['hasSubtypes'] as bool;

                // If the event has subtypes, navigate to the subtype screen.
                // Otherwise, you can navigate directly to the venue list or another screen.
                if (hasSubtypes) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventSubtypeScreen(eventType: eventName)),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VenueListScreen(eventType: eventName)),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}