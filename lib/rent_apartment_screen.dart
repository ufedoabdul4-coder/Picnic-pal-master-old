import 'package:flutter/material.dart';
import 'apartment_details_screen.dart'; // Import the new details screen
import 'favorite_apartments_screen.dart'; // Import the favorites screen

/// Data model for a single apartment listing.
class Apartment {
  final String id;
  final String title;
  final String address;
  final double price;
  final int bedrooms;
  final int bathrooms;
  final String imageUrl;
  final String propertyType;
  final DateTime dateAdded;

  const Apartment({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.imageUrl,
    required this.propertyType,
    required this.dateAdded,
  });
}

// A mock list of apartments for demonstration purposes.
final List<Apartment> mockApartments = [
  Apartment(
    id: '1',
    title: 'Modern Loft in Downtown',
    address: '123 Main St, Abuja',
    price: 250000,
    bedrooms: 2,
    bathrooms: 2,
    imageUrl: 'assets/images/apartment1.jpg', // Placeholder image path
    propertyType: 'Apartment',
    dateAdded: DateTime(2025, 12, 10),
  ),
  Apartment(
    id: '2',
    title: 'Cozy Suburban Family Home',
    address: '456 Oak Ave, Gwarinpa',
    price: 350000,
    bedrooms: 3,
    bathrooms: 2,
    imageUrl: 'assets/images/apartment2.jpg', // Placeholder image path
    propertyType: 'House',
    dateAdded: DateTime(2025, 12, 5),
  ),
  Apartment(
    id: '3',
    title: 'Luxury Penthouse with City View',
    address: '789 High Rise, Asokoro',
    price: 700000,
    bedrooms: 4,
    bathrooms: 5,
    imageUrl: 'assets/images/apartment3.jpg', // Placeholder image path
    propertyType: 'Apartment',
    dateAdded: DateTime(2025, 11, 28),
  ),
  Apartment(
    id: '4',
    title: 'Charming Studio Apartment',
    address: '101 Side St, Wuse II',
    price: 180000,
    bedrooms: 1,
    bathrooms: 1,
    imageUrl: 'assets/images/apartment4.jpg', // Placeholder image path
    propertyType: 'Studio',
    dateAdded: DateTime(2025, 12, 15),
  ),
];

class ApartmentCard extends StatelessWidget {
  final Apartment apartment;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const ApartmentCard({
    super.key,
    required this.apartment,
    required this.isFavorite,
    required this.onFavoritePressed,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ApartmentDetailsScreen(apartment: apartment)),
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
                Image.asset(
                  apartment.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: onFavoritePressed,
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
                    apartment.title,
                    style: TextStyle(
                      color: theme.colorScheme.onSecondary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: theme.colorScheme.onSecondary.withAlpha(179), size: 16),
                      const SizedBox(width: 4),
                      Text(apartment.address, style: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₦${apartment.price.toStringAsFixed(0)}/year',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.king_bed_outlined, color: theme.colorScheme.onSecondary.withAlpha(179), size: 20),
                          const SizedBox(width: 4),
                          Text('${apartment.bedrooms}', style: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179))),
                          const SizedBox(width: 16),
                          Icon(Icons.bathtub_outlined, color: theme.colorScheme.onSecondary.withAlpha(179), size: 20),
                          const SizedBox(width: 4),
                          Text('${apartment.bathrooms}', style: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179))),
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

class RentApartmentScreen extends StatefulWidget {
  const RentApartmentScreen({super.key});

  @override
  State<RentApartmentScreen> createState() => _RentApartmentScreenState();
}

