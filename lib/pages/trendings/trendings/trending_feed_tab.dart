import 'package:flutter/material.dart';
import 'package:mlimi/constants/trending_theme.dart';
import 'package:mlimi/models/trending_story.dart';
import 'package:mlimi/pages/trendings/widgets/bento_story_card.dart';
import 'package:mlimi/pages/trendings/widgets/carousel_story_card.dart';
import 'package:mlimi/services/trending_story_service.dart';

class TrendingFeedTab extends StatefulWidget {
  const TrendingFeedTab({super.key});

  @override
  State<TrendingFeedTab> createState() => _TrendingFeedTabState();
}

class _TrendingFeedTabState extends State<TrendingFeedTab> {
  final TrendingStoryService _service = TrendingStoryService();
  final ScrollController _scrollController = ScrollController();
  final List<TrendingStory> _stories = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) setState(() { _loading = true; _page = 1; _hasMore = true; });
    try {
      final result = await _service.fetchStories(page: 1);
      if (!mounted) return;
      setState(() {
        _stories..clear()..addAll(result.stories);
        _page = result.currentPage;
        _hasMore = result.hasMore;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    setState(() => _loadingMore = true);
    try {
      final result = await _service.fetchStories(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _stories.addAll(result.stories);
        _page = result.currentPage;
        _hasMore = result.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: TrendingTheme.primary));
    }
    if (_stories.isEmpty) {
      return Center(child: Text('No trends yet', style: TrendingTheme.bodyLg()));
    }

    return RefreshIndicator(
      color: TrendingTheme.primary,
      backgroundColor: TrendingTheme.surfaceContainer,
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        itemCount: _stories.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          if (index >= _stories.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: TrendingTheme.primary)),
            );
          }
          final story = _stories[index];
          if (story.isBento) return BentoStoryCard(story: story);
          return CarouselStoryCard(story: story);
        },
      ),
    );
  }
}
