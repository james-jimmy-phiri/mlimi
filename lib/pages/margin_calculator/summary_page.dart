import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/margin_record.dart';
import 'package:mlimi/services/margin_storage_service.dart';
import 'package:mlimi/utils/app_translations.dart';
import 'package:uuid/uuid.dart';

class SummaryPage extends StatelessWidget {
  final String cropName;
  final double fieldSize;
  final double sellingPrice;
  final List<SectionSummary> sectionSummaries;
  final double totalExpenditure;
  final double totalIncome;
  final double profitMargin;
  final double averageYiled;
  final String cropImage;
  final bool isViewOnly;

  SummaryPage({
    required this.cropName,
    required this.fieldSize,
    required this.sellingPrice,
    required this.sectionSummaries,
    required this.totalExpenditure,
    required this.totalIncome,
    required this.profitMargin,
    required this.averageYiled,
    required this.cropImage,
    this.isViewOnly = false,
  });

  Future<void> _saveRecord(BuildContext context) async {
    final record = MarginRecord(
      id: const Uuid().v4(),
      date: DateTime.now(),
      cropName: cropName,
      fieldSize: fieldSize,
      sellingPrice: sellingPrice,
      totalIncome: totalIncome,
      totalExpenditure: totalExpenditure,
      profitMargin: profitMargin,
      averageYield: averageYiled,
      cropImage: cropImage,
      sectionSummaries: sectionSummaries
          .map((s) => SectionSummaryRecord(
                sectionName: s.sectionName,
                contentItem: s.contentItem,
                inputValue: s.inputValue,
                rateAcre: s.rateAcre,
                total: s.total,
              ))
          .toList(),
    );

    bool success = await MarginStorageService().saveRecord(record);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.getString('record_saved')),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Record already saved!"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showSectionDetails(BuildContext context, SectionSummary section) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            section.sectionName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(AppTranslations.getString('item'), section.contentItem),
              Divider(),
              _buildDetailRow(AppTranslations.getString('input_value'), "MWK ${section.inputValue}"),
              Divider(),
              _buildDetailRow(AppTranslations.getString('rate_per_acre'), "MWK ${section.rateAcre}/Acre"),
              Divider(),
              _buildDetailRow(AppTranslations.getString('total'), "MWK ${section.total}", isBold: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppTranslations.getString('close'),
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6), // Lighter, cleaner background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSummaryParagraph(),
                    const SizedBox(height: 20),
                    _buildSummaryCard(
                        context,
                        AppTranslations.getString('total_income'),
                        "MWK ${totalIncome.toStringAsFixed(2)}",
                        Colors.green,
                        Icons.attach_money),
                    const SizedBox(height: 20),
                    _buildSectionSummaries(context),
                    const Divider(height: 40, color: Colors.grey),
                    _buildPieChart(context),
                    const SizedBox(height: 20),
                    _buildTotals(context),
                    const SizedBox(height: 30),
                    if (!isViewOnly)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () => _saveRecord(context),
                        icon: const Icon(Icons.save),
                        label: Text(
                          AppTranslations.getString('save_record'),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        image: DecorationImage(
          image: AssetImage('assets/images/${cropImage}1.jpg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: IconButton(
                        icon: SvgPicture.asset("assets/icons/back.svg",
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "${AppTranslations.getString('gross_margin_analysis')} $cropName",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${AppTranslations.getString('field_size')}: $fieldSize ${AppTranslations.getString('hectares')}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryParagraph() {
    String summary = AppTranslations.getString('summary_paragraph');
    summary = summary.replaceAll('@size', fieldSize.toString());
    summary = summary.replaceAll('@crop', cropName);
    summary = summary.replaceAll('@yield', averageYiled.toString());
    summary = summary.replaceAll('@price', sellingPrice.toStringAsFixed(2));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.green, size: 40),
          const SizedBox(height: 10),
          Text(
            summary,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value,
      Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSummaries(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 25,
              width: 5,
              decoration: BoxDecoration(
                  color: Colors.orange, borderRadius: BorderRadius.circular(5)),
            ),
            const SizedBox(width: 10),
            Text(
              AppTranslations.getString('variable_costs'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ...sectionSummaries.map((section) {
          return GestureDetector(
            onTap: () => _showSectionDetails(context, section),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.list_alt,
                      color: Colors.orange, size: 20),
                ),
                title: Text(
                  section.contentItem,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(section.sectionName,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                trailing: Text(
                  'MWK ${section.total}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context) {
    // Check if values are zero to avoid chart errors
    if (totalExpenditure == 0 && totalIncome == 0 && profitMargin == 0) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.redAccent,
                  value: totalExpenditure.abs(), // Use abs to prevent crash if negative
                  title: AppTranslations.getString('expenditure'),
                  radius: 50,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: totalIncome.abs(),
                  title: AppTranslations.getString('income'),
                  radius: 55,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.blueAccent,
                  value: profitMargin > 0 ? profitMargin : 0, // Show profit only if positive
                  title: AppTranslations.getString('profit'),
                  radius: 50,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotals(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildTotalRow(AppTranslations.getString('total_expenditure'),
              "MWK ${totalExpenditure.toStringAsFixed(2)}", Colors.redAccent),
          const Divider(color: Colors.white24),
          _buildTotalRow(AppTranslations.getString('total_income'),
              "MWK ${totalIncome.toStringAsFixed(2)}", Colors.greenAccent),
          const Divider(color: Colors.white24),
          _buildTotalRow(
              AppTranslations.getString('profit_margin'),
              "MWK ${profitMargin.toStringAsFixed(2)}",
              profitMargin >= 0 ? Colors.blueAccent : Colors.orangeAccent,
              isLarge: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, Color color,
      {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isLarge ? 22 : 18,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionSummary {
  final String sectionName;
  final String contentItem;
  final String inputValue;
  final double rateAcre;
  final double total;

  SectionSummary({
    required this.sectionName,
    required this.contentItem,
    required this.inputValue,
    required this.rateAcre,
    required this.total,
  });
}
