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
  final double latitude;
  final double longitude;

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
    required this.latitude,
    required this.longitude,
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
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
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
      'latitude': latitude,
      'longitude': longitude,
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

  String? _selectedState;
  String? _selectedArea;

  final Map<String, List<String>> _locationData = {
    'Abuja': ['Wuse', 'Wuse 2', 'Garki', 'Lugbe', 'Maitama', 'Asokoro', 'Jabi', 'Gwarinpa', 'Central Business District', 'Kubwa', 'Gwagwalada'],
    'Lagos': ['Ikeja', 'Lekki', 'Victoria Island', 'Yaba', 'Surulere', 'Ikoyi', 'Ajah', 'Maryland'],
    'Rivers': ['Port Harcourt', 'Obio-Akpor', 'Eleme', 'Gra'],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Rent an Apartment', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: [
          if (_selectedState != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () => setState(() {
                _selectedState = null;
                _selectedArea = null;
              }),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown(theme, 'State', _locationData.keys.toList(), _selectedState, (val) {
                    setState(() {
                      _selectedState = val;
                      _selectedArea = null;
                    });
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(theme, 'Area', _selectedState != null ? _locationData[_selectedState]! : [], _selectedArea, (val) {
                    setState(() => _selectedArea = val);
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _apartmentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading apartments: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          }
          final apartments = snapshot.data!.map((map) => Apartment.fromMap(map)).where((apt) {
            if (_selectedState != null && !apt.address.toLowerCase().contains(_selectedState!.toLowerCase())) return false;
            if (_selectedArea != null && !apt.address.toLowerCase().contains(_selectedArea!.toLowerCase())) return false;
            return true;
          }).toList();

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
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ApartmentDetailsScreen(apartment: apartment)));
                  },
                ),
              );
            },
          );
        },
      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, List<String> items, String? currentValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      isExpanded: true,
      hint: Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
      style: TextStyle(color: theme.colorScheme.onSurface),
      dropdownColor: theme.colorScheme.secondary,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.colorScheme.secondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

class ApartmentDetailsScreen extends StatelessWidget {
  final Apartment apartment;

  const ApartmentDetailsScreen({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(apartment.title, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (apartment.imageUrl.isNotEmpty)
              Image.network(
                apartment.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey,
                  child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.white)),
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey,
                child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.white)),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          apartment.title,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                      ),
                      Text(
                        '\$${apartment.price}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          apartment.address,
                          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.bed, '${apartment.bedrooms} Beds', theme),
                      _buildStatItem(Icons.bathtub, '${apartment.bathrooms} Baths', theme),
                      if (apartment.sizeSqm > 0) _buildStatItem(Icons.square_foot, '${apartment.sizeSqm} m²', theme),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    apartment.description,
                    style: TextStyle(fontSize: 16, height: 1.5, color: theme.colorScheme.onSurface.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking feature coming soon!")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Book Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
      ],
    );
  }
}