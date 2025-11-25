import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:http/http.dart' as http;
import 'profile_screen.dart';
// ignore: unused_import
import 'plan_picnic_screen.dart';
import 'chatbot_screen.dart';
import 'map_screen.dart';
import 'event_provider.dart';
import 'login_screen.dart';
import 'place.dart';
import 'venue_list_screen.dart'; // Import the new venue list screen

// Global key to access MyApp's state for theme changes from anywhere.
final GlobalKey<MyAppState> myAppKey = GlobalKey();

void main() {
  runApp(MyApp(key: myAppKey));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  // Public getter to allow other parts of the app to read the current theme mode.
  ThemeMode get currentThemeMode => _themeMode;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // High-contrast black and white theme for dark mode.
    // A very dark, near-black theme for a sleek look.
    final darkTheme = ThemeData( // A classic black and white theme
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.white, // White as the main accent color
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black, // Black text on white buttons
        surface: Color(0xFF2C2C2E), // Dark gray for cards, dialogs, and surfaces
        onSurface: Colors.white,
        secondary: Color(0xFF2C2C2E), // Dark gray for input fields
        onSecondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
    );

    // The "Picnic Pal" theme, now correctly configured as the app's light theme.
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFF042C20),
      primaryColor: const Color(0xFFD4A017),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFD4A017),
        onPrimary: Color(0xFF042C20), // Dark green text on gold buttons
        surface: Color(0xFF064C34), // A slightly lighter green for cards
        onSurface: Colors.white, // White text on cards/surfaces
        secondary: Color(0xFF064C34), // Inputs, profile cards
        onSecondary: Colors.white, // Text on main background
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF022015),
        elevation: 0,
      ),
    );

    // The MaterialApp should be the root. It will handle theme changes internally
    // without restarting the app. This fixes the splash screen issue.
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: const AnimatedSplashScreen(),
    );
  }
}

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String fullText = "Picnic Pal";
  String displayedText = "";
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );

    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_charIndex < fullText.length) {
        if (!mounted) return;
        setState(() {
          displayedText += fullText[_charIndex];
          _charIndex++;
        });
      } else {
        timer.cancel();
      }
    });

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Text(
            displayedText,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

   /// ----------AK THISis the  MAIN SCREEN WITH NAVIGATION ----------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const MapScreen(),
      const EventsPage(), // This will now be correctly indexed
      const ProfileScreen(),
    ];
  }

  // This function is no longer needed here as we handle it in the page list
  /* Removed unused method
  Widget _buildMapPage() { 
    // Check if the current platform is supported by the google_maps_flutter plugin.
    final isSupported = defaultTargetPlatform == TargetPlatform.android ||
                        defaultTargetPlatform == TargetPlatform.iOS;

    if (isSupported) {
      return const MapScreen();
    } else {
      return const UnsupportedPlatformWidget(featureName: "Map");
    }
  } 
  */

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // Use theme colors for consistency
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.fixed, // This ensures the background color is applied
        unselectedItemColor: Colors.white70, 
        // The currentIndex needs to be mapped back to the original icon index.
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

