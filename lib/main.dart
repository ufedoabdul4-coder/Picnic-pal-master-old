import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'profile_screen.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'plan_picnic_screen.dart';
import 'chatbot_screen.dart';
import 'map_screen.dart';
import 'event_provider.dart';
import 'login_screen.dart';
import 'place.dart';
import 'event_type_screen.dart'; // Import the new event type screen
import 'venue_list_screen.dart';
import 'rent_apartment_screen.dart';
import 'book_hotel_screen.dart';
import 'service_provider_selection_screen.dart';
import 'service_provider_intro_screen.dart';

// Global key to access MyApp's state for theme changes from anywhere.
final GlobalKey<MyAppState> myAppKey = GlobalKey();

void main() async {
  // This is required to ensure that Flutter's bindings are initialized
  // before any async operations are performed in main.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://zrxrtpcpvbowkzxcvdbq.supabase.co', // Replace with your actual Project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpyeHJ0cGNwdmJvd2t6eGN2ZGJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkyODUzOTksImV4cCI6MjA4NDg2MTM5OX0.WcjmbXhdVdZpWqs-iMmVRsuuOXC436NUOm02XvefT0E', // Replace with your actual Anon Key
  );

  // Initialize Google Maps Renderer to the latest version to avoid legacy warnings
  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
    mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  }

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('selected_theme') ?? 'Smart Pal';
  runApp(MyApp(key: myAppKey, initialTheme: savedTheme));
}

