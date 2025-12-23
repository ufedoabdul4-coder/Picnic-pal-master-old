import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? event;
  const EventDetailScreen({super.key, this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Mock event data (fallback if no event passed)
  late Map<String, dynamic> _eventData;

  final List<Map<String, dynamic>> _milestones = [
    {
      'id': 1,
      'title': 'Venue Booking Confirmed',
      'description': 'Grand Ballroom Hotel reservation secured',
      'dueDate': '2025-01-15',
      'completed': true,
    },
    {
      'id': 2,
      'title': 'Send Invitations',
      'description': 'Mail wedding invitations to all guests',
      'dueDate': '2025-03-01',
      'completed': true,
    },
    {
      'id': 3,
      'title': 'Finalize Menu Selection',
      'description': 'Confirm dinner menu with catering team',
      'dueDate': '2025-04-15',
      'completed': false,
    },
  ];

  final Map<String, dynamic> _budgetData = {
    'totalBudget': 50000.0,
    'totalSpent': 32500.0,
    'expenses': [
      {
        'id': 1,
        'category': 'Venue',
        'description': 'Grand Ballroom rental',
        'amount': 12000.0,
        'icon': Icons.location_city,
      },
      {
        'id': 2,
        'category': 'Catering',
        'description': 'Food and beverages',
        'amount': 8500.0,
        'icon': Icons.restaurant,
      },
    ],
  };

  final List<Map<String, dynamic>> _vendors = [
    {
      'id': 1,
      'name': 'Elegant Catering Co.',
      'category': 'Catering Service',
      'phone': '+1 (555) 234-5678',
      'email': 'info@elegantcatering.com',
      'icon': Icons.restaurant,
    },
    {
      'id': 2,
      'name': 'Perfect Moments Photography',
      'category': 'Photography & Videography',
      'phone': '+1 (555) 345-6789',
      'email': 'contact@perfectmoments.com',
      'icon': Icons.camera_alt,
    },
  ];

  final List<Map<String, dynamic>> _photos = [
    {
      'id': 1,
      'url': 'assets/images/event_weddings.jpg',
      'caption': 'Venue exterior',
    },
    {
      'id': 2,
      'url': 'assets/images/event_picnic.jpg',
      'caption': 'Ballroom setup',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    // Initialize event data from widget or use mock
    if (widget.event != null) {
      _eventData = Map.from(widget.event!);
      // Ensure all required fields exist
      _eventData.putIfAbsent('name', () => '${_eventData['clientName']}\'s ${_eventData['eventType']}');
      _eventData.putIfAbsent('date', () => _eventData['date'] ?? 'Date TBD');
      _eventData.putIfAbsent('status', () => _eventData['status'] ?? 'Upcoming');
      _eventData.putIfAbsent('clientName', () => _eventData['clientName'] ?? 'Client Name');
      _eventData.putIfAbsent('clientPhone', () => '+1 (555) 123-4567');
      _eventData.putIfAbsent('venueName', () => _eventData['venue'] ?? 'Venue TBD');
      _eventData.putIfAbsent('guestCount', () => '${_eventData['guests'] ?? 0} guests');
      _eventData.putIfAbsent('description', () => 'Event description goes here.');
      _eventData.putIfAbsent('image', () => _eventData['image'] ?? 'assets/images/event_weddings.jpg');

    } else {
      _eventData = {
        'id': 1,
        'name': 'Sarah & Michael\'s Wedding',
        'date': 'June 15, 2025 at 4:00 PM',
        'status': 'Upcoming',
        'image': 'assets/images/event_weddings.jpg',
        'clientName': 'Sarah Johnson',
        'clientEmail': 'sarah.johnson@email.com',
        'clientPhone': '+1 (555) 123-4567',
        'venueName': 'Grand Ballroom Hotel',
        'venueAddress': '123 Main Street, New York, NY 10001',
        'venueCapacity': '200 guests',
        'guestCount': '150 confirmed',
        'eventType': 'Wedding Reception',
        'duration': '6 hours',
        'description':
            'An elegant wedding celebration featuring a romantic garden ceremony followed by a sophisticated ballroom reception.',
      };
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _handleEditEvent,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEventData,
        child: Column(
          children: [
            _buildEventHeader(context),
            Container(
              color: theme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Timeline'),
                  Tab(text: 'Budget'),
                  Tab(text: 'Vendors'),
                  Tab(text: 'Photos'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(context),
                  _buildTimelineTab(context),
                  _buildBudgetTab(context),
                  _buildVendorsTab(context),
                  _buildPhotosTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  Widget _buildEventHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              _eventData['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
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
                  _eventData['name'],
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _eventData['date'],
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _eventData['status'],
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Description'),
          Text(_eventData['description'], style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Details'),
          _buildDetailRow(context, Icons.person, 'Client', _eventData['clientName']),
          _buildDetailRow(context, Icons.location_on, 'Venue', _eventData['venueName']),
          _buildDetailRow(context, Icons.people, 'Guests', _eventData['guestCount']),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _milestones.length,
      itemBuilder: (context, index) {
        final milestone = _milestones[index];
        return CheckboxListTile(
          title: Text(milestone['title']),
          subtitle: Text(milestone['dueDate']),
          value: milestone['completed'],
          onChanged: (bool? value) {
            setState(() {
              milestone['completed'] = value;
            });
          },
        );
      },
    );
  }

  Widget _buildBudgetTab(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: (_budgetData['expenses'] as List).length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Total Budget', style: theme.textTheme.titleMedium),
                  Text('\$${_budgetData['totalBudget']}', style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _budgetData['totalSpent'] / _budgetData['totalBudget'],
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text('Spent: \$${_budgetData['totalSpent']}', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          );
        }
        final expense = _budgetData['expenses'][index - 1];
        return ListTile(
          leading: CircleAvatar(child: Icon(expense['icon'])),
          title: Text(expense['category']),
          subtitle: Text(expense['description']),
          trailing: Text('\$${expense['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildVendorsTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vendors.length,
      itemBuilder: (context, index) {
        final vendor = _vendors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(child: Icon(vendor['icon'])),
            title: Text(vendor['name']),
            subtitle: Text(vendor['category']),
            trailing: IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () => _launchUrl('tel:${vendor['phone']}'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotosTab(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            photo['url'],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.image)),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> actions;
    switch (_currentTabIndex) {
      case 0: // Overview
        actions = [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleCallClient,
              icon: const Icon(Icons.phone, size: 20),
              label: const Text('Call Client'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _handleViewContract,
              icon: Icon(Icons.description, size: 20, color: theme.colorScheme.primary),
              label: Text('Contract', style: TextStyle(color: theme.colorScheme.primary)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),
        ];
        break;
      case 1: // Timeline
        actions = [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleAddMilestone,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Milestone'),
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
            ),
          ),
        ];
        break;
      case 2: // Budget
        actions = [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleExportBudget,
              icon: const Icon(Icons.download, size: 20),
              label: const Text('Export Budget'),
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
            ),
          ),
        ];
        break;
      case 3: // Vendors
        actions = [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleAddVendor,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Vendor'),
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
            ),
          ),
        ];
        break;
      case 4: // Photos
        actions = [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleSharePhotos,
              icon: const Icon(Icons.share, size: 20),
              label: const Text('Share Gallery'),
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
            ),
          ),
        ];
        break;
      default:
        actions = [];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(top: false, child: Row(children: actions)),
    );
  }

  Future<void> _refreshEventData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event data updated')));
    }
  }

  void _handleEditEvent() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit event functionality')));
  }

  void _handleAddExpense() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add expense functionality')));
  }

  void _handlePhotoAdded(XFile photo) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Photo added: ${photo.name}')));
  }

  void _handleCallClient() async {
    _launchUrl('tel:${_eventData['clientPhone']}');
  }

  void _handleViewContract() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('View contract functionality')));
  }

  void _handleAddMilestone() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add milestone functionality')));
  }

  void _handleExportBudget() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export budget functionality')));
  }

  void _handleAddVendor() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add vendor functionality')));
  }

  void _handleSharePhotos() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share photos functionality')));
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
      }
    }
  }
}