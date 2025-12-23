import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'rent_apartment_screen.dart'; // For Apartment model and mockApartments list

class AddEditApartmentScreen extends StatefulWidget {
  final Apartment? editingApartment;

  const AddEditApartmentScreen({super.key, this.editingApartment});

  @override
  State<AddEditApartmentScreen> createState() => _AddEditApartmentScreenState();
}

class _AddEditApartmentScreenState extends State<AddEditApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  String? _propertyType;
  File? _listingImage;

  @override
  void initState() {
    super.initState();
    // If we are editing, pre-fill the form
    if (widget.editingApartment != null) {
      final apartment = widget.editingApartment!;
      _titleController.text = apartment.title;
      _addressController.text = apartment.address;
      _priceController.text = apartment.price.toStringAsFixed(0);
      _bedroomsController.text = apartment.bedrooms.toString();
      _bathroomsController.text = apartment.bathrooms.toString();
      _propertyType = apartment.propertyType;
      // Note: Image editing is not handled in this simple implementation.
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _listingImage = File(pickedFile.path);
      });
    }
  }

  void _saveListing() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.editingApartment != null) {
        // Update existing apartment
        final int index = mockApartments.indexWhere((a) => a.id == widget.editingApartment!.id);
        if (index != -1) {
          final updatedApartment = Apartment(
            id: widget.editingApartment!.id, // Keep the original ID
            title: _titleController.text,
            address: _addressController.text,
            price: double.tryParse(_priceController.text) ?? 0,
            bedrooms: int.tryParse(_bedroomsController.text) ?? 0,
            bathrooms: int.tryParse(_bathroomsController.text) ?? 0,
            propertyType: _propertyType!,
            imageUrl: _listingImage?.path ?? widget.editingApartment!.imageUrl, // Keep old image if none is picked
            dateAdded: widget.editingApartment!.dateAdded, // Keep original date
          );
          mockApartments[index] = updatedApartment;
        }
      } else {
        // Add new apartment
        final newApartment = Apartment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          address: _addressController.text,
          price: double.tryParse(_priceController.text) ?? 0,
          bedrooms: int.tryParse(_bedroomsController.text) ?? 0,
          bathrooms: int.tryParse(_bathroomsController.text) ?? 0,
          propertyType: _propertyType!,
          imageUrl: _listingImage?.path ?? 'assets/images/apartment_placeholder.jpg', // Using path for demo
          dateAdded: DateTime.now(),
        );
        mockApartments.insert(0, newApartment);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.editingApartment != null ? 'Listing updated successfully!' : 'New listing added successfully!'),
            backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true); // Pop with 'true' to signal a refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.editingApartment != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Listing' : 'Add New Listing', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(theme),
              const SizedBox(height: 24),
              _buildTextFormField(controller: _titleController, label: 'Listing Title', icon: Icons.title),
              const SizedBox(height: 16),
              _buildTextFormField(controller: _addressController, label: 'Address', icon: Icons.location_city),
              const SizedBox(height: 16),
              _buildTextFormField(controller: _priceController, label: 'Price (per year)', icon: Icons.attach_money, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextFormField(controller: _bedroomsController, label: 'Bedrooms', icon: Icons.king_bed_outlined, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextFormField(controller: _bathroomsController, label: 'Bathrooms', icon: Icons.bathtub_outlined, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdownFormField(theme),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveListing,
                  icon: const Icon(Icons.save_alt_outlined),
                  label: Text(isEditing ? 'Save Changes' : 'Save Listing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
            image: _listingImage != null
                ? DecorationImage(image: FileImage(_listingImage!), fit: BoxFit.cover) // Show picked image
                : widget.editingApartment != null && !widget.editingApartment!.imageUrl.startsWith('assets/')
                    ? DecorationImage(image: FileImage(File(widget.editingApartment!.imageUrl)), fit: BoxFit.cover) // Show existing file image
                : null,
          ),
          child: _listingImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.primary, size: 40),
                    const SizedBox(height: 8),
                    Text('Tap to add a photo', style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String label, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.colorScheme.onSecondary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'This field cannot be empty' : null,
    );
  }

  Widget _buildDropdownFormField(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _propertyType,
      hint: Text('Select Property Type', style: TextStyle(color: theme.colorScheme.onSecondary.withOpacity(0.7))),
      onChanged: (value) => setState(() => _propertyType = value),
      items: ['Apartment', 'House', 'Studio', 'Penthouse']
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      style: TextStyle(color: theme.colorScheme.onSecondary, fontSize: 16),
      dropdownColor: theme.colorScheme.secondary,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.business_outlined, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => (value == null) ? 'Please select a property type' : null,
    );
  }
}