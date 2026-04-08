import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'add_hotel_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';

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

  factory HotelRoom.fromMap(Map<String, dynamic> map) {
    return HotelRoom(
      id: map['id']?.toString() ?? '',
      number: map['room_number'] ?? '',
      type: map['room_type'] ?? '',
      status: map['status'] ?? 'Available',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Hotel {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final int roomCount;
  final double rating;

  Hotel({required this.id, required this.name, required this.address, required this.imageUrl, required this.roomCount, required this.rating});
}

class Booking {
  final String id;
  final String guestName;
  final DateTime checkIn;
  final DateTime checkOut;
  final String status;
  final double amount;

  Booking({
    required this.id,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.amount,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id']?.toString() ?? '',
      guestName: map['guest_name'] ?? 'Guest',
      checkIn: DateTime.tryParse(map['check_in']?.toString() ?? '') ?? DateTime.now(),
      checkOut: DateTime.tryParse(map['check_out']?.toString() ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Pending',
      amount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class HotelManagerDashboardScreen extends StatefulWidget {
  const HotelManagerDashboardScreen({super.key});

  @override
  State<HotelManagerDashboardScreen> createState() => _HotelManagerDashboardScreenState();
}

class _HotelManagerDashboardScreenState extends State<HotelManagerDashboardScreen> {
  int _selectedIndex = 0;
  String _userName = "Manager";
  String _userEmail = "manager@hotel.com";
  Stream<List<Map<String, dynamic>>>? _roomsStream;
  Stream<List<Map<String, dynamic>>>? _notificationsStream;
  Stream<List<Map<String, dynamic>>>? _bookingsStream;
  String? _avatarUrl;
  bool _isUploading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initRoomsStream();
    _initBookingsStream();
    _initNotificationsStream();
  }

  void _initRoomsStream() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _roomsStream = Supabase.instance.client
          .from('hotel_rooms')
          .stream(primaryKey: ['id'])
          .eq('manager_id', user.id)
          .order('room_number', ascending: true);
    }
  }

  void _initBookingsStream() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _bookingsStream = Supabase.instance.client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('manager_id', user.id)
          .order('check_in', ascending: false);
    }
  }

  void _initNotificationsStream() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _notificationsStream = Supabase.instance.client
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('manager_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);
    }
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    String? nameFromDb;
    String? avatarFromDb;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('full_name, avatar_url') // Assuming 'full_name' from common practice
          .eq('id', user.id)
          .single();
      nameFromDb = data['full_name'];
      avatarFromDb = data['avatar_url'];
    } catch (e) {
      debugPrint("Could not fetch hotel manager's profile name: $e");
    }

    if (mounted) {
      setState(() {
        _userEmail = user.email ?? 'manager@hotel.com';
        if (nameFromDb != null && nameFromDb.isNotEmpty) {
          _userName = nameFromDb;
        }
        if (avatarFromDb != null && avatarFromDb.isNotEmpty) {
          _avatarUrl = avatarFromDb;
        }
      });
    }
  }

  Future<void> _showAddRoomDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final numberController = TextEditingController();
    final typeController = TextEditingController();
    final priceController = TextEditingController();
    String status = 'Available';

    await showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text('Add New Room', style: TextStyle(color: theme.colorScheme.onSurface)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: numberController,
                    decoration: InputDecoration(
                      labelText: 'Room Number',
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3))),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: typeController,
                    decoration: InputDecoration(
                      labelText: 'Room Type (e.g. Deluxe)',
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3))),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price per Night',
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3))),
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: status,
                    dropdownColor: theme.colorScheme.surface,
                    items: ['Available', 'Occupied', 'Cleaning']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: theme.colorScheme.onSurface))))
                        .toList(),
                    onChanged: (val) => status = val!,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3))),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user != null) {
                    try {
                      await Supabase.instance.client.from('hotel_rooms').insert({
                        'room_number': numberController.text,
                        'room_type': typeController.text,
                        'price': double.tryParse(priceController.text) ?? 0.0,
                        'status': status,
                        'manager_id': user.id,
                      });
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Room added successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error adding room: $e')),
                        );
                      }
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditRoomDialog(BuildContext context, HotelRoom room) async {
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController(text: room.price.toString());
    String status = room.status;

    await showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text('Edit Room ${room.number}', style: TextStyle(color: theme.colorScheme.onSurface)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: status,
                  dropdownColor: theme.colorScheme.surface,
                  items: ['Available', 'Occupied', 'Cleaning']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: theme.colorScheme.onSurface))))
                      .toList(),
                  onChanged: (val) => status = val!,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3))),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price per Night',
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3))),
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    backgroundColor: theme.colorScheme.surface,
                    title: Text('Delete Room?', style: TextStyle(color: theme.colorScheme.onSurface)),
                    content: Text('This action cannot be undone.', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8))),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface))),
                      TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                
                if (confirm == true && context.mounted) {
                   await Supabase.instance.client.from('hotel_rooms').delete().eq('id', room.id);
                   if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await Supabase.instance.client.from('hotel_rooms').update({
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'status': status,
                    }).eq('id', room.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Room updated successfully')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating room: $e')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final Uint8List fileBytes = await image.readAsBytes();
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        final String fileName = 'hotel_uploads/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage.from('hotel_assets').uploadBinary(fileName, fileBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo uploaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading photo: $e')),
        );
      }
    }
  }

  Future<void> _onUploadAvatar() async {
    setState(() => _isUploading = true);
    try {
      final picker = ImagePicker();
      final imageFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (imageFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isUploading = false);
        return;
      }

      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '${user.id}/$fileName';

      await Supabase.instance.client.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(filePath);

      await Supabase.instance.client.from('profiles').update({'avatar_url': imageUrl}).eq('id', user.id);

      if (mounted) {
        setState(() {
          _avatarUrl = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading avatar: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
    Widget? appBarTitle;
    List<Widget>? appBarActions;
    Widget? leadingWidget;
    bool centerTitle = true;

    switch (_selectedIndex) {
      case 0:
        appBarTitle = Text('Overview', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold));
        // Profile moved to actions in all tabs or specific tabs
        leadingWidget = _buildHomeAction(theme);
        appBarActions = [_buildProfileAvatarAction(theme)];
        bodyContent = _roomsStream == null || _bookingsStream == null
            ? Center(child: Text("Please log in to view dashboard", style: TextStyle(color: theme.colorScheme.onSurface)))
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _roomsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Unable to load rooms. Please check your internet connection.', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                    ));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
                  }

                  final rooms = (snapshot.data ?? []).map((data) => HotelRoom.fromMap(data)).toList();
                  
                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _bookingsStream,
                    builder: (context, bookingsSnapshot) {
                      final bookings = (bookingsSnapshot.data ?? []).map((data) => Booking.fromMap(data)).toList();

                      // Calculate metrics
                      int totalRooms = rooms.length;
                      int activeBookings = bookings.where((b) => b.status == 'Upcoming' || b.status == 'Pending').length;
                      
                      // Calculate Today's Revenue (sum of amounts for bookings created or checking in today)
                      DateTime now = DateTime.now();
                      double todayRevenue = bookings
                          .where((b) => b.checkIn.year == now.year && b.checkIn.month == now.month && b.checkIn.day == now.day)
                          .fold(0.0, (sum, b) => sum + b.amount);
                      
                      double occupancyRate = totalRooms > 0 ? (rooms.where((r) => r.status == 'Occupied').length / totalRooms) * 100 : 0;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOverviewCards(theme, totalRooms, activeBookings, todayRevenue, occupancyRate),
                            const SizedBox(height: 24),
                            Text('Recent Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                            const SizedBox(height: 12),
                            _buildNotificationsList(theme),
                          ],
                        ),
                      );
                    }
                  );
                },
              );
        break;
      case 1:
        appBarTitle = Text('My Hotels', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold));
        leadingWidget = _buildHomeAction(theme);
        appBarActions = [_buildProfileAvatarAction(theme)];
        bodyContent = ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHotelCard(theme, Hotel(id: '1', name: 'Grand Plaza Hotel', address: '123 Main St, Abuja', imageUrl: '', roomCount: 45, rating: 4.5)),
            _buildHotelCard(theme, Hotel(id: '2', name: 'Seaside Resort', address: '45 Beach Rd, Lagos', imageUrl: '', roomCount: 20, rating: 4.8)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const AddHotelScreen()));
              },
              icon: const Icon(Icons.add),
              label: const Text("Add New Hotel"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        );
        break;
      case 2:
        appBarTitle = Text('Room Management', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold));
        appBarActions = [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddRoomDialog(context)),
          _buildProfileAvatarAction(theme)
        ];
        leadingWidget = _buildHomeAction(theme);
        bodyContent = StreamBuilder<List<Map<String, dynamic>>>(
                stream: _roomsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Unable to load rooms. Please check your internet connection.', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                    ));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
                  }

                  final rooms = (snapshot.data ?? []).map((data) => HotelRoom.fromMap(data)).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsSection(theme, rooms),
                        const SizedBox(height: 24),
                        _buildActionButtons(theme),
                        const SizedBox(height: 24),
                        Text(
                          'Room Status',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 12),
                        _buildRoomsList(theme, rooms),
                      ],
                    ),
                  );
                },
              );
        break;
      case 3:
        appBarTitle = Text('Bookings', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold));
        leadingWidget = _buildHomeAction(theme);
        appBarActions = [_buildProfileAvatarAction(theme)];
        bodyContent = StreamBuilder<List<Map<String, dynamic>>>(
          stream: _bookingsStream,
          builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
               return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
             }
             final bookings = (snapshot.data ?? []).map((data) => Booking.fromMap(data)).toList();
             
             return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                    indicatorColor: theme.colorScheme.primary,
                    tabs: const [
                      Tab(text: "Upcoming"),
                      Tab(text: "Completed"),
                      Tab(text: "Cancelled"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBookingsList(theme, bookings.where((b) => b.status == 'Upcoming' || b.status == 'Pending').toList()),
                        _buildBookingsList(theme, bookings.where((b) => b.status == 'Completed').toList()),
                        _buildBookingsList(theme, bookings.where((b) => b.status == 'Cancelled').toList()),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        );
        break;
      case 4:
        appBarTitle = Text('Financial Overview', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold));
        leadingWidget = _buildHomeAction(theme);
        appBarActions = [_buildProfileAvatarAction(theme)];
        bodyContent = StreamBuilder<List<Map<String, dynamic>>>(
          stream: _bookingsStream,
          builder: (context, snapshot) {
            final bookings = (snapshot.data ?? []).map((data) => Booking.fromMap(data)).toList();
            
            // Calculate Total Balance
            double totalBalance = bookings.where((b) => b.status != 'Cancelled').fold(0.0, (sum, b) => sum + b.amount);

            // Calculate Revenue Trend (Last 7 Days)
            List<Map<String, dynamic>> trendData = [];
            DateTime now = DateTime.now();
            double maxDaily = 1.0; // Avoid division by zero

            for (int i = 6; i >= 0; i--) {
              DateTime day = now.subtract(Duration(days: i));
              double dailyTotal = bookings.where((b) => 
                b.checkIn.year == day.year && 
                b.checkIn.month == day.month && 
                b.checkIn.day == day.day &&
                b.status != 'Cancelled'
              ).fold(0.0, (sum, b) => sum + b.amount);
              
              if (dailyTotal > maxDaily) maxDaily = dailyTotal;
              
              String dayLabel = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1];
              trendData.add({'label': dayLabel, 'amount': dailyTotal});
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFinancialSummary(theme, totalBalance),
                  const SizedBox(height: 24),
                  Text("Revenue Trend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: trendData.map((data) {
                        return _buildBar(theme, data['amount'] / maxDaily, data['label']);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Payout History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  _buildPayoutHistory(theme),
                ],
              ),
            );
          }
        );
        break;
      default:
        appBarTitle = Text('Dashboard', style: TextStyle(color: theme.colorScheme.primary));
        bodyContent = Container();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: appBarTitle,
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: centerTitle,
        leading: leadingWidget,
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel_outlined), activeIcon: Icon(Icons.hotel), label: 'Hotels'),
          BottomNavigationBarItem(icon: Icon(Icons.bed_outlined), activeIcon: Icon(Icons.bed), label: 'Rooms'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on_outlined), activeIcon: Icon(Icons.monetization_on), label: 'Earnings'),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'occupied':
        return Colors.redAccent;
      case 'cleaning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatsSection(ThemeData theme, List<HotelRoom> rooms) {
    int totalRooms = rooms.length;
    int availableRooms = rooms.where((room) => room.status.toLowerCase() == 'available').length;
    int occupiedRooms = rooms.where((room) => room.status.toLowerCase() == 'occupied').length;
    int cleaningRooms = rooms.where((room) => room.status.toLowerCase() == 'cleaning').length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(theme, 'Total Rooms', totalRooms.toString(), Icons.meeting_room),
        _buildStatCard(theme, 'Available', availableRooms.toString(), Icons.check_circle_outline, color: Colors.green),
        _buildStatCard(theme, 'Occupied', occupiedRooms.toString(), Icons.hotel, color: Colors.redAccent),
        _buildStatCard(theme, 'Cleaning', cleaningRooms.toString(), Icons.cleaning_services, color: Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon, {Color? color}) {
    final displayColor = color ?? theme.colorScheme.primary;
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
              Icon(icon, color: displayColor, size: 28),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: displayColor)),
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
                onPressed: () => _showAddRoomDialog(context),
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
                onPressed: _uploadPhoto,
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
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            icon: Icon(Icons.switch_account_outlined, color: theme.colorScheme.onSecondary),
            label: Text('Switch to User View', style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeAction(ThemeData theme) {
    return IconButton(
      icon: const Icon(Icons.home),
      tooltip: 'Go to Home',
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      },
    );
  }

  Widget _buildProfileAvatarAction(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => _ProfileView(
             userName: _userName, 
             userEmail: _userEmail, 
             avatarUrl: _avatarUrl, 
             isUploading: _isUploading,
             onUpload: _onUploadAvatar,
             theme: theme
           )));
        },
        child: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
          child: _avatarUrl == null ? Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'M', style: TextStyle(color: theme.colorScheme.onPrimary)) : null,
        ),
      ),
    );
  }

  Widget _buildOverviewCards(ThemeData theme, int rooms, int bookings, double revenue, double occupancy) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(theme, 'Active Bookings', bookings.toString(), Icons.book_online, color: Colors.blue),
            _buildStatCard(theme, 'Today\'s Revenue', _formatCurrency(revenue), Icons.attach_money, color: Colors.green),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(theme, 'Total Rooms', rooms.toString(), Icons.meeting_room),
            _buildStatCard(theme, 'Occupancy Rate', '${occupancy.toStringAsFixed(1)}%', Icons.pie_chart, color: Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationsList(ThemeData theme) {
    if (_notificationsStream == null) {
      return Text("No notifications", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)));
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _notificationsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Unable to load notifications.", style: TextStyle(color: theme.colorScheme.error));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
        }
        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return Text("No notifications", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              color: theme.colorScheme.secondary,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: Icon(Icons.notifications_active, color: theme.colorScheme.primary, size: 20),
                title: Text(notification['message'] ?? 'Notification', style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 14)),
                subtitle: notification['created_at'] != null
                    ? Text(_formatDate(DateTime.parse(notification['created_at'])), style: TextStyle(fontSize: 10, color: theme.colorScheme.onSecondary.withOpacity(0.6)))
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHotelCard(ThemeData theme, Hotel hotel) {
    return Card(
      color: theme.colorScheme.secondary,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: hotel.imageUrl.isNotEmpty
                ? Image.network(hotel.imageUrl, fit: BoxFit.cover)
                : Icon(Icons.hotel, size: 50, color: Colors.grey[600]),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(hotel.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondary)),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(hotel.rating.toString(), style: TextStyle(color: theme.colorScheme.onSecondary)),
                      ],
                    )
                  ],
                ),
                Text(hotel.address, style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
                const SizedBox(height: 8),
                Text('${hotel.roomCount} Rooms', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(ThemeData theme, List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(child: Text("No bookings found.", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          color: theme.colorScheme.secondary,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(booking.guestName, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondary)),
            subtitle: Text('${_formatDate(booking.checkIn)} - ${_formatDate(booking.checkOut)}', style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatCurrency(booking.amount), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                Text(booking.status, style: TextStyle(color: booking.status == 'Confirmed' ? Colors.green : Colors.orange, fontSize: 12)),
              ],
            ),
            onTap: () {
              // Show details dialog
            },
          ),
        );
      },
    );
  }

  Widget _buildFinancialSummary(ThemeData theme, double totalBalance) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(_formatCurrency(totalBalance), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(ThemeData theme, double heightFactor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 150 * heightFactor,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildPayoutHistory(ThemeData theme) {
    return Column(
      children: [1, 2, 3].map((i) => Card(
        color: theme.colorScheme.secondary,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.1), child: const Icon(Icons.arrow_downward, color: Colors.green)),
          title: Text("Payout #$i", style: TextStyle(color: theme.colorScheme.onSecondary)),
          subtitle: Text("Processed on ${_formatDate(DateTime.now().subtract(Duration(days: i*5)))}", style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.6))),
          trailing: Text(_formatCurrency(500.0 * i), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondary)),
        ),
      )).toList(),
    );
  }

  Widget _buildRoomsList(ThemeData theme, List<HotelRoom> rooms) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return Card(
          color: theme.colorScheme.secondary,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => _showEditRoomDialog(context, room),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(room.number, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
            title: Text(room.type, style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(room.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(room.status).withOpacity(0.5)),
                    ),
                    child: Text(room.status, style: TextStyle(color: _getStatusColor(room.status), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
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

class _ProfileView extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? avatarUrl;
  final bool isUploading;
  final VoidCallback onUpload;
  final ThemeData theme;

  const _ProfileView({
    required this.userName,
    required this.userEmail,
    required this.avatarUrl,
    required this.isUploading,
    required this.onUpload,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), backgroundColor: theme.scaffoldBackgroundColor, iconTheme: IconThemeData(color: theme.colorScheme.primary)),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarUrl != null && !isUploading ? NetworkImage(avatarUrl!) : null,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: isUploading
                        ? CircularProgressIndicator(color: theme.colorScheme.primary)
                        : (avatarUrl == null
                            ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                            : null),
                  ),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: ElevatedButton(
                      onPressed: isUploading ? null : onUpload,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: theme.colorScheme.surface,
                        elevation: 2,
                      ),
                      child: Icon(Icons.edit, size: 20, color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(userName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Text(userEmail, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 32),
              _buildProfileItem(context, theme, Icons.settings_outlined, 'Settings'),
              _buildProfileItem(context, theme, Icons.help_outline, 'Help & Support'),
              _buildProfileItem(context, theme, Icons.logout, 'Logout', isDestructive: true),
            ],
          ),
        ),
    );
  }

  Widget _buildProfileItem(BuildContext context, ThemeData theme, IconData icon, String title, {bool isDestructive = false}) {
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
      onTap: () async {
        if (title == 'Logout') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text('Logout?', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
              content: Text('Are you sure you want to logout?', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8))),
              actions: [
                TextButton(
                  child: Text('No', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                  onPressed: () => Navigator.pop(ctx, false),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: const Text('Yes', style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            await Supabase.instance.client.auth.signOut();
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
          }
        }
      },
    );
  }
}