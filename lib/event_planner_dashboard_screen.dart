import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the login screen for logout navigation
import 'package:intl/intl.dart'; // Import for date and number formatting
import 'revenue_details_screen.dart'; // Import the new revenue details screen

class EventPlannerDashboardScreen extends StatefulWidget {
  const EventPlannerDashboardScreen({super.key});

  @override
  State<EventPlannerDashboardScreen> createState() => _EventPlannerDashboardScreenState();
}

class _EventPlannerDashboardScreenState extends State<EventPlannerDashboardScreen> {
  int _selectedIndex = 0;

  // Use `final` instead of `const` because EventPlannerWalletTab is not a constant.
  static final List<Widget> _widgetOptions = <Widget>[
    const EventPlannerHomeTab(),
    const EventPlannerBookingsTab(),
    EventPlannerWalletTab(), // New Wallet Tab
    const EventPlannerServicesTab(),
    const EventPlannerProfileTab(), // Profile is now the last item
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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online), 
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
      ),
    );
  }
}

class EventPlannerHomeTab extends StatelessWidget {
  const EventPlannerHomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/picnic_basket_logo.png', // Your logo asset
          height: 40,
          errorBuilder: (context, error, stackTrace) => Text('PicnicPal', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.onSurface),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon!')));
            },
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Revenue (Month)',
                  value: '£1,250',
                  icon: Icons.attach_money,
                  color: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RevenueDetailsScreen())),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'New Bookings',
                  value: '8',
                  icon: Icons.calendar_today_outlined,
                  color: Colors.blue,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigating to Bookings...'))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 12),
          Card(
            color: theme.colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.fact_check_outlined, color: theme.colorScheme.primary),
              title: Text('New Booking: "Lakeside Picnic"', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
              subtitle: Text('For this Saturday, 2:00 PM', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179))),
            ),
          ),
          Card(
            color: theme.colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.rate_review_outlined, color: theme.colorScheme.primary),
              title: Text('New Review: 4.5 Stars', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
              subtitle: Text('From user "Alex Ray"', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179))),
            ),
          ),
          Card(
            color: theme.colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.question_answer_outlined, color: theme.colorScheme.primary),
              title: Text('New Message', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
              subtitle: Text('Regarding "Garden Party" availability', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179))),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
              Text(
                value,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventPlannerWalletTab extends StatelessWidget {
  EventPlannerWalletTab({super.key});

  final List<Map<String, dynamic>> _transactionHistory = const [
    {'title': 'Payment: "Sunset Picnic"', 'amount': 250.00, 'date': 'Nov 26, 2025'},
    {'title': 'Platform Fee (5%)', 'amount': -12.50, 'date': 'Nov 26, 2025'},
    {'title': 'Payment: "Corporate Lunch"', 'amount': 800.00, 'date': 'Nov 24, 2025'},
    {'title': 'Platform Fee (5%)', 'amount': -40.00, 'date': 'Nov 24, 2025'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Wallet & Payouts', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ... (Other wallet components like balance would go here)
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()));
                },
                child: Text('View All', style: TextStyle(color: theme.colorScheme.primary)),
              )
            ],
          ),
          const SizedBox(height: 12),
          ..._transactionHistory.take(4).map((tx) => _buildHistoryTile(
            context,
            title: tx['title'],
            subtitle: tx['date'],
            amount: tx['amount'],
          )),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, {required String title, required String subtitle, required double amount}) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_GB', symbol: '£');
    final isCredit = amount > 0;

    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
          color: isCredit ? Colors.green : Colors.redAccent,
        ),
        title: Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
        trailing: Text(
          currencyFormat.format(amount),
          style: TextStyle(
            color: isCredit ? Colors.green : Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  // More detailed mock data for the dedicated screen
  static final List<Map<String, dynamic>> _fullTransactionHistory = [
    {'id': 'TXN1001', 'title': 'Payment: "Sunset Picnic"', 'amount': 250.00, 'date': '2025-11-26 14:30', 'status': 'Completed'},
    {'id': 'TXN1002', 'title': 'Platform Fee (5%)', 'amount': -12.50, 'date': '2025-11-26 14:31', 'status': 'Completed'},
    {'id': 'TXN1003', 'title': 'Payment: "Corporate Lunch"', 'amount': 800.00, 'date': '2025-11-24 10:15', 'status': 'Completed'},
    {'id': 'TXN1004', 'title': 'Platform Fee (5%)', 'amount': -40.00, 'date': '2025-11-24 10:16', 'status': 'Completed'},
    {'id': 'TXN1005', 'title': 'Refund: "Cancelled Booking"', 'amount': -150.00, 'date': '2025-11-22 09:00', 'status': 'Completed'},
    {'id': 'TXN1006', 'title': 'Payout to Bank Account', 'amount': -1100.50, 'date': '2025-11-15 18:00', 'status': 'Completed'},
    {'id': 'TXN1007', 'title': 'Payment: "Beach Bonfire"', 'amount': 450.00, 'date': '2025-11-14 11:45', 'status': 'Completed'},
    {'id': 'TXN1008', 'title': 'Platform Fee (5%)', 'amount': -22.50, 'date': '2025-11-14 11:46', 'status': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_GB', symbol: '£');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Transaction History', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _fullTransactionHistory.length,
        itemBuilder: (context, index) {
          final tx = _fullTransactionHistory[index];
          final amount = tx['amount'] as double;
          final isCredit = amount > 0;
          final parsedDate = DateTime.parse(tx['date']);

          return Card(
            color: theme.colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? Colors.green : Colors.redAccent,
              ),
              title: Text(tx['title'], style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${DateFormat('MMM d, yyyy, hh:mm a').format(parsedDate)} • ${tx['id']}',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              trailing: Text(
                currencyFormat.format(amount),
                style: TextStyle(
                  color: isCredit ? Colors.green : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EventPlannerServicesTab extends StatelessWidget {
  const EventPlannerServicesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Listings', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, centerTitle: true,
      ),
      body: const Center(child: Text('Your listings will appear here.')),
    );
  }
}

class EventPlannerBookingsTab extends StatelessWidget {
  const EventPlannerBookingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, centerTitle: true,
      ),
      body: const Center(child: Text('Your bookings will appear here.')),
    );
  }
}

class EventPlannerProfileTab extends StatelessWidget {
  const EventPlannerProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Icon(Icons.storefront, size: 50, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Center(child: Text("Planner's Business Name", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface))),
          const SizedBox(height: 30),
          ListTile(
            leading: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.onSurface),
            title: Text('Edit Profile', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onTap: () { /* Placeholder for edit profile navigation */ },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              // Show a confirmation dialog before logging out
              final bool? shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  final theme = Theme.of(dialogContext);
                  return AlertDialog(
                    backgroundColor: theme.colorScheme.surface,
                    title: Text('Logout?', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                    content: Text('Are you sure you want to logout?', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8))),
                    actions: <Widget>[
                      TextButton(
                        child: Text('No', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                        onPressed: () => Navigator.of(dialogContext).pop(false), // Dismiss the dialog and return false
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text('Yes', style: TextStyle(color: Colors.white)),
                        onPressed: () => Navigator.of(dialogContext).pop(true), // Dismiss the dialog and return true
                      ),
                    ],
                  );
                },
              );

              // If the user confirmed, then proceed with logout
              if (shouldLogout == true) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}