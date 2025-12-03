import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/nutrient_models.dart';
import 'package:mlimi/services/nutrient/nutrient_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                      child: _RecommendationSummary(result: _result!),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: _SmsPreview(bundle: _result!.sms),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      child: _DataTableCard(result: _result!),
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
      padding: const EdgeInsets.all(24),
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
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Required'
                  : null,
            ),
            const SizedBox(height: 16),
            _ModernTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: FontAwesomeIcons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Required';
                if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value.trim())) {
                  return 'Invalid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _FormSectionTitle(
              title: _language == 'en' ? 'Location Data' : 'Malo',
              icon: FontAwesomeIcons.locationDot,
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
      final request = NutrientRecommendationRequest(
        hhid: _hhidController.text.trim(),
        phone: _phoneController.text.trim(),
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
      style: GoogleFonts.poppins(fontSize: 14),
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
  });

  final bool isGenerating;
  final bool isSending;
  final bool hasResult;
  final VoidCallback onGenerate;
  final VoidCallback onSendSms;
  final VoidCallback onSendWhatsApp;
  final VoidCallback onDownload;

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

class _RecommendationSummary extends StatelessWidget {
  const _RecommendationSummary({required this.result});
  final NutrientRecommendationResult result;

  @override
  Widget build(BuildContext context) {
    final district = result.stringField('District') ?? '(unknown)';
    final area = result.stringField('Area_ha') ?? '-';
    final yieldLow = result.stringField('Rainfed_Yield_Target_Low_t_ha') ?? '-';
    final yieldHigh =
        result.stringField('Rainfed_Yield_Target_High_t_ha') ?? '-';
    final predicted = result.stringField('Predicted_Yield_t_ha') ?? '-';
    final optionCost =
        result.stringField('Option1_Est_Cost_USD_per_area') ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analysis Results',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _ResultCard(
              title: 'District',
              value: district,
              icon: FontAwesomeIcons.map,
              color: Colors.purple,
            ),
            _ResultCard(
              title: 'Area (ha)',
              value: area,
              icon: FontAwesomeIcons.rulerCombined,
              color: Colors.orange,
            ),
            _ResultCard(
              title: 'Target Yield',
              value: '$yieldLow - $yieldHigh',
              unit: 't/ha',
              icon: FontAwesomeIcons.bullseye,
              color: Colors.blue,
            ),
            _ResultCard(
              title: 'Predicted',
              value: predicted,
              unit: 't/ha',
              icon: FontAwesomeIcons.chartLine,
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[600]!, Colors.green[800]!],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(FontAwesomeIcons.wallet, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated Cost',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '\$$optionCost',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Option 1 (USD)',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit!,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SmsPreview extends StatelessWidget {
  const _SmsPreview({required this.bundle});
  final NutrientSmsBundle bundle;

  @override
  Widget build(BuildContext context) {
    final previews = [
      if (bundle.smsEn != null)
        _SmsBubble(title: 'English (Full)', body: bundle.smsEn!, isOut: true),
      if (bundle.smsShortEn != null)
        _SmsBubble(title: 'English (Short)', body: bundle.smsShortEn!, isOut: true),
      if (bundle.smsNy != null)
        _SmsBubble(title: 'Chichewa (Full)', body: bundle.smsNy!, isOut: true),
      if (bundle.smsShortNy != null)
        _SmsBubble(title: 'Chichewa (Short)', body: bundle.smsShortNy!, isOut: true),
    ];

    if (previews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message Previews',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5EA), // iOS message bg color style
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: previews,
          ),
        ),
      ],
    );
  }
}

class _SmsBubble extends StatelessWidget {
  const _SmsBubble({required this.title, required this.body, required this.isOut});
  final String title;
  final String body;
  final bool isOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isOut ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOut ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isOut ? 16 : 4),
                bottomRight: Radius.circular(isOut ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              body,
              style: GoogleFonts.poppins(
                color: isOut ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataTableCard extends StatelessWidget {
  const _DataTableCard({required this.result});
  final NutrientRecommendationResult result;

  @override
  Widget build(BuildContext context) {
    final rows = result.toDisplayRows();
    if (rows.isEmpty) return const SizedBox.shrink();

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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Prescription',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.grey[200],
              ),
              child: DataTable(
                headingTextStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
                dataTextStyle: GoogleFonts.poppins(
                  color: Colors.grey[800],
                ),
                columns: const [
                  DataColumn(label: Text('Metric')),
                  DataColumn(label: Text('Value')),
                ],
                rows: rows
                    .map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(Text(entry.key)),
                          DataCell(Text(entry.value)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
