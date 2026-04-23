import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rent_apartment_screen.dart'; // For Apartment model and mock data
import 'add_edit_apartment_screen.dart';
import 'manager_inbox_screen.dart'; // Import the new ManagerInboxScreen
import 'main.dart';

class ApartmentManagerDashboardScreen extends StatefulWidget {
  const ApartmentManagerDashboardScreen({super.key});

  @override
  State<ApartmentManagerDashboardScreen> createState() => _ApartmentManagerDashboardScreenState();
}

class _ApartmentManagerDashboardScreenState extends State<ApartmentManagerDashboardScreen> {
  Stream<List<Apartment>>? _apartmentsStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _apartmentsStream = Supabase.instance.client
            .from('apartments')
            .stream(primaryKey: ['id'])
            .eq('manager_id', user.id)
            .map((data) => data.map((map) => Apartment.fromMap(map)).toList());
      });
    }
  }

  Future<void> _refreshData() async {
    _initStream();
    await Future.delayed(const Duration(seconds: 1)); // UX delay
  }

  Future<void> _deleteApartment(String id) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Delete Listing?', style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text('Are you sure you want to delete this apartment? This action cannot be undone.', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client.from('apartments').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apartment deleted successfully')));
          _initStream();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apartment Manager Dashboard',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagerInboxScreen())),
          ),
        ],
      ),
      body: StreamBuilder<List<Apartment>>(
        stream: _apartmentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load apartments. Please check your internet connection.'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          }

          final managedApartments = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: theme.colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(theme, 'Total Listings', managedApartments.length.toString(), Icons.apartment_outlined),
                      _buildStatCard(theme, 'Occupied', '0', Icons.person_search_outlined), // Mock data
                      _buildStatCard(theme, 'Vacant', '0', Icons.no_accounts_outlined), // Mock data
                    ],
                  ),
                  const SizedBox(height: 32),

                  // My Listings Section
                  Text(
                    'My Listings',
                    style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: managedApartments.length,
                    itemBuilder: (context, index) {
                      return _ManagerApartmentCard(
                        apartment: managedApartments[index],
                        onEdit: () async {
                          await Navigator.push<bool>(context,
                              MaterialPageRoute(builder: (_) => AddEditApartmentScreen(editingApartment: managedApartments[index])));
                        },
                        onDelete: () => _deleteApartment(managedApartments[index].id),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddEditApartmentScreen()),
          );
          if (result == true) {
            setState(() {});
          }
        },
        label: const Text('Add Listing'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        color: theme.colorScheme.secondary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagerApartmentCard extends StatelessWidget {
  final Apartment apartment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ManagerApartmentCard({required this.apartment, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondary,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(apartment.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, o, s) => Container(width: 60, height: 60, color: theme.colorScheme.surface, child: Icon(Icons.image_not_supported, color: theme.colorScheme.onSurface.withOpacity(0.5)))),
        ),
        title: Text(apartment.title, style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
        subtitle: Text(apartment.address, style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary), onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}