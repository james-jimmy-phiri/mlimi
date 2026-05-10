import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/services/business_profile_service.dart';
import 'package:mlimi/utils/error_utils.dart';
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
  late final TextEditingController _operatingHoursController;
  late final TextEditingController _tagsController;
  late final TextEditingController _yearFoundedController;
  late final TextEditingController _employeesCountController;

  File? _newLogoImage;

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
    _operatingHoursController = TextEditingController(
      text: widget.profile.operatingHours?.toString() ?? '',
    );
    _yearFoundedController = TextEditingController(
      text: widget.profile.yearFounded?.toString() ?? '',
    );
    _employeesCountController = TextEditingController(
      text: widget.profile.employeesCount?.toString() ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.profile.tags?.join(', ') ?? '',
    );

    _selectedCategoryIds = widget.profile.categories?.map((c) => c.id!).toList() ?? [];
    _selectedPaymentMethods = widget.profile.paymentMethods?.toList() ?? [];
    _selectedDeliveryOptions = widget.profile.deliveryOptions?.toList() ?? [];
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
        _valueChains = results[3] as List<Map<String, dynamic>>;

        // Pre-select value chains from profile
        if (widget.profile.valueChains != null) {
          _selectedValueChainIds = widget.profile.valueChains!
              .map((vc) => (vc is Map ? vc['id'] : null) as int?)
              .whereType<int>()
              .toList();
        }

        _selectedSector = widget.profile.sector != null && _sectors.isNotEmpty
            ? _sectors.where((s) => s.id == widget.profile.sector!.id).cast<BusinessSector?>().firstOrNull
            : null;

        _selectedDistrict = widget.profile.district != null && _districts.isNotEmpty
            ? _districts.where((d) => d.id == widget.profile.district!.id).cast<BusinessDistrict?>().firstOrNull
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
        yearFounded: int.tryParse(_yearFoundedController.text),
        employeesCount: int.tryParse(_employeesCountController.text),
        logo: _newLogoImage,
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
        operatingHours: _operatingHoursController.text.isNotEmpty ? _operatingHoursController.text : null,
        paymentMethods: _selectedPaymentMethods.isNotEmpty ? _selectedPaymentMethods : null,
        deliveryOptions: _selectedDeliveryOptions.isNotEmpty ? _selectedDeliveryOptions : null,
        tags: _tagsController.text.isNotEmpty
            ? _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
            : null,
        valueChainIds: _selectedValueChainIds.isNotEmpty ? _selectedValueChainIds : null,
        customValueChains: _customValueChains.isNotEmpty ? _customValueChains : null,
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
            content: Text('${_language == 'en' ? 'Failed to update profile' : 'Zaphwanya kusintha mbiri'}: ${ErrorUtils.getFriendlyErrorMessage(e, _language)}'),
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
          _language == 'en' ? 'Edit Business Profile' : 'Sinthani Mbiri',
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
                Icons.edit_note_rounded,
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
                    _language == 'en' ? 'Update Business Profile' : 'Sinthani Mbiri ya Bizinesi',
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._categories.map((cat) {
                  final selected = _selectedCategoryIds.contains(cat.id);
                  return FilterChip(
                    label: Text(cat.name, style: GoogleFonts.poppins(fontSize: 12)),
                    selected: selected,
                    onSelected: (val) => setState(() {
                      if (val && cat.id != null) _selectedCategoryIds.add(cat.id!);
                      else if (!val && cat.id != null) _selectedCategoryIds.remove(cat.id!);
                    }),
                    selectedColor: kPrimaryColor.withOpacity(0.15),
                    checkmarkColor: kPrimaryColor,
                    side: BorderSide(color: selected ? kPrimaryColor : Colors.grey[300]!),
                  );
                }),
                ..._customCategories.map((name) {
                  return Chip(
                    label: Text(name, style: GoogleFonts.poppins(fontSize: 12)),
                    backgroundColor: kPrimaryColor.withOpacity(0.1),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(() => _customCategories.remove(name)),
                    side: BorderSide(color: kPrimaryColor.withOpacity(0.3)),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customCategoryController,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _language == 'en' ? 'Add custom category...' : 'Onjezani mtundu wina...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final text = _customCategoryController.text.trim();
                    if (text.isNotEmpty && !_customCategories.contains(text)) {
                      setState(() {
                        _customCategories.add(text);
                        _customCategoryController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(_language == 'en' ? 'Add' : 'Onjezani', style: GoogleFonts.poppins(fontSize: 13)),
                ),
              ],
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._valueChains.map((vc) {
                final id = vc['id'] as int;
                final name = vc['name'] as String? ?? '';
                final selected = _selectedValueChainIds.contains(id);
                return FilterChip(
                  label: Text(name, style: GoogleFonts.poppins(fontSize: 12)),
                  selected: selected,
                  onSelected: (val) => setState(() {
                    if (val) _selectedValueChainIds.add(id);
                    else _selectedValueChainIds.remove(id);
                  }),
                  selectedColor: kPrimaryColor.withOpacity(0.15),
                  checkmarkColor: kPrimaryColor,
                  side: BorderSide(color: selected ? kPrimaryColor : Colors.grey[300]!),
                );
              }),
              ..._customValueChains.map((name) {
                return Chip(
                  label: Text(name, style: GoogleFonts.poppins(fontSize: 12)),
                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() => _customValueChains.remove(name)),
                  side: BorderSide(color: kPrimaryColor.withOpacity(0.3)),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customValueChainController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _language == 'en' ? 'Add custom value chain...' : 'Onjezani nzere yina...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final text = _customValueChainController.text.trim();
                  if (text.isNotEmpty && !_customValueChains.contains(text)) {
                    setState(() {
                      _customValueChains.add(text);
                      _customValueChainController.clear();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(_language == 'en' ? 'Add' : 'Onjezani', style: GoogleFonts.poppins(fontSize: 13)),
              ),
            ],
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
              child: Text(_language == 'en' ? 'Add Item' : 'Onjezani'),
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
            initialValue: _offerings[index]['name'],
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: _getInputDecoration('Name', Icons.label_rounded).copyWith(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) => _offerings[index]['name'] = value,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _offerings[index]['description'],
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
                  initialValue: _offerings[index]['price']?.toString() ?? '',
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
                  initialValue: _offerings[index]['unit'],
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _getInputDecoration('Unit', Icons.scale_rounded).copyWith(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => _offerings[index]['unit'] = value,
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
