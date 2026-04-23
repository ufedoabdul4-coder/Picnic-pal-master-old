import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'booking_screen.dart'; // Import the new booking screen
import 'chatbot_screen.dart';
import 'agent_chat_screen.dart';

class Apartment {
  final String id;
  final String title;
  final String address;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> images;
  final String managerId;
  final String? managerName;
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
    required this.images,
    required this.managerId,
    this.managerName,
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
      images: (map['images'] as List?)
              ?.where((item) => item != null && item is String && item.isNotEmpty)
              .map((item) => item as String)
              .toList() ??
          [],
      managerId: map['manager_id'] ?? '',
      managerName: map['manager_name'],
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
      'images': images,
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
            return const Center(child: Text('Unable to load apartments. Please check your internet connection.'));
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
      initialValue: currentValue,
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

class ApartmentDetailsScreen extends StatefulWidget {
  final Apartment apartment;

  const ApartmentDetailsScreen({super.key, required this.apartment});

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  int _currentImageIndex = 0;
  String? _managerName;
  String? _managerAvatarUrl;

  @override
  void initState() {
    super.initState();
    _managerName = widget.apartment.managerName;
    if (_managerName == null) {
      _fetchManagerName();
    }
  }

  Future<void> _fetchManagerName() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', widget.apartment.managerId)
          .maybeSingle();
      if (mounted && data != null) {
        setState(() {
          _managerName = data['full_name'] as String?;
          _managerAvatarUrl = data['avatar_url'] as String?;
        });
      }
    } catch (e) {
      // Silence error if profile cannot be fetched
    }
  }

  @override
  Widget build(BuildContext context) {
    final apartment = widget.apartment;
    final theme = Theme.of(context);
    
    // Combine cover image and gallery images, ensuring unique list
    final List<String> displayImages = [];
    if (apartment.images.isNotEmpty) {
      displayImages.addAll(apartment.images);
    } else if (apartment.imageUrl.isNotEmpty) {
      displayImages.add(apartment.imageUrl);
    }

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
            // Image Gallery
            if (displayImages.isNotEmpty)
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: displayImages.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _FullScreenGallery(
                                  images: displayImages,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            displayImages[index],
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 300,
                              color: Colors.grey,
                              child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.white)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (displayImages.length > 1)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_currentImageIndex + 1} / ${displayImages.length}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              )
            else
              Container(
                height: 300,
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
                  // Address and Estate Name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apartment.address,
                              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                            ),
                            if (apartment.estateName.isNotEmpty)
                              Text(
                                apartment.estateName,
                                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Key Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.bed, '${apartment.bedrooms} Beds', theme),
                      _buildStatItem(Icons.bathtub, '${apartment.bathrooms} Baths', theme),
                      _buildStatItem(Icons.wc, '${apartment.toilets} Toilets', theme),
                      if (apartment.sizeSqm > 0) _buildStatItem(Icons.square_foot, '${apartment.sizeSqm} m²', theme),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Property Details
                  Text("Property Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildDetailChip(theme, "Type", apartment.propertyType),
                      _buildDetailChip(theme, "Condition", apartment.condition),
                      _buildDetailChip(theme, "Furnishing", apartment.furnishing),
                    ],
                  ),

                  if (apartment.amenities.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text("Amenities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: apartment.amenities.map((amenity) {
                        return Chip(
                          label: Text(amenity),
                          backgroundColor: theme.colorScheme.secondary,
                          labelStyle: TextStyle(color: theme.colorScheme.onSecondary),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),
                  // Description
                  Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    apartment.description,
                    style: TextStyle(fontSize: 16, height: 1.5, color: theme.colorScheme.onSurface.withOpacity(0.9)),
                  ),
                  if (_managerName != null) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserPostingsScreen(
                              userId: apartment.managerId,
                              userName: _managerName ?? "User",
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.secondary,
                              backgroundImage: _managerAvatarUrl != null
                                  ? NetworkImage(_managerAvatarUrl!)
                                  : null,
                              child: _managerAvatarUrl == null
                                  ? Icon(Icons.person, size: 16, color: theme.colorScheme.primary)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "$_managerName",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgentChatScreen(
                              apartment: apartment,
                              managerName: _managerName ?? "Agent",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text("Message Agent", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(
                          apartment: apartment,
                        )));
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

  Widget _buildDetailChip(ThemeData theme, String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        ],
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

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${_currentIndex + 1} / ${widget.images.length}', style: const TextStyle(color: Colors.white)),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.white, size: 50),
              ),
            ),
          );
          },
        ),
      );
    }
  }

class UserPostingsScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const UserPostingsScreen({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postingsStream = Supabase.instance.client
        .from('apartments')
        .stream(primaryKey: ['id'])
        .eq('manager_id', userId)
        .order('created_at');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("$userName's Postings", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: postingsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load postings.'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          }
          
          final apartments = snapshot.data!.map((map) => Apartment.fromMap(map)).toList();

          if (apartments.isEmpty) {
            return const Center(child: Text('No postings found for this user.'));
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
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(apartment.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.home)),
                  ),
                  title: Text(apartment.title, style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
                  subtitle: Text("\$${apartment.price}/night", style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApartmentDetailsScreen(apartment: apartment))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}