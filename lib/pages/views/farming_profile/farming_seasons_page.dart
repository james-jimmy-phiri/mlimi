import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/farming_profile_models.dart';
import 'package:mlimi/pages/views/farming_profile/season_detail_page.dart';
import 'package:mlimi/pages/views/farming_profile/add_edit_season_page.dart';
import 'package:mlimi/pages/views/farming_profile/farmers_directory_page.dart';
import 'package:mlimi/services/farming_profile_service.dart';
import 'package:mlimi/pages/views/signup/loginscreen.dart';

class FarmingSeasonsPage extends StatefulWidget {
  const FarmingSeasonsPage({Key? key}) : super(key: key);

  @override
  State<FarmingSeasonsPage> createState() => _FarmingSeasonsPageState();
}

class _FarmingSeasonsPageState extends State<FarmingSeasonsPage> {
  final FarmingProfileService _service = FarmingProfileService();
  final String _lang = GetStorage().read('language') ?? 'en';

  List<FarmingSeason> _seasons = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final seasons = await _service.getSeasons();
      setState(() { _seasons = seasons; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(context,
      MaterialPageRoute(builder: (_) => const AddEditSeasonPage()));
    if (result == true) _loadSeasons();
  }

  void _navigateToDetail(FarmingSeason season) async {
    final result = await Navigator.push(context,
      MaterialPageRoute(builder: (_) => SeasonDetailPage(seasonId: season.id)));
    if (result == true) _loadSeasons();
  }

  Future<void> _deleteSeason(FarmingSeason season) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_lang == 'en' ? 'Delete Season?' : 'Chotsani Nyengo?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          _lang == 'en'
              ? 'This will permanently delete "${season.name}" and all its data.'
              : 'Izi zidzafuta "${season.name}" ndi zochitika zake zonse.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_lang == 'en' ? 'Cancel' : 'Siyani', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(_lang == 'en' ? 'Delete' : 'Chotsani',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.deleteSeason(season.id);
      _loadSeasons();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red,
            content: Text(e.toString().replaceAll('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _lang == 'en' ? 'My Farming Profile' : 'Chikwatu Cha Mlimi',
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: _lang == 'en' ? 'Farmer Directory' : 'Mndandanda wa Alimi',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FarmersDirectoryPage())),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSeasons),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _lang == 'en' ? 'New Season' : 'Nyengo Yatsopano',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      final isUnauth = _error!.contains('UNAUTHORIZED');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isUnauth ? kPrimaryColor.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUnauth ? Icons.lock_outline : Icons.error_outline,
                  size: 52,
                  color: isUnauth ? kPrimaryColor : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isUnauth
                    ? (_lang == 'en'
                        ? 'Login required'
                        : 'Kuyenera kulowa')
                    : (_lang == 'en' ? 'Something went wrong' : 'Chinthu chinalakwika'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                isUnauth
                    ? (_lang == 'en'
                        ? 'Please login or create an account to access your farming profile and track your seasons.'
                        : 'Chonde lowani kapena lembetsani kuti mupeze chikwatu chanu cha mlimi.')
                    : _error!.replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              isUnauth
                  ? ElevatedButton.icon(
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SimpleLoginScreen())).then((_) => _loadSeasons()),
                      icon: const Icon(Icons.login),
                      label: Text(_lang == 'en' ? 'Login / Sign Up' : 'Lowani / Lembetsani',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _loadSeasons,
                      icon: const Icon(Icons.refresh),
                      label: Text(_lang == 'en' ? 'Try Again' : 'Yesaninso',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
            ],
          ),
        ),
      );
    }

    if (_seasons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: kPrimaryColor.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: Icon(Icons.agriculture, size: 64, color: kPrimaryColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 24),
              Text(
                _lang == 'en' ? 'No Seasons Yet' : 'Palibe Nyengo',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                _lang == 'en'
                    ? 'Start by creating your first farming season to track crops, livestock, expenses and profits.'
                    : 'Yambitsani nyengo yanu yoyamba ya ulimi kuti mutsatire mbewu, ziweto, ndalama ndi phindu.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _navigateToAdd,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(_lang == 'en' ? 'Create First Season' : 'Konzani Nyengo Yoyamba',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSeasons,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _seasons.length,
        itemBuilder: (context, index) => _buildSeasonCard(_seasons[index]),
      ),
    );
  }

  Widget _buildSeasonCard(FarmingSeason season) {
    final df = DateFormat('MMM dd, yyyy');
    final isActive = season.status == 'Active';
    final isHarvesting = season.status == 'Harvesting';
    final statusColor = isActive
        ? const Color(0xFF2E7D32)
        : isHarvesting
            ? Colors.orange[700]!
            : const Color(0xFF1565C0);

    return Dismissible(
      key: Key('season-${season.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        await _deleteSeason(season);
        return false;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToDetail(season),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Coloured header strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(season.name,
                          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(season.status,
                          style: GoogleFonts.poppins(
                              fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                    ),
                  ],
                ),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          '${df.format(season.startDate)}${season.endDate != null ? ' ? ${df.format(season.endDate!)}' : ''}',
                          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.water_drop_outlined, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(season.type, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statChip(Icons.grass, '${season.crops.length}', _lang == 'en' ? 'Crops' : 'Mbewu', const Color(0xFF2E7D32)),
                        _statChip(Icons.pets, '${season.livestock.length}', _lang == 'en' ? 'Livestock' : 'Ziweto', Colors.orange[700]!),
                        _statChip(Icons.hive_outlined, '${season.honey.length}', _lang == 'en' ? 'Honey' : 'Uchi', const Color(0xFFF57F17)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_lang == 'en' ? 'Tap to view details' : 'Dotani kuona tsatanetsatane',
                        style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 11)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 11, color: Colors.grey[400]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 15)),
        Text(label, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11)),
      ],
    );
  }
}
