import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/farming_profile_models.dart';
import 'package:mlimi/pages/views/farming_profile/public_farmer_profile_page.dart';
import 'package:mlimi/services/farming_profile_service.dart';

class FarmersDirectoryPage extends StatefulWidget {
  const FarmersDirectoryPage({Key? key}) : super(key: key);

  @override
  State<FarmersDirectoryPage> createState() => _FarmersDirectoryPageState();
}

class _FarmersDirectoryPageState extends State<FarmersDirectoryPage> {
  final FarmingProfileService _service = FarmingProfileService();
  final String _lang = GetStorage().read('language') ?? 'en';
  final _searchController = TextEditingController();

  List<PublicFarmerProfile> _farmers = [];
  List<PublicFarmerProfile> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCrop = '';

  @override
  void initState() {
    super.initState();
    _loadFarmers();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmers() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final farmers = await _service.getPublicFarmerProfiles();
      setState(() {
        _farmers = farmers;
        _filtered = farmers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _farmers.where((f) {
        final matchesName = f.name.toLowerCase().contains(query);
        final matchesDistrict = f.district?.toLowerCase().contains(query) ?? false;
        final matchesCrop = _selectedCrop.isEmpty ||
            f.primaryCrops.any((c) => c.toLowerCase().contains(_selectedCrop.toLowerCase()));
        return (matchesName || matchesDistrict) && matchesCrop;
      }).toList();
    });
  }

  List<String> get _allCrops {
    final crops = <String>{};
    for (final f in _farmers) { crops.addAll(f.primaryCrops); }
    return ['', ...crops.toList()..sort()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: kPrimaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryColor, Color(0xFF1B5E20)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _lang == 'en' ? 'Farmer Directory' : 'Mndandanda wa Alimi',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          _lang == 'en'
                              ? 'Connect with farmers, discover crops & buy direct'
                              : 'Lumikizani ndi alimi, pezani mbewu ndi kugula mwachindunji',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              _lang == 'en' ? 'Farmer Directory' : 'Mndandanda wa Alimi',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadFarmers),
            ],
          ),

          // Search + filter bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _lang == 'en' ? 'Search by name or district...' : 'Sakani dzina kapena dera...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () { _searchController.clear(); _applyFilter(); },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Crop filter chips
                  if (_allCrops.length > 1)
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _allCrops.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final crop = _allCrops[i];
                          final isSelected = _selectedCrop == crop;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedCrop = crop);
                              _applyFilter();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? kPrimaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? kPrimaryColor : Colors.grey[300]!),
                              ),
                              child: Text(
                                crop.isEmpty ? (_lang == 'en' ? 'All Crops' : 'Mbewu Zonse') : crop,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Results count
          if (!_isLoading && _error == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  _lang == 'en'
                      ? '${_filtered.length} farmer${_filtered.length != 1 ? 's' : ''} found'
                      : 'Alimi ${_filtered.length} apezeka',
                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ),

          // Content
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else if (_filtered.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildFarmerCard(_filtered[i]),
                  childCount: _filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFarmerCard(PublicFarmerProfile farmer) {
    final hasActive = farmer.activeSeasonCount > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PublicFarmerProfilePage(farmer: farmer))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: kPrimaryColor.withValues(alpha: 0.12),
                child: Text(
                  farmer.name.isNotEmpty ? farmer.name[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w800, color: kPrimaryColor),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(farmer.name,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        if (hasActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _lang == 'en' ? 'Active' : 'Wogwira',
                              style: GoogleFonts.poppins(
                                  fontSize: 10, fontWeight: FontWeight.w700, color: kPrimaryColor),
                            ),
                          ),
                      ],
                    ),
                    if (farmer.district != null || farmer.region != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 3),
                            Text(
                              [farmer.district, farmer.region].where((e) => e != null).join(', '),
                              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    // Crops chips
                    if (farmer.primaryCrops.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ...farmer.primaryCrops.take(3).map((crop) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.grass, size: 11, color: Colors.green[700]),
                                    const SizedBox(width: 3),
                                    Text(crop,
                                        style: GoogleFonts.poppins(
                                            fontSize: 11, color: Colors.green[800], fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              )),
                          ...farmer.primaryLivestock.take(2).map((ls) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.orange[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.pets, size: 11, color: Colors.orange[700]),
                                    const SizedBox(width: 3),
                                    Text(ls,
                                        style: GoogleFonts.poppins(
                                            fontSize: 11, color: Colors.orange[800], fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${farmer.seasonCount} ${_lang == 'en' ? 'season(s)' : 'nyengo'}',
                          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          _lang == 'en' ? 'View Profile' : 'Ona Mbiri',
                          style: GoogleFonts.poppins(
                              color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: kPrimaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 52, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _lang == 'en' ? 'Could not load farmer directory' : 'Sitinathe kutsegula mndandanda wa alimi',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              _lang == 'en'
                  ? 'This feature may not be available yet. Check back soon.'
                  : 'Zinthu izi zikhoza kuti sizikupezeka panopa. Bwerani posachedwapa.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFarmers,
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _lang == 'en' ? 'No farmers found' : 'Palibe alimi apezeka',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _lang == 'en' ? 'Try adjusting your search or filter.' : 'Yesani kusintha kusaka kwanu.',
              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
