import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/nutrient_models.dart';

class NutrientRecommendationSummary extends StatelessWidget {
  const NutrientRecommendationSummary({super.key, required this.result});
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
            NutrientResultCard(
              title: 'District',
              value: district,
              icon: FontAwesomeIcons.map,
              color: Colors.purple,
            ),
            NutrientResultCard(
              title: 'Area (ha)',
              value: area,
              icon: FontAwesomeIcons.rulerCombined,
              color: Colors.orange,
            ),
            NutrientResultCard(
              title: 'Target Yield',
              value: '$yieldLow - $yieldHigh',
              unit: 't/ha',
              icon: FontAwesomeIcons.bullseye,
              color: Colors.blue,
            ),
            NutrientResultCard(
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

class NutrientResultCard extends StatelessWidget {
  const NutrientResultCard({
    super.key,
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
      padding: const EdgeInsets.all(14),
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

class NutrientSmsPreview extends StatelessWidget {
  const NutrientSmsPreview({super.key, required this.bundle});
  final NutrientSmsBundle bundle;

  @override
  Widget build(BuildContext context) {
    final previews = [
      if (bundle.smsEn != null)
        NutrientSmsBubble(title: 'English (Full)', body: bundle.smsEn!, isOut: true),
      if (bundle.smsNy != null)
        NutrientSmsBubble(title: 'Chichewa (Full)', body: bundle.smsNy!, isOut: true),
      if (bundle.smsShortEn != null)
        NutrientSmsBubble(title: 'English (Short)', body: bundle.smsShortEn!, isOut: true),
      if (bundle.smsShortNy != null)
        NutrientSmsBubble(title: 'Chichewa (Short)', body: bundle.smsShortNy!, isOut: true),
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

class NutrientSmsBubble extends StatelessWidget {
  const NutrientSmsBubble({super.key, required this.title, required this.body, required this.isOut});
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

class NutrientDataTableCard extends StatelessWidget {
  const NutrientDataTableCard({super.key, required this.result});
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
