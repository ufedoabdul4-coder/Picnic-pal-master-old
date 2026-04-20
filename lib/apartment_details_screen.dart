import 'dart:io';
import 'package:flutter/material.dart';
import 'rent_apartment_screen.dart'; // Import to use the Apartment model
import 'package:intl/intl.dart';
import 'agent_chat_screen.dart';

class ApartmentDetailsScreen extends StatelessWidget {
  final Apartment apartment;

  const ApartmentDetailsScreen({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysAgo = DateTime.now().difference(apartment.dateAdded).inDays;
    final timePosted = daysAgo == 0 ? 'Today' : '$daysAgo days ago';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Property Details', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (apartment.imageUrl.startsWith('http'))
                  Image.network(
                    apartment.imageUrl,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                  )
                else if (apartment.imageUrl.startsWith('assets/'))
                  Image.asset(
                    apartment.imageUrl,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                  )
                else
                  Image.file(
                    File(apartment.imageUrl),
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                  ),
                if (apartment.isVerified)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: theme.colorScheme.onPrimary, size: 16),
                          const SizedBox(width: 4),
                          Text('Verified', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                    child: Text('Posted $timePosted', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Text(
                    apartment.title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₦${NumberFormat('#,###').format(apartment.price)} / year',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 16),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, color: theme.colorScheme.onSurface.withOpacity(0.6), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          apartment.address,
                          style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                  const SizedBox(height: 20),

                  // Quick Summary Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(context, Icons.apartment, apartment.propertyType),
                      _buildSummaryItem(context, Icons.king_bed_outlined, '${apartment.bedrooms} Beds'),
                      _buildSummaryItem(context, Icons.bathtub_outlined, '${apartment.bathrooms} Baths'),
                      _buildSummaryItem(context, Icons.water_drop_outlined, '${apartment.toilets} Toilets'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                  const SizedBox(height: 20),

                  // Property Details Section
                  Text('Property Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, 'Address', apartment.address),
                  _buildDetailRow(context, 'Total Area', '${apartment.sizeSqm.toStringAsFixed(0)} sqm'),
                  _buildDetailRow(context, 'Condition', apartment.condition),
                  _buildDetailRow(context, 'Furnishing', apartment.furnishing),
                  _buildDetailRow(context, 'Toilets', '${apartment.toilets}'),

                  const SizedBox(height: 24),
                  Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                  const SizedBox(height: 20),

                  // Amenities Section
                  if (apartment.amenities.isNotEmpty) ...[
                    Text('Facilities & Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: apartment.amenities.map((amenity) => _buildAmenityChip(context, amenity)).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Contact Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone),
                          label: const Text('Call Agent'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgentChatScreen(
                                  apartment: apartment,
                                  managerName: "Agent", // Or fetch manager name if available
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message_outlined),
                          label: const Text('Message'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, color: Colors.white54, size: 50),
                );
  }

  Widget _buildSummaryItem(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 15)),
          Text(value, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(BuildContext context, String amenity) {
    final theme = Theme.of(context);
    IconData icon;
    switch (amenity.toLowerCase()) {
      case '24-hour electricity': icon = Icons.flash_on; break;
      case 'air conditioning': icon = Icons.ac_unit; break;
      case 'balcony': icon = Icons.balcony; break;
      case 'kitchen cabinets': icon = Icons.kitchen; break;
      case 'refrigerator': icon = Icons.kitchen; break;
      case 'prepaid meter': icon = Icons.electric_meter; break;
      case 'tiled floor': icon = Icons.grid_view; break;
      case 'wardrobe': icon = Icons.checkroom; break;
      case 'tv': case 'smart tv': icon = Icons.tv; break;
      case 'wifi': case 'high speed internet': icon = Icons.wifi; break;
      case 'parking space': icon = Icons.local_parking; break;
      case 'swimming pool': icon = Icons.pool; break;
      case 'elevator': icon = Icons.elevator; break;
      case 'water heater': icon = Icons.hot_tub; break;
      default: icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(amenity, style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}