import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/farmer_models.dart';
import 'package:mlimi/pages/advisory/geo_specific_advisory_page.dart';
import 'package:mlimi/services/farmer_service.dart';

class AdvisoryLocationPickerPage extends StatefulWidget {
  const AdvisoryLocationPickerPage({super.key});

  @override
  State<AdvisoryLocationPickerPage> createState() =>
      _AdvisoryLocationPickerPageState();
}

class _AdvisoryLocationPickerPageState
    extends State<AdvisoryLocationPickerPage> {
  final FarmerService _farmerService = FarmerService();
  
  List<Region> _regions = [];
  Region? _selectedRegion;
  District? _selectedDistrict;
  Epa? _selectedEpa;
  Village? _selectedVillage;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _farmerService.loadFarmers();
      setState(() {
        _regions = data.regions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
      debugPrint('Error loading data: $e');
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  FadeInDown(
                    child: _SelectionStep<Region>(
                       title: 'Region',
                      value: _selectedRegion,
                      items: _regions,
                      itemLabel: (item) => item.region,
                      onChanged: (val) {
                        setState(() {
                          _selectedRegion = val;
                          _selectedDistrict = null;
                          _selectedEpa = null;
                          _selectedVillage = null;
                        });
                      },
                    ),
                  ),
                  if (_selectedRegion != null) ...[
                    const SizedBox(height: 20),
                    FadeInDown(
                      child: _SelectionStep<District>(
                        title: 'District',
                        value: _selectedDistrict,
                        items: _selectedRegion!.districts,
                        itemLabel: (item) => item.district,
                        onChanged: (val) {
                          setState(() {
                            _selectedDistrict = val;
                            _selectedEpa = null;
                            _selectedVillage = null;
                          });
                        },
                      ),
                    ),
                  ],
                  if (_selectedDistrict != null) ...[
                    const SizedBox(height: 20),
                    FadeInDown(
                      child: _SelectionStep<Epa>(
                        title: 'EPA',
                        value: _selectedEpa,
                        items: _selectedDistrict!.epas,
                        itemLabel: (item) => item.epa,
                        onChanged: (val) {
                          setState(() {
                            _selectedEpa = val;
                            _selectedVillage = null;
                          });
                        },
                      ),
                    ),
                  ],
                  if (_selectedEpa != null) ...[
                    const SizedBox(height: 20),
                    FadeInDown(
                      child: _SelectionStep<Village>(
                        title: 'Village',
                        value: _selectedVillage,
                        items: _selectedEpa!.villages,
                        itemLabel: (item) => item.village,
                        onChanged: (val) {
                          setState(() {
                            _selectedVillage = val;
                          });
                        },
                      ),
                    ),
                  ],
                  if (_selectedVillage != null) ...[
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
                              itemCount: _selectedVillage!.farmers.length,
                              separatorBuilder: (c, i) => const Divider(),
                              itemBuilder: (context, index) {
                                final farmer = _selectedVillage!.farmers[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        kPrimaryColor.withOpacity(0.1),
                                    child: Text(
                                      farmer.farmerName.isNotEmpty
                                          ? farmer.farmerName[0]
                                          : '?',
                                      style: GoogleFonts.poppins(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    farmer.farmerName,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    farmer.householdId,
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      size: 14),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GeoSpecificAdvisoryPage(
                                          initialHhid: farmer.householdId,
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

class _SelectionStep<T> extends StatelessWidget {
  const _SelectionStep({
    required this.title,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String title;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

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
          DropdownButtonFormField<T>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(itemLabel(item), style: GoogleFonts.poppins()),
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
