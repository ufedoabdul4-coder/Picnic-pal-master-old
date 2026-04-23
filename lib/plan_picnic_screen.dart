import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'event_provider.dart';
import 'venue_model.dart' as new_venue_model;
import 'place.dart';

final Map<String, List<String>> partyCategories = {
  "Celebrations": [
    "Birthday Party (Adult)", "Birthday Party (Kids)", "Anniversary",
    "Graduation Party", "Engagement Party", "Baby Shower", "Gender Reveal",
    "Retirement Party",
  ],
  "Social Gatherings": [
    "Family Reunion", "Friends Get-together", "Team Building Event",
    "Club/Group Meetup", "Alumni Meet", "Potluck", "BBQ/Grill Out",
    "Bonfire Night",
  ],
  "Romantic Occasions": [
    "Romantic Date", "Proposal", "First Date", "Valentine's Day Picnic",
  ],
  "Themed Parties": [
    "Watch Party", "Bohemian (Boho) Picnic", "Vintage Theme",
    "Tropical/Luau Party", "Movie Night Outdoors", "Costume Party", "Color-themed Party",
  ],
  "Relaxation & Wellness": [
    "Private Relaxation", "Yoga & Meditation Session", "Book Club Meeting",
    "Art & Sip (Painting)", "Mindful Picnic", "Solo Relaxation",
  ],
  "Holidays & Seasonal": [
    "Easter Picnic", "Independence Day BBQ", "Christmas Picnic",
    "New Year's Day Brunch", "Halloween Themed",
  ],
  "Food & Drink Focused": [
    "Wine & Cheese Tasting", "Brunch Picnic", "Dessert Party",
    "Craft Beer Tasting", "Gourmet Food Experience",
  ],
};

class PlanPicnicScreen extends StatefulWidget {
  final String? initialPartyType;
  final int? initialGuests;
  final DateTime? initialDate;
  final Place? initialVenue;
  final Event? editingEvent; // Add this to handle an event being edited

  const PlanPicnicScreen(
      {super.key,
      this.initialPartyType,
      this.initialGuests,
      this.initialDate,
      this.initialVenue,
      this.editingEvent});

  @override
  State<PlanPicnicScreen> createState() => _PlanPicnicScreenState();
}

class _PlanPicnicScreenState extends State<PlanPicnicScreen> {
  // --- State Variables ---
  new_venue_model.Venue? selectedVenue;
  int guests = 1;
  String? selectedPartyType;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String clothingSuggestion = "";

  // State for venue-specific add-ons
  final Map<String, int> _selectedSnacks = {};
  final Map<String, int> _selectedDrinks = {};
  final Map<String, int> _selectedRentals = {};

  // Simulated data for venue-specific options
  final Map<String, Map<String, List<String>>> _venueAddons = {
    "Millennium Park": {
      "snacks": ["Meat Pie", "Doughnut", "Samosa", "Popcorn", "Small Chops Platter"],
      "drinks": ["Water", "Coca-Cola", "Fanta", "Sprite", "Fresh Juice"],
      "rentals": ["Picnic Mat", "Canopy"],
    },
    "Jabi Lake": {
      "snacks": ["Grilled Fish", "Suya", "French Fries", "Prawns"],
      "drinks": ["Water", "Soft Drink", "Chapman", "Beer"],
      "rentals": ["Boat Ride (Ticket)", "Jet Ski (15 mins)"],
    },
    "BMT Gardens": {
      "snacks": ["Shawarma", "Burger & Fries", "Ice Cream"],
      "drinks": ["Water", "Milkshake", "Smoothie"],
    },
    "Mobile Party Bus": {
      "drinks": ["Soft Drinks Package", "Cocktail Bar Access"],
      "rentals": ["Onboard DJ", "Karaoke Machine", "Custom LED Lighting"],
    }
  };

  // Mock data for interior/exterior images. In a real app, this would come from your backend.
  final Map<String, Map<String, List<String>>> _venueGalleries = {
    "Millennium Park": {
      "exterior": ["assets/images/millennium_park.jpg", "assets/images/event_picnic.jpg"],
      "interior": [], // No interior for a park
    },
    "Jabi Lake": {
      "exterior": ["assets/images/jabi_lake.jpg", "assets/images/event_weddings.jpg"],
      "interior": ["assets/images/blucabana.jpg"], // Example interior
    },
    "BMT Gardens": {
      "exterior": ["assets/images/bmt_gardens.jpg"],
      "interior": [],
    }
    // Add other venues here...
  };

