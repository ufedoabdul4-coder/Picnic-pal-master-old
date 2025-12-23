import 'package:flutter/material.dart';
import 'rent_apartment_screen.dart'; // For Apartment model and mock data
import 'add_edit_apartment_screen.dart';

class ApartmentManagerDashboardScreen extends StatefulWidget {
  const ApartmentManagerDashboardScreen({super.key});

  @override
  State<ApartmentManagerDashboardScreen> createState() => _ApartmentManagerDashboardScreenState();
}

class _ApartmentManagerDashboardScreenState extends State<ApartmentManagerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // For demonstration, we'll assume the manager manages all mock apartments
    final List<Apartment> managedApartments = mockApartments;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apartment Manager Dashboard',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(theme, 'Total Listings', managedApartments.length.toString(), Icons.apartment_outlined),
                _buildStatCard(theme, 'Occupied', '3', Icons.person_search_outlined), // Mock data
                _buildStatCard(theme, 'Vacant', '1', Icons.no_accounts_outlined), // Mock data
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
                    final result = await Navigator.push<bool>(context,
                        MaterialPageRoute(builder: (_) => AddEditApartmentScreen(editingApartment: managedApartments[index])));
                    if (result == true) {
                      setState(() {});
                    }
                  },
                );
              },
            ),
          ],
        ),
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
  const _ManagerApartmentCard({required this.apartment, required this.onEdit});

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
          child: Image.asset(apartment.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, o, s) => Container(width: 60, height: 60, color: theme.colorScheme.surface, child: Icon(Icons.image_not_supported, color: theme.colorScheme.onSurface.withOpacity(0.5)))),
        ),
        title: Text(apartment.title, style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
        subtitle: Text(apartment.address, style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
        trailing: IconButton(
          icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary), onPressed: onEdit,
        ),
      ),
    );
  }
}