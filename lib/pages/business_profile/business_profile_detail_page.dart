import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/services/business_profile_service.dart';
import 'package:mlimi/pages/business_profile/edit_business_profile_page.dart';
import 'package:mlimi/utils/error_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class BusinessProfileDetailPage extends StatefulWidget {
  final int profileId;

  const BusinessProfileDetailPage({super.key, required this.profileId});

  @override
  State<BusinessProfileDetailPage> createState() =>
      _BusinessProfileDetailPageState();
}

class _BusinessProfileDetailPageState extends State<BusinessProfileDetailPage> {
  final _businessProfileService = BusinessProfileService();
  final _language = GetStorage().read('language') ?? 'en';

  BusinessProfile? _profile;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final profile = await _businessProfileService.getProfile(widget.profileId);
      setState(() {
        _profile = profile;
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

  Future<void> _navigateToEdit() async {
    if (_profile == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBusinessProfilePage(profile: _profile!),
      ),
    );

    if (result == true) {
      _loadProfile();
    }
  }

  Future<void> _deleteProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_language == 'en' ? 'Delete Profile' : 'Chotsani Mbiri'),
        content: Text(_language == 'en'
            ? 'Are you sure you want to delete this business profile?'
            : 'Mukutsimikiza kuti mukufuna kuchotsa mbiri iyi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_language == 'en' ? 'Cancel' : 'Lekani'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_language == 'en' ? 'Delete' : 'Chotsani'),
          ),
        ],
      ),
    );

    if (confirm == true && _profile != null) {
      try {
        await _businessProfileService.deleteProfile(_profile!.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_language == 'en'
                  ? 'Profile deleted successfully'
                  : 'Mbiri yachotsedwa bwino'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_language == 'en' ? 'Failed to delete' : 'Zaphwanya kuchotsa'}: ${ErrorUtils.getFriendlyErrorMessage(e, _language)}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _profile?.businessName ?? (_language == 'en' ? 'Business Profile' : 'Mbiri'),
          style: GoogleFonts.poppins(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (_profile != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEdit,
              tooltip: _language == 'en' ? 'Edit' : 'Sinthani',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteProfile,
              tooltip: _language == 'en' ? 'Delete' : 'Chotsani',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _language == 'en' ? 'Failed to load profile' : 'Talephera kutsegula',
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
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: Text(_language == 'en' ? 'Retry' : 'Yesani'),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildDescription(),
          const SizedBox(height: 16),
          _buildLocationInfo(),
          const SizedBox(height: 16),
          _buildContactInfo(),
          if (_profile!.contactInfo?.socialMedia != null) ...[
            const SizedBox(height: 16),
            _buildSocialMedia(),
          ],
          if (_profile!.offerings != null && _profile!.offerings!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildOfferings(),
          ],
          if (_profile!.galleryImages != null && _profile!.galleryImages!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildGalleryImages(),
          ],
          if (_profile!.galleryVideos != null && _profile!.galleryVideos!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildGalleryVideos(),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: _profile!.logoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_profile!.logoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _profile!.logoUrl == null
                ? Icon(Icons.business, size: 48, color: Colors.grey[400])
                : null,
          ),
          const SizedBox(height: 16),
          // Business Name
          Text(
            _profile!.businessName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Verification Status
          if (_profile!.isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 6),
                  Text(
                    _language == 'en' ? 'Verified Business' : 'Bizinesi Yotsimikizidwa',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // Sector and Categories
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_profile!.sector != null)
                _buildChip(_profile!.sector!.name, Colors.blue.shade700),
              if (_profile!.categories != null)
                ..._profile!.categories!.map((c) => _buildChip(c.name, Colors.purple.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    if (_profile!.description == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _language == 'en' ? 'About' : 'Zambiri',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _profile!.description!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _language == 'en' ? 'Location' : 'Malo',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, _profile!.location ?? 'N/A'),
          if (_profile!.district != null)
            _buildInfoRow(Icons.map, _profile!.district!.name),
          if (_profile!.addressLine != null)
            _buildInfoRow(Icons.home, _profile!.addressLine!),
          if (_profile!.townCity != null)
            _buildInfoRow(Icons.location_city, _profile!.townCity!),
          if (_profile!.gpsLat != null && _profile!.gpsLng != null)
            _buildInfoRow(
              Icons.gps_fixed,
              '${_profile!.gpsLat}, ${_profile!.gpsLng}',
            ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _language == 'en' ? 'Contact' : 'Mauthenga',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_profile!.contactInfo?.phone != null)
            _buildInfoRow(Icons.phone, _profile!.contactInfo!.phone!),
          if (_profile!.contactInfo?.email != null)
            _buildInfoRow(Icons.email, _profile!.contactInfo!.email!),
          if (_profile!.contactInfo?.website != null)
            InkWell(
              onTap: () => _launchUrl(_profile!.contactInfo!.website!),
              child: _buildInfoRow(
                Icons.language,
                _profile!.contactInfo!.website!,
                isLink: true,
              ),
            ),
          if (_profile!.businessLicenseNumber != null)
            _buildInfoRow(
              Icons.card_membership,
              _profile!.businessLicenseNumber!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isLink ? Colors.blue[700] : Colors.grey[700],
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMedia() {
    final socialMedia = _profile!.contactInfo!.socialMedia!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social Media',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (socialMedia.facebook != null && socialMedia.facebook!.isNotEmpty)
                _buildSocialButton('Facebook', Icons.facebook, socialMedia.facebook!),
              if (socialMedia.instagram != null && socialMedia.instagram!.isNotEmpty)
                _buildSocialButton('Instagram', Icons.camera_alt, socialMedia.instagram!),
              if (socialMedia.twitter != null && socialMedia.twitter!.isNotEmpty)
                _buildSocialButton('Twitter', Icons.chat, socialMedia.twitter!),
              if (socialMedia.linkedin != null && socialMedia.linkedin!.isNotEmpty)
                _buildSocialButton('LinkedIn', Icons.business_center, socialMedia.linkedin!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String name, IconData icon, String url) {
    return ElevatedButton.icon(
      onPressed: () => _launchUrl(url),
      icon: Icon(icon, size: 16),
      label: Text(name),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
    );
  }

  Widget _buildOfferings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _language == 'en' ? 'Products & Services' : 'Zogulitsa',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...(_profile!.offerings!.map((offering) => _buildOfferingCard(offering))),
        ],
      ),
    );
  }

  Widget _buildOfferingCard(BusinessOffering offering) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: offering.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(offering.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: offering.imageUrl == null
                ? Icon(
                    offering.type == 'service' ? Icons.work : Icons.shopping_bag,
                    color: Colors.grey[400],
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        offering.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: offering.type == 'service'
                            ? Colors.purple.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        offering.type,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: offering.type == 'service'
                              ? Colors.purple.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (offering.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    offering.description!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  offering.price != null
                      ? '${offering.currency} ${offering.price}${offering.unit != null ? ' / ${offering.unit}' : ''}'
                      : 'Contact for price',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryImages() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _language == 'en' ? 'Gallery Images' : 'Zithunzi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _profile!.galleryImages!.length,
            itemBuilder: (context, index) {
              final image = _profile!.galleryImages![index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewerPage(
                        imageUrl: image.imageUrl!,
                        caption: image.caption,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(image.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryVideos() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _language == 'en' ? 'Gallery Videos' : 'Makanema',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ..._profile!.galleryVideos!.map((video) => _buildVideoCard(video)),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BusinessGalleryVideo video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.play_circle_fill, size: 40, color: Colors.purple.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.caption ?? 'Video',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (video.fileSizeHuman != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    video.fileSizeHuman!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (video.durationHuman != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    video.durationHuman!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // You can implement video playback here
              if (video.videoUrl != null) {
                _launchUrl(video.videoUrl!);
              }
            },
          ),
        ],
      ),
    );
  }
}

// Image Viewer Page
class ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final String? caption;

  const ImageViewerPage({
    super.key,
    required this.imageUrl,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(imageUrl),
            if (caption != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  caption!,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