  // Mapping party types to suitable venue types for smart filtering
  final Map<String, List<String>> _partyVenueSuitability = {
    'romantic': ['Lakeside', 'Garden', 'Reservoir', 'Resort', 'Lounge'],
    'date': ['Lakeside', 'Garden', 'Reservoir', 'Resort', 'Lounge', 'Cafe'],
    'proposal': ['Lakeside', 'Garden', 'Resort'],
    'anniversary': ['Lakeside', 'Garden', 'Resort', 'Lounge'],
    'kids': ['Amusement Park', 'Park', 'Activity Center'],
    'birthday': ['Amusement Park', 'Park', 'Mobile', 'Lounge', 'Activity Center'],
    'team building': ['Park', 'Nature Reserve', 'Amusement Park', 'Resort', 'Activity Center'],
    'wellness': ['Park', 'Nature Reserve', 'Garden', 'Resort'],
    'yoga': ['Park', 'Nature Reserve', 'Garden', 'Resort'],
    'friends': ['Park', 'Lakeside', 'Lounge', 'Cafe', 'Activity Center'],
    'watch': ['Mobile', 'Park', 'Lounge'],
    'mobile': ['Mobile'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialPartyType != null) {
      selectedPartyType = widget.initialPartyType;
    }
    if (widget.initialGuests != null) {
      guests = widget.initialGuests!;
    }
    if (widget.initialDate != null) {
      selectedDate = widget.initialDate;
    }
    if (widget.initialVenue != null) {
      // Find the matching venue from the internal list
      final venueName = widget.initialVenue!.name.split(',').first;
      try {
        selectedVenue = new_venue_model.mockVenues.firstWhere(
          (v) => v.name.toLowerCase() == venueName.toLowerCase(),
        );
      } catch (e) { /* Venue not found in the list, do nothing */ }
    }
    // If we are editing an event, pre-fill the form
    if (widget.editingEvent != null) {
      final event = widget.editingEvent!;
      selectedPartyType = event.title;
      selectedDate = DateFormat.yMMMd().parse(event.date);
      // Find the venue from the list to pre-select it
      try {
        selectedVenue = new_venue_model.mockVenues.firstWhere(
          (v) => v.name.toLowerCase() == event.location.toLowerCase(),
        );
      } catch (e) {
        // If venue not in our hardcoded list, we can't pre-select it.
        // In a real app, venue data would be more robust.
      }
      // Note: Guests and Time are not stored in the Event model, so they can't be pre-filled.
      // This could be an area for future improvement.
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void generateClothingSuggestion() {
    // A more dynamic suggestion generator
    final romantic = ["romantic", "valentine", "proposal", "anniversary", "date"];
    final formal = ["engagement", "graduation", "retirement"];
    final casual = ["hangout", "friends", "family", "bbq", "potluck"];
    final themed = ["boho", "vintage", "tropical", "costume", "halloween"];
    final active = ["yoga", "team building"];

    final typeLower = selectedPartyType?.toLowerCase() ?? '';

    if (romantic.any((e) => typeLower.contains(e))) {
      clothingSuggestion = "Smart casual or a chic dress. Think elegant! 💕";
    } else if (formal.any((e) => typeLower.contains(e))) {
      clothingSuggestion = "Dress to impress! A step above casual. 👔";
    } else if (casual.any((e) => typeLower.contains(e))) {
      clothingSuggestion = "Relaxed and comfy. T-shirts, shorts, or jeans. 👕";
    } else if (themed.any((e) => typeLower.contains(e))) {
      clothingSuggestion = "Match the theme! Get creative and have fun. 🎭";
    } else if (active.any((e) => typeLower.contains(e))) {
      clothingSuggestion = "Activewear or something you can move in freely. 🧘";
    } else if (typeLower.contains("birthday")) {
      clothingSuggestion = "Bright, fun casuals with comfy shoes. 🎉";
    } else {
      clothingSuggestion = "Comfortable outdoor clothing is always a safe bet. 🧢";
    }
  }

  void showSummary() {
    if (selectedVenue == null || selectedPartyType == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill in all details to plan your event!"),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    generateClothingSuggestion();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.primary),
        ),
        title: Text(
          "Event Plan Summary",
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 16, height: 1.5),
              children: [
                TextSpan(text: "📍 Venue: ${selectedVenue!.name}\n"),
                ..._buildSummaryAddons(),
                TextSpan(text: "👥 Guests: $guests\n"),
                TextSpan(text: "🎉 Type: $selectedPartyType\n"),
                TextSpan(text: "📅 Date: ${DateFormat.yMMMd().format(selectedDate!)}\n"),
                TextSpan(text: "⏰ Time: ${selectedTime!.format(context)}\n"),
                TextSpan(text: "👗 Outfit: $clothingSuggestion"),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Close",
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 16),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text(widget.editingEvent != null ? "Update Event" : "Save Event"),
            onPressed: () {
              if (widget.editingEvent != null) {
                // Update existing event
                final updatedEvent = Event(
                  id: widget.editingEvent!.id, // Keep the original ID
                  title: selectedPartyType!,
                  date: DateFormat.yMMMd().format(selectedDate!),
                  location: selectedVenue!.name,
                  image: selectedVenue!.imageUrl,
                );
                eventProvider.updateEvent(updatedEvent);
              } else {
                // Add new event
                final newEvent = Event(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: selectedPartyType!,
                  date: DateFormat.yMMMd().format(selectedDate!),
                  location: selectedVenue!.name,
                  image: selectedVenue!.imageUrl,
                );
                eventProvider.addEvent(newEvent);
              }

              Navigator.pop(ctx); // Close the summary
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(widget.editingEvent != null ? "Event updated successfully!" : "Event saved! Check the 'Events' tab."),
                  backgroundColor: Colors.green,));
            },
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildSummaryAddons() {
    final List<TextSpan> addons = [];
    final allAddons = {..._selectedSnacks, ..._selectedDrinks, ..._selectedRentals};

    if (allAddons.isNotEmpty) {
      addons.add(const TextSpan(text: "🛒 Add-ons:\n", style: TextStyle(fontWeight: FontWeight.bold)));
      allAddons.forEach((item, count) {
        if (count > 0) {
          addons.add(TextSpan(text: "  • $item (x$count)\n"));
        }
      });
    }
    return addons;
  }

  void _showImageGallery(BuildContext context, String venueName, String galleryType) {
    final theme = Theme.of(context);
    final galleries = _venueGalleries[venueName];
    final images = galleries?[galleryType] ?? [];

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No $galleryType images available for this venue.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$venueName - ${galleryType.replaceFirst(galleryType[0], galleryType[0].toUpperCase())} Views',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2, color: Colors.black)]),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: theme.colorScheme.surface,
                          child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Type of Party", icon: Icons.celebration_outlined),
              _buildPartyTypeSelector(context),
              const SizedBox(height: 24),

              _buildSectionTitle("Select Venue", icon: Icons.location_on_outlined),
              _buildVenueSelector(),
              const SizedBox(height: 24),

              // Conditionally display image gallery viewers
              if (selectedVenue != null)
                _buildImageViewerButtons(context),

              // Conditionally display add-ons
              if (selectedVenue != null && _venueAddons.containsKey(selectedVenue!.name))
                _buildAddonsSection(),

              _buildSectionTitle("When is it?", icon: Icons.calendar_today_outlined),
              _buildDateTimePickers(),
              const SizedBox(height: 24),

              _buildSectionTitle("Number of Guests", icon: Icons.people_outline),
              _buildGuestCounter(),
              const SizedBox(height: 24),

              _buildPlanButton(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      title: Text("Plan Your Event",
          style: TextStyle(
              color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
      centerTitle: true,
      iconTheme: IconThemeData(color: theme.colorScheme.primary),
    );
  }

  Widget _buildSectionTitle(String title, {required IconData icon}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
              color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildVenueSelector() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () async {
          final result = await showModalBottomSheet<new_venue_model.Venue?>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => _VenueSelectionSheet(
              venues: new_venue_model.mockVenues,
              partyVenueSuitability: _partyVenueSuitability,
              selectedPartyType: selectedPartyType,
            ),
          );
          if (result != null) {
            setState(() {
              selectedVenue = result;
              // Reset addons when venue changes
              _selectedSnacks.clear();
              _selectedDrinks.clear();
              _selectedRentals.clear();
            });
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.secondary.withAlpha(200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedVenue?.name ?? "Choose a venue",
                style: TextStyle(
                    color: selectedVenue != null ? theme.colorScheme.onSecondary : theme.colorScheme.onSecondary.withOpacity(0.7),
                    fontSize: 16),
              ),
              Icon(Icons.arrow_forward_ios, color: theme.colorScheme.primary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageViewerButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Venue Gallery", icon: Icons.photo_library_outlined),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildPickerTile(
                  label: 'View Interior',
                  icon: Icons.house_siding_outlined,
                  onTap: () => _showImageGallery(context, selectedVenue!.name, 'interior'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPickerTile(
                  label: 'View Exterior',
                  icon: Icons.wb_sunny_outlined,
                  onTap: () => _showImageGallery(context, selectedVenue!.name, 'exterior'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAddonsSection() {
    final addons = _venueAddons[selectedVenue!.name]!;
    final snacks = addons['snacks'] ?? [];
    final drinks = addons['drinks'] ?? [];
    final rentals = addons['rentals'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Venue Add-ons", icon: Icons.add_shopping_cart_outlined),
        const SizedBox(height: 8),
        if (snacks.isNotEmpty) ...[
          _buildAddonSubTitle("Snacks"),
          ...snacks.map((item) => _buildAddonItem(item, _selectedSnacks)),
        ],
        if (drinks.isNotEmpty) ...[
          _buildAddonSubTitle("Drinks"),
          ...drinks.map((item) => _buildAddonItem(item, _selectedDrinks)),
        ],
        if (rentals.isNotEmpty) ...[
          _buildAddonSubTitle("Rentals"),
          ...rentals.map((item) => _buildAddonItem(item, _selectedRentals)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAddonSubTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0, left: 4.0),
      child: Text(title, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildAddonItem(String itemName, Map<String, int> selectionMap) {
    int count = selectionMap[itemName] ?? 0;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(itemName, style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 16)),
          Row(
            children: [
              _buildCounterButton(Icons.remove, () {
                if (count > 0) {
                  setState(() => selectionMap[itemName] = count - 1);
                }
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("$count", style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildCounterButton(Icons.add, () {
                setState(() => selectionMap[itemName] = count + 1);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildPickerTile(
              label: selectedDate == null
                  ? 'Select Date'
                  : DateFormat.yMMMd().format(selectedDate!),
              icon: Icons.calendar_month,
              onTap: _pickDate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPickerTile(
              label: selectedTime == null
                  ? 'Select Time'
                  : selectedTime!.format(context),
              icon: Icons.access_time,
              onTap: _pickTime,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTile({required String label, required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.secondary.withAlpha(200)),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) setState(() => selectedTime = time);
  }

  Widget _buildGuestCounter() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          _buildCounterButton(Icons.remove, () {
            if (guests > 1) setState(() => guests--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text("$guests",
                style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
          _buildCounterButton(Icons.add, () => setState(() => guests++)),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.colorScheme.onPrimary, size: 20),
      ),
    );
  }

  Widget _buildPartyTypeSelector(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () async {
          final result = await showModalBottomSheet<String?>(context: context,
            backgroundColor: theme.scaffoldBackgroundColor,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)),),
            builder: (ctx) => _PartySelectionSheet(partyCategories: partyCategories),);
          if (result != null) {
            setState(() {
              selectedPartyType = result;
              // Reset venue selection to encourage picking a suitable one
              selectedVenue = null; // Reset venue selection
            });
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.secondary.withAlpha(200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedPartyType ?? "Choose a party type",
                style: TextStyle(
                    color: selectedPartyType != null ? theme.colorScheme.onSecondary : theme.colorScheme.onSecondary.withOpacity(0.7),
                    fontSize: 16),
              ),
              Icon(Icons.arrow_forward_ios, color: theme.colorScheme.primary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanButton() {
    final theme = Theme.of(context);
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.celebration),
        label: const Text("Plan My Event"),
        onPressed: showSummary,
      ),
    );
  }
}

class _VenueSelectionSheet extends StatefulWidget {
  final List<new_venue_model.Venue> venues;
  final String? selectedPartyType;
  final Map<String, List<String>> partyVenueSuitability;

  const _VenueSelectionSheet({
    required this.venues,
    this.selectedPartyType,
    required this.partyVenueSuitability,
  });

  @override
  State<_VenueSelectionSheet> createState() => _VenueSelectionSheetState();
}

class _VenueSelectionSheetState extends State<_VenueSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<new_venue_model.Venue> _filteredVenues = [];

  @override
  void initState() {
    super.initState();
    _filteredVenues = widget.venues;
    _searchController.addListener(_filterVenues);
    _filterVenues(); // Initial filter based on party type
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterVenues() {
    final query = _searchController.text.toLowerCase();
    List<new_venue_model.Venue> tempVenues = widget.venues;

    if (widget.selectedPartyType != null) {
      final typeLower = widget.selectedPartyType!.toLowerCase();
      final suitableTypes = widget.partyVenueSuitability.entries
          .where((entry) => typeLower.contains(entry.key))
          .expand((entry) => entry.value)
          .toSet();

      if (suitableTypes.isNotEmpty) {
        // This part of the logic needs to be adapted or removed, as the new Venue model
        // doesn't have a `type` field. For now, we'll just search by name.
        // tempVenues = widget.venues.where((venue) => suitableTypes.contains(venue.type)).toList();
      }
    }

    setState(() {
      _filteredVenues = tempVenues.where((venue) {
        return venue.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(width: 40, height: 5, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 16),
                    Text("Select a Venue", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      style: TextStyle(color: theme.colorScheme.onSecondary),
                      decoration: InputDecoration(
                        hintText: 'Search venues...',
                        hintStyle: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                        filled: true,
                        fillColor: theme.colorScheme.secondary,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredVenues.length,
                  itemBuilder: (context, index) {
                    final venue = _filteredVenues[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pop(venue),
                      child: Card(
                        color: theme.colorScheme.secondary,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                              child: Image.asset( // Changed to Image.asset
                                venue.imageUrl,
                                width: 120,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 120,
                                  height: 90,
                                  color: theme.colorScheme.surface,
                                  child: Icon(Icons.image_not_supported, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      venue.name,
                                      style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    // Text(
                                    //   venue.type, // Type is not in the new model
                                    //   style: TextStyle(color: theme.colorScheme.primary, fontSize: 14),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PartySelectionSheet extends StatelessWidget {
  final Map<String, List<String>> partyCategories;
  const _PartySelectionSheet({required this.partyCategories});

  // Helper to determine the icon for a party type
  IconData _getPartyTypeIcon(String partyType) {
    final typeLower = partyType.toLowerCase();
    // Outdoor-specific events
    if (typeLower.contains('picnic') ||
        typeLower.contains('bbq') ||
        typeLower.contains('bonfire') ||
        typeLower.contains('outdoors')) {
      return Icons.wb_sunny_outlined; // Icon for outdoor events
    }
    // Indoor-specific events
    if (typeLower.contains('watch party') || typeLower.contains('movie night')) {
      return Icons.theaters_outlined; // Icon for indoor events
    }
    // Default for events that can be either
    return Icons.celebration_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icons = [Icons.cake, Icons.people, Icons.favorite, Icons.theater_comedy, Icons.self_improvement, Icons.flag, Icons.fastfood];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Text("Select Party Type", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: partyCategories.keys.length,
              itemBuilder: (context, index) {
                final category = partyCategories.keys.elementAt(index);
                final types = partyCategories[category]!;
                return ExpansionTile(
                  leading: Icon(icons[index % icons.length], color: theme.colorScheme.primary),
                  title: Text(category, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
                  iconColor: theme.colorScheme.onSurface.withOpacity(0.7),
                  collapsedIconColor: theme.colorScheme.onSurface.withOpacity(0.7),
                  children: types
                      .map((type) => ListTile(
                            leading: Icon(_getPartyTypeIcon(type), color: theme.colorScheme.onSurface.withOpacity(0.7), size: 20),
                            title: Text(type, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                            onTap: () => Navigator.of(context).pop(type),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
