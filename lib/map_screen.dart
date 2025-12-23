import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'place.dart';

class SmartPalMapScreen extends StatefulWidget {
  const SmartPalMapScreen({Key? key}) : super(key: key);

  @override
  State<SmartPalMapScreen> createState() => _SmartPalMapScreenState();
}

class _SmartPalMapScreenState extends State<SmartPalMapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(37.4219999, -122.0840575); // fallback
  Set<Marker> _markers = {};
  bool _loadingLocation = true;
  Place? _selectedPlace;

  // TODO: Replace with your actual API Key
  final String _apiKey = "AIzaSyA457DTcrXh0mtEjCibQK5hLJOYqG2suFQ";

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    if (permissionGranted == PermissionStatus.granted) {
      final locData = await location.getLocation();
      setState(() {
        _currentLocation = LatLng(locData.latitude!, locData.longitude!);
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation,
            onTap: () {
              setState(() {
                _selectedPlace = Place(
                  name: 'Your Location',
                  description: 'You are here',
                  rating: 0,
                  totalRatings: 0,
                  placeId: 'current_location',
                  latitude: _currentLocation.latitude,
                  longitude: _currentLocation.longitude,
                );
              });
            },
          ),
        );
        _loadingLocation = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 14),
      );
    }
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          _updateMapWithPlaceData(result);
        }
      }
    } catch (e) {
      debugPrint('Error searching place: $e');
    }
  }

  Future<void> _onMapTap(LatLng latLng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          // Geocoding results structure is slightly different, but we can adapt
          _updateMapWithPlaceData(result, isGeocode: true, tappedLatLng: latLng);
        }
      }
    } catch (e) {
      debugPrint('Error geocoding: $e');
    }
  }

  void _updateMapWithPlaceData(Map<String, dynamic> result, {bool isGeocode = false, LatLng? tappedLatLng}) {
    final geometry = result['geometry']['location'];
    final lat = isGeocode ? tappedLatLng!.latitude : geometry['lat'];
    final lng = isGeocode ? tappedLatLng!.longitude : geometry['lng'];
    final name = isGeocode ? "Selected Location" : result['name'];
    final address = result['formatted_address'];
    final rating = (result['rating'] as num?)?.toDouble() ?? 0.0;
    final userRatingsTotal = (result['user_ratings_total'] as num?)?.toInt() ?? 0;
    final placeId = result['place_id'];

    String? photoUrl;
    if (result['photos'] != null && (result['photos'] as List).isNotEmpty) {
      final photoRef = result['photos'][0]['photo_reference'];
      photoUrl =
          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoRef&key=$_apiKey';
    }

    final place = Place(
      name: name,
      description: address ?? '',
      rating: rating,
      totalRatings: userRatingsTotal,
      placeId: placeId,
      latitude: lat,
      longitude: lng,
      photoUrl: photoUrl,
    );

    setState(() {
      _selectedPlace = place;
      if (!isGeocode) {
        _currentLocation = LatLng(lat, lng);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
      }
      _markers.add(Marker(
        markerId: MarkerId(placeId),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: name, snippet: address),
        onTap: () {
          setState(() {
            _selectedPlace = place;
          });
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (latLng) async {
              await _onMapTap(latLng);
            },
          ),

          // Search bar at top
          Positioned(
            top: 40,
            left: 20,
            right: 200,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(8),
              color: theme.colorScheme.surface,
              child: TextField(
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search for a place',
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(15),
                ),
                onSubmitted: (value) {
                  _searchPlace(value);
                },
              ),
            ),
          ),

          // Bottom info panel
          if (!_loadingLocation && _selectedPlace == null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 200,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Smart Pal Map',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    FloatingActionButton(
                      mini: true,
                      heroTag: 'current_location_btn',
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      onPressed: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(_currentLocation, 16),
                        );
                      },
                      child: const Icon(Icons.my_location),
                    )
                  ],
                ),
              ),
            ),

          // Draggable Bottom Sheet for Selected Location
          if (_selectedPlace != null)
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.15,
              maxChildSize: 0.6,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Place Name and Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
 _selectedPlace!.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                            onPressed: () {
                              setState(() {
                                _selectedPlace = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // Place Photo (if available)
                      if (_selectedPlace!.photoUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _selectedPlace!.photoUrl!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),

                      // Rating and Address
                      if (_selectedPlace!.rating > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              "${_selectedPlace!.rating} (${_selectedPlace!.totalRatings})",
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedPlace!.description,
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Placeholder for directions or details action
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text("Get Directions"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
