import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mlimi/constants/trending_theme.dart';
import 'package:mlimi/models/trending_story.dart';
import 'package:mlimi/pages/trendings/trending_detail_screen.dart';
import 'package:mlimi/pages/trendings/widgets/glass_pill.dart';

class BentoStoryCard extends StatelessWidget {
  final TrendingStory story;

  const BentoStoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final images = story.images.length >= 3 ? story.images : List<String>.filled(3, story.coverImage ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TrendingDetailScreen(storyId: story.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      child: CachedNetworkImage(imageUrl: images[0], fit: BoxFit.cover, height: double.infinity),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(topRight: Radius.circular(12)),
                            child: CachedNetworkImage(imageUrl: images[1], fit: BoxFit.cover, width: double.infinity),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)),
                            child: CachedNetworkImage(imageUrl: images[2], fit: BoxFit.cover, width: double.infinity),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GlassPill(
                  label: story.categoryLabel,
                  textColor: TrendingTheme.tertiary,
                  backgroundColor: TrendingTheme.tertiaryContainer,
                ),
                const SizedBox(width: 8),
                Text(story.publishedAtRelative ?? '', style: TrendingTheme.labelSm()),
              ],
            ),
            const SizedBox(height: 6),
            Text(story.title, style: TrendingTheme.headlineSm()),
            const SizedBox(height: 4),
            Text(story.excerpt ?? story.description, style: TrendingTheme.bodyMd()),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Read More', style: TrendingTheme.labelMd(color: TrendingTheme.primary)),
                const Icon(Icons.arrow_forward, size: 16, color: TrendingTheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
