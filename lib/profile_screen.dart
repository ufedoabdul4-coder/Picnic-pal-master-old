import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
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
  String _userName = "User";
  String _userEmail = "";
  String _joinDateString = "";
  String? _avatarUrl;
  bool _isUploading = false;
  bool _isServiceProvider = false;

  @override
  void initState() {
    super.initState();
    _initializeUserDisplay();
    _loadProfileImage();
    _loadUserData();
    _loadServiceProviderStatus();
    // Add listeners to update the UI when data changes
    eventProvider.addListener(_onDataChanged);
    savedVenueProvider.addListener(_onDataChanged);
  }

  void _initializeUserDisplay() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _userEmail = user.email ?? 'No Email';
      
      String fullName = "User";
      final metadata = user.userMetadata;
      if (metadata != null) {
        fullName = metadata['first_name'] ?? metadata['full_name'] ?? metadata['name'] ?? "User";
      }
      
      if (fullName != "User" && fullName.isNotEmpty) {
        _userName = fullName.split(' ').first;
      }

      final createdAt = DateTime.parse(user.createdAt);
      _joinDateString = "Member since ${DateFormat('MMMM yyyy').format(createdAt)}";
    }
  }

  @override
  void dispose() {
    eventProvider.removeListener(_onDataChanged);
    savedVenueProvider.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _loadProfileImage() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path_${user.id}');
    if (imagePath != null && mounted && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    String fullName = "User";
    String? avatarUrl;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('first_name, full_name, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      
      if (data != null) {
        fullName = data['first_name'] ?? data['full_name'] ?? "User";
        avatarUrl = data['avatar_url'];
      } else {
        // Fallback to user metadata if profile data is missing
        final metadata = user.userMetadata;
        if (metadata != null) {
          fullName = metadata['first_name'] ?? metadata['full_name'] ?? metadata['name'] ?? "User";
          avatarUrl = metadata['avatar_url'];
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }

    // Extract first name
    if (fullName != "User" && fullName.isNotEmpty) {
      fullName = fullName.split(' ').first;
    }

    if (mounted) {
      setState(() {
        _userName = fullName;
        _userEmail = user.email ?? 'No Email';
        _avatarUrl = avatarUrl;
      });
    }
  }

  Future<void> _loadServiceProviderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isProvider = prefs.getBool('is_service_provider') ?? false;

    if (!isProvider) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          final data = await Supabase.instance.client
              .from('profiles')
              .select('role')
              .eq('id', user.id)
              .maybeSingle();

          if (data != null && data['role'] != null && data['role'] != 'user') {
            isProvider = true;
            await prefs.setBool('is_service_provider', true);
          }
        } catch (e) {
          debugPrint('Error loading provider status: $e');
        }
      }
    }

    if (mounted) {
      setState(() {
        _isServiceProvider = isProvider;
      });
    }
  }

  Future<void> _removeServiceProviderStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'role': 'user'})
            .eq('id', user.id);
      } catch (e) {
        debugPrint('Failed to update Supabase role: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_service_provider', false);
    await prefs.setString('user_role', 'user');

    if (!mounted) return;
    final currentContext = context;
    setState(() {
      _isServiceProvider = false;
    });
    ScaffoldMessenger.of(currentContext).showSnackBar(
      const SnackBar(content: Text('You are no longer a service provider.')),
    );
  }

  Future<void> _confirmRemoveServiceProvider() async {
    final currentContext = context;
    final shouldRemove = await showDialog<bool>(
      context: currentContext,
      builder: (BuildContext dialogContext) {
        final dialogTheme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: dialogTheme.colorScheme.surface,
          title: Text('Stop Being a Provider?', style: TextStyle(color: dialogTheme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
          content: Text('This will remove your service provider status and return you to a regular user account.', style: TextStyle(color: dialogTheme.colorScheme.onSurface.withOpacity(0.8))),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: dialogTheme.colorScheme.onSurface.withOpacity(0.7))),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Yes, remove', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      if (!mounted) return;
      await _removeServiceProviderStatus();
    }
  }

  Future<void> _pickProfileImage() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      
      final prefs = await SharedPreferences.getInstance();
      final file = File(pickedFile.path);
      
      const bucket = 'images'; 

      try {
        // Optional: Delete the old image from Supabase storage to save space
        if (_avatarUrl != null && _avatarUrl!.contains(user.id)) {
          final oldFileName = _avatarUrl!.split('?').first.split('/').last;
          await Supabase.instance.client.storage
              .from(bucket)
              .remove(['${user.id}/$oldFileName']);
        }

        // 1. Upload to Supabase Storage
        final fileExt = pickedFile.path.split('.').last;
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '${user.id}/$fileName';

        await Supabase.instance.client.storage
            .from(bucket)
            .upload(filePath, file);

        // 2. Get Public URL
        final imageUrl = Supabase.instance.client.storage
            .from(bucket)
            .getPublicUrl(filePath);

        // 3. Update Database Profile
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'avatar_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        });

        // 4. Update Local Cache
        final imageKey = 'profile_image_path_${user.id}';
        final oldPath = prefs.getString(imageKey);
        if (oldPath != null && File(oldPath).existsSync()) await File(oldPath).delete();

        final directory = await getApplicationDocumentsDirectory();
        final localImage = await file.copy('${directory.path}/$fileName');
        await prefs.setString(imageKey, localImage.path);

        if (mounted) {
          setState(() {
            _profileImage = localImage;
            _avatarUrl = imageUrl;
          });
        }
      } catch (e) {
        debugPrint("Upload failed: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image. Please check your connection.")),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.secondary,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_avatarUrl != null 
                                ? NetworkImage(_avatarUrl!) as ImageProvider
                                : null),
                        child: (_profileImage == null && _avatarUrl == null && !_isUploading)
                            ? Icon(Icons.person, size: 60, color: theme.colorScheme.primary.withOpacity(0.5))
                            : null,
                      ),
                      if (_isUploading)
                        CircularProgressIndicator(color: theme.colorScheme.primary),
                    ],
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
    final currentThemeName = myAppKey.currentState?.currentThemeName ?? 'Quivvo';
    
    // The list of available theme names. This should match the keys in MyAppState's `themes` map.
    final List<String> themeNames = ['Quivvo', 'Dark', 'Light', 'Espresso'];

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
      if (_isServiceProvider) {"icon": Icons.cancel_presentation, "title": "Stop Being a Service Provider", "color": Colors.orange},
      {"icon": Icons.help, "title": "Help & Support"},
      {"icon": Icons.logout, "title": "Logout", "color": Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: menuItems.map((item) {
          final title = item["title"] as String;
          final isLogout = title == "Logout";
          final color = item.containsKey("color") ? item["color"] as Color : theme.colorScheme.primary;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.secondary.withAlpha(200)),
            ),
            child: ListTile( // AK: Added onTap navigation
              leading: Icon(item["icon"] as IconData, color: color),
              title: Text(title, style: TextStyle(color: theme.colorScheme.onSecondary)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSecondary.withAlpha(179)),
              onTap: () async {
                if (title == "My Events") {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsPage()));
                }
                if (title == "Edit Profile") {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()))
                      .then((value) {
                    // Reload data if the page was popped with an update signal
                    if (value == true) _loadUserData();
                  });
                }
                if (title == "Stop Being a Service Provider") {
                  _confirmRemoveServiceProvider();
                }
                if (isLogout) {
                  // Show a confirmation dialog before logging out
                  final currentContext = context;
                  final shouldLogout = await showDialog<bool>(
                    context: currentContext,
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
                  );

                  if (shouldLogout == true) {
                    // Terminate the Supabase session
                    await Supabase.instance.client.auth.signOut();
                    
                    // Clear local flags and user data from SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('is_service_provider');

                    if (!mounted) return;
                    Navigator.of(currentContext).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
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
