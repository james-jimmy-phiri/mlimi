import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/nutrient_models.dart';

class NutrientRecommendationSummary extends StatelessWidget {
  const NutrientRecommendationSummary({
    super.key,
    required this.result,
    required this.farmerName,
  });
  final NutrientRecommendationResult result;
  final String farmerName;

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
          'Analysis Results for $farmerName',
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
          ],
        ),
        const SizedBox(height: 12),
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.all(20),
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [Colors.green[600]!, Colors.green[800]!],
        //     ),
        //     borderRadius: BorderRadius.circular(20),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.green.withOpacity(0.3),
        //         blurRadius: 12,
        //         offset: const Offset(0, 6),
        //       ),
        //     ],
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Row(
        //         children: [
        //            const Icon(FontAwesomeIcons.wallet, color: Colors.white70),
        //           const SizedBox(width: 8),
        //           Text(
        //             'Estimated Cost',
        //             style: GoogleFonts.poppins(
        //               color: Colors.white70,
        //               fontSize: 14,
        //             ),
        //           ),
        //         ],
        //       ),
        //       const SizedBox(height: 4),
        //       Text(
        //         '\$$optionCost',
        //         style: GoogleFonts.poppins(
        //           color: Colors.white,
        //           fontSize: 32,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       Text(
        //         'Option 1 (USD)',
        //         style: GoogleFonts.poppins(
        //           color: Colors.white54,
        //           fontSize: 12,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
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

class NutrientSmsPreview extends StatefulWidget {
  const NutrientSmsPreview({
    super.key,
    required this.bundle,
    required this.language,
  });

  final NutrientSmsBundle bundle;
  final String language;

  @override
  State<NutrientSmsPreview> createState() => _NutrientSmsPreviewState();
}

class _NutrientSmsPreviewState extends State<NutrientSmsPreview> {
  int _selectedIndex = 0; // 0 for Full, 1 for Short

  @override
  Widget build(BuildContext context) {
    final isEnglish = widget.language == 'en';
    
    // Determine which messages to show based on language and selection
    String? messageToShow;
    String title;

    if (isEnglish) {
      if (_selectedIndex == 0) {
        messageToShow = widget.bundle.smsEn;
        title = 'Advisor Message (Full)';
      } else {
        messageToShow = widget.bundle.smsShortEn;
        title = 'Advisor Message (Short)';
      }
    } else {
      if (_selectedIndex == 0) {
        messageToShow = widget.bundle.smsNy;
        title = 'Uthenga wa Ulangizi (Wonse)';
      } else {
        messageToShow = widget.bundle.smsShortNy;
        title = 'Uthenga wa Ulangizi (Mwachidule)';
      }
    }

    if (messageToShow == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEnglish ? 'Message Preview' : 'Uthenga Wanu',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            // Custom Tab Switcher
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton(
                    0,
                    isEnglish ? 'Full' : 'Wonse',
                  ),
                  _buildTabButton(
                    1,
                    isEnglish ? 'Short' : 'Ifupi',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(FontAwesomeIcons.solidMessage,
                        size: 16, color: kPrimaryColor),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                messageToShow,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String text) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? kPrimaryColor : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}


// class NutrientDataTableCard extends StatelessWidget {
//   const NutrientDataTableCard({super.key, required this.result});
//   final NutrientRecommendationResult result;

//   @override
//   Widget build(BuildContext context) {
//     final rows = result.toDisplayRows();
//     if (rows.isEmpty) return const SizedBox.shrink();

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Detailed Prescription',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 16),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Theme(
//               data: Theme.of(context).copyWith(
//                 dividerColor: Colors.grey[200],
//               ),
//               child: DataTable(
//                 headingTextStyle: GoogleFonts.poppins(
//                   fontWeight: FontWeight.bold,
//                   color: kPrimaryColor,
//                 ),
//                 dataTextStyle: GoogleFonts.poppins(
//                   color: Colors.grey[800],
//                 ),
//                 columns: const [
//                   DataColumn(label: Text('Metric')),
//                   DataColumn(label: Text('Value')),
//                 ],
//                 rows: rows
//                     .map(
//                       (entry) => DataRow(
//                         cells: [
//                           DataCell(Text(entry.key)),
//                           DataCell(Text(entry.value)),
//                         ],
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class VisualNutrientAdvisory extends StatelessWidget {
  const VisualNutrientAdvisory({
    super.key,
    required this.result,
    required this.language,
    required this.farmerName,
  });

  final NutrientRecommendationResult result;
  final String language;
  final String farmerName;

  @override
  Widget build(BuildContext context) {
    // Use fallbacks for keys based on identified debug logs
    final nitrogen = result.stringField('StarterN_kg_ha') ?? 
                     result.stringField('Nitrogen_kg_ha') ?? 
                     result.stringField('N_kg_ha') ?? '0';
    final phosphorus = result.stringField('P2O5_kg_ha') ?? 
                       result.stringField('Phosphorus_kg_ha') ?? 
                       result.stringField('P_kg_ha') ?? '0';
    final potassium = result.stringField('K2O_kg_ha') ?? 
                      result.stringField('Potassium_kg_ha') ?? 
                      result.stringField('K_kg_ha') ?? '0';
    final sulphate = result.stringField('S_kg_ha') ?? 
                     result.stringField('Sulphate_kg_ha') ?? 
                     result.stringField('S_kg_ha') ?? '0';
    final varieties = result.stringField('Varieties_Suggested') ?? result.stringField('Varieties') ?? '';

    final isEnglish = language == 'en';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Greeting
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(FontAwesomeIcons.userCheck, color: kPrimaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEnglish
                      ? 'Hello $farmerName, here is your farm plan:'
                      : 'Moni $farmerName, nayi ndondomeko yanu:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // // 1. Soil Requirements Section
        // _buildSectionHeader(
        //   isEnglish ? '1. Soil Requirements' : "1. Zosowa m'nthaka",
        //   FontAwesomeIcons.flask,
        // ),
        // const SizedBox(height: 8),
        // Text(
        //   isEnglish
        //       ? 'To reach your target yield, your soil needs these specific nutrients.'
        //       : 'Kuti mukolole zomwe mukufuna, nthaka yanu ikufunika izi.',
        //   style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
        // ),
        // const SizedBox(height: 16),
        // const SizedBox(height: 16),
        // GridView.count(
        //   crossAxisCount: 2,
        //   shrinkWrap: true,
        //   physics: const NeverScrollableScrollPhysics(),
        //   mainAxisSpacing: 12,
        //   crossAxisSpacing: 12,
        //   childAspectRatio: 1.3,
        //   children: [
        //     _buildNutrientCard('Nitrogen', nitrogen, Colors.blue, 'Nitrogen'),
        //     _buildNutrientCard('Phosphorus', phosphorus, Colors.orange, 'Phosphorus'),
        //     _buildNutrientCard('Potassium', potassium, Colors.red, 'Potassium'),
        //     _buildNutrientCard('Sulphate', sulphate, Colors.amber, 'Sulphate'),
        //   ],
        // ),
        // const SizedBox(height: 32),

        // 2. Fertilizer Options Section
        _buildSectionHeader(
          isEnglish ? '2. Fertilizer Options' : '2. Sankhani Manyowa',
          FontAwesomeIcons.bagShopping,
        ),
        const SizedBox(height: 8),
        Text(
          isEnglish
              ? 'Choose ONE of the following options to meet the requirements above.'
              : 'Sankhani NJIRA IMODZI yokha mwa izi kuti mukwaniritse zofunikirazo.',
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            final options = List.generate(3, (index) {
              final optNum = index + 1;
              final products = result.stringField('Option${optNum}_Products_for_Area');
              final cost = result.stringField('Option${optNum}_Est_Cost_USD_per_area');
              
              if (products == null || products.isEmpty || products == '0') return const SizedBox.shrink();
              
              String optionTitle = 'Option $optNum';
              final prodLower = products.toLowerCase();
              if (prodLower.contains('urea') && prodLower.contains('superphosphate')) {
                optionTitle = 'Urea + Superphosphate';
              } else if (prodLower.contains('npk') && prodLower.contains('superphosphate')) {
                optionTitle = 'NPK + Superphosphate';
              } else if (prodLower.contains('urea')) {
                 optionTitle = isEnglish ? 'Urea Only' : 'Urea Yokha';
              } else if (prodLower.contains('npk')) {
                 optionTitle = 'NPK';
              }

              final colors = [Colors.blue, Colors.green, Colors.purple];
              final color = colors[index % colors.length];

              String desc = products;
              if (cost != null && cost.isNotEmpty && cost != '0' && cost != '0.0') {
                 desc += '\nEstimated Cost: \$$cost';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFertilizerOption(
                  'Option $optNum',
                  optionTitle,
                  desc,
                  color,
                ),
              );
            }).whereType<Padding>().toList();

            if (options.isNotEmpty) {
              return Column(children: options);
            } else {
              // Fallback
              return Column(
                children: [
                  _buildFertilizerOption(
                    'Option 1',
                    isEnglish ? 'Urea Only' : 'Urea Yokha',
                    isEnglish
                        ? 'Apply Urea at 3/8 of a 50kg bag (22 kg).'
                        : 'Thirani Urea matumba 3/8 a 50kg (22 kg).',
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildFertilizerOption(
                    'Option 2',
                    'NPK + Superphosphate',
                    isEnglish
                        ? 'Apply NPK 23:21:0+4S at 43 kg AND Single Superphosphate at 2 and 1/8 bags (103 kg).'
                        : 'Thirani NPK 23:21:0+4S matumba 7/8 (43 kg) NDI Single Superphosphate matumba 2 ndi 1/8 (103 kg).',
                    Colors.green,
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 20),

        // 3. Application Advice Section
        _buildSectionHeader(
          isEnglish ? '3. Application Advice' : '3. Kagwiritsidwe Ntchito',
          FontAwesomeIcons.handHoldingDroplet,
        ),
         
        const SizedBox(height: 16),
        _buildApplicationAdviceDynamic(result, isEnglish),
        const SizedBox(height: 32),

        // 4. Variety Section
        if (varieties.isNotEmpty && varieties != '0') ...[
          _buildSectionHeader(
            isEnglish ? '4. Recommended Varieties' : '4. Mitundu ya Mbewu',
            FontAwesomeIcons.seedling,
          ),
          const SizedBox(height: 16),
          _buildVarietyCardDynamic(varieties, isEnglish),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: kPrimaryColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientCard(String symbol, String value, Color color, String name) {
    String displayValue = value;
    if (value.toLowerCase() == 'none' || value.isEmpty) {
      displayValue = '0'; 
    }

    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withOpacity(0.02),
            ],
          ),
          border: Border.all(color: color.withOpacity(0.12), width: 1.5),
          boxShadow: [
             BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    symbol.substring(0, 1),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              width: 40,
              color: color.withOpacity(0.1),
            ),
            const SizedBox(height: 12),
            Text(
              displayValue,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'kg/ha',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilizerOption(
      String option, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: const AssetImage('assets/images/soil_sample/fertilizer_application_1.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), 
                  BlendMode.darken
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              option,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationAdviceDynamic(NutrientRecommendationResult result, bool isEnglish) {
    final splitTiming = result.stringField('Split_Timing');
    final rhizobia = result.stringField('Rhizobia_Inoculant');
    final limeNote = result.stringField('Lime_Note');

    final bool hasSplitTiming = splitTiming != null && splitTiming.isNotEmpty && splitTiming != '0';
    final bool hasRhizobia = rhizobia != null && rhizobia.isNotEmpty && rhizobia != '0';
    final bool hasLimeNote = limeNote != null && limeNote.isNotEmpty && limeNote != '0';

    if (!hasSplitTiming && !hasRhizobia && !hasLimeNote) {
      // Fallback
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
           boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.asset(
                'assets/images/soil_sample/fertilizer_application_1.jpg',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildAdviceRow(
                isEnglish ? '2-4 Weeks Before' : 'Masabata 2-4 Musanadzale',
                isEnglish ? 'Apply lime before planting' : 'Thirani Laimu Musanadzale ',
                Icons.calendar_today,
                Colors.orange,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.asset(
              'assets/images/soil_sample/fertilizer_application_1.jpg',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasLimeNote)
                  _buildAdviceRow(
                    isEnglish ? 'Lime Preparation' : 'Kukonzekera Laimu',
                    limeNote!,
                    Icons.science,
                    Colors.orange,
                  ),
                if (hasSplitTiming)
                  Padding(
                    padding: EdgeInsets.only(top: hasLimeNote ? 16.0 : 0.0),
                    child: _buildAdviceRow(
                      isEnglish ? 'Application Timing' : 'Nthawi Yothira',
                      splitTiming!,
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                  ),
                if (hasRhizobia)
                   Padding(
                    padding: EdgeInsets.only(top: (hasLimeNote || hasSplitTiming) ? 16.0 : 0.0),
                    child: _buildAdviceRow(
                      isEnglish ? 'Seed Treatment' : 'Kusamalira Mbewu',
                      rhizobia!,
                      FontAwesomeIcons.seedling,
                      Colors.green,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceRow(String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVarietyCardDynamic(String varietiesSuggested, bool isEnglish) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.asset(
              'assets/images/soil_sample/soybean_varieties.JPG',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnglish ? 'Recommended Variety' : 'Mtundu Wovomerezeka',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _buildVarietyItemDynamic(varietiesSuggested),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVarietyItemDynamic(String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.grass, color: Colors.green[700], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
