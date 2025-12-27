import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'venue_model.dart';
import 'venue_details_screen.dart'; // Corrected import path

class VenueListScreen extends StatefulWidget {
  final String? eventType;
  const VenueListScreen({super.key, this.eventType});

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  List<Venue> _venues = [];
  bool _isLoading = false;
  final String _apiKey = "AIzaSyDciuCyVUv2vmay4Xh0ajSeJo4wjo-BxUI";

  @override
  void initState() {
    super.initState();
    _initializeVenues();
  }

  void _initializeVenues() {
    if (widget.eventType != null) {
      _fetchVenuesFromGoogle(widget.eventType!);
    } else {
      setState(() {
        _venues = mockVenues;
      });
    }
  }

  Future<void> _fetchVenuesFromGoogle(String eventType) async {
    setState(() => _isLoading = true);
    try {
      final location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
           setState(() => _venues = mockVenues);
           return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
           setState(() => _venues = mockVenues);
           return;
        }
      }

      final locData = await location.getLocation();
      if (locData.latitude == null || locData.longitude == null) {
         setState(() => _venues = mockVenues);
         return;
      }

      final query = _mapEventTypeToQuery(eventType);
      
      // Use Uri.https for safer URL construction and encoding
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/textsearch/json',
        {
          'query': query,
          'location': '${locData.latitude},${locData.longitude}',
          'radius': '5000',
          'key': _apiKey,
        },
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check for API specific status codes (like REQUEST_DENIED)
        if (data['status'] == 'OK' && data['results'] != null && data['results'] is List) {
          final results = data['results'] as List;

          final List<Venue> fetchedVenues = results.map((r) {
            String imageUrl = 'assets/images/event_picnic.jpg';
            if (r['photos'] != null && (r['photos'] as List).isNotEmpty) {
              final photoRef = r['photos'][0]['photo_reference'];
              imageUrl = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoRef&key=$_apiKey';
            }

            final isOpen = r['opening_hours'] != null && r['opening_hours']['open_now'] == true;
            // Robust parsing for rating to prevent "Null is not subtype of double" error
            final double rating = (r['rating'] is num) ? (r['rating'] as num).toDouble() : 0.0;
            final String address = r['formatted_address'] ?? '';
            
            double? lat;
            double? lng;
            double? distance;
            if (r['geometry'] != null && r['geometry']['location'] != null) {
               lat = (r['geometry']['location']['lat'] as num).toDouble();
               lng = (r['geometry']['location']['lng'] as num).toDouble();
               distance = _calculateDistance(locData.latitude!, locData.longitude!, lat, lng);
            }

            // Create a default event type for this venue so it's selectable in the next screen
            final defaultEvent = EventType(
              name: eventType,
              imageUrl: imageUrl,
              requirements: [
                 EventRequirement(name: 'Reservation', icon: Icons.calendar_today),
                 EventRequirement(name: 'Menu Selection', icon: Icons.restaurant_menu),
              ],
            );

            return Venue(
              name: r['name'] ?? 'Unknown Venue',
              imageUrl: imageUrl,
              status: isOpen ? 'Open Now' : 'Closed',
              rating: rating,
              location: address,
              availableEvents: [defaultEvent],
              latitude: lat,
              longitude: lng,
              distanceFromUser: distance,
            );
          }).toList();

          // Sort venues by distance (nearest first)
          fetchedVenues.sort((a, b) {
             if (a.distanceFromUser == null) return 1;
             if (b.distanceFromUser == null) return -1;
             return a.distanceFromUser!.compareTo(b.distanceFromUser!);
          });

          setState(() {
            _venues = fetchedVenues.isNotEmpty ? fetchedVenues : mockVenues;
          });
        } else {
           debugPrint('Places API Error: ${data['status']} - ${data['error_message'] ?? ''}');
           if (mounted && data['status'] != 'OK') {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Maps Error: ${data['status']}')));
           }
           setState(() => _venues = mockVenues);
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        setState(() => _venues = mockVenues);
      }
    } catch (e) {
      debugPrint('Error fetching venues: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error. Showing offline venues.')));
      }
      setState(() => _venues = mockVenues);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Haversine formula to calculate distance in km
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p)/2 + 
          cos(lat1 * p) * cos(lat2 * p) * 
          (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  String _mapEventTypeToQuery(String eventType) {
    final map = {
      'Coffee Catch-up': 'cafe',
      'Movie Night': 'movie theater',
      'Game Night': 'bowling alley arcade',
      'Brunch Date': 'brunch restaurant',
      'Shopping Trip': 'shopping mall',
      'Picnic': 'park',
      'Barbecue': 'park with bbq area',
      'Casual outing': 'cafe',
    };
    return map[eventType] ?? eventType;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.eventType != null ? 'Venues for ${widget.eventType}' : 'Select a Venue',
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
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
        : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _venues.length,
        itemBuilder: (context, index) {
          final venue = _venues[index];
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
                  child: venue.imageUrl.startsWith('http')
                  ? Image.network(
                    venue.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: theme.colorScheme.surface,
                      child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                    ),
                  )
                  : Image.asset(
                    venue.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: theme.colorScheme.surface,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: TextStyle(
                      color: theme.colorScheme.onSecondary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (venue.rating > 0 || venue.location.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (venue.rating > 0) ...[
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(venue.rating.toString(), style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.8))),
                          const SizedBox(width: 16),
                        ],
                        if (venue.location.isNotEmpty)
                          Expanded(child: Text(venue.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7)))),
                      ],
                    ),
                    if (venue.distanceFromUser != null) ...[
                      const SizedBox(height: 4),
                      Text('${venue.distanceFromUser!.toStringAsFixed(1)} km away', 
                        style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}