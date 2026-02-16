import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/nutrient_models.dart';
import 'package:mlimi/pages/advisory/widgets/nutrient_widgets.dart';
import 'package:mlimi/services/farmer/farmer_service.dart';

class SavedNutrientDetailsPage extends StatefulWidget {
  const SavedNutrientDetailsPage({super.key, required this.record});
  final NutrientRecommendationResult record;

  @override
  State<SavedNutrientDetailsPage> createState() => _SavedNutrientDetailsPageState();
}

class _SavedNutrientDetailsPageState extends State<SavedNutrientDetailsPage> {
  final _farmerService = FarmerService();
  String _farmerName = 'Farmer';
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _language = GetStorage().read('language') ?? 'en';
    _loadFarmer();
  }

  Future<void> _loadFarmer() async {
    await _farmerService.loadFarmers();
    // Assuming barcode_household stores the ID. If not, fallback to default.
    final hhid = widget.record.stringField('barcode_household');
    if (hhid != null && hhid.isNotEmpty) {
      final farmer = _farmerService.findFarmerByHhid(hhid);
      if (farmer != null && mounted) {
        setState(() {
          _farmerName = farmer.farmerName;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Recommendation Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: NutrientRecommendationSummary(
                result: widget.record,
                farmerName: _farmerName,
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 600),
              child: VisualNutrientAdvisory(
                result: widget.record,
                language: _language,
                farmerName: _farmerName,
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 600),
              child: NutrientSmsPreview(
                bundle: widget.record.sms,
                language: _language,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
