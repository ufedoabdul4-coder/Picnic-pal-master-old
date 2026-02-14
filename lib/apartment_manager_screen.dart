import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rent_apartment_screen.dart';
import 'add_edit_apartment_screen.dart';
import 'apartment_details_screen.dart';
import 'main.dart';

class ApartmentManagerScreen extends StatefulWidget {
  const ApartmentManagerScreen({super.key});

  @override
  State<ApartmentManagerScreen> createState() => _ApartmentManagerScreenState();
}

class _ApartmentManagerScreenState extends State<ApartmentManagerScreen> {
  // For this demo, we assume the user owns all mock apartments.
  List<Apartment> _myListings = [];

  @override
  void initState() {
    super.initState();
    _refreshListings();
  }

  Future<void> _refreshListings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client.from('apartments').select().eq('manager_id', user.id);
      if (mounted) {
        setState(() {
          _myListings = (response as List).map((e) => Apartment.fromMap(e)).toList();
        });
      }
    }
  }

  void _navigateToAddEdit({Apartment? apartment}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditApartmentScreen(editingApartment: apartment),
      ),
    );

    if (result == true) {
      _refreshListings();
    }
  }

  void _deleteApartment(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.from('apartments').delete().eq('id', id);
              if (mounted) {
                _refreshListings();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing deleted')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Listings', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
            },
            tooltip: 'Go to Home',
          ),
        ],
      ),
      body: _myListings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apartment, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No listings yet', style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _navigateToAddEdit(),
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                    child: const Text('Add Your First Apartment'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _myListings.length,
              itemBuilder: (context, index) {
                final apartment = _myListings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: _buildImage(apartment.imageUrl),
                      ),
                    ),
                    title: Text(apartment.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(apartment.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _navigateToAddEdit(apartment: apartment)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteApartment(apartment.id)),
                      ],
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ApartmentDetailsScreen(apartment: apartment))),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported));
    } else {
      return Image.file(File(imageUrl), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    }
  }
}