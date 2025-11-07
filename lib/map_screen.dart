import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Place> _places = [];
  List<Marker> _markers = [];

  // Initial camera position over Abuja, Nigeria
  static const LatLng _initialPosition = LatLng(9.0765, 7.3986);

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
    _markers = _places.map((place) {
      return Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(place.latitude, place.longitude),
        child: IconButton(
          icon: Icon(Icons.location_on, color: Colors.red, size: 45.0),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(place.name, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.0),
                      Text('Rating: ${place.rating} ⭐'),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }).toList();
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
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _initialPosition,
          initialZoom: 11.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
    );
  }
}