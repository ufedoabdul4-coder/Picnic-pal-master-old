import 'package:flutter/material.dart';
import 'rent_apartment_screen.dart'; // Import to use Apartment and ApartmentCard

class FavoriteApartmentsScreen extends StatefulWidget {
  final Set<String> favoriteApartmentIds;
  final Function(String) onFavoriteToggle;

  const FavoriteApartmentsScreen({
    super.key,
    required this.favoriteApartmentIds,
    required this.onFavoriteToggle,
  });

  @override
  State<FavoriteApartmentsScreen> createState() => _FavoriteApartmentsScreenState();
}

class _FavoriteApartmentsScreenState extends State<FavoriteApartmentsScreen> {
  late List<Apartment> _favoriteApartments;

  @override
  void initState() {
    super.initState();
    _updateFavorites();
  }

  void _updateFavorites() {
    // Filter the main list to get only the favorited apartments
    _favoriteApartments = mockApartments.where((apartment) => widget.favoriteApartmentIds.contains(apartment.id)).toList();
  }

  void _handleFavoriteToggle(String apartmentId) {
    // Call the callback from the parent screen
    widget.onFavoriteToggle(apartmentId);
    // Rebuild this screen to reflect the change
    setState(() {
      _updateFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Apartments', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: _favoriteApartments.isEmpty
          ? Center(
              child: Text(
                'You have no favorite apartments yet.',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _favoriteApartments.length,
              itemBuilder: (context, index) {
                final apartment = _favoriteApartments[index];
                return ApartmentCard(
                  apartment: apartment,
                  isFavorite: true, // It will always be a favorite on this screen
                  onFavoritePressed: () => _handleFavoriteToggle(apartment.id),
                );
              },
            ),
    );
  }
}