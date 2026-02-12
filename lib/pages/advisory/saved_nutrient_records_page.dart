import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/nutrient_models.dart';
import 'package:mlimi/pages/advisory/saved_nutrient_details_page.dart';
import 'package:mlimi/services/nutrient_storage_service.dart';

class SavedNutrientRecordsPage extends StatefulWidget {
  const SavedNutrientRecordsPage({super.key});

  @override
  State<SavedNutrientRecordsPage> createState() => _SavedNutrientRecordsPageState();
}

class _SavedNutrientRecordsPageState extends State<SavedNutrientRecordsPage> {
  final _storageService = NutrientStorageService();
  late List<NutrientRecommendationResult> _records;
  final String _language = GetStorage().read('language') ?? 'en';

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = _storageService.getSavedRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          _language == 'en' ? 'Saved Records' : 'Zolemba Zosungidwa',
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
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.folderOpen, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    _language == 'en'
                        ? 'No saved records found.'
                        : 'Palibe zolemba zomwe munasunga.',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final district = record.stringField('District') ?? 'Unknown';
                final area = record.stringField('Area_ha') ?? '-';
                final id = record.recommendationId?.toString() ?? 'N/A';

                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SavedNutrientDetailsPage(record: record),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(FontAwesomeIcons.fileContract, color: Colors.purple, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID: #$id',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    Text(
                                      district,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _language == 'en'
                                          ? 'Area: $area ha'
                                          : 'Malo: $area ha',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(record),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(NutrientRecommendationResult record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_language == 'en' ? 'Delete Record' : 'Chotsani Cholemba'),
        content: Text(_language == 'en'
            ? 'Are you sure you want to delete this record?'
            : 'Kodi muli ndi tsimikizo kuti mukufuna kuchotsa cholembachi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_language == 'en' ? 'Cancel' : 'Tiyeni tasiya'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_language == 'en' ? 'Delete' : 'Chotsani', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && record.recommendationId != null) {
      await _storageService.deleteRecord(record.recommendationId!);
      _loadRecords();
    }
  }
}
