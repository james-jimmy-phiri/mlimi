class AppNotification {
  final int id;
  final String event;
  final String message;
  final String title;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  AppNotification({
    required this.id,
    required this.event,
    required this.message,
    this.title = 'Mlimi Notification',
    required this.isRead,
    required this.createdAt,
    this.data = const {},
  });

  String? get trendingStoryId => data['trending_story_id']?.toString();

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      event: json['event'] ?? '',
      message: json['message'] ?? json['notification'] ?? '',
      title: json['title'] ?? 'Mlimi Notification',
      isRead: (json['isRead'] == true || json['isRead'] == 1) ||
          (json['is_read'] == true || json['is_read'] == 1) ||
          (json['is_viewed'] == true || json['is_viewed'] == 1),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'message': message,
      'title': title,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'data': data,
    };
  }
}
