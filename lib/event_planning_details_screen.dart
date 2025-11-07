import 'package:flutter/material.dart';
import 'venue_model.dart';

class EventPlanningDetailsScreen extends StatelessWidget {
  final Venue venue;
  final EventType eventType;

  const EventPlanningDetailsScreen({
    super.key,
    required this.venue,
    required this.eventType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            iconTheme: IconThemeData(color: theme.colorScheme.primary),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                eventType.name,
                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 2, color: Colors.black54)]),
              ),
              centerTitle: true,
              background: Hero(
                tag: eventType.imageUrl, // Simple hero animation
                child: Image.asset(eventType.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'Requirements for your ${eventType.name} at ${venue.name}:',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final requirement = eventType.requirements[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(requirement.icon, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          requirement.name,
                          style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: eventType.requirements.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This will connect you with a planner! Coming soon.')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Order Planner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}