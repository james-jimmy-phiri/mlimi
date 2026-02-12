import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/services/business_profile_service.dart';
import 'package:mlimi/pages/business_profile/create_business_profile_page.dart';
import 'package:mlimi/pages/business_profile/business_profile_detail_page.dart';
import 'package:mlimi/pages/business_profile/edit_business_profile_page.dart';

class BusinessProfilesPage extends StatefulWidget {
  const BusinessProfilesPage({super.key});

  @override
  State<BusinessProfilesPage> createState() => _BusinessProfilesPageState();
}

class _BusinessProfilesPageState extends State<BusinessProfilesPage> {
  final _businessProfileService = BusinessProfileService();
  final _language = GetStorage().read('language') ?? 'en';

  List<BusinessProfile> _profiles = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMoreProfiles();
      }
    }
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _businessProfileService.getProfiles(page: 1);
      setState(() {
        _profiles = result['profiles'] as List<BusinessProfile>;
        _currentPage = result['pagination']['current_page'];
        _totalPages = result['pagination']['last_page'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreProfiles() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = await _businessProfileService.getProfiles(page: _currentPage + 1);
      setState(() {
        _profiles.addAll(result['profiles'] as List<BusinessProfile>);
        _currentPage = result['pagination']['current_page'];
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateBusinessProfilePage(),
      ),
    );

    if (result == true) {
      _loadProfiles();
    }
  }

  Future<void> _navigateToDetail(BusinessProfile profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessProfileDetailPage(profileId: profile.id!),
      ),
    );

    if (result == true) {
      _loadProfiles();
    }
  }

  Future<void> _navigateToEdit(BusinessProfile profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBusinessProfilePage(profile: profile),
      ),
    );

    if (result == true) {
      _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _language == 'en' ? 'Business Profiles' : 'Mabizinesi',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfiles,
            tooltip: _language == 'en' ? 'Refresh' : 'Konzani',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add_business),
        label: Text(
          _language == 'en' ? 'Create Profile' : 'Pangani',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _language == 'en' ? 'Failed to load profiles' : 'Talephera kutsegula',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProfiles,
              icon: const Icon(Icons.refresh),
              label: Text(_language == 'en' ? 'Retry' : 'Yesani'),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            ),
          ],
        ),
      );
    }

    if (_profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _language == 'en' ? 'No Business Profiles' : 'Palibe Mabizinesi',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _language == 'en'
                  ? 'Create your first business profile'
                  : 'Pangani bizinesi yanu yoyamba',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreate,
              icon: const Icon(Icons.add_business),
              label: Text(_language == 'en' ? 'Create Profile' : 'Pangani'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfiles,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _profiles.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _profiles.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final profile = _profiles[index];
          return _buildProfileCard(profile);
        },
      ),
    );
  }

  Widget _buildProfileCard(BusinessProfile profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(profile),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: profile.logoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(profile.logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profile.logoUrl == null
                        ? Icon(Icons.business, size: 32, color: Colors.grey[400])
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Business Info
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
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (profile.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 14, color: Colors.green[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      _language == 'en' ? 'Verified' : 'Yotsimikizidwa',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (profile.client != null)
                          Text(
                            profile.client!.name,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (profile.sector != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              profile.sector!.name,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (profile.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  profile.description!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      profile.location ?? 'N/A',
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
              // Categories
              if (profile.categories != null && profile.categories!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: profile.categories!.take(3).map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.name,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.purple[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              // Stats and Actions
              Row(
                children: [
                  _buildStatItem(
                    Icons.image,
                    profile.galleryImages?.length ?? 0,
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    Icons.video_library,
                    profile.galleryVideos?.length ?? 0,
                    Colors.purple,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    Icons.shopping_bag,
                    profile.offerings?.length ?? 0,
                    Colors.orange,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _navigateToEdit(profile),
                    color: Colors.blue[700],
                    tooltip: _language == 'en' ? 'Edit' : 'Sinthani',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
