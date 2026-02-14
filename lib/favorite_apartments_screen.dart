import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rent_apartment_screen.dart'; // Import to use Apartment

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
  List<Apartment> _favoriteApartments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    if (widget.favoriteApartmentIds.isEmpty) {
      setState(() {
        _favoriteApartments = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('apartments')
          .select()
          .inFilter('id', widget.favoriteApartmentIds.toList());
      
      if (mounted) {
        setState(() {
          _favoriteApartments = (response as List).map((e) => Apartment.fromMap(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleFavoriteToggle(String apartmentId) {
    widget.onFavoriteToggle(apartmentId);
    setState(() {
      _favoriteApartments.removeWhere((apt) => apt.id == apartmentId);
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : _favoriteApartments.isEmpty
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
                return _buildApartmentCard(theme, apartment);
              },
            ),
    );
  }

  Widget _buildApartmentCard(ThemeData theme, Apartment apartment) {
    return Card(
      color: theme.colorScheme.secondary,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            apartment.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (c, o, s) => Container(width: 80, height: 80, color: Colors.grey, child: const Icon(Icons.home)),
          ),
        ),
        title: Text(apartment.title, style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
        subtitle: Text("${apartment.address}\n\$${apartment.price}/night", style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => _handleFavoriteToggle(apartment.id),
        ),
      ),
    );
  }
}