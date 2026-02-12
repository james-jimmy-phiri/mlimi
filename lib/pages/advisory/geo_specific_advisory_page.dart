import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/nutrient_models.dart';
import 'package:mlimi/services/nutrient/nutrient_service.dart';
import 'package:mlimi/services/nutrient_storage_service.dart';
import 'package:mlimi/pages/advisory/widgets/nutrient_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mlimi/services/farmer/farmer_service.dart';

class GeoSpecificAdvisoryPage extends StatefulWidget {
  const GeoSpecificAdvisoryPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialHhid,
  });

  final String? initialLatitude;
  final String? initialLongitude;
  final String? initialHhid;

  @override
  State<GeoSpecificAdvisoryPage> createState() =>
      _GeoSpecificAdvisoryPageState();
}

class _GeoSpecificAdvisoryPageState extends State<GeoSpecificAdvisoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _hhidController = TextEditingController();
  final _phoneController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _landSizeController = TextEditingController(text: '1');

  final _service = NutrientService();
  final _farmerService = FarmerService();
  final _storageService = NutrientStorageService();
  final _storage = GetStorage();

  String _gender = '';
  String _language = 'en';
  String _landUnit = 'ha';
  bool _shortSms = true;
  bool _isGenerating = false;
  bool _isSending = false;
  String _statusMessage = 'Status updates will appear here.';

  NutrientRecommendationResult? _result;

  List<String> get _genders => ['Female', 'Male', 'Other/Prefer not to say'];
  final _languages = const [
    {'label': 'English', 'value': 'en'},
    {'label': 'Chichewa', 'value': 'ny'},
  ];

  @override
  void initState() {
    super.initState();
    _language = _storage.read('language') ?? 'en';
    _phoneController.text = _storage.read('phone') ?? '';
    
    _farmerService.loadFarmers();

    // Pre-fill from initial params
    if (widget.initialLatitude != null) {
      _latitudeController.text = widget.initialLatitude!;
    }
    if (widget.initialLongitude != null) {
      _longitudeController.text = widget.initialLongitude!;
    }
    if (widget.initialHhid != null) {
      _hhidController.text = widget.initialHhid!;
    }
  }

  @override
  void dispose() {
    _hhidController.dispose();
    _phoneController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _landSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildFormCard(theme),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: _ActionButtons(
                      isGenerating: _isGenerating,
                      isSending: _isSending,
                      hasResult: _result != null,
                      onGenerate: _generateRecommendation,
                      onSendSms: () => _sendMessage('sms'),
                      onSendWhatsApp: () => _sendMessage('whatsapp'),
                      onDownload: _downloadCsv,
                      onSave: _saveRecord,
                    language: _language,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                    child: _StatusPanel(message: _statusMessage),
                  ),
                  const SizedBox(height: 24),
                  if (_result != null) ...[
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: NutrientRecommendationSummary(result: _result!),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: NutrientSmsPreview(bundle: _result!.sms),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      child: NutrientDataTableCard(result: _result!),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      backgroundColor: kPrimaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPrimaryColor,
                kPrimaryColor.withOpacity(0.8),
                const Color(0xFF00695C),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _language == 'en'
                          ? 'Nutrient Advisor'
                          : 'Ulangizi wa Nthaka',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _language == 'en'
                          ? 'Site-specific prescriptions based on soil data.'
                          : 'Ulangizi wa fetereza malingana ndi nthaka yanu.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormSectionTitle(
              title: _language == 'en' ? 'Farmer Details' : 'Mbiri ya Mlimi',
              icon: FontAwesomeIcons.user,
            ),
            const SizedBox(height: 20),
            _ModernTextField(
              controller: _hhidController,
              label: 'Household ID',
              icon: FontAwesomeIcons.qrcode,
              validator: (value) {
                if ((value == null || value.trim().isEmpty) &&
                    (_latitudeController.text.isEmpty ||
                        _longitudeController.text.isEmpty)) {
                  return 'Required if location is missing';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _ModernTextField(
              controller: _phoneController,
              label: 'Phone Number (Optional)',
              icon: FontAwesomeIcons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value.trim())) {
                  return 'Invalid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FormSectionTitle(
                  title: _language == 'en' ? 'Location Data' : 'Malo',
                  icon: FontAwesomeIcons.locationDot,
                ),
                TextButton.icon(
                  onPressed: _useGpsLocation,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: Text(
                    'Use GPS',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ModernTextField(
                    controller: _longitudeController,
                    label: 'Longitude',
                    icon: FontAwesomeIcons.globe,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ModernTextField(
                    controller: _latitudeController,
                    label: 'Latitude',
                    icon: FontAwesomeIcons.globe,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _FormSectionTitle(
              title: _language == 'en' ? 'Preferences' : 'Zokonda',
              icon: FontAwesomeIcons.sliders,
            ),
            const SizedBox(height: 20),
            _ModernDropdown(
              label: 'Gender',
              icon: FontAwesomeIcons.venusMars,
              value: _gender.isEmpty ? null : _gender,
              items: _genders,
              onChanged: (val) => setState(() => _gender = val ?? ''),
            ),
            const SizedBox(height: 16),
            _ModernDropdown(
              label: 'Language',
              icon: FontAwesomeIcons.language,
              value: _language,
              items: _languages.map((l) => l['value']!).toList(),
              displayItems: _languages.map((l) => l['label']!).toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() => _language = val);
                _storage.write('language', val);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _ModernTextField(
                    controller: _landSizeController,
                    label: 'Land Size',
                    icon: FontAwesomeIcons.ruler,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final numValue = double.tryParse(
                          value?.replaceAll(',', '.') ?? '');
                      if (numValue == null || numValue <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _ModernDropdown(
                    label: 'Unit',
                    value: _landUnit,
                    items: const ['ha', 'ac'],
                    displayItems: const ['Ha', 'Acres'],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _landUnit = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              activeColor: kPrimaryColor,
              title: Text(
                'Short SMS',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              subtitle: Text(
                'Condense text for cheaper SMS',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              value: _shortSms,
              onChanged: (value) => setState(() => _shortSms = value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateRecommendation() async {
    if (_isGenerating) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _statusMessage = 'Please fix the highlighted fields.';
      });
      return;
    }
    setState(() {
      _isGenerating = true;
      _statusMessage = 'Generating recommendation...';
      _result = null;
    });

    try {
      String hhid = _hhidController.text.trim();
      
      // If HHID is empty, try to find farmer by location
      if (hhid.isEmpty) {
        final lat = double.tryParse(_latitudeController.text.trim());
        final long = double.tryParse(_longitudeController.text.trim());
        
        if (lat != null && long != null) {
          setState(() => _statusMessage = 'Looking up farmer...');
          final farmer = _farmerService.findNearestFarmer(lat, long);
          if (farmer != null) {
            hhid = farmer.householdId;
            _showSnack('Identified farmer: ${farmer.farmerName}');
          } else {
            throw NutrientException('No farmer found at this location. Please enter Household ID.');
          }
        } else {
           throw NutrientException('Location or Household ID required.');
        }
      }

      final request = NutrientRecommendationRequest(
        hhid: hhid,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        language: _language,
        landUnit: _landUnit,
        landValue:
            double.tryParse(_landSizeController.text.replaceAll(',', '.')) ??
                1,
        shortSms: _shortSms,
        gender: _gender,
        newLongitude: _longitudeController.text.trim().isEmpty
            ? null
            : _longitudeController.text.trim(),
        newLatitude: _latitudeController.text.trim().isEmpty
            ? null
            : _latitudeController.text.trim(),
      );

      final response = await _service.generateRecommendation(request);
      setState(() {
        _result = response;
        _statusMessage = _language == 'en'
            ? 'Recommendation ready.'
            : 'Ulangizi wapezeka.';
      });
    } on NutrientException catch (error) {
      _showSnack(error.message);
      setState(() => _statusMessage = error.message);
    } catch (error) {
      const fallback = 'Something went wrong. Please try again.';
      _showSnack(fallback);
      setState(() => _statusMessage = fallback);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _sendMessage(String channel) async {
    if (_isSending || _result == null) return;
    final recommendationId = _result?.recommendationId;
    if (recommendationId == null) {
      _showSnack('Generate a recommendation first.');
      return;
    }
    setState(() {
      _isSending = true;
      _statusMessage = 'Sending via ${channel.toUpperCase()}...';
    });
    try {
      final response = await _service.sendRecommendation(
        recommendationId: recommendationId,
        channel: channel,
        language: _language,
        shortSms: _shortSms,
      );
      setState(() => _statusMessage = response.display);
      _showSnack(response.display,
          isError: !response.ok, details: response.reason);
    } on NutrientException catch (error) {
      setState(() => _statusMessage = error.message);
      _showSnack(error.message);
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _useGpsLocation() async {
    setState(() => _statusMessage = 'Getting GPS location...');
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Location services are disabled.', isError: true);
        setState(() => _statusMessage = 'Location services disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('Location permissions are denied.', isError: true);
          setState(() => _statusMessage = 'Location permissions denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnack('Location permissions are permanently denied.', isError: true);
        setState(() => _statusMessage = 'Location permissions permanently denied.');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();

      setState(() => _statusMessage = 'Finding nearest farmer...');
      final nearestFarmer = _farmerService.findNearestFarmer(
          position.latitude, position.longitude);

      if (nearestFarmer != null) {
        _hhidController.text = nearestFarmer.householdId;
        if (_genders.contains(nearestFarmer.gender)) {
          setState(() => _gender = nearestFarmer.gender);
        }
        _showSnack('Found nearest farmer: ${nearestFarmer.farmerName}');
        setState(() => _statusMessage =
            'Found nearest farmer: ${nearestFarmer.farmerName}');
      } else {
        _showSnack('No nearby farmer found in database.');
        setState(() => _statusMessage = 'No nearby farmer found.');
      }
    } catch (e) {
      _showSnack('Error getting location: $e', isError: true);
      setState(() => _statusMessage = 'Error getting location.');
    }
  }

  Future<void> _downloadCsv() async {
    if (_result?.table.isEmpty ?? true) {
      _showSnack('No data to download yet.');
      return;
    }
    try {
      final csv = _result!.toCsv();
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file =
          File('${directory.path}/nutrient_recommendation_$timestamp.csv');
      await file.writeAsString(csv);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Site-specific nutrient recommendation',
        ),
      );
      setState(() => _statusMessage = 'CSV exported successfully.');
    } catch (error) {
      _showSnack('Failed to export CSV.');
      setState(() => _statusMessage = 'Failed to export CSV.');
    }
  }

  Future<void> _saveRecord() async {
    if (_result == null) return;

    final success = await _storageService.saveRecord(_result!);
    if (success) {
      _showSnack(_language == 'en'
          ? 'Recommendation saved successfully!'
          : 'Ulangizi wasungidwa bwino!');
    } else {
      _showSnack(
        _language == 'en'
            ? 'This recommendation is already saved.'
            : 'Ulangizi uwu wasungidwa kale.',
        isError: true,
      );
    }
  }

  void _showSnack(String message, {bool isError = false, String? details}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: GoogleFonts.poppins()),
            if (details != null)
              Text(details, style: GoogleFonts.poppins(fontSize: 12)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isError ? Colors.red[400] : kPrimaryColor,
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kPrimaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kPrimaryColor,
          ),
        ),
      ],
    );
  }
}

class _ModernTextField extends StatelessWidget {
  const _ModernTextField({
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400], size: 18) : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPrimaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _ModernDropdown extends StatelessWidget {
  const _ModernDropdown({
    required this.label,
    this.icon,
    required this.value,
    required this.items,
    this.displayItems,
    required this.onChanged,
  });

  final String label;
  final IconData? icon;
  final String? value;
  final List<String> items;
  final List<String>? displayItems;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: List.generate(items.length, (index) {
        return DropdownMenuItem(
          value: items[index],
          child: Text(
            displayItems != null ? displayItems![index] : items[index],
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        );
      }),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400], size: 18) : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPrimaryColor, width: 1.5),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isGenerating,
    required this.isSending,
    required this.hasResult,
    required this.onGenerate,
    required this.onSendSms,
    required this.onSendWhatsApp,
    required this.onDownload,
    required this.onSave,
    required this.language,
  });

  final bool isGenerating;
  final bool isSending;
  final bool hasResult;
  final VoidCallback onGenerate;
  final VoidCallback onSendSms;
  final VoidCallback onSendWhatsApp;
  final VoidCallback onDownload;
  final VoidCallback onSave;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isGenerating ? null : onGenerate,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: kPrimaryColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isGenerating
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.wandMagicSparkles),
                      const SizedBox(width: 8),
                      Text(
                        'Generate Recommendation',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (hasResult) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  icon: FontAwesomeIcons.commentSms,
                  label: 'SMS',
                  color: Colors.blue,
                  onPressed: isSending ? null : onSendSms,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SecondaryButton(
                  icon: FontAwesomeIcons.whatsapp,
                  label: 'WhatsApp',
                  color: Colors.green,
                  onPressed: isSending ? null : onSendWhatsApp,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDownload,
              icon: const Icon(FontAwesomeIcons.download),
              label: Text('Download CSV', style: GoogleFonts.poppins()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(FontAwesomeIcons.floppyDisk),
              label: Text(
                language == 'en' ? 'Save Record' : 'Sungani Cholemba',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor.withOpacity(0.1),
                foregroundColor: kPrimaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(FontAwesomeIcons.circleInfo,
                color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
