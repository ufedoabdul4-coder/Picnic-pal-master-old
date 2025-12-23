import 'package:flutter/material.dart';
import 'book_hotel_screen.dart'; // To use the Hotel model
import 'package:intl/intl.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _adults = 1;
  int _children = 0;
  int _rooms = 1;

  int get _numberOfNights {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hotel Details',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.hotel.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                color: Colors.grey[800],
                child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotel.name,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: theme.colorScheme.onSurface.withOpacity(0.7), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.hotel.address,
                          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[400], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.hotel.rating} Stars',
                        style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Booking Details", theme),
                  const SizedBox(height: 12),
                  _buildDatePickers(theme),
                  const SizedBox(height: 16),
                  _buildCounterRow(theme, Icons.person_outline, 'Adults', _adults, (val) => setState(() => _adults = val), minValue: 1),
                  const SizedBox(height: 12),
                  _buildCounterRow(theme, Icons.child_care, 'Children', _children, (val) => setState(() => _children = val)),
                  const SizedBox(height: 12),
                  _buildCounterRow(theme, Icons.bed_outlined, 'Rooms', _rooms, (val) => setState(() => _rooms = val), minValue: 1),
                  const SizedBox(height: 20),
                  Divider(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      _numberOfNights > 0
                          ? 'Total: ₦${(widget.hotel.pricePerNight * _numberOfNights * _rooms).toStringAsFixed(2)}'
                          : '₦${widget.hotel.pricePerNight.toStringAsFixed(2)} / night',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Book Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDatePickers(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildPickerTile(
            theme: theme,
            label: _checkInDate == null ? 'Check-in' : DateFormat.yMMMd().format(_checkInDate!),
            icon: Icons.calendar_today_outlined,
            onTap: _pickDateRange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPickerTile(
            theme: theme,
            label: _checkOutDate == null ? 'Check-out' : DateFormat.yMMMd().format(_checkOutDate!),
            icon: Icons.calendar_today,
            onTap: _pickDateRange,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerTile({required ThemeData theme, required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.surface.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _checkInDate != null && _checkOutDate != null ? DateTimeRange(start: _checkInDate!, end: _checkOutDate!) : null,
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
      });
    }
  }

  Widget _buildCounterRow(ThemeData theme, IconData icon, String label, int value, ValueChanged<int> onChanged, {int minValue = 0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.7)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16)),
          ],
        ),
        Row(
          children: [
            _buildCounterButton(theme, Icons.remove, () {
              if (value > minValue) onChanged(value - 1);
            }),
            SizedBox(width: 20, child: Center(child: Text('$value', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)))),
            _buildCounterButton(theme, Icons.add, () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton(ThemeData theme, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.colorScheme.onPrimary, size: 18),
      ),
    );
  }
}