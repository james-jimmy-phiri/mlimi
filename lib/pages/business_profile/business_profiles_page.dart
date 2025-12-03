import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/services/business_profile_service.dart';
import 'package:mlimi/pages/business_profile/create_business_profile_page.dart';

class BusinessProfilesPage extends StatefulWidget {
  const BusinessProfilesPage({super.key});

  @override
  State<BusinessProfilesPage> createState() => _BusinessProfilesPageState();
}

class _BusinessProfilesPageState extends State<BusinessProfilesPage> {
  final _businessProfileService = BusinessProfileService();
  late Future<List<BusinessProfile>> _profilesFuture;
  final _language = GetStorage().read('language') ?? 'en';

  @override
  void initState() {
    super.initState();
    _refreshProfiles();
  }

  void _refreshProfiles() {
    setState(() {
      _profilesFuture = _businessProfileService.getProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          _language == 'en' ? 'Business Profiles' : 'Mabizinesi',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateBusinessProfilePage(),
            ),
          );
          if (result == true) {
            _refreshProfiles();
          }
        },
        icon: const Icon(Icons.add_business),
        label: Text(
          _language == 'en' ? 'Create Profile' : 'Pangani Mbiri',
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
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshProfiles();
            await _profilesFuture;
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: _Header(language: _language),
                  ),
                ),
              ),
              FutureBuilder<List<BusinessProfile>>(
                future: _profilesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          _language == 'en'
                              ? 'Failed to load profiles. Please try again.'
                              : 'Talephera kutsegula mbiri. Chonde yesaninso.',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          _language == 'en'
                              ? 'No business profiles found.'
                              : 'Palibe mbiri ya bizinesi yomwe yapezeka.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }

                  final profiles = snapshot.data!;
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: Duration(milliseconds: 100 * index),
                            child: _ProfileCard(
                              language: _language,
                              profile: profiles[index],
                            ),
                          );
                        },
                        childCount: profiles.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
        ),
      ),
    );
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
  final BusinessProfile profile;
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
                  backgroundImage: profile.logoUrl != null
                      ? NetworkImage(profile.logoUrl!)
                      : null,
                  child: profile.logoUrl == null
                      ? const Icon(Icons.business_center, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.businessName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (profile.location != null)
                        Text(
                          profile.location!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                    ],
                  ),
                ),
                if (profile.isVerified)
                  Chip(
                    backgroundColor: Colors.green.shade50,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Text(language == 'en' ? 'Verified' : 'Yovomerezeka'),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (profile.description != null) ...[
              Text(
                language == 'en' ? 'About' : 'Zokhudza',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                profile.description!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to details page if needed
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(
                      language == 'en' ? 'View Details' : 'Onani Zambiri',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                    ),
                    onPressed: () {
                      // Implement share functionality
                    },
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
