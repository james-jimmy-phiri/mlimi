import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/farming_profile_models.dart';
import 'package:mlimi/pages/views/farming_profile/season_detail_page.dart';
import 'package:mlimi/pages/views/farming_profile/add_edit_season_page.dart';
import 'package:mlimi/services/farming_profile_service.dart';

class FarmingSeasonsPage extends StatefulWidget {
  const FarmingSeasonsPage({Key? key}) : super(key: key);

  @override
  State<FarmingSeasonsPage> createState() => _FarmingSeasonsPageState();
}

class _FarmingSeasonsPageState extends State<FarmingSeasonsPage> {
  final FarmingProfileService _service = FarmingProfileService();
  final String _language = GetStorage().read('language') ?? 'en';
  
  List<FarmingSeason> _seasons = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final seasons = await _service.getSeasons();
      setState(() {
        _seasons = seasons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToAddSeason() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditSeasonPage()),
    );
    if (result == true) {
      _loadSeasons();
    }
  }

  void _navigateToSeasonDetails(FarmingSeason season) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeasonDetailPage(seasonId: season.id),
      ),
    );
    if (result == true) {
      _loadSeasons();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _language == 'en' ? 'Farming Profile' : 'Chikwatu Cha Mlimi',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSeasons,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddSeason,
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _language == 'en' ? 'New Season' : 'Nyengo Yatsopano',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSeasons,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_seasons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _language == 'en' ? 'No farming seasons yet' : 'Palibe nyengo zaulimi',
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _language == 'en'
                  ? 'Add your first season to track your farming activities'
                  : 'Onjezani nyengo yanu yoyamba',
              style: GoogleFonts.poppins(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSeasons,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _seasons.length,
        itemBuilder: (context, index) {
          final season = _seasons[index];
          return _buildSeasonCard(season);
        },
      ),
    );
  }

  Widget _buildSeasonCard(FarmingSeason season) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final startDateStr = dateFormat.format(season.startDate);
    final isCompleted = season.status == 'Completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToSeasonDetails(season),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      season.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.blue[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      season.status,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.blue[700] : Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Started: $startDateStr',
                    style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.grass, '${season.crops.length} Crops'),
                  _buildStatItem(Icons.pets, '${season.livestock.length} Livestock'),
                  _buildStatItem(Icons.hive_outlined, '${season.honey.length} Honey'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kPrimaryColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
