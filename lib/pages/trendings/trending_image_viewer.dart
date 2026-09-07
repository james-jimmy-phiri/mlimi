import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mlimi/constants/trending_theme.dart';
import 'package:mlimi/models/trending_story.dart';
import 'package:mlimi/pages/trendings/trending_detail_screen.dart';
import 'package:mlimi/pages/trendings/widgets/glass_pill.dart';
import 'package:mlimi/services/trending_story_service.dart';
import 'package:share_plus/share_plus.dart';

class TrendingImageViewer extends StatefulWidget {
  final TrendingStory story;
  final int initialIndex;

  const TrendingImageViewer({super.key, required this.story, this.initialIndex = 0});

  @override
  State<TrendingImageViewer> createState() => _TrendingImageViewerState();
}

class _TrendingImageViewerState extends State<TrendingImageViewer> {
  late final PageController _controller;
  late int _index;
  final TrendingStoryService _service = TrendingStoryService();
  late TrendingStory _story;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
    _story = widget.story;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    try {
      final result = await _service.toggleLike(_story.id);
      setState(() => _story = _story.copyWith(
            isLiked: result['is_liked'] == true,
            likeCountFormatted: result['like_count_formatted']?.toString() ?? _story.likeCountFormatted,
          ));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final images = _story.images;

    return Scaffold(
      backgroundColor: TrendingTheme.pureBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 0.9,
              maxScale: 4,
              child: Center(
                child: CachedNetworkImage(imageUrl: images[i], fit: BoxFit.contain, width: double.infinity),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 0,
            right: 0,
            child: Row(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: TrendingTheme.glass(),
                  child: Text('${_index + 1} / ${images.length}', style: TrendingTheme.labelMd()),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: TrendingTheme.glass(),
                      child: const Icon(Icons.close, color: TrendingTheme.onSurface),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (images.length > 1)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 56,
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(images.length, (i) {
                  return Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.only(right: i < images.length - 1 ? 4 : 0),
                      color: Colors.white.withValues(alpha: i == _index ? 1 : 0.2),
                    ),
                  );
                }),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.paddingOf(context).bottom + 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Color(0x66000000), Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_story.eventTag != null) ...[
                    GlassPill(label: _story.eventTag!, uppercase: true),
                    const SizedBox(height: 8),
                  ],
                  GlassPill(label: _story.categoryLabel),
                  const SizedBox(height: 8),
                  Text(_story.title, style: TrendingTheme.headlineMd(color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                    _story.excerpt ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TrendingTheme.bodyMd(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Row(
                          children: [
                            Icon(
                              _story.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _story.isLiked ? TrendingTheme.primary : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(_story.likeCountFormatted, style: TrendingTheme.labelMd(color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => Share.share(_story.title),
                        child: const Icon(Icons.share_outlined, color: Colors.white),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TrendingDetailScreen(storyId: _story.id)),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: TrendingTheme.primary,
                          foregroundColor: TrendingTheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('View Story', style: TrendingTheme.labelMd(color: TrendingTheme.onPrimary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
