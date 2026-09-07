import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mlimi/constants/trending_theme.dart';
import 'package:mlimi/models/trending_story.dart';
import 'package:mlimi/pages/trendings/creator_profile_screen.dart';
import 'package:mlimi/pages/trendings/trending_detail_screen.dart';
import 'package:mlimi/pages/trendings/widgets/glass_pill.dart';
import 'package:mlimi/services/trending_story_service.dart';

class TrendingExploreTab extends StatefulWidget {
  final void Function(String category)? onCategorySelected;

  const TrendingExploreTab({super.key, this.onCategorySelected});

  @override
  State<TrendingExploreTab> createState() => _TrendingExploreTabState();
}

class _TrendingExploreTabState extends State<TrendingExploreTab> {
  final TrendingStoryService _service = TrendingStoryService();
  final TextEditingController _searchController = TextEditingController();
  TrendingExploreData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _service.fetchExplore();
      if (!mounted) return;
      setState(() { _data = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: TrendingTheme.primary));
    }
    final data = _data;
    if (data == null) {
      return Center(child: Text('Unable to load explore', style: TrendingTheme.bodyLg()));
    }

    return RefreshIndicator(
      color: TrendingTheme.primary,
      backgroundColor: TrendingTheme.surfaceContainer,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _searchController,
            style: TrendingTheme.bodyMd(color: TrendingTheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search trends, topics, stories...',
              hintStyle: TrendingTheme.bodyMd(color: TrendingTheme.outline),
              prefixIcon: const Icon(Icons.search, color: TrendingTheme.primary),
              filled: true,
              fillColor: TrendingTheme.surfaceContainerLow,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: TrendingTheme.primary.withValues(alpha: 0.4)),
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                // Search handled via feed tab filter - parent can wire later
              }
            },
          ),
          const SizedBox(height: 24),
          _sectionHeader('Trending Categories', 'See all'),
          const SizedBox(height: 12),
          _categoryBento(data.categories),
          const SizedBox(height: 32),
          _sectionHeader('For You', 'More'),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.forYou.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) => _forYouCard(data.forYou[i]),
            ),
          ),
          const SizedBox(height: 32),
          _sectionHeader('Publisher', 'Profile'),
          const SizedBox(height: 12),
          _publisherCard(data.publisher),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action) {
    return Row(
      children: [
        Text(title, style: TrendingTheme.headlineSm()),
        const Spacer(),
        Text(action, style: TrendingTheme.labelMd(color: TrendingTheme.primary)),
      ],
    );
  }

  Widget _categoryBento(List<TrendingCategory> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final top = categories.take(4).toList();

    return SizedBox(
      height: 280,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                if (top.isNotEmpty)
                  Expanded(
                    flex: 1,
                    child: _categoryTile(top[0], tall: true),
                  ),
                const SizedBox(width: 8),
                if (top.length > 1)
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _categoryTile(top.length > 1 ? top[1] : top[0])),
                        const SizedBox(height: 8),
                        if (top.length > 2) Expanded(child: _categoryTile(top[2])),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (top.length > 3) ...[
            const SizedBox(height: 8),
            SizedBox(height: 80, child: _categoryTile(top[3], wide: true)),
          ],
        ],
      ),
    );
  }

  Widget _categoryTile(TrendingCategory category, {bool tall = false, bool wide = false}) {
    return GestureDetector(
      onTap: () => widget.onCategorySelected?.call(category.slug),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(wide ? 16 : 24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (category.coverImage != null)
              CachedNetworkImage(imageUrl: category.coverImage!, fit: BoxFit.cover)
            else
              Container(color: TrendingTheme.surfaceContainerHigh),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isEditorsPick) ...[
                    GlassPill(label: "Editor's Pick", uppercase: true),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  Text(category.name, style: TrendingTheme.headlineSm(color: Colors.white)),
                  Text('${category.storyCount} stories', style: TrendingTheme.labelSm(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _forYouCard(TrendingStory story) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrendingDetailScreen(storyId: story.id))),
      child: SizedBox(
        width: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: story.coverImage != null
                    ? CachedNetworkImage(imageUrl: story.coverImage!, fit: BoxFit.cover)
                    : Container(color: TrendingTheme.surfaceContainerHigh),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                GlassPill(label: story.categoryLabel, textColor: TrendingTheme.tertiary, backgroundColor: TrendingTheme.tertiaryContainer),
                const SizedBox(width: 8),
                Text(story.readTimeLabel, style: TrendingTheme.labelSm()),
              ],
            ),
            const SizedBox(height: 6),
            Text(story.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TrendingTheme.headlineSm()),
          ],
        ),
      ),
    );
  }

  Widget _publisherCard(TrendingPublisher publisher) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatorProfileScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TrendingTheme.surfaceContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TrendingTheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: publisher.avatarUrl != null ? CachedNetworkImageProvider(publisher.avatarUrl!) : null,
              backgroundColor: TrendingTheme.surfaceContainerHigh,
              child: publisher.avatarUrl == null ? const Icon(Icons.eco, color: TrendingTheme.primary) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(publisher.displayName, style: TrendingTheme.labelMd()),
                      if (publisher.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 16, color: TrendingTheme.primary),
                      ],
                    ],
                  ),
                  Text(publisher.username, style: TrendingTheme.labelSm()),
                  Text(publisher.tagline, style: TrendingTheme.bodyMd(), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: TrendingTheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Follow', style: TrendingTheme.labelMd(color: TrendingTheme.onPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}