/// ---------- HOME SCREEN ----------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Removed onMapTapped as it's handled by bottom nav

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Place> _recommendedPlaces = []; // Holds only the venues for the slideshow
  bool _isLoading = true;
  String? _errorMessage;
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedVenues();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRecommendedVenues() async {
    // This is a mock API endpoint. Replace with your actual API.
    // For this example, I'm using a static JSON file host.
    final url = Uri.parse('https://api.npoint.io/4c7c82d5b508a9e3a740');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final allApiPlaces = data.map((json) {
          return Place(
            placeId: json['placeId'],
            name: json['name'],
            description: json['description'],
            photoUrl: json['photoUrl'],
            rating: (json['rating'] as num).toDouble(),
            totalRatings: json['totalRatings'],
            latitude: (json['latitude'] as num).toDouble(),
            longitude: (json['longitude'] as num).toDouble(),
          );
        }).toList();

        // Filter for the "Recommended" slideshow
        final recommendedPlaces = allApiPlaces.where((place) {
          final nameLower = place.name.toLowerCase();
          final descLower = place.description.toLowerCase();
          final isInAbuja = nameLower.contains('abuja') || descLower.contains('abuja');
          final isPartyVenue = nameLower.contains('picnic') || descLower.contains('picnic') || nameLower.contains('party') || descLower.contains('party');
          return isInAbuja && isPartyVenue;
        }).toList();
        if (mounted) {
          setState(() {
            _recommendedPlaces = recommendedPlaces;
            _isLoading = false;
            startSlideshow();
          });
        }
      } else {
        throw Exception('Failed to load venues: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not fetch venues. Please try again later.';
          _isLoading = false;
        });
      }
    }
  }

  void startSlideshow() {
    timer?.cancel();
    if (_recommendedPlaces.isEmpty) return;

    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) {
        timer?.cancel();
        return;
      }
      setState(() {
        currentIndex = (currentIndex + 1) % _recommendedPlaces.length;
      });
    });
  }

 void _showPlaceInfoDialog(Place place) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
        backgroundColor: theme.colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.primary),
        ),
        title: Text(place.name, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        content: Text(place.description, style: TextStyle(color: theme.colorScheme.onSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: theme.colorScheme.primary, fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
              foregroundColor: const Color(0xFF042C20),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PlanPicnicScreen(initialVenue: place)));
              Navigator.of(context).pop();
            },
            child: const Text('Plan Here'),
          ),
        ],
      );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'PicnicPal',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ready to plan your next event?',
                style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withAlpha(179))), 
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 100,
                width: 140, // Set a fixed width to show only one item
                child: PageView(
                  controller: PageController(viewportFraction: 1.0), // Each page takes the full viewport
                  children: [
                    _quickAction(Icons.celebration, 'Plan Event', () => _showPlanningOptions(context)),
                    _quickAction(Icons.apartment_outlined, 'Rent Apartments', () { // New Item
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Apartment rentals coming soon!"),
                        backgroundColor: Color(0xFFD4A017),
                      ));
                    }),
                    _quickAction(Icons.hotel_outlined, 'Book Hotel', () { // New Item
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Hotel booking coming soon!"),
                        backgroundColor: Color(0xFFD4A017),
                      ));
                    }),
                    _quickAction(Icons.card_giftcard, 'Send Gift', () {
                      // Placeholder for gift functionality
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Gift feature coming soon!"),
                        backgroundColor: Color(0xFFD4A017), // Keep gold for snackbar
                      ));
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text('Recommended Venues',
                style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10), 
            Expanded(child: _buildVenuesWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildVenuesWidget() {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179)))); 
    }

    if (_recommendedPlaces.isEmpty) {
      return Center(child: Text('No recommended venues found.', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179))));
    }

    return _buildSlideshow();
  }

  Widget _buildSlideshow() {
    return GestureDetector(
      onTap: () => _showPlaceInfoDialog(_recommendedPlaces[currentIndex]),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _recommendedPlaces[currentIndex].photoUrl != null
                ? Image.network(_recommendedPlaces[currentIndex].photoUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800], child: const Icon(Icons.image_not_supported, color: Colors.white54)))
                : Container(color: Colors.grey[800], child: const Icon(Icons.image_not_supported, color: Colors.white54)),
          ),
          _buildVenueCardOverlay(_recommendedPlaces[currentIndex]),
        ],
      ),
    );
  }

  Widget _buildVenueCardOverlay(Place place) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Text(
          place.name,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showPlanningOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.primary),
          ),
          title: Text(
            'How would you like to plan?',
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.smart_toy_outlined, color: theme.colorScheme.primary),
                title: Text('Plan with AI Assistant', style: TextStyle(color: theme.colorScheme.onSurface)), // Replaced withOpacity
                subtitle: Text('Chat with our AI to get started.', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179))),
                onTap: () {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
                },
              ),
              const Divider(color: Colors.transparent), // Replaced withOpacity
              ListTile(
                leading: Icon(Icons.edit_calendar_outlined, color: theme.colorScheme.primary),
                title: Text('Plan Manually', style: TextStyle(color: theme.colorScheme.onSurface)),
                subtitle: Text('Choose all the details yourself.', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                onTap: () {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VenueListScreen())); // Corrected path
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickAction(IconData icon, String text, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary,
            child: Icon(icon, color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}

/// A placeholder widget for features not supported on the current platform or for specific map functionality.
class UnsupportedPlatformWidget extends StatelessWidget {
  final String featureName;
  const UnsupportedPlatformWidget({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(featureName, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'The full interactive $featureName feature is not available on this platform.\n\nPlease try again on a supported device.',
            textAlign: TextAlign.center, 
            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179), fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}


/// ---------- EVENTS PAGE ----------
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  void initState() {
    super.initState();
    eventProvider.addListener(_onEventAdded);
  }

  @override
  void dispose() {
    eventProvider.removeListener(_onEventAdded);
    super.dispose();
  }

  void _onEventAdded() {
    setState(() {});
  }

  void _showDeleteConfirmation(BuildContext context, Event event) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
        ),
        title: Text('Delete Event?', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)), // Correct
        content: Text('Are you sure you want to delete the event "${event.title}"?', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(204))), // Replaced withOpacity
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179))),
          ),
          ElevatedButton(
            onPressed: () {
              eventProvider.deleteEvent(event);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event deleted successfully'), backgroundColor: Colors.redAccent),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = eventProvider.events;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text('My Saved Events', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: events.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey), // Grey is fine for a neutral placeholder
                  SizedBox(height: 20),
                  Text(
                    'No Saved Events',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Plan an event from the Home screen\nto see it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card( // The card itself remains for elevation and shape
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                  color: isDarkMode ? theme.colorScheme.surface : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 20),
                  clipBehavior: Clip.antiAlias, // Ensures content respects the border radius
                  child: Stack(
                    children: [
                      // Image with a gradient overlay for text readability. Changed to Image.asset.
                      Image.asset(
                        event.image,
                        height: 220,
                        width: double.maxFinite,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 220, color: Colors.grey[isDarkMode ? 800 : 300], child: const Icon(Icons.image_not_supported, color: Colors.white54)),
                      ),
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          ),
                        ),
                      ),
                      // Text content positioned at the bottom
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 2)])),
                            const SizedBox(height: 6),
                            Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.white70), const SizedBox(width: 6), Text(event.date, style: const TextStyle(color: Colors.white70))]),
                            const SizedBox(height: 4),
                            Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.white70), const SizedBox(width: 6), Text(event.location, style: const TextStyle(color: Colors.white70))]),
                          ],
                        ),
                      ),
                      // Delete button positioned at the top right
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => PlanPicnicScreen(editingEvent: event)),
                                );
                              },
                              style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.3)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                              onPressed: () => _showDeleteConfirmation(context, event),
                              style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.3)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
