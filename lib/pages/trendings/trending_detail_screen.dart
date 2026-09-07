import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mlimi/constants/trending_theme.dart';
import 'package:mlimi/models/trending_story.dart';
import 'package:mlimi/pages/trendings/creator_profile_screen.dart';
import 'package:mlimi/pages/trendings/trending_image_viewer.dart';
import 'package:mlimi/pages/trendings/widgets/glass_pill.dart';
import 'package:mlimi/services/trending_story_service.dart';
import 'package:share_plus/share_plus.dart';

class TrendingDetailScreen extends StatefulWidget {
  final String storyId;

  const TrendingDetailScreen({super.key, required this.storyId});

  @override
  State<TrendingDetailScreen> createState() => _TrendingDetailScreenState();
}

class _TrendingDetailScreenState extends State<TrendingDetailScreen> {
  final TrendingStoryService _service = TrendingStoryService();
  final ScrollController _scrollController = ScrollController();
  TrendingStory? _story;
  List<TrendingStory> _related = [];
  bool _loading = true;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() => setState(() => _scrollOffset = _scrollController.offset));
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final result = await _service.fetchStoryDetail(widget.storyId);
      if (!mounted) return;
      setState(() {
        _story = result['story'] as TrendingStory;
        _related = result['related'] as List<TrendingStory>;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_story == null) return;
    try {
      final result = await _service.toggleLike(_story!.id);
      setState(() => _story = _story!.copyWith(
            isLiked: result['is_liked'] == true,
            likeCount: int.tryParse(result['like_count']?.toString() ?? '0') ?? _story!.likeCount,
            likeCountFormatted: result['like_count_formatted']?.toString() ?? _story!.likeCountFormatted,
          ));
    } catch (_) {}
  }

  Future<void> _toggleBookmark() async {
    if (_story == null) return;
    try {
      final saved = await _service.toggleBookmark(_story!.id);
      setState(() => _story = _story!.copyWith(isBookmarked: saved));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(scaffoldBackgroundColor: TrendingTheme.background),
      child: Scaffold(
        backgroundColor: TrendingTheme.background,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: TrendingTheme.primary))
            : _story == null
                ? Center(child: Text('Story not found', style: TrendingTheme.bodyLg()))
                : CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: TrendingTheme.background.withValues(alpha: 0.85),
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back, color: TrendingTheme.primary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: Text('Trending', style: TrendingTheme.displayLgMobile().copyWith(fontSize: 18)),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: TrendingTheme.onSurfaceVariant),
                            onPressed: () => Share.share('${_story!.title}\n\n${_story!.excerpt ?? ''}'),
                          ),
                          IconButton(
                            icon: Icon(
                              _story!.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                              color: TrendingTheme.onSurfaceVariant,
                            ),
                            onPressed: _toggleBookmark,
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: ClipRect(
                          child: SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.62,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Transform.translate(
                                  offset: Offset(0, _scrollOffset * 0.3),
                                  child: _story!.coverImage != null
                                      ? CachedNetworkImage(imageUrl: _story!.coverImage!, fit: BoxFit.cover)
                                      : Container(color: TrendingTheme.surfaceContainerHigh),
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          TrendingTheme.background,
                                          TrendingTheme.background.withValues(alpha: 0.8),
                                          Colors.transparent,
                                        ],
                                        stops: const [0, 0.35, 1],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GlassPill(
                                        label: _story!.categoryLabel,
                                        textColor: TrendingTheme.primary,
                                        backgroundColor: TrendingTheme.primary,
                                        uppercase: true,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(_story!.title, style: TrendingTheme.displayLgMobile().copyWith(color: TrendingTheme.onSurfaceVariant)),
                                      const SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatorProfileScreen())),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundImage: _story!.authorLogo != null
                                                  ? CachedNetworkImageProvider(_story!.authorLogo!)
                                                  : null,
                                              backgroundColor: TrendingTheme.surfaceContainerHigh,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(_story!.authorName, style: TrendingTheme.labelMd(color: TrendingTheme.onSurface)),
                                            const _Dot(),
                                            Text(_story!.publishedAtFormatted ?? '', style: TrendingTheme.labelMd(color: TrendingTheme.onSurfaceVariant)),
                                            const _Dot(),
                                            const Icon(Icons.visibility, size: 14, color: TrendingTheme.onSurfaceVariant),
                                            const SizedBox(width: 4),
                                            Text('${_story!.viewCountFormatted} views', style: TrendingTheme.labelMd(color: TrendingTheme.onSurfaceVariant)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._story!.bodyParagraphs.asMap().entries.map((entry) {
                                final i = entry.key;
                                final p = entry.value;
                                if (i == 0 && p.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TrendingTheme.bodyLg().copyWith(height: 1.7),
                                        children: [
                                          TextSpan(
                                            text: p[0],
                                            style: TrendingTheme.displayLgMobile().copyWith(
                                              color: TrendingTheme.primary,
                                              height: 0.8,
                                              fontSize: 48,
                                            ),
                                          ),
                                          TextSpan(text: p.length > 1 ? p.substring(1) : ''),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(p, style: TrendingTheme.bodyLg().copyWith(height: 1.7)),
                                );
                              }),
                              if (_story!.images.length > 1) ...[
                                SizedBox(
                                  height: 384,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _story!.images.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                                    itemBuilder: (_, i) => GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => TrendingImageViewer(story: _story!, initialIndex: i)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: CachedNetworkImage(
                                          imageUrl: _story!.images[i],
                                          width: 288,
                                          height: 384,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: TrendingTheme.outlineVariant.withValues(alpha: 0.15)),
                                    bottom: BorderSide(color: TrendingTheme.outlineVariant.withValues(alpha: 0.15)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _engagementButton(
                                      icon: _story!.isLiked ? Icons.favorite : Icons.favorite_border,
                                      label: _story!.likeCountFormatted,
                                      onTap: _toggleLike,
                                      active: _story!.isLiked,
                                    ),
                                    const SizedBox(width: 28),
                                    _engagementButton(
                                      icon: Icons.chat_bubble_outline,
                                      label: _story!.commentCountFormatted,
                                      onTap: () {},
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () => Share.share(_story!.title),
                                      icon: const Icon(Icons.send_outlined, color: TrendingTheme.onSurface),
                                    ),
                                  ],
                                ),
                              ),
                              if (_related.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Text('Related Stories', style: TrendingTheme.headlineSm()),
                                const SizedBox(height: 12),
                                ..._related.map((s) => _relatedTile(s)),
                              ],
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _engagementButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: active ? TrendingTheme.primary : TrendingTheme.onSurface, size: 24),
          const SizedBox(width: 8),
          Text(label, style: TrendingTheme.labelMd()),
        ],
      ),
    );
  }

  Widget _relatedTile(TrendingStory story) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TrendingDetailScreen(storyId: story.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: story.coverImage ?? '',
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(story.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TrendingTheme.labelMd()),
                  const SizedBox(height: 4),
                  Text('${story.categoryLabel} • ${story.readTimeLabel}', style: TrendingTheme.labelSm()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: TrendingTheme.outlineVariant.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
