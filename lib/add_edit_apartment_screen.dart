import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rent_apartment_screen.dart';

class AddEditApartmentScreen extends StatefulWidget {
  final Apartment? editingApartment;
  const AddEditApartmentScreen({super.key, this.editingApartment});

  @override
  State<AddEditApartmentScreen> createState() => _AddEditApartmentScreenState();
}

class _AddEditApartmentScreenState extends State<AddEditApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _estateNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _toiletsController;
  late TextEditingController _sizeController;
  late TextEditingController _amenitiesController;

  String _propertyType = 'Apartment';
  String _bedrooms = '1';
  String _bathrooms = '1';
  String _condition = 'Fair';
  String _furnishing = 'Unfurnished';
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editingApartment?.title ?? '');
    _addressController = TextEditingController(text: widget.editingApartment?.address ?? '');
    _estateNameController = TextEditingController(text: widget.editingApartment?.estateName ?? '');
    _descriptionController = TextEditingController(text: widget.editingApartment?.description ?? '');
    _priceController = TextEditingController(text: widget.editingApartment?.price.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.editingApartment?.imageUrl ?? '');
    _toiletsController = TextEditingController(text: widget.editingApartment?.toilets.toString() ?? '1');
    _sizeController = TextEditingController(text: widget.editingApartment?.sizeSqm.toString() ?? '0');
    _amenitiesController = TextEditingController(text: widget.editingApartment?.amenities.join(', ') ?? '');

    if (widget.editingApartment != null) {
      // Ensure values are valid for dropdowns, otherwise keep defaults
      if (['Apartment', 'House', 'Studio', 'Duplex', 'Villa'].contains(widget.editingApartment!.propertyType)) {
        _propertyType = widget.editingApartment!.propertyType;
      }
      if (widget.editingApartment!.bedrooms >= 1 && widget.editingApartment!.bedrooms <= 20) {
        _bedrooms = widget.editingApartment!.bedrooms.toString();
      }
      if (widget.editingApartment!.bathrooms >= 1 && widget.editingApartment!.bathrooms <= 10) {
        _bathrooms = widget.editingApartment!.bathrooms.toString();
      }
      if (['New', 'Renovated', 'Fair', 'Old'].contains(widget.editingApartment!.condition)) {
        _condition = widget.editingApartment!.condition;
      }
      if (['Furnished', 'Semi-Furnished', 'Unfurnished'].contains(widget.editingApartment!.furnishing)) {
        _furnishing = widget.editingApartment!.furnishing;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _estateNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _toiletsController.dispose();
    _sizeController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickMedia();
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageUrlController.text = pickedFile.path;
      });
    }
  }

  Future<void> _saveApartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in.')));
      setState(() => _isLoading = false);
      return;
    }

    final amenitiesList = _amenitiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final apartmentData = {
      'title': _titleController.text.trim(),
      'address': _addressController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'image_url': _imageUrlController.text.trim(),
      'manager_id': user.id,
      'property_type': _propertyType,
      'bedrooms': int.parse(_bedrooms),
      'bathrooms': int.parse(_bathrooms),
      'toilets': int.tryParse(_toiletsController.text.trim()) ?? 0,
      'size_sqm': double.tryParse(_sizeController.text.trim()) ?? 0.0,
      'condition': _condition,
      'furnishing': _furnishing,
      'amenities': amenitiesList,
    };

    try {
      if (widget.editingApartment != null) {
        await Supabase.instance.client
            .from('apartments')
            .update(apartmentData)
            .eq('id', widget.editingApartment!.id);
      } else {
        await Supabase.instance.client.from('apartments').insert(apartmentData);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.editingApartment != null ? 'Edit Apartment' : 'Add Apartment', style: TextStyle(color: theme.colorScheme.primary)),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(theme, _titleController, 'Title'),
              const SizedBox(height: 16),
              _buildDropdown(theme, 'Property Type', ['Apartment', 'House', 'Studio', 'Duplex', 'Villa'], _propertyType, (val) => setState(() => _propertyType = val!)),
              const SizedBox(height: 16),
              _buildImagePicker(theme),
              const SizedBox(height: 16),
              _buildTextField(theme, _addressController, 'Property Address'),
              const SizedBox(height: 16),
              _buildTextField(theme, _estateNameController, 'Estate Name (Optional)', isOptional: true),
              const SizedBox(height: 16),
              _buildTextField(theme, _descriptionController, 'Description', maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(theme, _priceController, 'Price per night', isNumber: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdown(theme, 'Bedrooms', List.generate(20, (index) => (index + 1).toString()), _bedrooms, (val) => setState(() => _bedrooms = val!))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDropdown(theme, 'Bathrooms', List.generate(10, (index) => (index + 1).toString()), _bathrooms, (val) => setState(() => _bathrooms = val!))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(theme, _toiletsController, 'Toilets', isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(theme, _sizeController, 'Property Size (sqm)', isNumber: true)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdown(theme, 'Condition', ['New', 'Renovated', 'Fair', 'Old'], _condition, (val) => setState(() => _condition = val!))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDropdown(theme, 'Furnishing', ['Furnished', 'Semi-Furnished', 'Unfurnished'], _furnishing, (val) => setState(() => _furnishing = val!))),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(theme, _amenitiesController, 'Facilities (comma separated)', maxLines: 2),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveApartment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : Text(widget.editingApartment != null ? 'Update Listing' : 'Create Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, TextEditingController controller, String label, {bool isNumber = false, int maxLines = 1, bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: theme.colorScheme.secondary,
        contentPadding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (isOptional) return null;
        return value == null || value.isEmpty ? 'Required' : null;
      },
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, List<String> items, String currentValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      style: TextStyle(color: theme.colorScheme.onSurface),
      dropdownColor: theme.colorScheme.secondary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: theme.colorScheme.secondary,
        contentPadding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.3)),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _selectedImage!.path.toLowerCase().endsWith('.mp4') || _selectedImage!.path.toLowerCase().endsWith('.mov')
                    ? Container(
                        color: Colors.black12,
                        child: Center(child: Icon(Icons.play_circle_fill, size: 50, color: theme.colorScheme.primary)),
                      )
                    : Image.file(_selectedImage!, fit: BoxFit.cover),
              )
            : (_imageUrlController.text.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _imageUrlController.text.startsWith('http')
                        ? Image.network(_imageUrlController.text, fit: BoxFit.cover)
                        : Image.file(File(_imageUrlController.text), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: theme.colorScheme.onSurface)),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 30, color: theme.colorScheme.primary),
                      const SizedBox(height: 6),
                      Text('Add 5 Photos or Videos', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.bold)),
                      Text('(first picture is used as your cover photo)', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                      Text('(Tap to add)', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                    ],
                  )),
      ),
    );
  }
}