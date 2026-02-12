import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/nutrient_models.dart';
import 'package:mlimi/pages/advisory/widgets/nutrient_widgets.dart';

class SavedNutrientDetailsPage extends StatelessWidget {
  const SavedNutrientDetailsPage({super.key, required this.record});
  final NutrientRecommendationResult record;

  @override
  Widget build(BuildContext context) {
    final district = record.stringField('District') ?? 'Unknown';

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
              child: NutrientRecommendationSummary(result: record),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 600),
              child: NutrientSmsPreview(bundle: record.sms),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 600),
              child: NutrientDataTableCard(result: record),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
