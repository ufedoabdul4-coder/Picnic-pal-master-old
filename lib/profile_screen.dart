import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'main.dart'; // Import main to access the global key
import 'event_provider.dart'; // To get event data
import 'saved_venue_provider.dart'; // To get saved venue data
import 'login_screen.dart'; // Import the login screen for logout navigation
import 'settings_screen.dart'; // Import the new settings screen
import 'edit_profile_screen.dart'; // Import the new edit profile screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String _userName = "Loading...";
  String _userEmail = "Loading...";
  String _joinDateString = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUserData();
    _loadJoinDate();
    // Add listeners to update the UI when data changes
    eventProvider.addListener(_onDataChanged);
    savedVenueProvider.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    eventProvider.removeListener(_onDataChanged);
    savedVenueProvider.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && mounted) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Jamal-din';
        _userEmail = prefs.getString('user_email') ?? 'samuel@example.com';
      });
    }
  }

  Future<void> _loadJoinDate() async {
    final prefs = await SharedPreferences.getInstance();
    String? joinDate = prefs.getString('join_date');

    if (joinDate == null) {
      // If it's the first time, set the date and save it.
      final now = DateTime.now();
      joinDate = DateFormat('MMMM yyyy').format(now); // e.g., "January 2024"
      await prefs.setString('join_date', joinDate);
    }

    if (mounted) {
      setState(() => _joinDateString = "Member since $joinDate");
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', pickedFile.path);
      if (mounted) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    }
  }

  // A single method to rebuild the state when providers notify of changes
  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildProfileSection(context),
              _buildStatsSection(context),
              _buildThemeSelector(context), // Replaced toggle with a selector menu
              _buildMenuSection(context),
              _buildPremiumSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profile',
            style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
            icon: Icon(Icons.settings, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.primary, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(77),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!) as ImageProvider
                        : const AssetImage("assets/images/profile.jpg"),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: theme.colorScheme.primary, shape: BoxShape.circle),
                    child: Icon(Icons.edit, color: theme.colorScheme.onPrimary, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
           _userName,
            style: TextStyle( // This will now adapt via theme
                color: theme.colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            _userEmail,
            style: TextStyle(color: theme.colorScheme.primary, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            _joinDateString,
            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.secondary.withAlpha(200)),
        ),
        child: Builder(builder: (context) {
          
          final eventsPlanned = eventProvider.events.length;
          final venuesVisited = eventProvider.events.map((e) => e.location).toSet().length;
          final savedVenues = savedVenueProvider.savedVenueNames.length;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, eventsPlanned.toString(), "Events Planned"),
              _buildDivider(context),
              _buildStatItem(context, venuesVisited.toString(), "Venues Visited"),
              _buildDivider(context),
              _buildStatItem(context, savedVenues.toString(), "Saved Venues"),
            ],
          );
        }),
      );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final theme = Theme.of(context);
    // Access the current theme name from MyAppState via the global key
    final currentThemeName = myAppKey.currentState?.currentThemeName ?? 'Picnic Pal';
    
    // The list of available theme names. This should match the keys in MyAppState's `themes` map.
    final List<String> themeNames = ['Picnic Pal', 'Dark', 'Light'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        onSelected: (String newThemeName) {
          // Call the changeTheme method with the selected theme name (String)
          myAppKey.currentState?.changeTheme(newThemeName);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          for (final themeName in themeNames)
            PopupMenuItem<String>(
              value: themeName,
              child: Row(
                children: [
                  if (currentThemeName == themeName)
                    Icon(Icons.check, color: theme.colorScheme.primary)
                  else
                    const SizedBox(width: 24), // Keep alignment
                  const SizedBox(width: 8),
                  Text(themeName),
                ],
              ),
            ),
        ],
        child: ListTile(
          leading: Icon(Icons.brightness_6_outlined, color: theme.colorScheme.primary),
          title: Text('Theme', style: TextStyle(color: theme.colorScheme.onSecondary)),
          // Display the current theme name
          trailing: Text(currentThemeName, style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String number, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(number,
            style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179), fontSize: 12),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 1,
      height: 40,
      color: theme.colorScheme.secondary.withAlpha(200),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final theme = Theme.of(context);
    final menuItems = [
      {"icon": Icons.edit, "title": "Edit Profile"},
      {"icon": Icons.calendar_today, "title": "My Events"},
      {"icon": Icons.favorite, "title": "Saved Venues"},
      {"icon": Icons.help, "title": "Help & Support"},
      {"icon": Icons.logout, "title": "Logout", "color": Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: menuItems.map((item) {
          final isLogout = item["title"] == "Logout";
          final color = isLogout ? item["color"] as Color : theme.colorScheme.primary;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.secondary.withAlpha(200)),
            ),
            child: ListTile( // AK: Added onTap navigation
              leading: Icon(item["icon"] as IconData, color: color),
              title: Text(item["title"] as String, style: TextStyle(color: theme.colorScheme.onSecondary)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSecondary.withAlpha(179)),
              onTap: () {
                if (item["title"] == "My Events") {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsPage()));
                }
                if (item["title"] == "Edit Profile") {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()))
         
                      .then((value) {
                    // Reload data if the page was popped with an update signal
                    if (value == true) _loadUserData();
                  });
                }
                if (isLogout) {
                  // Show a confirmation dialog before logging out
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
                  ).then((shouldLogout) {
                    if (shouldLogout == true) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPremiumSection(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary, width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Upgrade to Premium",
              style: TextStyle(
                  color: Color(0xFFD4A017), // Keep gold for emphasis
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Get unlimited events, priority venue bookings, and exclusive features",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(179), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Upgrade Now",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
