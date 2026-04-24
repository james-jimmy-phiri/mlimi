import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/farming_profile_models.dart';
import 'package:mlimi/pages/views/farming_profile/add_edit_season_page.dart';
import 'package:mlimi/pages/views/farming_profile/add_activity_page.dart';
import 'package:mlimi/services/farming_profile_service.dart';

class SeasonDetailPage extends StatefulWidget {
  final int seasonId;

  const SeasonDetailPage({Key? key, required this.seasonId}) : super(key: key);

  @override
  State<SeasonDetailPage> createState() => _SeasonDetailPageState();
}

class _SeasonDetailPageState extends State<SeasonDetailPage> {
  final FarmingProfileService _service = FarmingProfileService();
  final String _language = GetStorage().read('language') ?? 'en';
  FarmingSeason? _season;
  SeasonSalesSummary? _summary;
  List<CommoditySale> _sales = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSeasonDetails();
  }

  Future<void> _loadSeasonDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final details = await _service.getSeasonDetails(widget.seasonId);
      setState(() {
        _season = details['season'];
        _summary = details['summary'];
        _sales = details['sales'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToAddActivity(String type) async {
    if (_season == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityPage(
          seasonId: _season!.id,
          activityType: type,
        ),
      ),
    );
    
    if (result == true) {
      _loadSeasonDetails();
    }
  }

  void _navigateToEditSeason() async {
    if (_season == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSeasonPage(season: _season),
      ),
    );

    if (result == true) {
      _loadSeasonDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _season?.name ?? (_language == 'en' ? 'Season Details' : 'Tsatanetsatane wa Nyengo'),
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (_season != null && _season!.status != 'Completed')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditSeason,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _season == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error ?? 'Failed to load', style: GoogleFonts.poppins(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSeasonDetails,
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSeasonDetails,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSeasonHeader(),
            const SizedBox(height: 24),
            _buildSectionHeader(_language == 'en' ? 'Crops' : 'Mbewu', Icons.grass, () => _navigateToAddActivity('crop')),
            _buildCropsList(),
            const SizedBox(height: 24),
            _buildSectionHeader(_language == 'en' ? 'Livestock' : 'Ziweto', Icons.pets, () => _navigateToAddActivity('livestock')),
            _buildLivestockList(),
            const SizedBox(height: 24),
            _buildSectionHeader(_language == 'en' ? 'Honey' : 'Uchi', Icons.hive, () => _navigateToAddActivity('honey')),
            _buildHoneyList(),
            const SizedBox(height: 24),
            if (_summary != null && _summary!.salesCount > 0) ...[
              _buildSectionHeader(_language == 'en' ? 'Sales Summary' : 'Chigamulo Cha Zogulitsa', Icons.monetization_on, null),
              _buildSalesSummary(),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonHeader() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _season!.name,
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _season!.status == 'Completed' ? Colors.blue[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _season!.status,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _season!.status == 'Completed' ? Colors.blue[700] : Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_language == 'en' ? 'Start Date:' : 'Tsiku Loyamba:'} ${dateFormat.format(_season!.startDate)}',
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
            if (_season!.endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${_language == 'en' ? 'End Date:' : 'Tsiku Lomaliza:'} ${dateFormat.format(_season!.endDate!)}',
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
              ),
            if (_season!.notes != null && _season!.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  _season!.notes!,
                  style: GoogleFonts.poppins(color: Colors.grey[800], fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback? onAdd) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (onAdd != null && _season!.status != 'Completed')
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: Text(_language == 'en' ? 'Add' : 'Onjezani', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
            ),
        ],
      ),
    );
  }

  Widget _buildCropsList() {
    if (_season!.crops.isEmpty) {
      return _buildEmptyState(_language == 'en' ? 'No crops added' : 'Palibe mbewu yowonjezedwa');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _season!.crops.length,
      itemBuilder: (context, index) {
        final crop = _season!.crops[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.grass, color: Color(0xFF2E7D32))),
            title: Text(crop.valueChain?.name ?? 'Unknown Crop', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${crop.areaCultivated} acres • Expected: ${crop.totalExpectedHarvestQuantity ?? 0} ${crop.unitOfMeasurement ?? 'kg'}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLivestockList() {
    if (_season!.livestock.isEmpty) {
      return _buildEmptyState(_language == 'en' ? 'No livestock added' : 'Palibe ziweto zowonjezedwa');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _season!.livestock.length,
      itemBuilder: (context, index) {
        final ls = _season!.livestock[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFFFF3E0), child: Icon(Icons.pets, color: Color(0xFFEF6C00))),
            title: Text(ls.valueChain?.name ?? 'Unknown Animal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Text(
              'Quantity: ${ls.numberOfAnimals} • Variety: ${ls.animalVariety ?? 'N/A'}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHoneyList() {
    if (_season!.honey.isEmpty) {
      return _buildEmptyState(_language == 'en' ? 'No honey added' : 'Palibe uchi wowonjezedwa');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _season!.honey.length,
      itemBuilder: (context, index) {
        final h = _season!.honey[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFFFF8E1), child: Icon(Icons.hive, color: Color(0xFFF57F17))),
            title: Text(h.valueChain?.name ?? 'Honey', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Text(
              'Beehives: ${h.numberOfBeehives} • Expected: ${h.expectedProductionKg} kg',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalesSummary() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_language == 'en' ? 'Total Revenue' : 'Phindu Lonse', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
                    Text('MWK ${_summary!.totalRevenue}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: kPrimaryColor)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_language == 'en' ? 'Sales Count' : 'Chiwerengero', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
                    Text('${_summary!.salesCount}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Text(message, style: GoogleFonts.poppins(color: Colors.grey[500])),
      ),
    );
  }
}
