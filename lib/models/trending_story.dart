class TrendingPublisher {
  final String displayName;
  final String username;
  final String tagline;
  final String bio;
  final String? location;
  final String? avatarUrl;
  final bool isVerified;
  final int followersCount;
  final String followersFormatted;
  final int followingCount;
  final int impactCount;
  final String impactFormatted;
  final int storyCount;

  TrendingPublisher({
    required this.displayName,
    required this.username,
    required this.tagline,
    required this.bio,
    this.location,
    this.avatarUrl,
    required this.isVerified,
    required this.followersCount,
    required this.followersFormatted,
    required this.followingCount,
    required this.impactCount,
    required this.impactFormatted,
    required this.storyCount,
  });

  factory TrendingPublisher.fromJson(Map<String, dynamic> json) {
    return TrendingPublisher(
      displayName: json['display_name'] ?? 'Farm Radio Trust',
      username: json['username'] ?? '@mlimi_app',
      tagline: json['tagline'] ?? '',
      bio: json['bio'] ?? '',
      location: json['location'],
      avatarUrl: json['avatar_url'],
      isVerified: json['is_verified'] == true,
      followersCount: int.tryParse(json['followers_count']?.toString() ?? '0') ?? 0,
      followersFormatted: json['followers_count_formatted'] ?? '0',
      followingCount: int.tryParse(json['following_count']?.toString() ?? '0') ?? 0,
      impactCount: int.tryParse(json['impact_count']?.toString() ?? '0') ?? 0,
      impactFormatted: json['impact_count_formatted'] ?? '0',
      storyCount: int.tryParse(json['story_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class TrendingCategory {
  final String slug;
  final String name;
  final String? coverImage;
  final int storyCount;
  final bool isEditorsPick;

  TrendingCategory({
    required this.slug,
    required this.name,
    this.coverImage,
    required this.storyCount,
    required this.isEditorsPick,
  });

  factory TrendingCategory.fromJson(Map<String, dynamic> json) {
    return TrendingCategory(
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      coverImage: json['cover_image'],
      storyCount: int.tryParse(json['story_count']?.toString() ?? '0') ?? 0,
      isEditorsPick: json['is_editors_pick'] == true,
    );
  }
}

class TrendingStory {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String? excerpt;
  final List<String> bodyParagraphs;
  final String? storyDate;
  final String category;
  final String categoryLabel;
  final List<String> tags;
  final bool isFeatured;
  final bool isEditorsPick;
  final String? publishedAt;
  final String? publishedAtRelative;
  final String? publishedAtFormatted;
  final String authorName;
  final String authorSubtitle;
  final String? authorLogo;
  final String? authorUsername;
  final String? externalLink;
  final int viewCount;
  final String viewCountFormatted;
  final int likeCount;
  final String likeCountFormatted;
  final int commentCount;
  final String commentCountFormatted;
  final int readTimeMinutes;
  final String readTimeLabel;
  final String cardLayoutType;
  final String? eventTag;
  final bool isLiked;
  final bool isBookmarked;
  final String? coverImage;
  final List<String> images;

  TrendingStory({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.excerpt,
    required this.bodyParagraphs,
    this.storyDate,
    required this.category,
    required this.categoryLabel,
    required this.tags,
    required this.isFeatured,
    required this.isEditorsPick,
    this.publishedAt,
    this.publishedAtRelative,
    this.publishedAtFormatted,
    required this.authorName,
    required this.authorSubtitle,
    this.authorLogo,
    this.authorUsername,
    this.externalLink,
    required this.viewCount,
    required this.viewCountFormatted,
    required this.likeCount,
    required this.likeCountFormatted,
    required this.commentCount,
    required this.commentCountFormatted,
    required this.readTimeMinutes,
    required this.readTimeLabel,
    required this.cardLayoutType,
    this.eventTag,
    required this.isLiked,
    required this.isBookmarked,
    this.coverImage,
    required this.images,
  });

  bool get isBento => cardLayoutType == 'bento' && images.length >= 3;

  TrendingStory copyWith({
    int? likeCount,
    String? likeCountFormatted,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return TrendingStory(
      id: id,
      title: title,
      slug: slug,
      description: description,
      excerpt: excerpt,
      bodyParagraphs: bodyParagraphs,
      storyDate: storyDate,
      category: category,
      categoryLabel: categoryLabel,
      tags: tags,
      isFeatured: isFeatured,
      isEditorsPick: isEditorsPick,
      publishedAt: publishedAt,
      publishedAtRelative: publishedAtRelative,
      publishedAtFormatted: publishedAtFormatted,
      authorName: authorName,
      authorSubtitle: authorSubtitle,
      authorLogo: authorLogo,
      authorUsername: authorUsername,
      externalLink: externalLink,
      viewCount: viewCount,
      viewCountFormatted: viewCountFormatted,
      likeCount: likeCount ?? this.likeCount,
      likeCountFormatted: likeCountFormatted ?? this.likeCountFormatted,
      commentCount: commentCount,
      commentCountFormatted: commentCountFormatted,
      readTimeMinutes: readTimeMinutes,
      readTimeLabel: readTimeLabel,
      cardLayoutType: cardLayoutType,
      eventTag: eventTag,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      coverImage: coverImage,
      images: images,
    );
  }

  factory TrendingStory.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = rawImages is List ? rawImages.map((e) => e.toString()).toList() : <String>[];
    final rawTags = json['tags'];
    final tags = rawTags is List ? rawTags.map((e) => e.toString()).toList() : <String>[];
    final rawParagraphs = json['body_paragraphs'];
    final paragraphs = rawParagraphs is List
        ? rawParagraphs.map((e) => e.toString()).toList()
        : <String>[];

    return TrendingStory(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      excerpt: json['excerpt'],
      bodyParagraphs: paragraphs.isNotEmpty ? paragraphs : [json['description'] ?? ''],
      storyDate: json['story_date'],
      category: json['category'] ?? 'general',
      categoryLabel: json['category_label'] ?? json['category'] ?? 'General',
      tags: tags,
      isFeatured: json['is_featured'] == true,
      isEditorsPick: json['is_editors_pick'] == true,
      publishedAt: json['published_at'],
      publishedAtRelative: json['published_at_relative'],
      publishedAtFormatted: json['published_at_formatted'],
      authorName: json['author_name'] ?? 'Farm Radio Trust',
      authorSubtitle: json['author_subtitle'] ?? 'Mlimi App',
      authorLogo: json['author_logo'],
      authorUsername: json['author_username'],
      externalLink: json['external_link'],
      viewCount: int.tryParse(json['view_count']?.toString() ?? '0') ?? 0,
      viewCountFormatted: json['view_count_formatted'] ?? '0',
      likeCount: int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      likeCountFormatted: json['like_count_formatted'] ?? '0',
      commentCount: int.tryParse(json['comment_count']?.toString() ?? '0') ?? 0,
      commentCountFormatted: json['comment_count_formatted'] ?? '0',
      readTimeMinutes: int.tryParse(json['read_time_minutes']?.toString() ?? '1') ?? 1,
      readTimeLabel: json['read_time_label'] ?? '1m read',
      cardLayoutType: json['card_layout_type'] ?? 'carousel',
      eventTag: json['event_tag'],
      isLiked: json['is_liked'] == true,
      isBookmarked: json['is_bookmarked'] == true,
      coverImage: json['cover_image'] ?? json['hero_image'],
      images: images,
    );
  }
}

class TrendingStoryPage {
  final List<TrendingStory> stories;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  TrendingStoryPage({
    required this.stories,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });
}

class TrendingExploreData {
  final List<TrendingCategory> categories;
  final List<TrendingStory> forYou;
  final List<TrendingStory> featured;
  final TrendingPublisher publisher;

  TrendingExploreData({
    required this.categories,
    required this.forYou,
    required this.featured,
    required this.publisher,
  });
}
