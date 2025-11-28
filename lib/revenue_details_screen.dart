import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueDetailsScreen extends StatelessWidget {
  const RevenueDetailsScreen({super.key});

  // Mock data for monthly revenue. In a real app, this would come from a database or API.
  final Map<String, double> _monthlyRevenue = const {
    'November 2025': 1250.00,
    'October 2025': 980.50,
    'September 2025': 1500.75,
    'August 2025': 750.00,
    'July 2025': 2100.25,
    'June 2025': 1800.00,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalRevenue = _monthlyRevenue.values.fold(0.0, (sum, item) => sum + item);
    final currencyFormat = NumberFormat.currency(locale: 'en_GB', symbol: '£');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Revenue Details', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary), // To make the back arrow match the theme
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Total Revenue Summary Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Revenue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      currencyFormat.format(totalRevenue),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Monthly Breakdown List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _monthlyRevenue.length,
              itemBuilder: (context, index) {
                final month = _monthlyRevenue.keys.elementAt(index);
                final revenue = _monthlyRevenue[month]!;
                return Card(
                  color: theme.colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(month, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
                    trailing: Text(currencyFormat.format(revenue), style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}