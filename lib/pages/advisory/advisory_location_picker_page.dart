import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/advisory/geo_specific_advisory_page.dart';

class AdvisoryLocationPickerPage extends StatefulWidget {
  const AdvisoryLocationPickerPage({super.key});

  @override
  State<AdvisoryLocationPickerPage> createState() =>
      _AdvisoryLocationPickerPageState();
}

class _AdvisoryLocationPickerPageState extends State<AdvisoryLocationPickerPage> {
  String? _selectedDistrict;
  String? _selectedEpa;
  String? _selectedSection;
  String? _selectedFarmer;

  // Mock Data
  final _districts = ['Lilongwe', 'Dedza', 'Kasungu', 'Mchinji'];
  final _epas = ['Chitsime', 'Malingunde', 'Ming\'ongo', 'Mpingu'];
  final _sections = ['Section A', 'Section B', 'Section C'];
  final _farmers = [
    {'name': 'James Phiri', 'id': 'HH-1001'},
    {'name': 'Mary Banda', 'id': 'HH-1002'},
    {'name': 'John Doe', 'id': 'HH-1003'},
  ];

  @override
  Widget build(BuildContext context) {
    final language = GetStorage().read('language') ?? 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          language == 'en' ? 'Select Location' : 'Sankhani Malo',
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
          children: [
            FadeInDown(
              child: _SelectionStep(
                title: 'District',
                value: _selectedDistrict,
                items: _districts,
                onChanged: (val) {
                  setState(() {
                    _selectedDistrict = val;
                    _selectedEpa = null;
                    _selectedSection = null;
                    _selectedFarmer = null;
                  });
                },
              ),
            ),
            if (_selectedDistrict != null) ...[
              const SizedBox(height: 20),
              FadeInDown(
                child: _SelectionStep(
                  title: 'EPA',
                  value: _selectedEpa,
                  items: _epas,
                  onChanged: (val) {
                    setState(() {
                      _selectedEpa = val;
                      _selectedSection = null;
                      _selectedFarmer = null;
                    });
                  },
                ),
              ),
            ],
            if (_selectedEpa != null) ...[
              const SizedBox(height: 20),
              FadeInDown(
                child: _SelectionStep(
                  title: 'Section',
                  value: _selectedSection,
                  items: _sections,
                  onChanged: (val) {
                    setState(() {
                      _selectedSection = val;
                      _selectedFarmer = null;
                    });
                  },
                ),
              ),
            ],
            if (_selectedSection != null) ...[
              const SizedBox(height: 20),
              FadeInDown(
                child: Container(
                  width: double.infinity,
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Farmer',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _farmers.length,
                        separatorBuilder: (c, i) => const Divider(),
                        itemBuilder: (context, index) {
                          final farmer = _farmers[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: kPrimaryColor.withOpacity(0.1),
                              child: Text(
                                farmer['name']![0],
                                style: GoogleFonts.poppins(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              farmer['name']!,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              farmer['id']!,
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GeoSpecificAdvisoryPage(
                                    initialHhid: farmer['id'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectionStep extends StatelessWidget {
  const _SelectionStep({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String title;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: GoogleFonts.poppins()),
                    ))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
    );
  }
}
