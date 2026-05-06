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
            Icon(Icons.error_outline_rounded, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            Text(
              _language == 'en' ? 'Failed to Load' : 'Talephera kutsegula',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: Text(_language == 'en' ? 'Retry' : 'Yesani'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildActionButtons(),
                const SizedBox(height: 32),
                
                _buildSectionHeader(_language == 'en' ? 'About Business' : 'Zokhudza Bizinesi', Icons.info_outline_rounded),
                _buildDescription(),
                const SizedBox(height: 32),
                
                _buildSectionHeader(_language == 'en' ? 'Location' : 'Malo', Icons.location_on_outlined),
                _buildLocationInfo(),
                const SizedBox(height: 32),
                
                _buildSectionHeader(_language == 'en' ? 'Contact Details' : 'Mauthenga', Icons.contact_phone_outlined),
                _buildContactInfo(),
                
                if (_profile!.contactInfo?.socialMedia != null) ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader('Social Presence', Icons.public_rounded),
                  _buildSocialMedia(),
                ],
                
                if (_profile!.offerings != null && _profile!.offerings!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    _language == 'en' ? 'Products & Services' : 'Zogulitsa',
                    Icons.shopping_bag_outlined,
                  ),
                  _buildOfferings(),
                ],
                
                if (_profile!.galleryImages != null && _profile!.galleryImages!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    _language == 'en' ? 'Gallery' : 'Zithunzi',
                    Icons.photo_library_outlined,
                  ),
                  _buildGalleryImages(),
                ],
                
                if (_profile!.galleryVideos != null && _profile!.galleryVideos!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    _language == 'en' ? 'Makanema' : 'Videos',
                    Icons.video_library_outlined,
                  ),
                  _buildGalleryVideos(),
                ],
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: kPrimaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Pattern/Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kPrimaryColor, Color(0xFF1B5E20)],
                ),
              ),
            ),
            // Abstract background icon
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                Icons.business_rounded,
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            // Business Identity
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: _profile!.logoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_profile!.logoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _profile!.logoUrl == null
                      ? Icon(Icons.business_rounded, size: 50, color: kPrimaryColor.withOpacity(0.5))
                      : null,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _profile!.businessName,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_profile!.sector != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _profile!.sector!.name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          onPressed: _navigateToEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          onPressed: _deleteProfile,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_profile!.isVerified)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _language == 'en' ? 'Verified' : 'Yotsimikizidwa',
                    style: GoogleFonts.poppins(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_profile!.isVerified) const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              if (_profile!.contactInfo?.phone != null) {
                _launchUrl('tel:${_profile!.contactInfo!.phone}');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.call_rounded, color: kPrimaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _language == 'en' ? 'Contact' : 'Lumikizani',
                    style: GoogleFonts.poppins(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildDescription() {
    if (_profile!.description == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        _profile!.description!,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.place_rounded, _profile!.location ?? 'N/A'),
          if (_profile!.district != null)
            _buildInfoRow(Icons.map_rounded, _profile!.district!.name),
          if (_profile!.addressLine != null)
            _buildInfoRow(Icons.home_rounded, _profile!.addressLine!),
          if (_profile!.townCity != null)
            _buildInfoRow(Icons.location_city_rounded, _profile!.townCity!),
          if (_profile!.gpsLat != null && _profile!.gpsLng != null)
            _buildInfoRow(
              Icons.explore_rounded,
              'GPS: ${_profile!.gpsLat}, ${_profile!.gpsLng}',
            ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_profile!.contactInfo?.phone != null)
            _buildInfoRow(Icons.phone_iphone_rounded, _profile!.contactInfo!.phone!),
          if (_profile!.contactInfo?.email != null)
            _buildInfoRow(Icons.alternate_email_rounded, _profile!.contactInfo!.email!),
          if (_profile!.contactInfo?.website != null)
            InkWell(
              onTap: () => _launchUrl(_profile!.contactInfo!.website!),
              child: _buildInfoRow(
                Icons.language_rounded,
                _profile!.contactInfo!.website!,
                isLink: true,
              ),
            ),
          if (_profile!.businessLicenseNumber != null)
            _buildInfoRow(
              Icons.badge_rounded,
              _profile!.businessLicenseNumber!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: kPrimaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isLink ? kPrimaryColor : Colors.black87,
                fontWeight: isLink ? FontWeight.w600 : FontWeight.w400,
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

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (socialMedia.facebook != null && socialMedia.facebook!.isNotEmpty)
          _buildSocialCard('Facebook', Icons.facebook_rounded, const Color(0xFF1877F2), socialMedia.facebook!),
        if (socialMedia.instagram != null && socialMedia.instagram!.isNotEmpty)
          _buildSocialCard('Instagram', Icons.camera_alt_rounded, const Color(0xFFE4405F), socialMedia.instagram!),
        if (socialMedia.twitter != null && socialMedia.twitter!.isNotEmpty)
          _buildSocialCard('Twitter', Icons.chat_bubble_rounded, const Color(0xFF1DA1F2), socialMedia.twitter!),
        if (socialMedia.linkedin != null && socialMedia.linkedin!.isNotEmpty)
          _buildSocialCard('LinkedIn', Icons.business_center_rounded, const Color(0xFF0A66C2), socialMedia.linkedin!),
      ],
    );
  }

  Widget _buildSocialCard(String name, IconData icon, Color color, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
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
    return Column(
      children: _profile!.offerings!.map((offering) => _buildOfferingCard(offering)).toList(),
    );
  }

  Widget _buildOfferingCard(BusinessOffering offering) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              image: offering.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(offering.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: offering.imageUrl == null
                ? Icon(
                    offering.type == 'service' ? Icons.handyman_rounded : Icons.shopping_cart_rounded,
                    color: kPrimaryColor.withOpacity(0.2),
                    size: 30,
                  )
                : null,
          ),
          const SizedBox(width: 16),
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
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (offering.type == 'service' ? Colors.purple : Colors.orange).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        offering.type.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: offering.type == 'service' ? Colors.purple : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (offering.description != null)
                  Text(
                    offering.description!,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Text(
                  offering.price != null
                      ? 'MWK ${offering.price}${offering.unit != null ? ' / ${offering.unit}' : ''}'
                      : 'Price on Request',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
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
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(image.imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGalleryVideos() {
    return Column(
      children: _profile!.galleryVideos!.map((video) => _buildVideoCard(video)).toList(),
    );
  }

  Widget _buildVideoCard(BusinessGalleryVideo video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.play_circle_filled_rounded, size: 40, color: Colors.purple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.caption ?? 'Business Presentation',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (video.durationHuman != null)
                  Text(
                    video.durationHuman!,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            onPressed: () {
              if (video.videoUrl != null) _launchUrl(video.videoUrl!);
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
