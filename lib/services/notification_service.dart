import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mlimi/constants/url.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  // Chichewa versions (highest priority)
  final String? titleNy;
  final String? messageNy;
  final String event;
  final bool isViewed;
  final String received;
  final String? createdAt;
  final Map<String, dynamic> data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.titleNy,
    this.messageNy,
    required this.event,
    required this.isViewed,
    required this.received,
    this.createdAt,
    this.data = const {},
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Mlimi Notification',
      message: json['message'] ?? json['notification'] ?? '',
      titleNy: json['title_ny'],
      messageNy: json['message_ny'],
      event: json['event'] ?? 'general',
      isViewed: json['is_viewed'] == true,
      received: json['received'] ?? '',
      createdAt: json['created_at'],
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'])
          : {},
    );
  }

  /// Returns the title in the user's stored language preference.
  /// Chichewa (ny) is the highest priority.
  String localizedTitle(String language) {
    if (language == 'ny' && titleNy != null && titleNy!.isNotEmpty) {
      return titleNy!;
    }
    return title;
  }

  /// Returns the message body in the user's stored language preference.
  String localizedMessage(String language) {
    if (language == 'ny' && messageNy != null && messageNy!.isNotEmpty) {
      return messageNy!;
    }
    return message;
  }

  String? get trendingStoryId => data['trending_story_id']?.toString();
}

class NotificationService {
  final _storage = GetStorage();

  Map<String, String> _headers() => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_storage.read('token')}',
      };

  Future<Map<String, dynamic>> fetchNotifications({bool unreadOnly = false}) async {
    final response = await http.get(
      Uri.parse('${apiurl}v1/profile/notifications?per_page=50${unreadOnly ? '&unread_only=1' : ''}'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final raw = body['notifications'];
      final list = raw is Map ? (raw['data'] as List? ?? []) : (raw as List? ?? []);
      return {
        'items': list.map((e) => AppNotification.fromJson(e)).toList(),
        'unread_count': body['unread_count'] ?? 0,
      };
    }
    throw Exception('Failed to load notifications');
  }

  Future<void> markAsRead(String id) async {
    await http.get(
      Uri.parse('${apiurl}v1/profile/notifications/$id/view'),
      headers: _headers(),
    );
  }

  Future<void> markAllRead() async {
    await http.post(
      Uri.parse('${apiurl}v1/profile/notifications/mark-all-read'),
      headers: _headers(),
    );
  }

  Future<void> registerDeviceToken(String token, {String platform = 'android'}) async {
    if (_storage.read('token') == null) return;
    await http.post(
      Uri.parse('${apiurl}v1/profile/device-token'),
      headers: _headers(),
      body: json.encode({'token': token, 'platform': platform}),
    );
  }

  /// Sync the user's language selection to the backend so notifications
  /// are delivered in Chichewa (ny) or English (en) accordingly.
  Future<void> syncLanguageToBackend(String language) async {
    if (_storage.read('token') == null) return;
    try {
      await http.patch(
        Uri.parse('${apiurl}v1/profile/language'),
        headers: _headers(),
        body: json.encode({'language': language}),
      );
    } catch (_) {
      // Non-critical — local language still works even if sync fails
      if (kDebugMode) debugPrint('[NotificationService] Language sync failed silently.');
    }
  }
}
