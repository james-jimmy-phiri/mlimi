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
}
