import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/aggregation_models.dart';

class AggregationService {
  final String baseUrl = '${apiurl}v1';

  Map<String, String> get _headers {
    final token = GetStorage().read('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getAggregations({String? status, int? groupId, int page = 1}) async {
    String url = '$baseUrl/aggregations?page=$page';
    if (status != null && status.isNotEmpty) url += '&status=$status';
    if (groupId != null) url += '&group_id=$groupId';

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? [];
      final List<Aggregation> aggregations = data.map((json) => Aggregation.fromJson(json)).toList();
      return {
        'aggregations': aggregations,
        'current_page': jsonResponse['current_page'],
        'last_page': jsonResponse['last_page'],
      };
    } else {
      throw Exception('Failed to load aggregations');
    }
  }

  Future<Aggregation> getAggregationDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/aggregations/$id'), headers: _headers);
    if (response.statusCode == 200) {
      return Aggregation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch aggregation details');
    }
  }

  Future<Aggregation> createAggregation(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/aggregations'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Aggregation.fromJson(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to create aggregation');
    }
  }

  Future<AggregationContribution> addContribution(int id, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/aggregations/$id/contribute'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return AggregationContribution.fromJson(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to add contribution');
    }
  }

  Future<AggregationContribution> addNewMemberContribution(int id, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/aggregations/$id/contribute-new-member'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return AggregationContribution.fromJson(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to add new member and contribution');
    }
  }

  Future<AggregationSale> recordSale(int id, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/aggregations/$id/sell'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return AggregationSale.fromJson(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to record sale');
    }
  }

  Future<AggregationMetrics> getDashboardStats() async {
    final response = await http.get(Uri.parse('$baseUrl/aggregations/dashboard/stats'), headers: _headers);
    if (response.statusCode == 200) {
      return AggregationMetrics.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch dashboard metrics');
    }
  }
}
