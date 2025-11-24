import 'package:flutter/material.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _selectedIndex = 0;

  // Placeholder pages for the dashboard sections
  static const List<Widget> _widgetOptions = <Widget>[
    VendorHomeTab(),
    VendorListingsTab(),
    VendorBookingsTab(),
    VendorProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: _selectedIndex == 1 // Show FAB only on Listings tab
          ? FloatingActionButton(
              onPressed: () { /* Placeholder for adding a new listing */ },
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            ) : null,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
      ),
    );
  }
}

// Placeholder Tab Widgets

class VendorHomeTab extends StatelessWidget {
  const VendorHomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.onSurface),
            onPressed: () {
              // Placeholder for notifications
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon!')));
            },
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSummarySection(context),
          const SizedBox(height: 24),
          Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 12),
          _buildRecentActivityCard(context, icon: Icons.fact_check_outlined, title: 'New Booking: "Lakeside Picnic"', subtitle: 'For this Saturday, 2:00 PM'),
          _buildRecentActivityCard(context, icon: Icons.rate_review_outlined, title: 'New Review: 4.5 Stars', subtitle: 'From user "Alex Ray"'),
          _buildRecentActivityCard(context, icon: Icons.question_answer_outlined, title: 'New Message', subtitle: 'Regarding "Garden Party" availability'),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _SummaryCard(title: 'Revenue (Month)', value: '\$1,250', icon: Icons.attach_money, color: Colors.green)),
        SizedBox(width: 16),
        Expanded(child: _SummaryCard(title: 'New Bookings', value: '8', icon: Icons.calendar_today_outlined, color: Colors.blue)),
      ],
    );
  }

  Widget _buildRecentActivityCard(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179))),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179), fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class VendorListingsTab extends StatelessWidget {
  const VendorListingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Listings', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: const Center(child: Text('Your listings will appear here.')),
    );
  }
}

class VendorBookingsTab extends StatelessWidget {
  const VendorBookingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: const Center(child: Text('Your bookings will appear here.')),
    );
  }
}

class VendorProfileTab extends StatelessWidget {
  const VendorProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: const Center(child: Text('Your vendor profile will appear here.')),
    );
  }
}