class _RentApartmentScreenState extends State<RentApartmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Apartment> _filteredApartments = [];
  final Set<String> _favoriteApartmentIds = {};

  // Filter state
  String? _locationFilter;
  Set<String> _propertyTypes = {};
  int? _minBedrooms;
  String _sortBy = 'Recommended';
  String _minPrice = '';
  String _maxPrice = '';

  @override
  void initState() {
    super.initState();
    _filteredApartments = mockApartments;
    _searchController.addListener(_filterApartments);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterApartments);
    _searchController.dispose();
    super.dispose();
  }

  void _filterApartments() {
    final query = _searchController.text.toLowerCase();
    final minPrice = double.tryParse(_minPrice);
    final maxPrice = double.tryParse(_maxPrice);

    setState(() {
      List<Apartment> results = mockApartments.where((apartment) {
        final titleLower = apartment.title.toLowerCase();
        final addressLower = apartment.address.toLowerCase();
        final matchesText = query.isEmpty || titleLower.contains(query) || addressLower.contains(query);

        final matchesLocation = _locationFilter == null ||
            (_locationFilter == 'Nearby' && (apartment.address.contains('Wuse') || apartment.address.contains('Main St'))) || // Simple nearby logic
            (apartment.address.toLowerCase().contains(_locationFilter!.toLowerCase()));

        final matchesPropertyType = _propertyTypes.isEmpty || _propertyTypes.contains(apartment.propertyType);
        final matchesMinPrice = minPrice == null || apartment.price >= minPrice;
        final matchesMaxPrice = maxPrice == null || apartment.price <= maxPrice;
        final matchesBedrooms = _minBedrooms == null || apartment.bedrooms >= _minBedrooms!;

        return matchesText && matchesLocation && matchesPropertyType && matchesMinPrice && matchesMaxPrice && matchesBedrooms;
      }).toList();

      // Sorting logic
      if (_sortBy == 'Lowest Price') {
        results.sort((a, b) => a.price.compareTo(b.price));
      } else if (_sortBy == 'Newest Listings') {
        results.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      }
      // 'Recommended' is the default order, so no sorting is needed.

      _filteredApartments = results;
    });
  }

  void _toggleFavorite(String apartmentId) {
    setState(() {
      if (_favoriteApartmentIds.contains(apartmentId)) {
        _favoriteApartmentIds.remove(apartmentId);
      } else {
        _favoriteApartmentIds.add(apartmentId);
      }
    });
  }

  void _navigateToFavorites() async {
    // Navigate to the favorites screen and wait for it to be popped.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoriteApartmentsScreen(
          favoriteApartmentIds: _favoriteApartmentIds,
          onFavoriteToggle: _toggleFavorite,
        ),
      ),
    );
    // Rebuild the screen when returning to reflect any changes made on the favorites screen.
    setState(() {});
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        builder: (_, controller) => _FilterSheet(
          scrollController: controller,
          initialMinPrice: _minPrice,
          initialMaxPrice: _maxPrice,
          locationFilter: _locationFilter,
          propertyTypes: _propertyTypes,
          minBedrooms: _minBedrooms,
          sortBy: _sortBy,
          onApply: (Map<String, dynamic> filters) {
            setState(() {
              _locationFilter = filters['location'];
              _propertyTypes = filters['propertyTypes'];
              _minBedrooms = filters['minBedrooms'];
              _sortBy = filters['sortBy'];
              _minPrice = filters['minPrice'];
              _maxPrice = filters['maxPrice'];
            });
            _filterApartments();
            Navigator.pop(context);
          },
          onReset: () {
            setState(() {
              _locationFilter = null;
              _propertyTypes.clear();
              _minBedrooms = null;
              _sortBy = 'Recommended';
              _minPrice = '';
              _maxPrice = '';
            });
            _filterApartments();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Rent Apartments', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: _navigateToFavorites,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or address...',
                hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(153)),
                filled: true,
                fillColor: theme.colorScheme.secondary,
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSecondary.withAlpha(153)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _filteredApartments.length,
              itemBuilder: (context, index) {
                final apartment = _filteredApartments[index];
                final isFavorite = _favoriteApartmentIds.contains(apartment.id);
                return ApartmentCard(apartment: apartment, isFavorite: isFavorite, onFavoritePressed: () => _toggleFavorite(apartment.id));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final ScrollController scrollController;
  final String initialMinPrice;
  final String initialMaxPrice;
  final String? locationFilter;
  final Set<String> propertyTypes;
  final int? minBedrooms;
  final String sortBy;
  final Function(Map<String, dynamic>) onApply;
  final Function() onReset;

  const _FilterSheet({
    required this.scrollController,
    required this.initialMinPrice,
    required this.initialMaxPrice,
    this.locationFilter,
    required this.propertyTypes,
    this.minBedrooms,
    required this.sortBy,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _location;
  late Set<String> _propertyTypes;
  late int? _minBedrooms;
  late String _sortBy;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _location = widget.locationFilter;
    _propertyTypes = Set.from(widget.propertyTypes);
    _minBedrooms = widget.minBedrooms;
    _sortBy = widget.sortBy;
    _minPriceController = TextEditingController(text: widget.initialMinPrice);
    _maxPriceController = TextEditingController(text: widget.initialMaxPrice);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary))),
          const SizedBox(height: 24),

          _buildSectionTitle('Location', theme),
          _buildChoiceChips(['Nearby', 'Asokoro', 'Gwarinpa', 'Wuse II'], _location, (selected) => setState(() => _location = selected)),

          _buildSectionTitle('Property Type', theme),
          _buildMultiChoiceChips(['Apartment', 'House', 'Studio'], _propertyTypes, (type) => setState(() => _propertyTypes.contains(type) ? _propertyTypes.remove(type) : _propertyTypes.add(type))),

          _buildSectionTitle('Price Range (per year)', theme),
          Row(children: [
            Expanded(child: _buildPriceField(_minPriceController, 'Min Price', theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildPriceField(_maxPriceController, 'Max Price', theme)),
          ]),

          _buildSectionTitle('Bedrooms', theme),
          _buildChoiceChips(['1+', '2+', '3+', '4+'], _minBedrooms == null ? null : '$_minBedrooms+', (selected) => setState(() => _minBedrooms = selected == null ? null : int.parse(selected.replaceAll('+', '')))),

          _buildSectionTitle('Sort By', theme),
          _buildChoiceChips(['Recommended', 'Lowest Price', 'Newest Listings'], _sortBy, (selected) => setState(() => _sortBy = selected!)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(children: [
          Expanded(child: OutlinedButton(onPressed: widget.onReset, child: const Text('Reset'), style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.primary, side: BorderSide(color: theme.colorScheme.primary)))),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton(onPressed: () => widget.onApply({
            'location': _location,
            'propertyTypes': _propertyTypes, // This is already a Set<String>
            'minBedrooms': _minBedrooms,
            'sortBy': _sortBy,
            'minPrice': _minPriceController.text,
            'maxPrice': _maxPriceController.text,
          }), child: const Text('Apply'))), // No need to cast here
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
  );

  Widget _buildChoiceChips(List<String> options, String? selectedValue, Function(String?) onSelect) {
    return Wrap(
      spacing: 8.0,
      children: options.map((option) => ChoiceChip(
        label: Text(option),
        selected: selectedValue == option,
        onSelected: (selected) => onSelect(selected ? option : null),
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(color: selectedValue == option ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: StadiumBorder(side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3))),
      )).toList(),
    );
  }

  Widget _buildMultiChoiceChips(List<String> options, Set<String> selectedValues, Function(String) onSelect) {
    return Wrap(
      spacing: 8.0,
      children: options.map((option) => FilterChip(
        label: Text(option),
        selected: selectedValues.contains(option),
        onSelected: (_) => onSelect(option),
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(color: selectedValues.contains(option) ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: StadiumBorder(side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3))),
      )).toList(),
    );
  }

  Widget _buildPriceField(TextEditingController controller, String hint, ThemeData theme) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(153)),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        prefixText: '₦',
        prefixStyle: TextStyle(color: theme.colorScheme.onSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}