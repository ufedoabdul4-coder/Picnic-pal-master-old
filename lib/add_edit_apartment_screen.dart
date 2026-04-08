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
  String _selectedState = 'Abuja';
  String _selectedArea = 'Wuse';

  final Map<String, List<String>> _locationData = {
    'Abuja': ['Wuse', 'Wuse 2', 'Garki', 'Lugbe', 'Maitama', 'Asokoro', 'Jabi', 'Gwarinpa', 'Central Business District', 'Kubwa', 'Gwagwalada'],
    'Lagos': ['Ikeja', 'Lekki', 'Victoria Island', 'Yaba', 'Surulere', 'Ikoyi', 'Ajah', 'Maryland'],
    'Rivers': ['Port Harcourt', 'Obio-Akpor', 'Eleme', 'Gra'],
  };
  List<File> _selectedImages = [];
  List<String> _existingImages = [];

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
      
      // Attempt to pre-fill State and Area from the existing address string
      for (var state in _locationData.keys) {
        if (widget.editingApartment!.address.contains(state)) {
          _selectedState = state;
          // Default to first area in state, then check if we can find a specific one
          _selectedArea = _locationData[state]!.first;
          for (var area in _locationData[state]!) {
            if (widget.editingApartment!.address.contains(area)) {
              _selectedArea = area;
              break;
            }
          }

          // Remove the detected State and Area from the address field to avoid duplication
          String addr = widget.editingApartment!.address;
          if (addr.endsWith(_selectedState)) {
            addr = addr.substring(0, addr.length - _selectedState.length).trim();
            if (addr.endsWith(',')) addr = addr.substring(0, addr.length - 1).trim();
          }
          if (addr.endsWith(_selectedArea)) {
            addr = addr.substring(0, addr.length - _selectedArea.length).trim();
            if (addr.endsWith(',')) addr = addr.substring(0, addr.length - 1).trim();
          }
          _addressController.text = addr;
          break;
        }
      }
      _fetchExistingImages();
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

  Future<void> _fetchExistingImages() async {
    if (widget.editingApartment == null) return;
    try {
      final response = await Supabase.instance.client
          .from('apartments')
          .select('images')
          .eq('id', widget.editingApartment!.id)
          .maybeSingle();

      if (response != null && response['images'] != null) {
        final List<dynamic> rawImages = response['images'];
        setState(() {
          _existingImages = rawImages
              .where((item) => item != null && item is String && item.toString().isNotEmpty)
              .map((item) => item.toString())
              .toList();
        });
      } else if (_imageUrlController.text.isNotEmpty) {
        setState(() {
          _existingImages = [_imageUrlController.text];
        });
      }
    } catch (e) {
      debugPrint('Error fetching images: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFiles = await picker.pickMultipleMedia(limit: 20);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      // Optional: Show a snackbar here if you want to notify the user of an error
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _removeExistingImage(String url) async {
    if (url.isEmpty) return;

    setState(() {
      _existingImages.remove(url);
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Attempt to extract file path and delete from storage
      // Expected URL format: .../apartment-images/filename
      if (url.startsWith('http')) {
        try {
          final uri = Uri.parse(url);
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('apartment-images');
          
          if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
             final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
             await supabase.storage.from('apartment-images').remove([filePath]);
          }
        } catch (e) {
          debugPrint('Error parsing URL for deletion: $e');
        }
      }

      // Update database row immediately
      final validImages = _existingImages.where((img) => img.isNotEmpty).toList();
      final String newCover = validImages.isNotEmpty ? validImages.first : '';
      await supabase.from('apartments').update({
        'images': validImages,
        'image_url': newCover,
      }).eq('id', widget.editingApartment!.id);

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting image: $e')));
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

    // Start with existing images
    List<String> allImageUrls = [..._existingImages];
    String coverImageUrl = allImageUrls.isNotEmpty ? allImageUrls.first : '';

    final supabase = Supabase.instance.client;

    // Upload new images
    for (var imageFile in _selectedImages) {
      try {
        final fileName = '${user.id}-${DateTime.now().millisecondsSinceEpoch}-${imageFile.path.split('/').last}';
        final filePath = 'apartment-images/$fileName';

        await supabase.storage.from('apartment-images').uploadBinary(
          filePath,
          await imageFile.readAsBytes(),
        );

        final uploadedUrl = supabase.storage.from('apartment-images').getPublicUrl(filePath);
        allImageUrls.add(uploadedUrl);
      } catch (uploadError) {
        debugPrint('Image upload failed for ${imageFile.path}: $uploadError');
      }
    }

    // Update the cover image to the first one available
    if (allImageUrls.isNotEmpty) {
      coverImageUrl = allImageUrls.first;
    }

    final apartmentData = {
      'title': _titleController.text.trim(),
      'address': "${_addressController.text.trim()}, $_selectedArea, $_selectedState",
      'description': _descriptionController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'image_url': coverImageUrl, // Keep primary image for backward compatibility
      'images': allImageUrls, // Send full list
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
        await supabase
            .from('apartments')
            .update(apartmentData)
            .eq('id', widget.editingApartment!.id);
      } else {
        await supabase.from('apartments').insert(apartmentData);
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
              Text("Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(theme, 'State', _locationData.keys.toList(), _selectedState, (val) {
                      setState(() {
                        _selectedState = val!;
                        _selectedArea = _locationData[_selectedState]!.first;
                      });
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(theme, 'Area', _locationData[_selectedState]!, _selectedArea, (val) => setState(() => _selectedArea = val!)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(theme, _addressController, 'Street Address / Landmark'),
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
      isExpanded: true,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
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

  // Helper to build the image preview based on state (File vs Network vs Asset)
  Widget _buildPreviewContent(ThemeData theme) {
    List<Widget> thumbs = [];
    int totalIndex = 0;

    // 1. Existing images from DB
    for (var path in _existingImages) {
      if (path.isEmpty) continue;
      Widget imageWidget;
      
      // Strict check to ensure we only use Image.network for valid web URLs
      if (path.startsWith('http')) {
        imageWidget = Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
      } else if (path.startsWith('assets/')) {
        imageWidget = Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image));
      } else {
        // Fallback for unexpected strings to avoid crashes
        imageWidget = Container(color: Colors.grey[300], child: const Icon(Icons.broken_image));
      }
      
      List<Widget> stackChildren = [
        imageWidget,
        Positioned(top: 0, right: 0, child: GestureDetector(
            onTap: () => _removeExistingImage(path),
            child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), padding: const EdgeInsets.all(2), child: const Icon(Icons.close, color: Colors.white, size: 18)),
        )),
      ];

      if (totalIndex == 0) {
        stackChildren.add(Positioned(bottom: 0, left: 0, right: 0, child: Container(color: Colors.black54, padding: const EdgeInsets.all(2), child: const Text("Cover", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10)))));
      }

      thumbs.add(
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Stack(fit: StackFit.expand, children: stackChildren),
        )
      );
      totalIndex++;
    }

    // 2. Newly selected images
    for (int i = 0; i < _selectedImages.length; i++) {
      final file = _selectedImages[i];
      final path = file.path.toLowerCase();
      Widget content;
      if (path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi') || path.endsWith('.mkv')) {
        content = Container(color: Colors.black12, child: Icon(Icons.play_circle_fill, color: theme.colorScheme.primary));
      } else {
        content = Image.file(file, fit: BoxFit.cover);
      }

      List<Widget> stackChildren = [
        content,
        Positioned(top: 0, right: 0, child: GestureDetector(
            onTap: () => _removeSelectedImage(i),
            child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), padding: const EdgeInsets.all(2), child: const Icon(Icons.close, color: Colors.white, size: 18)),
        )),
      ];

      if (totalIndex == 0) {
        stackChildren.add(Positioned(bottom: 0, left: 0, right: 0, child: Container(color: Colors.black54, padding: const EdgeInsets.all(2), child: const Text("Cover", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10)))));
      }

      thumbs.add(
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Stack(fit: StackFit.expand, children: stackChildren),
        )
      );
      totalIndex++;
    }

    if (thumbs.isNotEmpty) {
      return ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        children: thumbs,
      );
    }

    // 3. Default placeholder if no images
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 30, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text('Add up to 20 Photos', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.bold)),
        Text('(first picture is used as your cover photo)', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
        Text('(Tap to add)', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
      ],
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildPreviewContent(theme),
        ),
      ),
    );
  }
}