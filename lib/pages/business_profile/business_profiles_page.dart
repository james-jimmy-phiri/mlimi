import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/services/business_profile_service.dart';
import 'package:mlimi/pages/business_profile/create_business_profile_page.dart';
import 'package:mlimi/pages/business_profile/business_profile_detail_page.dart';
import 'package:mlimi/utils/error_utils.dart';

class BusinessProfilesPage extends StatefulWidget {
  const BusinessProfilesPage({super.key});

  @override
  State<BusinessProfilesPage> createState() => _BusinessProfilesPageState();
}

class _BusinessProfilesPageState extends State<BusinessProfilesPage> {
  final _businessProfileService = BusinessProfileService();
  final _language = GetStorage().read('language') ?? 'en';
  final _searchController = TextEditingController();

  List<BusinessProfile> _profiles = [];
  List<BusinessSector> _sectors = [];
  List<BusinessDistrict> _districts = [];
  List<Map<String, dynamic>> _valueChains = [];

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  // Filters
  BusinessSector? _filterSector;
  BusinessDistrict? _filterDistrict;
  Map<String, dynamic>? _filterValueChain;
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLookups();
    _loadProfiles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMoreProfiles();
      }
    }
  }

  Future<void> _loadLookups() async {
    final results = await Future.wait([
      _businessProfileService.getSectors(),
      _businessProfileService.getDistricts(),
      _businessProfileService.getValueChains(),
    ]);
    if (mounted) {
      setState(() {
        _sectors = results[0] as List<BusinessSector>;
        _districts = results[1] as List<BusinessDistrict>;
        _valueChains = results[2] as List<Map<String, dynamic>>;
      });
    }
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _businessProfileService.getProfiles(
        page: 1,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sectorId: _filterSector?.id,
        districtId: _filterDistrict?.id,
        valueChainId: _filterValueChain?['id'],
      );
      setState(() {
        _profiles = result['profiles'] as List<BusinessProfile>;
        final pagination = result['pagination'];
        _currentPage = pagination?['current_page'] ?? 1;
        _totalPages = pagination?['last_page'] ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = ErrorUtils.getFriendlyErrorMessage(e, _language);
      });
    }
  }

  Future<void> _loadMoreProfiles() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final result = await _businessProfileService.getProfiles(
        page: _currentPage + 1,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sectorId: _filterSector?.id,
        districtId: _filterDistrict?.id,
        valueChainId: _filterValueChain?['id'],
      );
      setState(() {
        _profiles.addAll(result['profiles'] as List<BusinessProfile>);
        _currentPage = result['pagination']?['current_page'] ?? _currentPage + 1;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _applySearch(String value) {
    _searchQuery = value;
    _loadProfiles();
  }

  void _showFilterSheet() {
    BusinessSector? tempSector = _filterSector;
    BusinessDistrict? tempDistrict = _filterDistrict;
    Map<String, dynamic>? tempValueChain = _filterValueChain;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _language == 'en' ? 'Filter Businesses' : 'Seyani Mabizinesi',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              Text(
                _language == 'en' ? 'Sector' : 'Gawo',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<BusinessSector>(
                value: tempSector,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: _language == 'en' ? 'All Sectors' : 'Magawo Onse',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: [
                  DropdownMenuItem<BusinessSector>(value: null, child: Text(_language == 'en' ? 'All Sectors' : 'Magawo Onse', style: GoogleFonts.poppins())),
                  ..._sectors.map((s) => DropdownMenuItem(value: s, child: Text(s.name, style: GoogleFonts.poppins()))),
                ],
                onChanged: (val) => setSheet(() => tempSector = val),
              ),
              const SizedBox(height: 20),

              Text(
                _language == 'en' ? 'District' : 'Boma',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<BusinessDistrict>(
                value: tempDistrict,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: _language == 'en' ? 'All Districts' : 'Maboma Onse',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: [
                  DropdownMenuItem<BusinessDistrict>(value: null, child: Text(_language == 'en' ? 'All Districts' : 'Maboma Onse', style: GoogleFonts.poppins())),
                  ..._districts.map((d) => DropdownMenuItem(value: d, child: Text(d.name, style: GoogleFonts.poppins()))),
                ],
                onChanged: (val) => setSheet(() => tempDistrict = val),
              ),
              const SizedBox(height: 20),
              Text(_language == 'en' ? 'Value Chain' : 'Nzere wa Mtengo',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700])),
              const SizedBox(height: 8),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: tempValueChain,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: _language == 'en' ? 'All Value Chains' : 'Mizere Onse',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: [
                  DropdownMenuItem<Map<String, dynamic>>(value: null, child: Text(_language == 'en' ? 'All Value Chains' : 'Mizere Onse', style: GoogleFonts.poppins())),
                  ..._valueChains.map((vc) => DropdownMenuItem(value: vc, child: Text(vc['name'] ?? '', style: GoogleFonts.poppins()))),
                ],
                onChanged: (val) => setSheet(() => tempValueChain = val),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setSheet(() {
                          tempSector = null;
                          tempDistrict = null;
                          tempValueChain = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(_language == 'en' ? 'Clear' : 'Chotsani', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterSector = tempSector;
                          _filterDistrict = tempDistrict;
                          _filterValueChain = tempValueChain;
                        });
                        Navigator.pop(ctx);
                        _loadProfiles();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(_language == 'en' ? 'Apply Filters' : 'Gwiritsani', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateBusinessProfilePage()),
    );
    if (result == true) _loadProfiles();
  }

  Future<void> _navigateToDetail(BusinessProfile profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessProfileDetailPage(profileId: profile.id!),
      ),
    );
    if (result == true) _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = _filterSector != null || _filterDistrict != null || _filterValueChain != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(hasActiveFilter),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: _language == 'en' ? 'Search businesses…' : 'Sakani mabizinesi…',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 22),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded, color: Colors.grey[400], size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    _applySearch('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (v) {
                          if (v.isEmpty || v.length >= 2) _applySearch(v);
                        },
                        onSubmitted: _applySearch,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: hasActiveFilter ? kPrimaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: hasActiveFilter ? Colors.white : Colors.grey[600],
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasActiveFilter)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_filterSector != null)
                      _buildFilterChip(_filterSector!.name, () {
                        setState(() => _filterSector = null);
                        _loadProfiles();
                      }),
                    if (_filterDistrict != null)
                      _buildFilterChip(_filterDistrict!.name, () {
                        setState(() => _filterDistrict = null);
                        _loadProfiles();
                      }),
                    if (_filterValueChain != null)
                      _buildFilterChip(_filterValueChain!['name'] ?? '', () {
                        setState(() => _filterValueChain = null);
                        _loadProfiles();
                      }),
                  ],
                ),
              ),
            ),
          // Content
          SliverToBoxAdapter(
            child: _isLoading
                ? _buildLoading()
                : _hasError
                    ? _buildError()
                    : _buildContent(),
          ),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          // Bottom FAB padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        backgroundColor: kPrimaryColor,
        elevation: 4,
        icon: const Icon(Icons.add_business_rounded, color: Colors.white),
        label: Text(
          _language == 'en' ? 'Register Business' : 'Lembetsani Bizinesi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: kPrimaryColor)),
      backgroundColor: kPrimaryColor.withOpacity(0.1),
      side: BorderSide(color: kPrimaryColor.withOpacity(0.3)),
      deleteIcon: const Icon(Icons.close, size: 14, color: kPrimaryColor),
      onDeleted: onRemove,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildAppBar(bool hasActiveFilter) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: kPrimaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          _language == 'en' ? 'Business Profiles' : 'Mabizinesi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kPrimaryColor, Color(0xFF1B5E20)],
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.business_center_rounded,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: _language == 'en' ? 'Refresh' : 'Bwezani',
          onPressed: _loadProfiles,
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 80, color: Colors.red[200]),
          const SizedBox(height: 24),
          Text(
            _language == 'en' ? 'Connection Error' : 'Vuto la Inthaneti',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadProfiles,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(_language == 'en' ? 'Retry' : 'Yesani'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_profiles.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.business_rounded, size: 64, color: kPrimaryColor.withOpacity(0.4)),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty || _filterSector != null || _filterDistrict != null
                  ? (_language == 'en' ? 'No Results Found' : 'Palibe Zowonjezedwa')
                  : (_language == 'en' ? 'No Businesses Registered' : 'Palibe Mabizinesi'),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _filterSector != null || _filterDistrict != null
                  ? (_language == 'en' ? 'Try adjusting your filters.' : 'Sinthani kafukufuku wanu.')
                  : (_language == 'en'
                      ? 'Register your business to connect with thousands of market actors.'
                      : 'Lembetsani bizinesi yanu kuti anthu ambiri adziwe zomwe mumagulitsa.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14, height: 1.5),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: _profiles.map((profile) => _buildProfileCard(profile)).toList(),
      ),
    );
  }

  Widget _buildProfileCard(BusinessProfile profile) {
    return GestureDetector(
      onTap: () => _navigateToDetail(profile),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLogo(profile),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                profile.businessName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (profile.isVerified)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(Icons.verified_rounded, size: 18, color: kPrimaryColor),
                              ),
                          ],
                        ),
                        if (profile.sector != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            profile.sector!.name,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        if (profile.location != null)
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 13, color: Colors.grey[400]),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  profile.location!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (profile.description != null && profile.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  profile.description!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 14),
              Divider(color: Colors.grey[100], height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMiniStat(
                    Icons.shopping_bag_outlined,
                    profile.offerings?.length ?? 0,
                    _language == 'en' ? 'offerings' : 'zogulitsa',
                  ),
                  const SizedBox(width: 16),
                  _buildMiniStat(
                    Icons.photo_library_outlined,
                    profile.galleryImages?.length ?? 0,
                    _language == 'en' ? 'photos' : 'zithunzi',
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        _language == 'en' ? 'View' : 'Onani',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: kPrimaryColor),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BusinessProfile profile) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: profile.logoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                profile.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.business_rounded,
                  size: 32,
                  color: kPrimaryColor.withOpacity(0.3),
                ),
              ),
            )
          : Icon(Icons.business_rounded, size: 32, color: kPrimaryColor.withOpacity(0.3)),
    );
  }

  Widget _buildMiniStat(IconData icon, int count, String label) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey[400]),
        const SizedBox(width: 5),
        Text(
          '$count $label',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
