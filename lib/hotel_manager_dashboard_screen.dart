import 'dart:io';
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
  String? _avatarUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initRoomsStream();
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

      final File file = File(image.path);
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        final String fileName = 'hotel_uploads/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage.from('hotel_assets').upload(fileName, file);

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
        bodyContent = _roomsStream == null
            ? Center(child: Text("Please log in to view dashboard", style: TextStyle(color: theme.colorScheme.onSurface)))
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _roomsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Unable to load rooms.\n${snapshot.error.toString().contains("PGRST205") ? "Table 'hotel_rooms' not found in database." : snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                    ));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
                  }

                  final rooms = snapshot.data!.map((data) => HotelRoom.fromMap(data)).toList();

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatarUrl != null && !_isUploading ? NetworkImage(_avatarUrl!) : null,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: _isUploading
                        ? CircularProgressIndicator(color: theme.colorScheme.primary)
                        : (_avatarUrl == null
                            ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                            : null),
                  ),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _onUploadAvatar,
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
              Text(_userName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Text(_userEmail, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 32),
              _buildProfileItem(theme, Icons.settings_outlined, 'Settings'),
              _buildProfileItem(theme, Icons.help_outline, 'Help & Support'),
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