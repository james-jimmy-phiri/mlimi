import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mlimi/constants/url.dart';

class HttpProvider {
  Future<Map<String, dynamic>?> getUser(String token) async {
    try {
      var url = Uri.parse('${apiurl}v1/profile');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['profile'];
      } else if (response.statusCode == 401) {
        return {'error': 'unauthorized'};
      } else {
        print('Failed to load user data: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error occurred: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProfile(String token, int clientId, Map<String, dynamic> data) async {
    try {
      var url = Uri.parse('${apiurl}v1/profile/$clientId/update');
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        return {'error': 'unauthorized'};
      } else {
        print('Failed to update profile: ${response.statusCode} - ${response.body}');
        return {'error': 'failed', 'details': response.body};
      }
    } catch (error) {
      print('Error occurred: $error');
      return {'error': 'exception', 'details': error.toString()};
    }
  }
}
