import 'package:flutter/material.dart';
import 'venue_model.dart';
import '../event_planning_details_screen.dart'; // Corrected import path
import 'plan_picnic_screen.dart'; // To reuse the picker tile
import 'saved_venue_provider.dart';

class VenueDetailsScreen extends StatefulWidget {
  final Venue venue;
  const VenueDetailsScreen({super.key, required this.venue});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  // Mock data for interior/exterior images. In a real app, this would come from your backend.
  final Map<String, Map<String, List<String>>> _venueGalleries = {
    "Millennium Park": {
      // Sub-galleries for Millennium Park's exterior
      "exterior_kids_playground": ["assets/images/millennium_park.jpg"], // Placeholder image
      "exterior_fountains": ["assets/images/event_picnic.jpg"], // Placeholder image
      "exterior_gate": ["assets/images/millennium_park.jpg"], // Placeholder image
      // A general exterior list for other venues or as a fallback
      "exterior": ["assets/images/millennium_park.jpg", "assets/images/event_picnic.jpg"],
      "interior": [], // Explicitly empty
    },
    "Jabi Lake": {
      "exterior": ["assets/images/jabi_lake.jpg", "assets/images/event_weddings.jpg"],
      "interior": ["assets/images/blucabana.jpg"], // Example interior
    },
    "BMT Gardens": {
      "exterior": ["assets/images/bmt_gardens.jpg"],
      "interior": [],
    }
    // Add other venues here...
  };

  @override
  void initState() {
    super.initState();
    savedVenueProvider.addListener(_onProviderUpdate);
  }

  void _onProviderUpdate() => setState(() {});

  void _showImageGallery(BuildContext context, String venueName, String galleryType) {
    final theme = Theme.of(context);
    final galleries = _venueGalleries[venueName];
    final images = galleries?[galleryType] ?? [];

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No $galleryType images available for this venue.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset(images[index], fit: BoxFit.cover)),
            );
          },
        ),
      ),
    );
  }

  void _showMillenniumParkExteriorOptions(BuildContext context) {
    final theme = Theme.of(context);
    final Map<String, String> options = {
      'Kids Playground': 'exterior_kids_playground',
      'Fountains': 'exterior_fountains',
      'Gate': 'exterior_gate',
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Millennium Park Exterior", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.entries.map((entry) {
            return ListTile(
              title: Text(entry.key, style: TextStyle(color: theme.colorScheme.onSecondary)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSecondary.withOpacity(0.7)),
              onTap: () {
                Navigator.of(ctx).pop(); // Close the options dialog
                _showImageGallery(context, "Millennium Park", entry.value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close', style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    savedVenueProvider.removeListener(_onProviderUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interiorImages = _venueGalleries[widget.venue.name]?['interior'] ?? [];
    final exteriorImages = _venueGalleries[widget.venue.name]?['exterior'] ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            iconTheme: IconThemeData(color: theme.colorScheme.primary),
            actions: [
              IconButton(
                icon: Icon(
                  savedVenueProvider.isVenueSaved(widget.venue.name)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => savedVenueProvider.toggleSavedVenue(widget.venue.name),
                tooltip: 'Save Venue',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.venue.name,
                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 2, color: Colors.black54)]),
              ),
              centerTitle: true,
              background: Image.asset(
                widget.venue.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text("Venue Gallery", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      if (interiorImages.isNotEmpty)
                        Expanded(
                          child: _buildPickerTile(
                            context: context,
                            label: 'View Interior',
                            icon: Icons.house_siding_outlined,
                            onTap: () => _showImageGallery(context, widget.venue.name, 'interior'),
                          ),
                        ),
                      if (interiorImages.isNotEmpty && exteriorImages.isNotEmpty)
                        const SizedBox(width: 12),
                      if (exteriorImages.isNotEmpty)
                        Expanded(
                          child: _buildPickerTile(
                            context: context,
                            label: 'View Exterior',
                            icon: Icons.wb_sunny_outlined,
                            onTap: () {
                              if (widget.venue.name == "Millennium Park") {
                                _showMillenniumParkExteriorOptions(context);
                              } else {
                                _showImageGallery(context, widget.venue.name, 'exterior');
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Text('Select Event Type', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final eventType = widget.venue.availableEvents[index];
                  return EventTypeCard(
                    venue: widget.venue,
                    eventType: eventType,
                  );
                },
                childCount: widget.venue.availableEvents.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // Re-using the picker tile widget for a consistent UI
  Widget _buildPickerTile({required BuildContext context, required String label, required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.secondary.withAlpha(200)),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventTypeCard extends StatelessWidget {
  final Venue venue;
  final EventType eventType;

  const EventTypeCard({super.key, required this.venue, required this.eventType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPlanningDetailsScreen(venue: venue, eventType: eventType),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(eventType.imageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                eventType.name,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2)]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}