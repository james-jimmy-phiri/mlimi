import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/app_notification.dart';

class NotificationService {
  final String baseUrl = '${apiurl}v1/profile/notifications';

  Map<String, String> get _headers {
    final token = GetStorage().read('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await http.get(Uri.parse(baseUrl), headers: _headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      
      // Handle the case where the API returns an array directly, or a paginated object
      List<dynamic> data = [];
      if (jsonResponse is List) {
        data = jsonResponse;
      } else if (jsonResponse != null && jsonResponse['data'] != null) {
        data = jsonResponse['data'];
      }

      return data.map((item) => AppNotification.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<AppNotification> getNotificationDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: _headers);
    if (response.statusCode == 200) {
      return AppNotification.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch notification details');
    }
  }

  Future<bool> markAsRead(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id/view'), headers: _headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to mark notification as read');
    }
  }
}
