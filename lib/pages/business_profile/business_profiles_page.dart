import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';

class BusinessProfilesPage extends StatelessWidget {
  const BusinessProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final language = GetStorage().read('language') ?? 'en';
    final profiles = _demoProfiles(language);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          language == 'en' ? 'Business Profiles' : 'Mabizinesi',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                language == 'en'
                    ? 'Profile builder coming soon!'
                    : 'Kumanga mbiri kukubwera posachedwa!',
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_business),
        label: Text(
          language == 'en' ? 'Create Profile' : 'Pangani Mbiri',
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF1F8E9),
              Color(0xFFE8F5E9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Header(language: language),
            const SizedBox(height: 20),
            ...profiles.map(
              (profile) => _ProfileCard(
                language: language,
                profile: profile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _demoProfiles(String language) {
    return [
      {
        'title_en': 'Agro Inputs Hub',
        'title_ny': 'Malo a Zida Zaulimi',
        'location': 'Lilongwe, Malawi',
        'focus_en': 'Input distribution & agronomist support',
        'focus_ny': 'Kugawa zida ndi upangiri waulimi',
        'rating': 4.9,
      },
      {
        'title_en': 'Green Harvest Co-op',
        'title_ny': 'Green Harvest Co-op',
        'location': 'Mzuzu, Malawi',
        'focus_en': 'Irrigated horticulture off-taker',
        'focus_ny': 'Wogula zokolola za madzi',
        'rating': 4.7,
      },
      {
        'title_en': 'Smart Cold Chain',
        'title_ny': 'Smart Cold Chain',
        'location': 'Blantyre, Malawi',
        'focus_en': 'Cold storage & last mile logistics',
        'focus_ny': 'Kusunga kuzizira ndi mayendedwe omaliza',
        'rating': 4.6,
      },
    ];
  }
}

class _Header extends StatelessWidget {
  final String language;
  const _Header({required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF558B2F),
            Color(0xFF2E7D32),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language == 'en'
                ? 'Showcase your agribusiness story.'
                : 'Onetsani mbiri ya bizinesi yanu.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            language == 'en'
                ? 'Modern cards, rich media galleries and trust badges help you win new customers.'
                : 'Makadi amakono, zithunzi ndi zizindikiro zimakuthandizani kupeza makasitomala atsopano.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String language;
  final Map<String, dynamic> profile;
  const _ProfileCard({required this.language, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: kPrimaryLight,
                  child: const Icon(Icons.business_center, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language == 'en'
                            ? profile['title_en']
                            : profile['title_ny'],
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        profile['location'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  backgroundColor: Colors.green.shade50,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Text(profile['rating'].toString()),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              language == 'en' ? 'Main Focus' : 'Cholinga Chachikulu',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              language == 'en'
                  ? profile['focus_en']
                  : profile['focus_ny'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(
                      language == 'en' ? 'Preview' : 'Onani',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: Text(
                      language == 'en' ? 'Share' : 'Gawani',
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