class MyApp extends StatefulWidget {
  final String initialTheme;
  const MyApp({super.key, this.initialTheme = 'Smart Pal'});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late String _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.initialTheme;
  }

  // Public getter for the current theme name
  String get currentThemeName => _currentTheme;

  Future<void> changeTheme(String themeName) async {
    setState(() {
      _currentTheme = themeName;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', themeName);
  }

  @override
  Widget build(BuildContext context) {
    // High-contrast black and white theme for dark mode.
    // A very dark, near-black theme for a sleek look.
    final darkTheme = ThemeData(
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

    // The new "Origin" theme
    final originTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFDECCB7), // Light beige background
      primaryColor: const Color(0xFF433633), // Main dark brown color
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF433633), // Main interactive color (buttons, icons)
        onPrimary: Colors.white, // White text on dark brown buttons for good contrast
        surface: Color(0xFFEFE5D8), // A lighter beige for cards
        onSurface: Color(0xFF433633), // Dark brown text on surfaces
        secondary: Color(0xFFEFE5D8), // Surfaces for input fields, etc.
        onSecondary: Color(0xFF433633), // Text on secondary surfaces
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFDECCB7), // Match the background
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF433633)), // Use the text color for icons
      ),
    );

    final Map<String, ThemeData> themes = {
      'Smart Pal': lightTheme,
      'Dark': darkTheme,
      'Light': originTheme, // Renamed "Origin" to "Light"
    };

    // The MaterialApp should be the root. It will handle theme changes internally
    // without restarting the app. This fixes the splash screen issue.
    return MaterialApp(
      // The theme is now dynamically selected from our map
      theme: themes[_currentTheme],
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

  String fullText = "Smart Pal";
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

    _requestAllPermissions();

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

    Timer(const Duration(seconds: 4), () async {
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;

      if (!mounted) return;
      
      if (session != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  Future<void> _requestAllPermissions() async {
    // Request all necessary permissions when the app starts
    await [
      Permission.location,
      Permission.camera,
      Permission.microphone,
      Permission.notification,
      Permission.photos,
      Permission.storage,
    ].request();
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
      const SmartPalMapScreen(),
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
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Use a theme-aware color for unselected items
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
  final TextEditingController _searchController = TextEditingController();
  List<Place> _allApiPlaces = []; // Holds all venues from the API
  List<Place> _recommendedPlaces = []; // Holds only the venues for the slideshow
  List<Place> _filteredPlaces = [];
  bool _isLoading = true;
  String? _errorMessage;
  int currentIndex = 0;
  Timer? timer;
  bool _isSearching = false;
  bool _isServiceProvider = false;

  @override
  void initState() {
    super.initState();
    _fetchVenues(); // Fetch the hardcoded venues
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkServiceProviderStatus();
  }

  @override
  void dispose() {
    // No longer need to remove the listener as we are using onChanged
    _searchController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredPlaces = _allApiPlaces.where((place) {
        final nameLower = place.name.toLowerCase();
        final descriptionLower = place.description.toLowerCase();
        return nameLower.contains(query) || descriptionLower.contains(query);
      }).toList();
    });
  }

  Future<void> _checkServiceProviderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isProvider = prefs.getBool('is_service_provider') ?? false;

    // If not found locally (e.g., new device), check Supabase
    if (!isProvider) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          final data = await Supabase.instance.client
              .from('profiles')
              .select('role')
              .eq('id', user.id)
              .maybeSingle();

          if (data != null && data['role'] != 'user') {
            isProvider = true;
            // Sync local storage for next time
            await prefs.setBool('is_service_provider', true);
            await prefs.setString('user_role', data['role']);
          }
        } catch (e) {
          debugPrint('Error checking provider status: $e');
        }
      }
    }

    setState(() {
      _isServiceProvider = isProvider;
    });
  }

  Future<void> _fetchVenues() async {
    // Using a hardcoded list of venues instead of fetching from an API.
    final List<Place> hardcodedPlaces = [
      Place(
        placeId: "1",
        name: "Millennium Park, Abuja",
        description: "A large, well-maintained park with lush green spaces, a river, and Italian-style gardens. Perfect for picnics and relaxation.",        
        photoUrl: "assets/images/millennium_park.jpg", // Using local asset
        rating: 4.5,
        totalRatings: 1200,
        latitude: 9.072264,
        longitude: 7.491302,
      ),
      Place(
        placeId: "2",
        name: "Jabi Lake Park, Abuja",
        description: "A beautiful lakeside park offering boat rides, a serene environment for picnics, and a great spot for evening walks.",        
        photoUrl: "assets/images/jabi_lake.jpg", // Using local asset
        rating: 4.3,
        totalRatings: 850,
        latitude: 9.065,
        longitude: 7.427,
      ),
      Place(
        placeId: "3",
        name: "Magicland Amusement Park",
        description: "An amusement park with various rides and attractions, suitable for family outings and fun-filled party events.",        
        photoUrl: "assets/images/magicland.jpg", // Using local asset
        rating: 4.1,
        totalRatings: 950,
        latitude: 9.055,
        longitude: 7.47,
      ),
      Place(
        placeId: "4",
        name: "Central Park Abuja",
        description: "A modern and vibrant park known for its well-manicured lawns, playground, and space for various recreational activities and picnics.",        
        photoUrl: "assets/images/central_park.jpg", // Using local asset
        rating: 4.6,
        totalRatings: 1100,
        latitude: 9.058,
        longitude: 7.493,
      ),
    ];
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Filter for the "Recommended" slideshow from the hardcoded list
    final recommended = hardcodedPlaces.where((place) {
      final descLower = place.description.toLowerCase();
      return descLower.contains('picnic') || descLower.contains('park');
    }).toList();
    try {
      // Fetch venues listed by service providers from Supabase.
      // This assumes you have a 'venues' table with relevant columns.
      final response = await Supabase.instance.client.from('venues').select();

    setState(() {
      _allApiPlaces = hardcodedPlaces;
      _recommendedPlaces = recommended;
      _isLoading = false;
      startSlideshow();
    });
      final List<Place> providerVenues = (response as List).map((data) {
        return Place(
          placeId: (data['id'] ?? '').toString(),
          name: data['name'] ?? 'Unnamed Venue',
          description: data['description'] ?? '',
          // Assuming 'image_url' is the column name in your Supabase table.
          // A fallback image is used if the URL is null.
          photoUrl: data['image_url'] ?? 'assets/images/central_park.jpg',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          totalRatings: 0, // This data isn't in the assumed table structure.
          latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      if (providerVenues.isEmpty && mounted) {
        setState(() {
          _errorMessage = 'No venues from service providers found.';
        });
      }

      // The slideshow will now feature venues from service providers.
      setState(() {
        _allApiPlaces = providerVenues;
        _recommendedPlaces = providerVenues;
        _isLoading = false;
        if (providerVenues.isNotEmpty) {
          startSlideshow();
        }
      });
    } catch (e) {
      debugPrint('Error fetching provider venues: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load venues. Please try again later.';
        });
      }
    }
  }

  void startSlideshow() {
    timer?.cancel();
    if (_recommendedPlaces.isEmpty) return;

    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_recommendedPlaces.isEmpty) {
        timer.cancel();
        return;
      }
      setState(() {
        currentIndex = (currentIndex + 1) % _recommendedPlaces.length;
      });
    });
  }

  Timer? get newMethod => timer;

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
          'Smart Pal',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) => _onSearchChanged(), // This will now trigger the search on every keystroke
                decoration: InputDecoration(
                  hintText: 'Search venues, events...',
                  hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withAlpha(153)),
                  filled: true,
                  fillColor: theme.colorScheme.secondary,
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSecondary.withAlpha(153)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Ready to plan your next event?',
                  style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withAlpha(179))), 
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24.0, // Horizontal space between items
                  runSpacing: 24.0, // Vertical space between rows
                  children: [
                    _quickAction(Icons.celebration, 'Plan Event', () => _showPlanningOptions(context)),
                    _quickAction(
                        Icons.apartment_outlined, 'Rent Apartments', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentApartmentScreen()))),
                    _quickAction(
                        Icons.hotel_outlined, 'Book Hotel', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookHotelScreen()))),
                    _quickAction(Icons.card_giftcard, 'Send Gift', () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Gift feature coming soon!"),
                        backgroundColor: Color(0xFFD4A017),
                      ));
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Become a Service Provider Section
              if (_isServiceProvider)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.manage_accounts, size: 32, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Service Provider Portal",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            ),
                            Text(
                              "Manage roles & services",
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceProviderSelectionScreen())),
                        style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                        child: const Text("Access"),
                      ),
                    ],
                  ),
                )
              else
                Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business_center, size: 32, color: theme.colorScheme.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Become a Service Provider",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                          ),
                          Text(
                            "Offer services & manage events",
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceProviderIntroScreen())),
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                      child: const Text("Join"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text('Recommended Venues',
                  style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10), 
              SizedBox(height: 250, child: _buildVenuesWidget()),
            ],
          ),
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

    if (_isSearching) {
      return _buildSearchResults();
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
                ? Image.asset(_recommendedPlaces[currentIndex].photoUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800], child: const Icon(Icons.image_not_supported, color: Colors.white54)))
                : Container(color: Colors.grey[800], child: const Icon(Icons.image_not_supported, color: Colors.white54)),
          ),
          _buildVenueCardOverlay(_recommendedPlaces[currentIndex]),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final theme = Theme.of(context);
    if (_filteredPlaces.isEmpty) {
      return Center(child: Text('No venues found for "${_searchController.text}"', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179))));
    }

    return ListView.builder(
      itemCount: _filteredPlaces.length,
      itemBuilder: (context, index) {
        final place = _filteredPlaces[index];
        return GestureDetector(
          onTap: () => _showPlaceInfoDialog(place),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.asset(
                  place.photoUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(height: 180, color: Colors.grey[800], child: const Icon(Icons.image_not_supported, color: Colors.white54)),
                ),
                _buildVenueCardOverlay(place),
              ],
            ),
          ),
        );
      },
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EventTypeScreen())); // Navigate to the new event type screen
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
    // Calculate a flexible width for the items to prevent overflow on smaller screens.
    // This allows for roughly two items per row on most phone sizes.
    final itemWidth = (MediaQuery.of(context).size.width / 2) - 48;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: itemWidth, // Use the calculated flexible width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(icon, color: theme.colorScheme.onPrimary),
            ),
            const SizedBox(height: 8),
            Text(text, style: TextStyle(color: theme.colorScheme.onSurface), textAlign: TextAlign.center),
          ],
        ),
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
 