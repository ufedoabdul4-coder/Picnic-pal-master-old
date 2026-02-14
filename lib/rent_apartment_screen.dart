import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Apartment {
  final String id;
  final String title;
  final String address;
  final String description;
  final double price;
  final String imageUrl;
  final String managerId;
  final DateTime dateAdded;
  final bool isVerified;
  final String propertyType;
  final int bedrooms;
  final int bathrooms;
  final int toilets;
  final double sizeSqm;
  final String condition;
  final String furnishing;
  final List<String> amenities;
  final String estateName;

  Apartment({
    required this.id,
    required this.title,
    required this.address,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.managerId,
    required this.dateAdded,
    required this.isVerified,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    required this.toilets,
    required this.sizeSqm,
    required this.condition,
    required this.furnishing,
    required this.amenities,
    required this.estateName,
  });

  factory Apartment.fromMap(Map<String, dynamic> map) {
    return Apartment(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      address: map['address'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] ?? '',
      managerId: map['manager_id'] ?? '',
      dateAdded: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      isVerified: map['is_verified'] ?? false,
      propertyType: map['property_type'] ?? 'Apartment',
      bedrooms: (map['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (map['bathrooms'] as num?)?.toInt() ?? 0,
      toilets: (map['toilets'] as num?)?.toInt() ?? 0,
      sizeSqm: (map['size_sqm'] as num?)?.toDouble() ?? 0.0,
      condition: map['condition'] ?? 'Fair',
      furnishing: map['furnishing'] ?? 'Unfurnished',
      amenities: map['amenities'] != null ? List<String>.from(map['amenities']) : [],
      estateName: map['estate_name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'address': address,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'manager_id': managerId,
      'property_type': propertyType,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'toilets': toilets,
      'size_sqm': sizeSqm,
      'condition': condition,
      'furnishing': furnishing,
      'amenities': amenities,
      'estate_name': estateName,
    };
  }
}

class RentApartmentScreen extends StatefulWidget {
  const RentApartmentScreen({super.key});

  @override
  State<RentApartmentScreen> createState() => _RentApartmentScreenState();
}

class _RentApartmentScreenState extends State<RentApartmentScreen> {
  final _apartmentsStream = Supabase.instance.client
      .from('apartments')
      .stream(primaryKey: ['id'])
      .order('created_at');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Rent an Apartment', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _apartmentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading apartments: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          }
          final apartments = snapshot.data!.map((map) => Apartment.fromMap(map)).toList();

          if (apartments.isEmpty) {
            return Center(
              child: Text(
                'No apartments listed yet.',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final apartment = apartments[index];
              return Card(
                color: theme.colorScheme.secondary,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(apartment.imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, o, s) => Container(width: 80, height: 80, color: Colors.grey, child: const Icon(Icons.home))),
                  ),
                  title: Text(apartment.title, style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
                  subtitle: Text("${apartment.address}\n\$${apartment.price}/night", style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}