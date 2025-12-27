import 'package:flutter/material.dart';
import 'venue_list_screen.dart';

class EventSubtypeScreen extends StatefulWidget {
  final String eventType;

  const EventSubtypeScreen({
    super.key,
    required this.eventType,
  });

  @override
  State<EventSubtypeScreen> createState() => _EventSubtypeScreenState();
}

class _EventSubtypeScreenState extends State<EventSubtypeScreen> {
  // This map holds all the specific event types for each main category.
  // You can easily add more categories and subtypes here!
  final Map<String, List<String>> _eventSubtypes = {
    'Picnic': [
      'Classic Park Picnic',
      'Romantic Sunset Picnic',
      'Famiy Fun Day Picnic',
      'Beachside Picnic',
      'Hiking Trail Picnic',
    ],
    'Barbecue': [
      'Backyard BBQ Bash',
      'Community Cookout',
      'Tailgate Grill Party',
      'Smoker Showdown',
    ],
    'Party': [
      'Birthday Party',
      'Holiday Party',
      'Graduation Party',
      'Themed Costume Party',
    ],
    'Casual outing': [
      'Coffee Catch-up',
      'Movie Night',
      'Game Night',
      'Brunch Date',
      'Shopping Trip',
    ],
    // Add other main event types and their subtypes here
  };

  late final List<String> _subtypesToShow;

  @override
  void initState() {
    super.initState();
    // Get the correct list of subtypes for the event type passed to the screen.
    _subtypesToShow = _eventSubtypes[widget.eventType] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a ${widget.eventType}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
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
        itemCount: _subtypesToShow.length,
        itemBuilder: (context, index) {
          final subtype = _subtypesToShow[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(subtype),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VenueListScreen(eventType: subtype)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}