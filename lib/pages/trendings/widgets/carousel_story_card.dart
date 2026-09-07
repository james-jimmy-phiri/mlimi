import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mlimi/constants/trending_theme.dart';
import 'package:mlimi/models/trending_story.dart';
import 'package:mlimi/pages/trendings/trending_detail_screen.dart';
import 'package:mlimi/pages/trendings/trending_image_viewer.dart';
import 'package:mlimi/pages/trendings/widgets/glass_pill.dart';
import 'package:mlimi/services/trending_story_service.dart';
import 'package:share_plus/share_plus.dart';

class CarouselStoryCard extends StatefulWidget {
  final TrendingStory story;
  final VoidCallback? onUpdated;

  const CarouselStoryCard({super.key, required this.story, this.onUpdated});

  @override
  State<CarouselStoryCard> createState() => _CarouselStoryCardState();
}

class _CarouselStoryCardState extends State<CarouselStoryCard> {
  final PageController _controller = PageController();
  final TrendingStoryService _service = TrendingStoryService();
  int _index = 0;
  late TrendingStory _story;

  @override
  void initState() {
    super.initState();
    _story = widget.story;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleBookmark() async {
    try {
      final saved = await _service.toggleBookmark(_story.id);
      setState(() => _story = _story.copyWith(isBookmarked: saved));
      widget.onUpdated?.call();
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    try {
      final result = await _service.toggleLike(_story.id);
      setState(() => _story = _story.copyWith(
            isLiked: result['is_liked'] == true,
            likeCount: int.tryParse(result['like_count']?.toString() ?? '0') ?? _story.likeCount,
            likeCountFormatted: result['like_count_formatted']?.toString() ?? _story.likeCountFormatted,
          ));
    } catch (_) {}
  }

  void _openDetail() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TrendingDetailScreen(storyId: _story.id)));
  }

  @override
  Widget build(BuildContext context) {
    final images = _story.images.isNotEmpty ? _story.images : [_story.coverImage ?? ''];

    return GestureDetector(
      onTap: _openDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrendingImageViewer(story: _story, initialIndex: i),
                      ),
                    ),
                    child: CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover),
                  ),
                ),
                if (images.length > 1)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: List.generate(images.length, (i) {
                        return Expanded(
                          child: Container(
                            height: 3,
                            margin: EdgeInsets.only(right: i < images.length - 1 ? 4 : 0),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: i == _index ? 0.35 : 0.1),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: i == _index ? 1 : 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(decoration: TrendingTheme.scrimBottom()),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlassPill(label: _story.categoryLabel),
                            const SizedBox(height: 6),
                            Text(_story.title, style: TrendingTheme.headlineMd(color: Colors.white)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleBookmark,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _story.isBookmarked ? TrendingTheme.primary : TrendingTheme.surfaceContainerHigh,
                            shape: BoxShape.circle,
                            border: Border.all(color: TrendingTheme.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          child: Icon(
                            _story.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                            color: _story.isBookmarked ? TrendingTheme.onPrimary : TrendingTheme.onSurface,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _story.excerpt ?? _story.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TrendingTheme.bodyMd(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_story.publishedAtRelative ?? ''} • ${_story.viewCountFormatted} views',
                        style: TrendingTheme.labelSm(),
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _story.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: _story.isLiked ? TrendingTheme.primary : TrendingTheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(_story.likeCountFormatted, style: TrendingTheme.labelMd(color: TrendingTheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Share.share('${_story.title}\n\n${_story.excerpt ?? _story.description}'),
                      child: const Icon(Icons.share_outlined, size: 20, color: TrendingTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
