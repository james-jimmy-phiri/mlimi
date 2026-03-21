import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/advisory/advisory_location_picker_page.dart';
import 'package:mlimi/pages/advisory/geo_specific_advisory_page.dart';
import 'package:mlimi/pages/advisory/saved_nutrient_records_page.dart';

class AdvisoryMethodSelectionPage extends StatelessWidget {
  const AdvisoryMethodSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final language = GetStorage().read('language') ?? 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          language == 'en' ? 'Soil Nutrient Recommendation' : 'Malangizo a Fetereza',
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            // Main Content
            Positioned.fill(
              bottom: 80, // Leave space for the sponsored section
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      language == 'en'
                          ? 'How do you want to find your location?'
                          : 'Mufuna kupeza bwanji malo anu?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: _MethodCard(
                        title: language == 'en'
                            ? 'Choose Site Location'
                            : 'Sankhani Malo',
                        description: language == 'en'
                            ? 'Select District, EPA, and Section manually.'
                            : 'Sankhani Boma, EPA, ndi Dera.',
                        icon: FontAwesomeIcons.mapLocationDot,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdvisoryLocationPickerPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 500),
                      child: _MethodCard(
                        title: language == 'en'
                            ? 'Enter Site Location'
                            : 'Lembani Malo',
                        description: language == 'en'
                            ? 'Enter Household ID and coordinates directly.'
                            : 'Lembani nambala ya banja ndi malo.',
                        icon: FontAwesomeIcons.keyboard,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const GeoSpecificAdvisoryPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 500),
                      child: _MethodCard(
                        title:
                            language == 'en' ? 'Use GPS Location' : 'Gwiritsani GPS',
                        description: language == 'en'
                            ? 'Auto-detect your current position.'
                            : 'Dziwani malo omwe muli pano.',
                        icon: FontAwesomeIcons.satelliteDish,
                        color: Colors.green,
                        onTap: () => _handleGpsLocation(context, language),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 500),
                      child: _MethodCard(
                        title: language == 'en' ? 'Saved Records' : 'Zolemba Zosungidwa',
                        description: language == 'en'
                            ? 'View previously saved nutrient recommendations.'
                            : 'Onani malangizo a fetereza omwe munasunga kale.',
                        icon: FontAwesomeIcons.floppyDisk,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedNutrientRecordsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sponsored By Section
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: const Color(0xFFF5F7FA), // Match background color
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      language == 'en' ? 'Sponsored by' : 'Yathandizidwa ndi',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SponsoredLogo(assetPath: 'assets/logo/empower.png'),
                        const SizedBox(width: 15),
                        _SponsoredLogo(assetPath: 'assets/logo/iita.png'),
                        const SizedBox(width: 15),
                        _SponsoredLogo(assetPath: 'assets/logo/nasfam.png'),
                        const SizedBox(width: 15),
                        _SponsoredLogo(assetPath: 'assets/logo/taighde.png'),
                        const SizedBox(width: 15),
                        _SponsoredLogo(assetPath: 'assets/logo/ucd.png'),
                      ],
                    ),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGpsLocation(BuildContext context, String language) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language == 'en'
                ? 'Location services are disabled.'
                : 'Ma GPS atsekedwa.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(language == 'en'
                  ? 'Location permissions are denied'
                  : 'Simunavomereze kugwiritsa ntchito GPS'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language == 'en'
                ? 'Location permissions are permanently denied.'
                : 'Simungathe kugwiritsa ntchito GPS.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  language == 'en' ? 'Getting location...' : 'Kufufuza malo...',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GeoSpecificAdvisoryPage(
              initialLatitude: position.latitude.toString(),
              initialLongitude: position.longitude.toString(),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language == 'en'
                ? 'Failed to get location.'
                : 'Talephera kupeza malo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
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
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _SponsoredLogo extends StatelessWidget {
  final String assetPath;

  const _SponsoredLogo({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
