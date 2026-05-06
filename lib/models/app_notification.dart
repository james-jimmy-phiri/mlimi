class AppNotification {
  final int id;
  final String event;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.event,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      event: json['event'] ?? '',
      message: json['message'] ?? '',
      // Backend might return is_read or isRead, and it might be 0/1 or bool
      isRead: (json['isRead'] == true || json['isRead'] == 1) || 
              (json['is_read'] == true || json['is_read'] == 1),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
