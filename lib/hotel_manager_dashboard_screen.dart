import 'package:flutter/material.dart';
import 'add_hotel_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class HotelRoom {
  final String id;
  final String number;
  final String type;
  final String status; // Available, Occupied, Cleaning
  final double price;

  HotelRoom({
    required this.id,
    required this.number,
    required this.type,
    required this.status,
    required this.price,
  });
}

final List<HotelRoom> mockRooms = [
  HotelRoom(id: '1', number: '101', type: 'Deluxe Suite', status: 'Occupied', price: 250.0),
  HotelRoom(id: '2', number: '102', type: 'Standard Room', status: 'Available', price: 120.0),
  HotelRoom(id: '3', number: '103', type: 'Standard Room', status: 'Cleaning', price: 120.0),
  HotelRoom(id: '4', number: '201', type: 'Presidential Suite', status: 'Available', price: 500.0),
];

class HotelManagerDashboardScreen extends StatefulWidget {
  const HotelManagerDashboardScreen({super.key});

  @override
  State<HotelManagerDashboardScreen> createState() => _HotelManagerDashboardScreenState();
}

class _HotelManagerDashboardScreenState extends State<HotelManagerDashboardScreen> {
  int _selectedIndex = 0;
  String _userName = "Manager";
  String _userEmail = "manager@hotel.com";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    String? nameFromDb;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('full_name') // Assuming 'full_name' from common practice
          .eq('id', user.id)
          .single();
      nameFromDb = data['full_name'];
    } catch (e) {
      debugPrint("Could not fetch hotel manager's profile name: $e");
    }

    if (mounted) {
      setState(() {
        _userEmail = user.email ?? 'manager@hotel.com';
        if (nameFromDb != null && nameFromDb.isNotEmpty) {
          _userName = nameFromDb;
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget bodyContent;
    Widget appBarTitle;
    List<Widget>? appBarActions;
    bool centerTitle = true;

    switch (_selectedIndex) {
      case 0:
        centerTitle = false;
        appBarTitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back,', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            Text(_userName, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ],
        );
        appBarActions = [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'M', style: TextStyle(color: theme.colorScheme.onPrimary)),
            ),
          ),
        ];
        bodyContent = SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsSection(theme),
              const SizedBox(height: 24),
              _buildActionButtons(theme),
              const SizedBox(height: 24),
              Text(
                'Room Status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              _buildRoomsList(theme),
            ],
          ),
        );
        break;
      case 1:
        appBarTitle = Text('Manage Rooms', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold));
        bodyContent = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bed_outlined, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text('Room management coming soon', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 18)),
            ],
          ),
        );
        break;
      case 2:
        appBarTitle = Text('Profile', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold));
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
              Text(_userName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Text(_userEmail, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 32),
              _buildProfileItem(theme, Icons.settings_outlined, 'Settings'),
              _buildProfileItem(theme, Icons.help_outline, 'Help & Support'),
              const SizedBox(height: 20),
              _buildProfileItem(theme, Icons.logout, 'Logout', isDestructive: true),
            ],
          ),
        );
        break;
      default:
        appBarTitle = Text('Hotel Dashboard', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold));
        bodyContent = Container();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: appBarTitle,
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: centerTitle,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: appBarActions,
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bed_outlined), activeIcon: Icon(Icons.bed), label: 'Rooms'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    // Example statistics, you can replace with real data as needed
    int totalRooms = mockRooms.length;
    int availableRooms = mockRooms.where((room) => room.status == 'Available').length;
    int occupiedRooms = mockRooms.where((room) => room.status == 'Occupied').length;
    int cleaningRooms = mockRooms.where((room) => room.status == 'Cleaning').length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(theme, 'Total Rooms', totalRooms.toString(), Icons.meeting_room),
        _buildStatCard(theme, 'Available', availableRooms.toString(), Icons.check_circle_outline),
        _buildStatCard(theme, 'Occupied', occupiedRooms.toString(), Icons.hotel),
        _buildStatCard(theme, 'Cleaning', cleaningRooms.toString(), Icons.cleaning_services),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        color: theme.colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSecondary.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddHotelScreen()),
              );
            },
            icon: const Icon(Icons.add_business, size: 28),
            label: const Text('Add New Hotel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.bed, color: theme.colorScheme.onSecondary),
                label: Text('Add Rooms', style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add_a_photo, color: theme.colorScheme.onSecondary),
                label: Text('Upload Photos', style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildRoomsList(ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockRooms.length,
      itemBuilder: (context, index) {
        final room = mockRooms[index];
        return Card(
          color: theme.colorScheme.secondary,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(room.number, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
            title: Text(room.type, style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
            subtitle: Text(room.status, style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
            trailing: Text('\$${room.price}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
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
          showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              final dialogTheme = Theme.of(dialogContext);
              return AlertDialog(
                backgroundColor: dialogTheme.colorScheme.surface,
                title: Text('Logout?', style: TextStyle(color: dialogTheme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                content: Text('Are you sure you want to logout?', style: TextStyle(color: dialogTheme.colorScheme.onSurface.withOpacity(0.8))),
                actions: <Widget>[
                  TextButton(
                    child: Text('No', style: TextStyle(color: dialogTheme.colorScheme.onSurface.withOpacity(0.7))),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text('Yes', style: TextStyle(color: Colors.white)),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ],
              );
            },
          ).then((shouldLogout) async {
            if (shouldLogout == true && context.mounted) {
              await Supabase.instance.client.auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            }
          });
        }
      },
    );
  }
}