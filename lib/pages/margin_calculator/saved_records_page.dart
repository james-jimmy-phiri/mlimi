import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/margin_record.dart';
import 'package:mlimi/pages/margin_calculator/summary_page.dart';
import 'package:mlimi/services/margin_storage_service.dart';
import 'package:mlimi/utils/app_translations.dart';
import 'package:intl/intl.dart';

class SavedRecordsPage extends StatefulWidget {
  const SavedRecordsPage({Key? key}) : super(key: key);

  @override
  _SavedRecordsPageState createState() => _SavedRecordsPageState();
}

class _SavedRecordsPageState extends State<SavedRecordsPage> {
  final MarginStorageService _storageService = MarginStorageService();
  List<MarginRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = _storageService.getSavedRecords().reversed.toList();
    });
  }

  Future<void> _deleteRecord(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppTranslations.getString('confirm_delete'),
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(AppTranslations.getString('delete_prompt'),
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppTranslations.getString('cancel'),
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppTranslations.getString('delete'),
                  style: GoogleFonts.poppins(color: Colors.white))),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.deleteRecord(id);
      _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120.0,
            backgroundColor: Bgreen,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                AppTranslations.getString('saved_records'),
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        color: Colors.white.withOpacity(0.5), blurRadius: 10),
                  ],
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFFE8F5E9),
                      Color(0xFFC8E6C9),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (_records.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rule_folder_outlined,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    Text(
                      AppTranslations.getString('no_records'),
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final record = _records[index];
                  return FadeInUp(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SummaryPage(
                                cropName: record.cropName,
                                fieldSize: record.fieldSize,
                                sellingPrice: record.sellingPrice,
                                sectionSummaries: record.sectionSummaries
                                    .map((s) => SectionSummary(
                                          sectionName: s.sectionName,
                                          contentItem: s.contentItem,
                                          inputValue: s.inputValue,
                                          rateAcre: s.rateAcre,
                                          total: s.total,
                                        ))
                                    .toList(),
                                totalExpenditure: record.totalExpenditure,
                                totalIncome: record.totalIncome,
                                profitMargin: record.profitMargin,
                                averageYiled: record.averageYield,
                                cropImage: record.cropImage,
                                isViewOnly: true,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/${record.cropImage}1.jpg'),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.3),
                                        BlendMode.darken),
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      record.cropName,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        DateFormat('MMM d, yyyy')
                                            .format(record.date),
                                        style: GoogleFonts.poppins(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildInfoColumn(
                                        AppTranslations.getString('profit'),
                                        "MWK ${record.profitMargin.toStringAsFixed(0)}",
                                        Colors.green[700]!),
                                    _buildInfoColumn(
                                        AppTranslations.getString('income'),
                                        "MWK ${record.totalIncome.toStringAsFixed(0)}",
                                        Colors.blue[700]!),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      onPressed: () =>
                                          _deleteRecord(record.id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _records.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
