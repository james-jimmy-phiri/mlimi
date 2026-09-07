import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mlimi/constants/trending_theme.dart';
import 'package:mlimi/models/trending_story.dart';
import 'package:mlimi/pages/trendings/trending_detail_screen.dart';
import 'package:mlimi/pages/trendings/widgets/trending_top_bar.dart';
import 'package:mlimi/services/trending_story_service.dart';

class CreatorProfileScreen extends StatefulWidget {
  const CreatorProfileScreen({super.key});

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> with SingleTickerProviderStateMixin {
  final TrendingStoryService _service = TrendingStoryService();
  late TabController _tabController;
  TrendingPublisher? _publisher;
  List<TrendingStory> _stories = [];
  bool _loading = true;
  bool _following = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final publisher = await _service.fetchPublisher();
      final page = await _service.fetchPublisherStories();
      if (!mounted) return;
      setState(() {
        _publisher = publisher;
        _stories = page.stories;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(scaffoldBackgroundColor: TrendingTheme.background),
      child: Scaffold(
        backgroundColor: TrendingTheme.background,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: TrendingTheme.primary))
            : Column(
                children: [
                  TrendingTopBar(showBack: true),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _profileHeader(_publisher!),
                        const SizedBox(height: 24),
                        TabBar(
                          controller: _tabController,
                          indicatorColor: TrendingTheme.primary,
                          labelColor: TrendingTheme.primary,
                          unselectedLabelColor: TrendingTheme.onSurfaceVariant,
                          tabs: const [
                            Tab(text: 'STORIES'),
                            Tab(text: 'SERIES'),
                            Tab(text: 'SAVED'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            childAspectRatio: 4 / 5,
                          ),
                          itemCount: _stories.length,
                          itemBuilder: (_, i) {
                            final story = _stories[i];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TrendingDetailScreen(storyId: story.id)),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  story.coverImage != null
                                      ? CachedNetworkImage(imageUrl: story.coverImage!, fit: BoxFit.cover)
                                      : Container(color: TrendingTheme.surfaceContainerHigh),
                                  if (story.isFeatured)
                                    const Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Icon(Icons.auto_awesome, color: TrendingTheme.primary, size: 18),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _profileHeader(TrendingPublisher publisher) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [
              TrendingTheme.primary,
              TrendingTheme.primaryContainer,
              TrendingTheme.tertiary,
            ]),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: TrendingTheme.surfaceContainer,
            backgroundImage: publisher.avatarUrl != null ? CachedNetworkImageProvider(publisher.avatarUrl!) : null,
            child: publisher.avatarUrl == null ? const Icon(Icons.eco, size: 48, color: TrendingTheme.primary) : null,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(publisher.displayName, style: TrendingTheme.headlineMd()),
            if (publisher.isVerified) ...[
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: TrendingTheme.primary, size: 20),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(publisher.tagline, style: TrendingTheme.bodyMd()),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat(publisher.followersFormatted, 'Followers'),
            _stat('${publisher.followingCount}', 'Following'),
            _stat(publisher.impactFormatted, 'Impact'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          publisher.bio,
          textAlign: TextAlign.center,
          style: TrendingTheme.bodyMd(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _following = !_following),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _following ? TrendingTheme.surfaceContainer : TrendingTheme.primaryContainer,
                  foregroundColor: _following ? TrendingTheme.onSurface : TrendingTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_following ? 'Following' : 'Follow'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: TrendingTheme.onSurface,
                  side: BorderSide(color: TrendingTheme.outlineVariant.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Message'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: TrendingTheme.headlineSm()),
        Text(label, style: TrendingTheme.labelSm()),
      ],
    );
  }
}
