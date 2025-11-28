import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/nutrient_models.dart';

class NutrientService {
  NutrientService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final GetStorage _storage = GetStorage();

  Future<NutrientRecommendationResult> generateRecommendation(
    NutrientRecommendationRequest request,
  ) async {
    final uri = Uri.parse('${apiurl}v1/nutrient/recommendations');
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );

    final decoded = _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return NutrientRecommendationResult.fromJson(decoded);
    }
    throw NutrientException(_extractMessage(decoded));
  }

  Future<NutrientSendResponse> sendRecommendation({
    required int recommendationId,
    required String channel,
    required String language,
    required bool shortSms,
  }) async {
    final uri = Uri.parse(
      '${apiurl}v1/nutrient/recommendations/$recommendationId/send',
    );
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'channel': channel,
        'language': language,
        'short_sms': shortSms,
      }),
    );

    final decoded = _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return NutrientSendResponse.fromJson(decoded);
    }
    throw NutrientException(_extractMessage(decoded));
  }

  Map<String, String> _headers() {
    final token = _storage.read('token') as String?;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': 'Unexpected server response'};
    }
  }

  String _extractMessage(Map<String, dynamic> decoded) {
    if (decoded['message'] != null) {
      return decoded['message'].toString();
    }
    final errors = decoded['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstKey = errors.keys.first;
      final messages = errors[firstKey];
      if (messages is List && messages.isNotEmpty) {
        return messages.first.toString();
      }
    }
    return 'Something went wrong. Please try again.';
  }
}

