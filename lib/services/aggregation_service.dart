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

  Future<Aggregation> createAggregation(Map<String, dynamic> data, {String? imagePath}) async {
    if (imagePath != null) {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/aggregations'));
      request.headers.addAll(_headers);
      
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return Aggregation.fromJson(jsonResponse['data']);
      } else {
        final errorBody = json.decode(responseBody);
        throw Exception(errorBody['message'] ?? 'Failed to create aggregation');
      }
    } else {
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
  }

  Future<void> deleteAggregation(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/aggregations/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to delete aggregation');
    }
  }

  Future<void> finalizeAndBroadcast(int id, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/aggregations/$id/finalize'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to finalize aggregation');
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

  Future<AggregationMetrics> getDashboardStats({int? groupId}) async {
    String url = '$baseUrl/aggregations/dashboard/stats';
    if (groupId != null) url += '?group_id=$groupId';
    
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return AggregationMetrics.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch dashboard metrics');
    }
  }

  Future<List<AggregationGroupMember>> getGroupMembers(int groupId) async {
    final response = await http.get(Uri.parse('$baseUrl/clients/$groupId/members'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AggregationGroupMember.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch group members');
    }
  }

  Future<List<AggregationBuyer>> getBuyers() async {
    final response = await http.get(Uri.parse('$baseUrl/buyers'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AggregationBuyer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch buyers');
    }
  }

  Future<List<Map<String, dynamic>>> getGroups() async {
    final response = await http.get(Uri.parse('$baseUrl/clients'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      // Fallback to business profiles if clients endpoint is missing
      final profilesResponse = await http.get(Uri.parse('$baseUrl/business-profiles'), headers: _headers);
      if (profilesResponse.statusCode == 200) {
        final data = json.decode(profilesResponse.body);
        final List<dynamic> profiles = data['business_profiles'] ?? [];
        return profiles.map((p) => {'id': p['id'], 'name': p['business_name']}).toList();
      }
      throw Exception('Failed to fetch groups');
    }
  }

  Future<List<Map<String, dynamic>>> getValueChains() async {
    final response = await http.get(Uri.parse('$baseUrl/value-chains'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch value chains');
    }
  }

  Future<AggregationContribution> updateContribution(int aggregationId, int contributionId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/aggregations/$aggregationId/contributions/$contributionId'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return AggregationContribution.fromJson(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to update contribution');
    }
  }
}
