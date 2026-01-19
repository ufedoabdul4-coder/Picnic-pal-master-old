import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the login screen for logout navigation
import 'package:intl/intl.dart'; // Import for date and number formatting
import 'revenue_details_screen.dart'; // Import the new revenue details screen
import 'event_detail_screen.dart'; // Import the new event detail screen

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

class EventPlannerHomeTab extends StatefulWidget {
  const EventPlannerHomeTab({super.key});

  @override
  State<EventPlannerHomeTab> createState() => _EventPlannerHomeTabState();
}

class _EventPlannerHomeTabState extends State<EventPlannerHomeTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Mock data for metrics
  final List<Map<String, dynamic>> _metricsData = [
    {
      "title": "Active Events",
      "value": "12",
      "icon": Icons.event,
      "color": const Color(0xFF3498DB),
      "details": {"Weddings": 5, "Corporate": 4, "Social": 3},
    },
    {
      "title": "Upcoming Deadlines",
      "value": "8",
      "icon": Icons.schedule,
      "color": const Color(0xFFF39C12),
      "details": {"This Week": 3, "Next Week": 5},
    },
    {
      "title": "This Month's Revenue",
      "value": "\$45,200",
      "icon": Icons.attach_money,
      "color": const Color(0xFF27AE60),
      "details": {"Completed": "\$32,000", "Pending": "\$13,200"},
    },
    {
      "title": "Pending Tasks",
      "value": "24",
      "icon": Icons.task_alt,
      "color": const Color(0xFFE74C3C),
      "details": {"High Priority": 8, "Medium Priority": 10, "Low Priority": 6},
    },
  ];

  // Mock data for recent events
  final List<Map<String, dynamic>> _recentEvents = [
    {
      "id": 1,
      "clientName": "Sarah Johnson",
      "eventType": "Wedding",
      "eventDate": "2025-01-15",
      "status": "In Progress",
      "progress": 0.75,
      "statusColor": const Color(0xFF3498DB),
      "venue": "Grand Ballroom Hotel",
      "budget": "\$35,000",
      "image": "assets/images/event_weddings.jpg", // Using local asset
    },
    {
      "id": 2,
      "clientName": "Tech Corp Inc.",
      "eventType": "Corporate Conference",
      "eventDate": "2025-01-22",
      "status": "Planning",
      "progress": 0.45,
      "statusColor": const Color(0xFFF39C12),
      "venue": "Convention Center",
      "budget": "\$50,000",
      "image": "assets/images/event        _picnic.jpg", // Using local asset
    },
    {
      "id": 3,
      "clientName": "Michael Chen",
      "eventType": "Birthday Party",
      "eventDate": "2025-01-18",
      "status": "Confirmed",
      "progress": 0.90,
      "statusColor": const Color(0xFF27AE60),
      "venue": "Garden Terrace",
      "budget": "\$8,500",
      "image": "assets/images/millennium_park.jpg", // Using local asset
    },
    {
      "id": 4,
      "clientName": "Anderson & Partners",
      "eventType": "Product Launch",
      "eventDate": "2025-02-05",
      "status": "Initial Contact",
      "progress": 0.20,
      "statusColor": const Color(0xFF7F8C8D),
      "venue": "Downtown Gallery",
      "budget": "\$28,000",
      "image": "assets/images/central_park.jpg", // Using local asset
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  void _showMetricDetails(BuildContext context, Map<String, dynamic> metric) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (metric["color"] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    metric["icon"] as IconData,
                    color: metric["color"] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    metric["title"] as String,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Breakdown",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            ...(metric["details"] as Map<String, dynamic>).entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: theme.textTheme.bodyLarge),
                    Text(
                      entry.value.toString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Good Morning,",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                "Jessica",
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () {},
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    "3",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Metrics Cards
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _metricsData.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final metric = _metricsData[index];
                          return GestureDetector(
                            onLongPress: () => _showMetricDetails(context, metric),
                            child: _MetricsCardWidget(
                              title: metric["title"] as String,
                              value: metric["value"] as String,
                              icon: metric["icon"] as IconData,
                              color: metric["color"] as Color,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Recent Events Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Events",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to full event list
                            },
                            child: Text(
                              "View All",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Recent Events List
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final event = _recentEvents[index];
                  return _RecentEventsWidget(
                    event: event,
                    onEdit: () {
                      // Navigate to edit
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                      );
                    },
                    onViewTimeline: () {
                      // View timeline
                    },
                    onContactClient: () {
                      // Contact client
                    },
                    onArchive: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Event archived: ${event["clientName"]}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                }, childCount: _recentEvents.length),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to new event
        },
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        label: Text(
          'New Event',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}

class _MetricsCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricsCardWidget({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentEventsWidget extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onEdit;
  final VoidCallback onViewTimeline;
  final VoidCallback onContactClient;
  final VoidCallback onArchive;

  const _RecentEventsWidget({
    required this.event,
    required this.onEdit,
    required this.onViewTimeline,
    required this.onContactClient,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    event["image"],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event["eventType"],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event["clientName"],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (event["statusColor"] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event["status"],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: event["statusColor"] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(context, Icons.calendar_today, event["eventDate"]),
                _buildInfoItem(context, Icons.location_on, event["venue"]),
                _buildInfoItem(context, Icons.attach_money, event["budget"]),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: event["progress"],
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(event["statusColor"]),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onContactClient,
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: const Text("Contact"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onViewTimeline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Timeline"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
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

class EventPlannerBookingsTab extends StatefulWidget {
  const EventPlannerBookingsTab({super.key});

  @override
  State<EventPlannerBookingsTab> createState() => _EventPlannerBookingsTabState();
}

class _EventPlannerBookingsTabState extends State<EventPlannerBookingsTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _sortBy = 'Date';

  Map<String, dynamic> _activeFilters = {
    'status': <String>[],
    'eventType': <String>[],
    'dateRange': null,
  };

  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    _allEvents = [
      {
        "id": 1,
        "clientName": "Sarah Johnson",
        "eventType": "Wedding",
        "date": "Dec 28, 2025",
        "venue": "Grand Ballroom, Plaza Hotel",
        "status": "Upcoming",
        "budget": "\$45,000",
        "guests": 200,
        "image": "assets/images/event_weddings.jpg",
      },
      {
        "id": 2,
        "clientName": "Tech Corp Inc",
        "eventType": "Corporate",
        "date": "Jan 15, 2026",
        "venue": "Convention Center",
        "status": "In Progress",
        "budget": "\$75,000",
        "guests": 500,
        "image": "assets/images/event_picnic.jpg",
      },
      {
        "id": 3,
        "clientName": "Michael Chen",
        "eventType": "Birthday",
        "date": "Dec 20, 2025",
        "venue": "Sunset Garden Restaurant",
        "status": "Upcoming",
        "budget": "\$8,500",
        "guests": 75,
        "image": "assets/images/millennium_park.jpg",
      },
      {
        "id": 4,
        "clientName": "Global Summit 2025",
        "eventType": "Conference",
        "date": "Nov 10, 2025",
        "venue": "International Conference Hall",
        "status": "Completed",
        "budget": "\$120,000",
        "guests": 1000,
        "image": "assets/images/central_park.jpg",
      },
      {
        "id": 5,
        "clientName": "Emma Rodriguez",
        "eventType": "Wedding",
        "date": "Feb 14, 2026",
        "venue": "Beachside Resort",
        "status": "Upcoming",
        "budget": "\$55,000",
        "guests": 150,
        "image": "assets/images/event_weddings.jpg",
      },
    ];

    setState(() {
      _filteredEvents = List.from(_allEvents);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _loadMoreEvents();
      }
    }
  }

  Future<void> _loadMoreEvents() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoadingMore = false);
  }

  Future<void> _refreshEvents() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _filteredEvents = List.from(_allEvents);
    });
  }

  void _filterEvents() {
    List<Map<String, dynamic>> filtered = List.from(_allEvents);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchLower = _searchController.text.toLowerCase();
      filtered = filtered.where((event) {
        return (event['clientName'] as String).toLowerCase().contains(searchLower) ||
            (event['eventType'] as String).toLowerCase().contains(searchLower) ||
            (event['venue'] as String).toLowerCase().contains(searchLower);
      }).toList();
    }

    // Apply sorting
    _sortEvents(filtered);

    setState(() {
      _filteredEvents = filtered;
    });
  }

  void _sortEvents(List<Map<String, dynamic>> events) {
    switch (_sortBy) {
      case 'Date':
        events.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
        break;
      case 'Client Name':
        events.sort((a, b) => (a['clientName'] as String).compareTo(b['clientName'] as String));
        break;
      case 'Status':
        events.sort((a, b) => (a['status'] as String).compareTo(b['status'] as String));
        break;
      case 'Budget':
        events.sort((a, b) => (a['budget'] as String).compareTo(b['budget'] as String));
        break;
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildSortOptions(),
    );
  }

  Widget _buildSortOptions() {
    final theme = Theme.of(context);
    final sortOptions = ['Date', 'Client Name', 'Status', 'Budget'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Sort By',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...sortOptions.map(
            (option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                  _filterEvents();
                });
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Events',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _filterEvents(),
                    decoration: InputDecoration(
                      hintText: 'Search events, clients...',
                      prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: colorScheme.onSurface.withOpacity(0.6)),
                              onPressed: () {
                                _searchController.clear();
                                _filterEvents();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: colorScheme.surface.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showSortOptions,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.filter_list, color: colorScheme.onPrimary, size: 24),
                  ),
                ),
              ],
            ),
          ),
          // Event list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 64, color: colorScheme.onSurface.withOpacity(0.4)),
                            const SizedBox(height: 16),
                            Text(
                              'No events found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshEvents,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredEvents.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _filteredEvents.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final event = _filteredEvents[index];
                            return _EventCardWidget(
                              event: event,
                              onTap: () {
                                // Navigate to details
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create new event')));
        },
        icon: Icon(Icons.add, color: colorScheme.onPrimary),
        label: Text('Add Event', style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
      ),
    );
  }
}

class _EventCardWidget extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;

  const _EventCardWidget({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor;
    switch (event['status']) {
      case 'Upcoming':
        statusColor = Colors.blueAccent;
        break;
      case 'In Progress':
        statusColor = Colors.orangeAccent;
        break;
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left-aligned Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    event['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 30, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              event['clientName'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Status Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event['status'],
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Event Type Label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event['eventType'],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Date
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(
                            event['date'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event['venue'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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