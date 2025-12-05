import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final List<Place> _places = [];
  final Set<Marker> _markers = {};

  // Initial camera position over Abuja, Nigeria
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(9.0765, 7.3986),
    zoom: 11.0,
  );

  @override
  void initState() {
    super.initState();
    _loadHardcodedPlaces();
    _createMarkers();
  }

  void _loadHardcodedPlaces() {
    // This is a copy of the data from HomeScreen. In a larger app,
    // this data would come from a shared provider or service.
    _places.addAll([
      Place(
        name: 'Millennium Park, Abuja',
        rating: 4.5,
        totalRatings: 1500,
        placeId: '1',
        photoUrl: 'assets/millennium_park.jpg',
        description: 'The largest public park in Abuja...',
        latitude: 9.072264,
        longitude: 7.491302,
      ),
      Place(
        name: 'Jabi Lake, Abuja',
        rating: 4.4,
        totalRatings: 900,
        placeId: '2',
        photoUrl: 'assets/jabi_lake.jpg',
        description: 'A beautiful man-made lake...',
        latitude: 9.0559,
        longitude: 7.4269,
      ),
      Place(
        name: 'Almat Farms, Kuje',
        rating: 4.6,
        totalRatings: 750,
        placeId: '3',
        photoUrl: 'assets/almat_farms.jpg',
        description: 'A lush resort and farm...',
        latitude: 8.8995,
        longitude: 7.2228,
      ),
      Place(
        name: 'Gurara Waterfalls, Niger',
        rating: 4.7,
        totalRatings: 1200,
        placeId: '4',
        photoUrl: 'assets/gurara_falls.jpg',
        description: 'A spectacular natural waterfall...',
        latitude: 9.1950,
        longitude: 7.2833,
      ),
    ]);
  }

  void _createMarkers() {
    _markers.clear();
    for (final place in _places) {
      _markers.add(
        Marker(
          markerId: MarkerId(place.placeId),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: 'Rating: ${place.rating} ⭐',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Venue Map', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        myLocationButtonEnabled: false, // Optional: to keep the UI clean
        zoomControlsEnabled: false, // Optional: to keep the UI clean
      ),
    );
  }
}