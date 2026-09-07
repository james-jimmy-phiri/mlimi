import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/services/language_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'aggregation_details_screen.dart';

class StartAggregationScreen extends StatefulWidget {
  const StartAggregationScreen({Key? key}) : super(key: key);

  @override
  State<StartAggregationScreen> createState() => _StartAggregationScreenState();
}

class _StartAggregationScreenState extends State<StartAggregationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitPriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedValueChainId;
  int? _selectedMeasureId = 1; // Default to Kg
  DateTime? _expectedSupplyDate;
  File? _selectedImage;

  // Loaded from GetStorage (group logged-in account)
  late final int? _groupId;
  late final String _groupName;

  @override
  void initState() {
    super.initState();
    final storage = GetStorage();
    _groupId = storage.read('client_id');
    _groupName = storage.read('name') ?? 'My Group';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AggregationProvider>(context, listen: false);
      if (provider.valueChains.isEmpty) {
        provider.fetchValueChains();
      }
    });
  }

  @override
  void dispose() {
    _unitPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1024);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedSupplyDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: kPrimaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expectedSupplyDate = picked);
  }

  void _submit() async {
    final language = GetStorage().read('language') ?? 'en';
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_groupId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language == 'ny' ? 'Kulowani kaye monga gulu' : 'Please log in as a group account first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = Provider.of<AggregationProvider>(context, listen: false);

      Map<String, dynamic> payload = {
        'group_id': _groupId,
        'value_chain_id': _selectedValueChainId,
        'measure_id': _selectedMeasureId,
        'unit_price': _unitPriceController.text.isNotEmpty
            ? double.tryParse(_unitPriceController.text) ?? 0
            : null,
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'expected_supply_date': _expectedSupplyDate != null
            ? '${_expectedSupplyDate!.year}-${_expectedSupplyDate!.month.toString().padLeft(2, '0')}-${_expectedSupplyDate!.day.toString().padLeft(2, '0')}'
            : null,
      };

      // Remove null values — backend doesn't need them
      payload.removeWhere((k, v) => v == null);

      final newAgg = await provider.createAggregation(
        payload,
        imagePath: _selectedImage?.path,
      );

      if (newAgg != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageService.getText('successStart', language)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Navigate directly to the management/detail screen for the new aggregation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AggregationDetailsScreen(aggregationId: newAgg.id!),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? LanguageService.getText('failedStart', language)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = GetStorage().read('language') ?? 'en';
    final isNy = language == 'ny';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        title: Text(
          isNy ? 'Yambani Zosonkhanitsa' : 'Start New Aggregation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Consumer<AggregationProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header card
                  _buildHeaderCard(isNy),
                  const SizedBox(height: 20),

                  // ─── Group info (read-only) ───────────────────────────────
                  _buildSectionLabel(isNy ? 'Gulu' : 'Farmer Group'),
                  const SizedBox(height: 8),
                  _buildGroupCard(isNy),
                  const SizedBox(height: 20),

                  // ─── Value Chain ─────────────────────────────────────────
                  _buildSectionLabel(isNy ? 'Msewu wa Mtengo' : 'Value Chain / Commodity'),
                  const SizedBox(height: 8),
                  provider.isLoadingValueChains
                      ? const LinearProgressIndicator()
                      : _buildValueChainDropdown(provider, language),
                  const SizedBox(height: 20),

                  // ─── Measurement Unit ────────────────────────────────────
                  _buildSectionLabel(isNy ? 'Muyeso' : 'Unit of Measure'),
                  const SizedBox(height: 8),
                  _buildMeasureDropdown(language),
                  const SizedBox(height: 20),

                  // ─── Unit Price & Supply Date ─────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel(isNy ? 'Mtengo pa Yuniti (MWK)' : 'Price per Unit (MWK)'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _unitPriceController,
                              hint: '0.00',
                              icon: Icons.payments_outlined,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              required: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel(isNy ? 'Tsiku la Kuperekedwa' : 'Expected Supply Date'),
                            const SizedBox(height: 8),
                            _buildDateField(isNy),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── Description ─────────────────────────────────────────
                  _buildSectionLabel(isNy ? 'Mfotokozero ya Zokolola' : 'Product Description'),
                  const SizedBox(height: 8),
                  _buildDescriptionField(language),
                  const SizedBox(height: 20),

                  // ─── Product Image ───────────────────────────────────────
                  _buildSectionLabel(isNy ? 'Chithunzi cha Zokolola' : 'Product Image (Optional)'),
                  const SizedBox(height: 8),
                  _buildImagePicker(isNy),
                  const SizedBox(height: 36),

                  // ─── Submit Button ───────────────────────────────────────
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    onPressed: provider.isActionLoading ? null : _submit,
                    child: provider.isActionLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            isNy ? 'Yekezani Zosonkhanitsa' : 'Initialize Aggregation',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Widget helpers ──────────────────────────────────────────────────────────

  Widget _buildHeaderCard(bool isNy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor.withValues(alpha: 0.85), kPrimaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNy ? 'Yambani Zosonkhanitsa Zatsopano' : 'Start New Aggregation Pool',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  isNy ? 'Ikani zida za zosonkhanitsa pamodzi.' : 'Initialize a collective selling process for your group.',
                  style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(bool isNy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: kPrimaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.groups_2_rounded, color: kPrimaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _groupName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                ),
                Text(
                  isNy ? 'Gulu lolembetsa' : 'Registered Farmer Group',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (_groupId == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Not set',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
          else
            Icon(Icons.verified_rounded, color: kPrimaryColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
    );
  }

  Widget _buildValueChainDropdown(AggregationProvider provider, String language) {
    final groups = provider.valueChainsBySector;
    final List<DropdownMenuItem<int>> items = [];

    final sectorOrder = ['crops', 'livestock', 'honey'];
    final sectorLabels = {'crops': '🌾 Crops', 'livestock': '🐄 Livestock', 'honey': '🍯 Honey'};

    int headerIdCounter = -1;

    for (final sector in sectorOrder) {
      final vcs = groups[sector] ?? [];
      if (vcs.isEmpty) continue;
      // Add disabled header with unique negative ID
      items.add(DropdownMenuItem<int>(
        enabled: false,
        value: headerIdCounter--,
        child: Text(
          sectorLabels[sector] ?? sector.toUpperCase(),
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: kPrimaryColor, letterSpacing: 0.5),
        ),
      ));
      for (final vc in vcs) {
        items.add(DropdownMenuItem<int>(
          value: vc.id,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(vc.name, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
          ),
        ));
      }
    }

    // Fallback: show remaining sectors not in predefined order
    for (final sector in groups.keys) {
      if (!sectorOrder.contains(sector)) {
        final vcs = groups[sector]!;
        if (vcs.isEmpty) continue;
        final displaySector = sector.isEmpty ? 'OTHER' : sector.toUpperCase();
        items.add(DropdownMenuItem<int>(
          enabled: false,
          value: headerIdCounter--,
          child: Text(
            '  $displaySector',
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ));
        for (final vc in vcs) {
          items.add(DropdownMenuItem<int>(
            value: vc.id,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(vc.name, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
            ),
          ));
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonFormField<int>(
        decoration: _inputDecoration(
          language == 'ny' ? 'Sankhani Msewu wa Mtengo' : 'Select Value Chain',
          Icons.eco_rounded,
        ),
        initialValue: _selectedValueChainId,
        items: items,
        onChanged: (val) {
          if (val != null && val >= 0) setState(() => _selectedValueChainId = val);
        },
        validator: (val) => (val == null || val < 0)
            ? LanguageService.getText('required', language)
            : null,
        isExpanded: true,
      ),
    );
  }

  Widget _buildMeasureDropdown(String language) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonFormField<int>(
        decoration: _inputDecoration(LanguageService.getText('measurementUnit', language), Icons.scale_rounded),
        // ignore: deprecated_member_use
        value: _selectedMeasureId,
        items: [
          DropdownMenuItem(value: 1, child: Text(LanguageService.getText('kilogramsKg', language), style: GoogleFonts.poppins())),
          DropdownMenuItem(value: 2, child: Text(LanguageService.getText('tonnesT', language), style: GoogleFonts.poppins())),
          DropdownMenuItem(value: 3, child: Text(LanguageService.getText('bags', language), style: GoogleFonts.poppins())),
        ],
        onChanged: (val) => setState(() => _selectedMeasureId = val),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(hint, icon),
        validator: required
            ? (val) => (val == null || val.isEmpty)
                ? LanguageService.getText('required', GetStorage().read('language') ?? 'en')
                : null
            : null,
      ),
    );
  }

  Widget _buildDateField(bool isNy) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: kPrimaryColor, size: 18),
            const SizedBox(width: 10),
            Text(
              _expectedSupplyDate == null
                  ? (isNy ? 'Sankhani tsiku' : 'Select date')
                  : '${_expectedSupplyDate!.day}/${_expectedSupplyDate!.month}/${_expectedSupplyDate!.year}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: _expectedSupplyDate == null ? Colors.grey[400] : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(String language) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 3,
        decoration: _inputDecoration(
          language == 'ny' ? 'Mfotokozero ya mtundu, kayendedwe...' : 'Describe quality, variety, and relevant details...',
          Icons.description_outlined,
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isNy) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: _selectedImage != null ? 180 : 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3), style: BorderStyle.solid),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.file(_selectedImage!, width: double.infinity, height: 180, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: kPrimaryColor.withValues(alpha: 0.5), size: 32),
                  const SizedBox(height: 6),
                  Text(
                    isNy ? 'Onjezani chithunzi' : 'Tap to add a photo',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
      prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: kPrimaryColor.withValues(alpha: 0.5), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
