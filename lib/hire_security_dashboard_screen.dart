import 'package:flutter/material.dart';

class SecurityGuard {
  final String id;
  final String name;
  final String role;
  final double rating;
  final bool isAvailable;
  final String imageUrl;
  final int jobsCompleted;

  SecurityGuard({
    required this.id,
    required this.name,
    required this.role,
    required this.rating,
    required this.isAvailable,
    required this.imageUrl,
    required this.jobsCompleted,
  });
}

final List<SecurityGuard> mockGuards = [
  SecurityGuard(
    id: '1',
    name: 'John Doe',
    role: 'Event Security',
    rating: 4.8,
    isAvailable: true,
    imageUrl: 'assets/images/guard1.jpg',
    jobsCompleted: 120,
  ),
  SecurityGuard(
    id: '2',
    name: 'Jane Smith',
    role: 'Personal Bodyguard',
    rating: 4.9,
    isAvailable: false,
    imageUrl: 'assets/images/guard2.jpg',
    jobsCompleted: 85,
  ),
  SecurityGuard(
    id: '3',
    name: 'Mike Johnson',
    role: 'Venue Patrol',
    rating: 4.5,
    isAvailable: true,
    imageUrl: 'assets/images/guard3.jpg',
    jobsCompleted: 200,
  ),
  SecurityGuard(
    id: '4',
    name: 'Sarah Connor',
    role: 'VIP Protection',
    rating: 5.0,
    isAvailable: true,
    imageUrl: 'assets/images/guard4.jpg',
    jobsCompleted: 45,
  ),
];

class HireSecurityDashboardScreen extends StatefulWidget {
  const HireSecurityDashboardScreen({super.key});

  @override
  State<HireSecurityDashboardScreen> createState() => _HireSecurityDashboardScreenState();
}

class _HireSecurityDashboardScreenState extends State<HireSecurityDashboardScreen> {
  String _searchQuery = '';
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget bodyContent;
    String appBarTitle;

    switch (_selectedIndex) {
      case 0:
        appBarTitle = 'Hire Security';
        final filteredGuards = mockGuards.where((guard) {
          return guard.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 guard.role.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
        bodyContent = SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(theme),
              const SizedBox(height: 24),
              _buildStatsSection(theme),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Personnel',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('See All', style: TextStyle(color: theme.colorScheme.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildGuardsList(theme, filteredGuards),
            ],
          ),
        );
        break;
      case 1:
        appBarTitle = 'My Jobs';
        bodyContent = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_outline, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text('No active jobs', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 18)),
            ],
          ),
        );
        break;
      case 2:
        appBarTitle = 'Profile';
        bodyContent = SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(Icons.person, size: 50, color: theme.colorScheme.onPrimary),
              ),
              const SizedBox(height: 16),
              Text('Security Client', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Text('client@example.com', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 32),
              _buildProfileItem(theme, Icons.person_outline, 'Edit Profile'),
              _buildProfileItem(theme, Icons.payment, 'Payment Methods'),
              _buildProfileItem(theme, Icons.history, 'Hiring History'),
              _buildProfileItem(theme, Icons.settings_outlined, 'Settings'),
              _buildProfileItem(theme, Icons.help_outline, 'Help & Support'),
              const SizedBox(height: 20),
              _buildProfileItem(theme, Icons.logout, 'Logout', isDestructive: true),
            ],
          ),
        );
        break;
      default:
        appBarTitle = 'Hire Security';
        bodyContent = Container();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
        ],
      ),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      style: TextStyle(color: theme.colorScheme.onSecondary),
      decoration: InputDecoration(
        hintText: 'Search guards, roles...',
        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(150)),
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(theme, 'Total Guards', '${mockGuards.length}', Icons.group)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(theme, 'Available', '${mockGuards.where((g) => g.isAvailable).length}', Icons.check_circle_outline)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(theme, 'Active Jobs', '12', Icons.work_outline)),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 12),
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondary)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSecondary.withAlpha(180))),
        ],
      ),
    );
  }

  Widget _buildGuardsList(ThemeData theme, List<SecurityGuard> guards) {
    if (guards.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text('No guards found.', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)))));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: guards.length,
      itemBuilder: (context, index) {
        final guard = guards[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.secondary.withAlpha(50)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: theme.colorScheme.surface,
                  child: Image.asset(
                    guard.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 40, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(guard.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: guard.isAvailable ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(guard.isAvailable ? 'Available' : 'On Duty', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: guard.isAvailable ? Colors.green : Colors.red)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(guard.role, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSecondary.withAlpha(180))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${guard.rating}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondary)),
                        const SizedBox(width: 12),
                        Icon(Icons.work, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text('${guard.jobsCompleted} Jobs', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(ThemeData theme, IconData icon, String title, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
      onTap: () {
        if (title == 'Logout') {
           Navigator.of(context).pop();
        }
      },
    );
  }
}