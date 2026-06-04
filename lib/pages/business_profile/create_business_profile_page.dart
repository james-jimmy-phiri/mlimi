import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/services/business_profile_service.dart';
import 'package:mlimi/utils/error_utils.dart';
import 'package:geolocator/geolocator.dart';

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

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _townCityController = TextEditingController();
  final _gpsLatController = TextEditingController();
  final _gpsLngController = TextEditingController();
  
  // Social Media Controllers
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  final _tagsController = TextEditingController();
  final _yearFoundedController = TextEditingController();
  final _employeesCountController = TextEditingController();

  File? _logoImage;
  List<File> _galleryImages = [];
  List<File> _galleryVideos = [];

  List<BusinessSector> _sectors = [];
  List<BusinessCategory> _categories = [];
  List<BusinessDistrict> _districts = [];
  List<Map<String, dynamic>> _valueChains = [];

  BusinessSector? _selectedSector;
  bool _showCustomSector = false;
  final _customSectorController = TextEditingController();
  BusinessDistrict? _selectedDistrict;
  List<int> _selectedCategoryIds = [];
  List<String> _customCategories = [];
  final _customCategoryController = TextEditingController();
  List<int> _selectedValueChainIds = [];
  List<String> _customValueChains = [];
  final _customValueChainController = TextEditingController();
  List<String> _selectedPaymentMethods = [];
  List<String> _selectedDeliveryOptions = [];

  final List<String> _paymentOptions = ['Cash', 'Mobile Money', 'Bank Transfer', 'Cheque'];
  final List<String> _deliveryOptionsList = ['Pick-up', 'Delivery', 'Both'];

  List<Map<String, dynamic>> _offerings = [];

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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
    _operatingHoursController.dispose();
    _tagsController.dispose();
    _yearFoundedController.dispose();
    _employeesCountController.dispose();
    _customSectorController.dispose();
    _customCategoryController.dispose();
    _customValueChainController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final List<dynamic> results = await Future.wait([
        _businessProfileService.getSectors(),
        _businessProfileService.getCategories(),
        _businessProfileService.getDistricts(),
        _businessProfileService.getValueChains(),
      ]);

      setState(() {
        _sectors = results[0] as List<BusinessSector>;
        _categories = results[1] as List<BusinessCategory>;
        _districts = results[2] as List<BusinessDistrict>;
        _valueChains = (results[3] as List).map((e) => e as Map<String, dynamic>).toList();
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_language == 'en' ? 'Failed to load lookups' : 'Zaphwanya kutsegula zofunikira'}: ${ErrorUtils.getFriendlyErrorMessage(e, _language)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _logoImage = File(pickedFile.path));
    }
  }

  Future<void> _pickGalleryImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _galleryImages.addAll(pickedFiles.map((f) => File(f.path)));
      });
    }
  }

  Future<void> _pickGalleryVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final int bytes = await file.length();
      if (bytes > 100 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_language == 'en' ? 'Video must be smaller than 100MB' : 'Kanema asapitirire 100MB')),
          );
        }
        return;
      }
      setState(() => _galleryVideos.add(file));
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
          SnackBar(content: Text('${_language == 'en' ? 'Failed to get location' : 'Zaphwanya kuziwa komwe muli'}: ${ErrorUtils.getFriendlyErrorMessage(e, _language)}')),
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
      });
    });
  }

  Future<void> _pickOfferingImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _offerings[index]['image'] = File(pickedFile.path);
      });
    }
  }

  void _removeOffering(int index) {
    setState(() => _offerings.removeAt(index));
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _businessProfileService.createProfile(
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
        logo: _logoImage,
        businessLicenseNumber: _licenseController.text.isNotEmpty ? _licenseController.text : null,
        sectorId: _showCustomSector ? null : _selectedSector?.id,
        customSector: _showCustomSector ? _customSectorController.text.trim() : null,
        categoryIds: _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds : null,
        customCategories: _customCategories.isNotEmpty ? _customCategories : null,
        districtId: _selectedDistrict?.id,
        addressLine: _addressLineController.text.isNotEmpty ? _addressLineController.text : null,
        townCity: _townCityController.text.isNotEmpty ? _townCityController.text : null,
        gpsLat: _gpsLatController.text.isNotEmpty ? _gpsLatController.text : null,
        gpsLng: _gpsLngController.text.isNotEmpty ? _gpsLngController.text : null,
        yearFounded: int.tryParse(_yearFoundedController.text),
        employeesCount: int.tryParse(_employeesCountController.text),
        operatingHours: _operatingHoursController.text.isNotEmpty ? _operatingHoursController.text : null,
        paymentMethods: _selectedPaymentMethods.isNotEmpty ? _selectedPaymentMethods : null,
        deliveryOptions: _selectedDeliveryOptions.isNotEmpty ? _selectedDeliveryOptions : null,
        tags: _tagsController.text.isNotEmpty
            ? _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
            : null,
        valueChainIds: _selectedValueChainIds.isNotEmpty ? _selectedValueChainIds : null,
        customValueChains: _customValueChains.isNotEmpty ? _customValueChains : null,
        offerings: _offerings.isNotEmpty ? _offerings : null,
        galleryImages: _galleryImages.isNotEmpty ? _galleryImages : null,
        galleryVideos: _galleryVideos.isNotEmpty ? _galleryVideos : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_language == 'en'
                ? 'Profile created successfully!'
                : 'Mbiri yapangidwa bwino!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e, s) {
      print('Error creating profile: $e');
      print('Stacktrace: $s');
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('unauthenticated') || errorStr.contains('401')) {
        final phone = GetStorage().read('phone');
        if (phone != null) {
          final success = await _showReAuthModal(phone);
          if (success == true) {
            // Retry submission!
            _submitProfile();
            return;
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_language == 'en' ? 'Failed to create profile' : 'Zaphwanya kupanga mbiri'}: ${ErrorUtils.getFriendlyErrorMessage(e, _language)}'),
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
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionHeader(
                            _language == 'en' ? 'Brand Identity' : 'Chidziwitso cha Bizinesi',
                            Icons.stars_rounded,
                          ),
                          _buildLogoSection(),
                          const SizedBox(height: 32),
                          
                          _buildSectionHeader(
                            _language == 'en' ? 'Core Information' : 'Zambiri zazikulu',
                            Icons.business_center_rounded,
                          ),
                          _buildBusinessInfoSection(),
                          const SizedBox(height: 32),
                          
                          _buildSectionHeader(
                            _language == 'en' ? 'Location Details' : 'Zambiri za Malo',
                            Icons.location_on_rounded,
                          ),
                          _buildLocationSection(),
                          const SizedBox(height: 32),
                          
                          _buildSectionHeader(
                            _language == 'en' ? 'Contact & Digital' : 'Zolumikizirana',
                            Icons.contact_mail_rounded,
                          ),
                          _buildContactSection(),
                          const SizedBox(height: 32),
                          
                          _buildSectionHeader(
                            _language == 'en' ? 'Social Presence' : 'Social Media',
                            Icons.public_rounded,
                          ),
                          _buildSocialMediaSection(),
                          const SizedBox(height: 32),
                          
                          _buildSectionHeader(
                            _language == 'en' ? 'Operations & Tags' : 'Ntchito ndi Zizindikiro',
                            Icons.settings_rounded,
                          ),
                          _buildOperationsSection(),
                          const SizedBox(height: 32),

                          if (_valueChains.isNotEmpty) ...[
                            _buildSectionHeader(
                              _language == 'en' ? 'Value Chains' : 'Nzere za Mtengo',
                              Icons.link_rounded,
                            ),
                            _buildValueChainsSection(),
                            const SizedBox(height: 32),
                          ],

                          _buildSectionHeader(
                            _language == 'en' ? 'Offerings (Products/Services)' : 'Zogulitsa ndi Ntchito',
                            Icons.shopping_bag_rounded,
                            action: TextButton.icon(
                              onPressed: _addOffering,
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              label: Text(_language == 'en' ? 'Add Item' : 'Onjezani'),
                              style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                            ),
                          ),
                          _buildOfferingsSection(),
                          const SizedBox(height: 32),

                          _buildSectionHeader(
                            _language == 'en' ? 'Media Gallery' : 'Zithunzi ndi Makanema',
                            Icons.collections_rounded,
                          ),
                          _buildGallerySection(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomSheet: _isLoadingData ? null : _buildSubmitBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: kPrimaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          _language == 'en' ? 'Create Business Profile' : 'Pangani Mbiri',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kPrimaryColor,
                    kPrimaryColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.business,
                size: 250,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  Widget _buildSubmitBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    _language == 'en' ? 'Launch Business Profile' : 'Tumizani Mbiri ya Bizinesi',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[200]!, width: 4),
                    image: _logoImage != null
                        ? DecorationImage(
                            image: FileImage(_logoImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _logoImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, size: 40, color: kPrimaryColor.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            Text(
                              _language == 'en' ? 'Upload Logo' : 'Ikani Logo',
                              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              if (_logoImage != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _pickLogo,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Business Name *' : 'Dzina la Bizinesi *',
              Icons.business_rounded,
            ),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<BusinessSector?>(
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Industry Sector' : 'Gawo la Bizinesi',
              Icons.category_rounded,
            ),
            value: _showCustomSector ? null : _selectedSector,
            items: [
              ..._sectors.map((s) => DropdownMenuItem<BusinessSector?>(value: s, child: Text(s.name))),
              DropdownMenuItem<BusinessSector?>(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 16, color: kPrimaryColor),
                    const SizedBox(width: 8),
                    Text(_language == 'en' ? 'Other (Add New)' : 'Zina (Onjeza Tsopano)',
                        style: GoogleFonts.poppins(color: kPrimaryColor)),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                if (value == null && !_showCustomSector) {
                  // "Other" was selected
                  _showCustomSector = true;
                  _selectedSector = null;
                } else {
                  _showCustomSector = false;
                  _selectedSector = value;
                }
              });
            },
          ),
          if (_showCustomSector) ...
            [
              const SizedBox(height: 12),
              TextFormField(
                controller: _customSectorController,
                style: GoogleFonts.poppins(fontSize: 15),
                decoration: _getInputDecoration(
                  _language == 'en' ? 'Enter Sector Name' : 'Lembani Gawo',
                  Icons.edit_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => setState(() => _showCustomSector = false),
                  ),
                ),
                validator: (v) => _showCustomSector && (v?.isEmpty ?? true) ? 'Required' : null,
              ),
            ],
          const SizedBox(height: 20),
          // ── Categories ──
          if (_categories.isNotEmpty) ...[
            Text(
              _language == 'en' ? 'Business Categories' : 'Mitundu ya Bizinesi',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _showMultiSelectBottomSheet(
                  title: _language == 'en' ? 'Select Categories' : 'Sankhani Mitundu',
                  items: _categories,
                  selectedIds: _selectedCategoryIds,
                  getId: (item) => (item as BusinessCategory).id,
                  getName: (item) => (item as BusinessCategory).name,
                  onConfirm: (updatedIds) {
                    setState(() {
                      _selectedCategoryIds = List<int>.from(updatedIds);
                    });
                  },
                  allowCustom: true,
                  customItems: _customCategories,
                  onConfirmCustom: (updatedCustoms) {
                    setState(() {
                      _customCategories = updatedCustoms;
                    });
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (_selectedCategoryIds.isEmpty && _customCategories.isEmpty)
                            ? (_language == 'en' ? 'Select Categories' : 'Sankhani Mitundu')
                            : '${_selectedCategoryIds.length + _customCategories.length} selected',
                        style: GoogleFonts.poppins(
                          color: (_selectedCategoryIds.isEmpty && _customCategories.isEmpty) ? Colors.grey[500] : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            if (_selectedCategoryIds.isNotEmpty || _customCategories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ..._selectedCategoryIds.map((id) {
                      final cat = _categories.firstWhere((c) => c.id == id);
                      return Chip(
                        label: Text(cat.name, style: GoogleFonts.poppins(fontSize: 11)),
                        backgroundColor: kPrimaryColor.withOpacity(0.1),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _selectedCategoryIds.remove(id)),
                      );
                    }),
                    ..._customCategories.map((name) => Chip(
                          label: Text(name, style: GoogleFonts.poppins(fontSize: 11)),
                          backgroundColor: kPrimaryColor.withOpacity(0.1),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => setState(() => _customCategories.remove(name)),
                        )),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Business Description *' : 'Kufotokozera *',
              Icons.description_rounded,
            ).copyWith(alignLabelWithHint: true),
            maxLines: 4,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _licenseController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Business License No.' : 'Nambala ya Lazense',
              Icons.badge_rounded,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _yearFoundedController,
                  style: GoogleFonts.poppins(fontSize: 15),
                  decoration: _getInputDecoration(
                    _language == 'en' ? 'Year Founded' : 'Chaka chomwe idayambira',
                    Icons.event_available_rounded,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _employeesCountController,
                  style: GoogleFonts.poppins(fontSize: 15),
                  decoration: _getInputDecoration(
                    _language == 'en' ? 'Employees' : 'Ogwira Ntchito',
                    Icons.people_alt_rounded,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _locationController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Primary Location *' : 'Malo Akulu *',
              Icons.place_rounded,
            ),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<BusinessDistrict>(
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
            decoration: _getInputDecoration(
              _language == 'en' ? 'District' : 'Boma',
              Icons.map_rounded,
            ),
            value: _selectedDistrict,
            items: _districts
                .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                .toList(),
            onChanged: (value) => setState(() => _selectedDistrict = value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _addressLineController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Physical Address' : 'Adiresi ya Malo',
              Icons.home_rounded,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _townCityController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Town / City' : 'Tawuni / Mzinda',
              Icons.location_city_rounded,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _gpsLatController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _getInputDecoration('Latitude', Icons.explore_rounded),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _gpsLngController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _getInputDecoration('Longitude', Icons.explore_rounded),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location_rounded, size: 20),
              label: Text(
                _language == 'en' ? 'Get GPS from Current Location' : 'Pezani GPS pamene muli',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Business Phone *' : 'Lamya ya Bizinesi *',
              Icons.phone_rounded,
            ),
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration(
              'Business Email *',
              Icons.email_rounded,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _websiteController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Website URL' : 'Webusaiti',
              Icons.language_rounded,
            ),
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _operatingHoursController,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Operating Hours (e.g. Mon-Fri 8am-5pm)' : 'Maola Ogwira Ntchito',
              Icons.access_time_rounded,
            ).copyWith(alignLabelWithHint: true),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          Text(_language == 'en' ? 'Payment Methods' : 'Njira za Kulipira',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _paymentOptions.map((opt) {
              final selected = _selectedPaymentMethods.contains(opt);
              return FilterChip(
                label: Text(opt, style: GoogleFonts.poppins(fontSize: 12)),
                selected: selected,
                onSelected: (val) => setState(() {
                  if (val) _selectedPaymentMethods.add(opt);
                  else _selectedPaymentMethods.remove(opt);
                }),
                selectedColor: kPrimaryColor.withOpacity(0.15),
                checkmarkColor: kPrimaryColor,
                side: BorderSide(color: selected ? kPrimaryColor : Colors.grey[300]!),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(_language == 'en' ? 'Delivery Options' : 'Njira za Kutumizia',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _deliveryOptionsList.map((opt) {
              final selected = _selectedDeliveryOptions.contains(opt);
              return FilterChip(
                label: Text(opt, style: GoogleFonts.poppins(fontSize: 12)),
                selected: selected,
                onSelected: (val) => setState(() {
                  if (val) _selectedDeliveryOptions.add(opt);
                  else _selectedDeliveryOptions.remove(opt);
                }),
                selectedColor: kPrimaryColor.withOpacity(0.15),
                checkmarkColor: kPrimaryColor,
                side: BorderSide(color: selected ? kPrimaryColor : Colors.grey[300]!),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _tagsController,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: _getInputDecoration(
              _language == 'en' ? 'Tags (comma-separated)' : 'Zizindikiro (gawanikani ndi koma)',
              Icons.label_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueChainsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              _showMultiSelectBottomSheet(
                title: _language == 'en' ? 'Select Value Chains' : 'Sankhani Nzere',
                items: _valueChains,
                selectedIds: _selectedValueChainIds,
                getId: (item) => item['id'] as int,
                getName: (item) => item['name'] as String? ?? '',
                onConfirm: (updatedIds) {
                  setState(() {
                    _selectedValueChainIds = List<int>.from(updatedIds);
                  });
                },
                allowCustom: true,
                customItems: _customValueChains,
                onConfirmCustom: (updatedCustoms) {
                  setState(() {
                    _customValueChains = updatedCustoms;
                  });
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      (_selectedValueChainIds.isEmpty && _customValueChains.isEmpty)
                          ? (_language == 'en' ? 'Select Value Chains' : 'Sankhani Nzere')
                          : '${_selectedValueChainIds.length + _customValueChains.length} selected',
                      style: GoogleFonts.poppins(
                        color: (_selectedValueChainIds.isEmpty && _customValueChains.isEmpty) ? Colors.grey[500] : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
          if (_selectedValueChainIds.isNotEmpty || _customValueChains.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ..._selectedValueChainIds.map((id) {
                    final vc = _valueChains.firstWhere((c) => c['id'] == id);
                    return Chip(
                      label: Text(vc['name'] as String? ?? '', style: GoogleFonts.poppins(fontSize: 11)),
                      backgroundColor: kPrimaryColor.withOpacity(0.1),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _selectedValueChainIds.remove(id)),
                    );
                  }),
                  ..._customValueChains.map((name) => Chip(
                        label: Text(name, style: GoogleFonts.poppins(fontSize: 11)),
                        backgroundColor: kPrimaryColor.withOpacity(0.1),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _customValueChains.remove(name)),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _facebookController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration('Facebook URL', Icons.facebook_rounded),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _instagramController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration('Instagram URL', Icons.camera_alt_rounded),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _twitterController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration('Twitter URL', Icons.alternate_email_rounded),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _linkedinController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: _getInputDecoration('LinkedIn URL', Icons.work_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferingsSection() {
    if (_offerings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _language == 'en' ? 'List your main products or services' : 'Lembetsani zogulitsa zanu',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addOffering,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor.withOpacity(0.1),
                foregroundColor: kPrimaryColor,
                elevation: 0,
              ),
              child: Text(_language == 'en' ? 'Add First Item' : 'Onjezani Choyamba'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: List.generate(_offerings.length, (index) {
        return _buildOfferingItem(index);
      }),
    );
  }

  Widget _buildOfferingItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _offerings[index]['type'],
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                  decoration: _getInputDecoration('Type', Icons.layers_rounded).copyWith(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                onPressed: () => _removeOffering(index),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: _getInputDecoration('Name', Icons.label_rounded).copyWith(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) => _offerings[index]['name'] = value,
          ),
          const SizedBox(height: 12),
          TextFormField(
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: _getInputDecoration('Short Description', Icons.notes_rounded).copyWith(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) => _offerings[index]['description'] = value,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _getInputDecoration('Price', Icons.payments_rounded).copyWith(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    prefixText: 'MWK ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _offerings[index]['price'] = double.tryParse(value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _getInputDecoration('Unit', Icons.scale_rounded).copyWith(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => _offerings[index]['unit'] = value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Offering Image Picker
          GestureDetector(
            onTap: () => _pickOfferingImage(index),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: _offerings[index]['image'] != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _offerings[index]['image'] as File,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _offerings[index]['image'] = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: Colors.grey[400], size: 32),
                        const SizedBox(height: 8),
                        Text(
                          _language == 'en' ? 'Add Product Image' : 'Onjezani chithunzi',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildGalleryPicker(
                  onTap: _pickGalleryImages,
                  icon: Icons.add_photo_alternate_rounded,
                  label: _language == 'en' ? 'Add Photos' : 'Zithunzi',
                  count: _galleryImages.length,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGalleryPicker(
                  onTap: _pickGalleryVideo,
                  icon: Icons.video_call_rounded,
                  label: _language == 'en' ? 'Add Videos' : 'Makanema',
                  count: _galleryVideos.length,
                ),
              ),
            ],
          ),
          if (_galleryImages.isNotEmpty || _galleryVideos.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              _language == 'en' ? 'Selected Media' : 'Zomwe Mwasankha',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._galleryImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 100,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(file),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _galleryImages.removeAt(index)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  ..._galleryVideos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    final fileName = file.path.split('/').last;
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 100,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.videocam, size: 40, color: kPrimaryColor),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    fileName,
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _galleryVideos.removeAt(index)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGalleryPicker({required VoidCallback onTap, required IconData icon, required String label, required int count}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: kPrimaryColor),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
            if (count > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
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
                _language == 'en' ? 'Create Profile' : 'Pangani Mbiri',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
  void _showMultiSelectBottomSheet({
    required String title,
    required List<dynamic> items,
    required List<dynamic> selectedIds,
    required dynamic Function(dynamic item) getId,
    required String Function(dynamic item) getName,
    required void Function(List<dynamic> updatedIds) onConfirm,
    bool allowCustom = false,
    List<String>? customItems,
    void Function(List<String> updatedCustomItems)? onConfirmCustom,
  }) {
    List<dynamic> tempSelectedIds = List.from(selectedIds);
    List<String> tempCustomItems = customItems != null ? List.from(customItems) : [];
    TextEditingController customController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...items.map((item) {
                          final id = getId(item);
                          final name = getName(item);
                          final isSelected = tempSelectedIds.contains(id);
                          return CheckboxListTile(
                            title: Text(name, style: GoogleFonts.poppins()),
                            value: isSelected,
                            activeColor: kPrimaryColor,
                            onChanged: (bool? checked) {
                              setModalState(() {
                                if (checked == true) {
                                  tempSelectedIds.add(id);
                                } else {
                                  tempSelectedIds.remove(id);
                                }
                              });
                            },
                          );
                        }),
                        if (allowCustom) ...[
                          const Divider(),
                          ...tempCustomItems.map((customName) {
                            return CheckboxListTile(
                              title: Text(customName, style: GoogleFonts.poppins()),
                              value: true,
                              activeColor: kPrimaryColor,
                              onChanged: (bool? checked) {
                                setModalState(() {
                                  tempCustomItems.remove(customName);
                                });
                              },
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: customController,
                                    decoration: InputDecoration(
                                      hintText: _language == 'en' ? 'Add other...' : 'Onjezani zina...',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    if (customController.text.trim().isNotEmpty) {
                                      setModalState(() {
                                        tempCustomItems.add(customController.text.trim());
                                        customController.clear();
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(_language == 'en' ? 'Add' : 'Onjeza', style: GoogleFonts.poppins(color: Colors.white)),
                                )
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          onConfirm(tempSelectedIds);
                          if (allowCustom && onConfirmCustom != null) {
                            onConfirmCustom(tempCustomItems);
                          }
                          Navigator.pop(context);
                        },
                        child: Text(_language == 'en' ? 'Confirm Selection' : 'Tsimikizani', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _showReAuthModal(String phone) async {
    final TextEditingController pinController = TextEditingController();
    bool isAuthenticating = false;
    String? pinError;

    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _language == 'en' ? 'Session Expired' : 'Nthawi Yanu Yatha',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _language == 'en'
                          ? 'Your session has expired. Please enter your PIN for $phone to continue submitting your profile.'
                          : 'Nthawi yanu yatha. Chonde lowetsani PIN yanu ya $phone kuti mupitirize.',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: 'PIN',
                        errorText: pinError,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    isAuthenticating
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              final pin = pinController.text.trim();
                              if (pin.isEmpty || pin.length < 4) {
                                setModalState(() => pinError = _language == 'en' ? 'Enter a valid 4-digit PIN' : 'Lowetsani PIN yolondola');
                                return;
                              }
                              setModalState(() {
                                isAuthenticating = true;
                                pinError = null;
                              });

                              try {
                                final response = await http.post(
                                  Uri.parse('${apiurl}v1/auth/login'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({'phone': phone, 'pin': pin}),
                                );
                                if (response.statusCode == 200) {
                                  final token = jsonDecode(response.body)['token'];
                                  GetStorage().write('token', token);
                                  if (mounted) Navigator.pop(context, true);
                                } else {
                                  setModalState(() => pinError = _language == 'en' ? 'Incorrect PIN' : 'PIN yolakwika');
                                }
                              } catch (e) {
                                setModalState(() => pinError = _language == 'en' ? 'Network error. Try again.' : 'Vuto la intaneti.');
                              } finally {
                                setModalState(() => isAuthenticating = false);
                              }
                            },
                            child: Text(_language == 'en' ? 'Verify & Resume' : 'Tsimikizani', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(_language == 'en' ? 'Cancel' : 'Tiyeni', style: GoogleFonts.poppins(color: Colors.grey[600])),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
