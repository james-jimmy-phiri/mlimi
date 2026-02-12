import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/services/business_profile_service.dart';
import 'package:geolocator/geolocator.dart';

class EditBusinessProfilePage extends StatefulWidget {
  final BusinessProfile profile;

  const EditBusinessProfilePage({super.key, required this.profile});

  @override
  State<EditBusinessProfilePage> createState() =>
      _EditBusinessProfilePageState();
}

class _EditBusinessProfilePageState extends State<EditBusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _businessProfileService = BusinessProfileService();
  final _language = GetStorage().read('language') ?? 'en';

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _websiteController;
  late final TextEditingController _licenseController;
  late final TextEditingController _addressLineController;
  late final TextEditingController _townCityController;
  late final TextEditingController _gpsLatController;
  late final TextEditingController _gpsLngController;
  late final TextEditingController _facebookController;
  late final TextEditingController _instagramController;
  late final TextEditingController _twitterController;
  late final TextEditingController _linkedinController;

  File? _newLogoImage;
  
  List<BusinessSector> _sectors = [];
  List<BusinessCategory> _categories = [];
  List<BusinessDistrict> _districts = [];
  
  BusinessSector? _selectedSector;
  BusinessDistrict? _selectedDistrict;
  List<int> _selectedCategoryIds = [];
  
  List<Map<String, dynamic>> _offerings = [];
  
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.profile.businessName);
    _descriptionController = TextEditingController(text: widget.profile.description);
    _locationController = TextEditingController(text: widget.profile.location);
    _emailController = TextEditingController(text: widget.profile.contactInfo?.email);
    _phoneController = TextEditingController(text: widget.profile.contactInfo?.phone);
    _websiteController = TextEditingController(text: widget.profile.contactInfo?.website);
    _licenseController = TextEditingController(text: widget.profile.businessLicenseNumber);
    _addressLineController = TextEditingController(text: widget.profile.addressLine);
    _townCityController = TextEditingController(text: widget.profile.townCity);
    _gpsLatController = TextEditingController(text: widget.profile.gpsLat);
    _gpsLngController = TextEditingController(text: widget.profile.gpsLng);
    _facebookController = TextEditingController(text: widget.profile.contactInfo?.socialMedia?.facebook);
    _instagramController = TextEditingController(text: widget.profile.contactInfo?.socialMedia?.instagram);
    _twitterController = TextEditingController(text: widget.profile.contactInfo?.socialMedia?.twitter);
    _linkedinController = TextEditingController(text: widget.profile.contactInfo?.socialMedia?.linkedin);
    
    _selectedCategoryIds = widget.profile.categories?.map((c) => c.id!).toList() ?? [];
    _offerings = widget.profile.offerings?.map((o) => {
      'id': o.id,
      'type': o.type,
      'name': o.name,
      'description': o.description,
      'price': o.price,
      'currency': o.currency,
      'unit': o.unit,
      'image': null,
      'is_active': o.isActive,
    }).toList() ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _licenseController.dispose();
    _addressLineController.dispose();
    _townCityController.dispose();
    _gpsLatController.dispose();
    _gpsLngController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _businessProfileService.getSectors(),
        _businessProfileService.getCategories(),
        _businessProfileService.getDistricts(),
      ]);

      setState(() {
        _sectors = results[0] as List<BusinessSector>;
        _categories = results[1] as List<BusinessCategory>;
        _districts = results[2] as List<BusinessDistrict>;
        
        _selectedSector = widget.profile.sector != null
            ? _sectors.firstWhere(
                (s) => s.id == widget.profile.sector!.id,
                orElse: () => _sectors.first,
              )
            : null;
        
        _selectedDistrict = widget.profile.district != null
            ? _districts.firstWhere(
                (d) => d.id == widget.profile.district!.id,
                orElse: () => _districts.first,
              )
            : null;
        
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _newLogoImage = File(pickedFile.path));
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _gpsLatController.text = position.latitude.toStringAsFixed(7);
        _gpsLngController.text = position.longitude.toStringAsFixed(7);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  void _addOffering() {
    setState(() {
      _offerings.add({
        'type': 'product',
        'name': '',
        'description': '',
        'price': null,
        'currency': 'MWK',
        'unit': '',
        'image': null,
        'is_active': true,
      });
    });
  }

  void _removeOffering(int index) {
    setState(() => _offerings.removeAt(index));
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _businessProfileService.updateProfile(
        id: widget.profile.id!,
        businessName: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
        socialMedia: {
          'facebook': _facebookController.text,
          'instagram': _instagramController.text,
          'twitter': _twitterController.text,
          'linkedin': _linkedinController.text,
        },
        logo: _newLogoImage,
        businessLicenseNumber: _licenseController.text.isNotEmpty ? _licenseController.text : null,
        sectorId: _selectedSector?.id,
        categoryIds: _selectedCategoryIds,
        districtId: _selectedDistrict?.id,
        addressLine: _addressLineController.text.isNotEmpty ? _addressLineController.text : null,
        townCity: _townCityController.text.isNotEmpty ? _townCityController.text : null,
        gpsLat: _gpsLatController.text.isNotEmpty ? _gpsLatController.text : null,
        gpsLng: _gpsLngController.text.isNotEmpty ? _gpsLngController.text : null,
        offerings: _offerings.isNotEmpty ? _offerings : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_language == 'en'
                ? 'Profile updated successfully!'
                : 'Mbiri yasinthidwa bwino!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _language == 'en' ? 'Edit Business Profile' : 'Sinthani Mbiri',
          style: GoogleFonts.poppins(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLogoSection(),
                    const SizedBox(height: 24),
                    _buildBusinessInfoSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildContactSection(),
                    const SizedBox(height: 24),
                    _buildSocialMediaSection(),
                    const SizedBox(height: 24),
                    _buildOfferingsSection(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLogoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _language == 'en' ? 'Business Logo' : 'Logo ya Bizinesi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickLogo,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _newLogoImage != null
                      ? DecorationImage(
                          image: FileImage(_newLogoImage!),
                          fit: BoxFit.cover,
                        )
                      : widget.profile.logoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(widget.profile.logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: _newLogoImage == null && widget.profile.logoUrl == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate,
                              size: 40, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            _language == 'en' ? 'Add Logo' : 'Ikani Logo',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            if (_newLogoImage != null || widget.profile.logoUrl != null)
              TextButton(
                onPressed: _pickLogo,
                child: Text(_language == 'en' ? 'Change Logo' : 'Sinthani Logo'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _language == 'en' ? 'Business Information' : 'Zambiri za Bizinesi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _language == 'en' ? 'Business Name *' : 'Dzina la Bizinesi *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.business),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BusinessSector>(
              decoration: InputDecoration(
                labelText: _language == 'en' ? 'Sector' : 'Gawo',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              value: _selectedSector,
              items: _sectors
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSector = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: _language == 'en' ? 'Description *' : 'Kufotokozera *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _licenseController,
              decoration: InputDecoration(
                labelText: _language == 'en' ? 'Business License Number' : 'Nambala ya Lazense',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.card_membership),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _language == 'en' ? 'Location' : 'Malo',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: _language == 'en' ? 'Location *' : 'Malo *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BusinessDistrict>(
              decoration: InputDecoration(
                labelText: _language == 'en' ? 'District' : 'Boma',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.map),
              ),
              value: _selectedDistrict,
              items: _districts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDistrict = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressLineController,
              decoration: InputDecoration(
                labelText: _language == 'en' ? 'Address Line' : 'Adiresi',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _townCityController,
              decoration: InputDecoration(
                labelText: _language == 'en' ? 'Town/City' : 'Tawuni',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gpsLatController,
                    decoration: const InputDecoration(
                      labelText: 'GPS Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _gpsLngController,
                    decoration: const InputDecoration(
                      labelText: 'GPS Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: Text(_language == 'en' ? 'Use My Location' : 'Gwiritsani Ntchito Malo Anga'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _language == 'en' ? 'Contact Information' : 'Mauthenga',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: _language == 'en' ? 'Phone *' : 'Lamya *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: InputDecoration(
                labelText: _language == 'en' ? 'Website' : 'Webusaiti',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.language),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _language == 'en' ? 'Social Media' : 'Social Media',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _facebookController,
              decoration: const InputDecoration(
                labelText: 'Facebook',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.facebook),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instagramController,
              decoration: const InputDecoration(
                labelText: 'Instagram',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.camera_alt),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _twitterController,
              decoration: const InputDecoration(
                labelText: 'Twitter',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.chat),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _linkedinController,
              decoration: const InputDecoration(
                labelText: 'LinkedIn',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _language == 'en' ? 'Products & Services' : 'Zogulitsa',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addOffering,
                  icon: const Icon(Icons.add),
                  label: Text(_language == 'en' ? 'Add' : 'Onjezani'),
                ),
              ],
            ),
            if (_offerings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _language == 'en' ? 'No offerings added' : 'Palibe zogulitsa',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              )
            else
              ...List.generate(_offerings.length, (index) {
                return _buildOfferingItem(index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferingItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _offerings[index]['type'],
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'product', child: Text('Product')),
                    DropdownMenuItem(value: 'service', child: Text('Service')),
                  ],
                  onChanged: (value) {
                    setState(() => _offerings[index]['type'] = value);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeOffering(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _offerings[index]['name'],
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              _offerings[index]['name'] = value;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _offerings[index]['description'],
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              _offerings[index]['description'] = value;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: _offerings[index]['price']?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Price (MWK)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _offerings[index]['price'] = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: _offerings[index]['unit'],
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    _offerings[index]['unit'] = value;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
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
                _language == 'en' ? 'Update Profile' : 'Sinthani Mbiri',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
