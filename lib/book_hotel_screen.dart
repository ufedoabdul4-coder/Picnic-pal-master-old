import 'package:flutter/material.dart';
import 'hotel_details_screen.dart';

class Hotel {
  final String id;
  final String name;
  final String address;
  final double pricePerNight;
  final double rating;
  final String imageUrl;

  const Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.pricePerNight,
    required this.rating,
    required this.imageUrl,
  });
}

// Mock list of hotels for demonstration
final List<Hotel> mockHotels = [
  const Hotel(
    id: '1',
    name: 'The Transcorp Hilton Abuja',
    address: '1 Aguiyi Ironsi Street, Maitama, Abuja',
    pricePerNight: 85000.00,
    rating: 4.5,
    imageUrl: 'assets/images/hotel1.jpg', // Placeholder image
  ),
  const Hotel(
    id: '2',
    name: 'Nicon Luxury Hotel',
    address: 'Plot 903 Tafawa Balewa Way, Area 11, Garki, Abuja',
    pricePerNight: 62000.00,
    rating: 4.2,
    imageUrl: 'assets/images/hotel2.jpg', // Placeholder image
  ),
  const Hotel(
    id: '3',
    name: 'Fraser Suites Abuja',
    address: '29 Usuma Street, Maitama, Abuja',
    pricePerNight: 98000.00,
    rating: 4.7,
    imageUrl: 'assets/images/hotel3.jpg', // Placeholder image
  ),
];

class HotelCard extends StatelessWidget {
  final Hotel hotel;

  const HotelCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HotelDetailsScreen(hotel: hotel)),
        );
      },
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.only(bottom: 16.0),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              hotel.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(height: 200, color: Colors.grey[800], child: const Icon(Icons.image_not_supported, color: Colors.white54)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hotel.address,
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₦${hotel.pricePerNight.toStringAsFixed(2)}/night',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[400], size: 18),
                          Text('${hotel.rating}', style: TextStyle(color: theme.colorScheme.onSurface)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookHotelScreen extends StatelessWidget {
  const BookHotelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Hotel',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockHotels.length,
        itemBuilder: (context, index) {
          final hotel = mockHotels[index];
          return HotelCard(hotel: hotel);
        },
      ),
    );
  }
}