import 'package:flutter/material.dart';

class EventRequirement {
  final String name;
  final IconData icon;

  EventRequirement({required this.name, required this.icon});
}

class EventType {
  final String name;
  final String imageUrl;
  final List<EventRequirement> requirements;

  EventType({
    required this.name,
    required this.imageUrl,
    required this.requirements,
  });
}

class Venue {
  final String name;
  final String imageUrl;
  final String status;
  final List<EventType> availableEvents;

  Venue({
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.availableEvents,
  });
}

// --- Mock Data for Demonstration ---

// Default event types for venues that don't have specific ones
final List<EventType> _defaultEvents = [
  EventType(
    name: 'Birthday',
    imageUrl: 'assets/images/event_birthday.jpg',
    requirements: [
      EventRequirement(name: 'Decorations', icon: Icons.celebration_outlined),
      EventRequirement(name: 'Cake & Catering', icon: Icons.cake_outlined),
    ],
  ),
  EventType(
    name: 'Get-together',
    imageUrl: 'assets/images/event_picnic.jpg',
    requirements: [
      EventRequirement(name: 'Catering Services', icon: Icons.fastfood_outlined),
      EventRequirement(name: 'Music & Sound', icon: Icons.speaker_outlined),
    ],
  ),
];

final List<Venue> mockVenues = [
  Venue(
    name: 'Millennium Park',
    imageUrl: 'assets/images/millennium_park.jpg', // Changed to local asset
    status: 'Open for Events',
    availableEvents: [
      EventType(
        name: 'Picnic',
        imageUrl: 'assets/images/event_picnic.jpg', // Changed to local asset
        requirements: [
          EventRequirement(name: 'Picnic Mats & Baskets', icon: Icons.shopping_basket_outlined),
          EventRequirement(name: 'Catering Services (Optional)', icon: Icons.fastfood_outlined),
          EventRequirement(name: 'Park Permit (for large groups)', icon: Icons.description_outlined),
          EventRequirement(name: 'Waste Disposal Plan', icon: Icons.recycling_outlined),
        ],
      ),
      EventType(
        name: 'Birthday',
        imageUrl: 'assets/images/event_birthday.jpg', // Changed to local asset
        requirements: [
          EventRequirement(name: 'Decorations (Balloons, Banners)', icon: Icons.celebration_outlined),
          EventRequirement(name: 'Sound System', icon: Icons.speaker_outlined),
          EventRequirement(name: 'Cake & Catering', icon: Icons.cake_outlined),
          EventRequirement(name: 'Games & Activities', icon: Icons.sports_esports_outlined),
        ],
      ),
    ],
  ),
  Venue(
    name: 'Jabi Lake',
    imageUrl: 'assets/images/jabi_lake.jpg', // Changed to local asset
    status: 'Booking Soon',
    availableEvents: [
      EventType(
        name: 'Weddings',
        imageUrl: 'assets/images/event_weddings.jpg', // Corrected typo: wedding -> weddings
        requirements: [
          EventRequirement(name: 'Lakeside Altar Setup', icon: Icons.church_outlined),
          EventRequirement(name: 'Guest Seating Arrangement', icon: Icons.chair_outlined),
          EventRequirement(name: 'Professional Photography', icon: Icons.camera_alt_outlined),
          EventRequirement(name: 'Gourmet Catering', icon: Icons.restaurant_menu_outlined),
        ],
      ),
      EventType(
        name: 'Corporate',
        imageUrl: 'assets/images/event_corporate.jpg', // Changed to local asset
        requirements: [
          EventRequirement(name: 'Projector & Screen', icon: Icons.desktop_windows_outlined),
          EventRequirement(name: 'Podium & Microphone', icon: Icons.mic_outlined),
          EventRequirement(name: 'Corporate Branding', icon: Icons.flag_outlined),
          EventRequirement(name: 'Lunch & Coffee Breaks', icon: Icons.coffee_outlined),
        ],
      ),
    ],
  ),
  Venue(
    name: 'BluCabana',
    imageUrl: 'assets/images/blucabana.jpg', // Changed to local asset
    status: 'Open for Events',
    availableEvents: [
       EventType(
        name: 'Concerts',
        imageUrl: 'assets/images/event_concert.jpg', // Changed to local asset
        requirements: [
          EventRequirement(name: 'Stage & Lighting', icon: Icons.light_mode_outlined),
          EventRequirement(name: 'Professional Sound System', icon: Icons.speaker_group_outlined),
          EventRequirement(name: 'Security & Crowd Control', icon: Icons.security_outlined),
          EventRequirement(name: 'Ticketing & Entry Management', icon: Icons.confirmation_number_outlined),
        ],
      ),
    ],
  ),
  // --- Venues from plan_picnic_screen.dart ---
  Venue(
    name: "Mobile Party Bus",
    imageUrl: "assets/images/mobile_party_bus.jpg", // Changed to local asset
    status: "Available",
    availableEvents: _defaultEvents,
  ),
  Venue(
    name: "Almat Farms",
    imageUrl: "assets/images/almat_farms.jpg", // Changed to local asset
    status: "Open for Events",
    availableEvents: _defaultEvents,
  ),
  Venue(
    name: "The Vue",
    imageUrl: "assets/images/the_vue.jpg", // Changed to local asset
    status: "Open for Events",
    availableEvents: _defaultEvents,
  ),
  Venue(
    name: "Crush Cafe",
    imageUrl: "assets/images/crush_cafe.jpg", // Changed to local asset
    status: "Open for Events",
    availableEvents: _defaultEvents,
  ),
  Venue(
    name: "Trukadero by CityBowl",
    imageUrl: "assets/images/trukadero.jpg", // Changed to local asset
    status: "Open for Events",
    availableEvents: _defaultEvents,
  ),
  Venue(
    name: "BMT Gardens",
    imageUrl: "assets/images/bmt_gardens.jpg", // Changed to local asset
    status: "Open for Events",
    availableEvents: _defaultEvents,
  ),
  Venue(
    name: "Magicland Park",
    imageUrl: "assets/images/magicland_park.jpg", // Changed to local asset
    status: "Open for Events",
    availableEvents: _defaultEvents,
  ),
  Venue(
    name: "Gurara Falls",
    imageUrl: "assets/images/gurara_falls.jpg", // Changed to local asset
    status: "Open for Events",
    availableEvents: _defaultEvents,
  ),
];