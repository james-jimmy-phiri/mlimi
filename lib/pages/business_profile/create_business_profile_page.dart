import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/services/business_profile_service.dart';

class CreateBusinessProfilePage extends StatefulWidget {
  const CreateBusinessProfilePage({super.key});

  @override
  State<CreateBusinessProfilePage> createState() =>
      _CreateBusinessProfilePageState();
}

class _CreateBusinessProfilePageState extends State<CreateBusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _businessProfileService = BusinessProfileService();
  final _language = GetStorage().read('language') ?? 'en';

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  File? _logoImage;
  List<BusinessSector> _sectors = [];
  BusinessSector? _selectedSector;
  bool _isLoading = false;
  bool _isLoadingSectors = true;

  @override
  void initState() {
    super.initState();
    _loadSectors();
  }

  Future<void> _loadSectors() async {
    try {
      final sectors = await _businessProfileService.getSectors();
      setState(() {
        _sectors = sectors;
        _isLoadingSectors = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSectors = false;
      });
      // Handle error silently or show retry
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSector == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_language == 'en'
              ? 'Please select a sector'
              : 'Chonde sankhani gawo la bizinesi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profile = BusinessProfile(
        businessName: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        sectorId: _selectedSector!.id,
        contactInfo: ContactInfo(
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          website:
              _websiteController.text.isNotEmpty ? _websiteController.text : null,
        ),
      );

      await _businessProfileService.createProfile(profile, _logoImage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_language == 'en'
                ? 'Profile created successfully!'
                : 'Mbiri ya bizinesi yapangidwa bwino!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_language == 'en'
                ? 'Failed to create profile: $e'
                : 'Talephera kupanga mbiri: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _language == 'en' ? 'Create Business Profile' : 'Pangani Mbiri',
          style: GoogleFonts.poppins(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      image: _logoImage != null
                          ? DecorationImage(
                              image: FileImage(_logoImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _logoImage == null
                        ? const Icon(Icons.add_a_photo,
                            size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _language == 'en' ? 'Tap to add logo' : 'Dinani kuti muike logo',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),

              // Business Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText:
                      _language == 'en' ? 'Business Name' : 'Dzina la Bizinesi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _language == 'en'
                        ? 'Please enter business name'
                        : 'Chonde lembani dzina la bizinesi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Sector Dropdown
              DropdownButtonFormField<BusinessSector>(
                decoration: InputDecoration(
                  labelText: _language == 'en' ? 'Sector' : 'Gawo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                value: _selectedSector,
                items: _sectors.map((sector) {
                  return DropdownMenuItem(
                    value: sector,
                    child: Text(sector.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSector = value;
                  });
                },
                hint: _isLoadingSectors
                    ? Text(_language == 'en' ? 'Loading...' : 'Kutsegula...')
                    : Text(_language == 'en' ? 'Select Sector' : 'Sankhani Gawo'),
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: _language == 'en' ? 'Description' : 'Kufotokozera',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _language == 'en'
                        ? 'Please enter description'
                        : 'Chonde lembani kufotokozera';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: _language == 'en' ? 'Location' : 'Malo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _language == 'en'
                        ? 'Please enter location'
                        : 'Chonde lembani malo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Contact Info Section
              Text(
                _language == 'en' ? 'Contact Information' : 'Mauthenga',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: _language == 'en' ? 'Phone' : 'Lamya',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _websiteController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: _language == 'en' ? 'Website' : 'Webusaiti',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.language),
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _language == 'en' ? 'Create Profile' : 'Pangani Mbiri',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
