import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/farming_profile_models.dart';

class FarmingProfileService {
  final String baseUrl = '${apiurl}v1';

  Map<String, String> get _authHeaders {
    final token = GetStorage().read('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ---------------------------------------------------------------------------
  // VALUE CHAINS
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getValueChains() async {
    final response = await http.get(
      Uri.parse('$baseUrl/value-chains'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED: Please login or signup to access your farming profile');
    } else {
      throw Exception('Failed to load value chains');
    }
  }

  // ---------------------------------------------------------------------------
  // SEASONS
  // ---------------------------------------------------------------------------

  Future<List<FarmingSeason>> getSeasons() async {
    final response = await http.get(
      Uri.parse('$baseUrl/farming-seasons'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((json) => FarmingSeason.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED: Please login or signup to access your farming profile');
    } else {
      throw Exception('Failed to load farming seasons');
    }
  }

  Future<Map<String, dynamic>> getSeasonDetails(int seasonId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/farming-seasons/$seasonId'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return {
        'season': FarmingSeason.fromJson(jsonResponse['data']),
        'summary': jsonResponse['season_sales_summary'] != null
            ? SeasonSalesSummary.fromJson(jsonResponse['season_sales_summary'])
            : null,
        'sales': (jsonResponse['season_sales'] as List<dynamic>?)
                ?.map((s) => SeasonSale.fromJson(s))
                .toList() ??
            [],
        'expenditures': (jsonResponse['expenditures'] as List<dynamic>?)
                ?.map((e) => SeasonExpenditure.fromJson(e))
                .toList() ??
            [],
      };
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED: Please login or signup to access your farming profile');
    } else {
      throw Exception('Failed to load season details');
    }
  }

  Future<FarmingSeason> createSeason({
    required String name,
    required String type,
    required String startYear,
    required String startDate,
    String? endDate,
    required String status,
    String? notes,
  }) async {
    final body = {
      'name': name,
      'type': type,
      'start_year': startYear,
      'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
    final response = await http.post(
      Uri.parse('$baseUrl/farming-seasons'),
      headers: _authHeaders,
      body: json.encode(body),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return FarmingSeason.fromJson(jsonResponse['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create season');
    }
  }

  Future<FarmingSeason> updateSeason(int id, {
    required String name,
    required String type,
    required String startYear,
    required String startDate,
    String? endDate,
    required String status,
    String? notes,
  }) async {
    final body = {
      'name': name,
      'type': type,
      'start_year': startYear,
      'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'status': status,
      if (notes != null) 'notes': notes,
    };
    final response = await http.put(
      Uri.parse('$baseUrl/farming-seasons/$id'),
      headers: _authHeaders,
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return FarmingSeason.fromJson(jsonResponse['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update season');
    }
  }

  Future<void> deleteSeason(int seasonId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/farming-seasons/$seasonId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete season');
    }
  }

  // ---------------------------------------------------------------------------
  // CROPS
  // ---------------------------------------------------------------------------

  Future<SeasonCrop> addCrop(int seasonId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/farming-seasons/$seasonId/crops'),
      headers: _authHeaders,
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return SeasonCrop.fromJson(jsonResponse['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add crop');
    }
  }

  Future<SeasonCrop> updateCrop(int cropId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/season-crops/$cropId'),
      headers: _authHeaders,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return SeasonCrop.fromJson(jsonResponse['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update crop');
    }
  }

  Future<void> deleteCrop(int cropId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/season-crops/$cropId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete crop');
    }
  }

  // ---------------------------------------------------------------------------
  // LIVESTOCK
  // ---------------------------------------------------------------------------

  Future<SeasonLivestock> addLivestock(int seasonId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/farming-seasons/$seasonId/livestock'),
      headers: _authHeaders,
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return SeasonLivestock.fromJson(jsonResponse['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add livestock');
    }
  }

  Future<SeasonLivestock> updateLivestock(int livestockId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/season-livestock/$livestockId'),
      headers: _authHeaders,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return SeasonLivestock.fromJson(jsonResponse['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update livestock');
    }
  }

  Future<void> deleteLivestock(int livestockId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/season-livestock/$livestockId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete livestock');
    }
  }

  // ---------------------------------------------------------------------------
  // HONEY
  // ---------------------------------------------------------------------------

  Future<SeasonHoney> addHoney(int seasonId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/farming-seasons/$seasonId/honey'),
      headers: _authHeaders,
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return SeasonHoney.fromJson(jsonResponse['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add honey');
    }
  }

  Future<SeasonHoney> updateHoney(int honeyId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/season-honey/$honeyId'),
      headers: _authHeaders,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return SeasonHoney.fromJson(jsonResponse['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update honey');
    }
  }

  Future<void> deleteHoney(int honeyId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/season-honey/$honeyId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete honey');
    }
  }

  // ---------------------------------------------------------------------------
  // EXPENDITURES
  // ---------------------------------------------------------------------------

  Future<List<SeasonExpenditure>> getExpenditures(int seasonId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/farming-seasons/$seasonId/expenditures'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((e) => SeasonExpenditure.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    } else {
      // Return empty list gracefully for any unexpected errors
      return [];
    }
  }

  Future<SeasonExpenditure> addExpenditure(int seasonId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/farming-seasons/$seasonId/expenditures'),
      headers: _authHeaders,
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return SeasonExpenditure.fromJson(jsonResponse['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add expenditure');
    }
  }

  Future<void> deleteExpenditure(int expenditureId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/season-expenditures/$expenditureId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete expenditure');
    }
  }

  // ---------------------------------------------------------------------------
  // SALES (recording sales linked to a season)
  // ---------------------------------------------------------------------------

  Future<void> recordSale({
    required int commodityId,
    required int valueChainId,
    required double quantitySold,
    required double unitPrice,
    required int seasonId,
    String? buyerName,
    String? saleDate,
  }) async {
    final body = {
      'commodity_id': commodityId,
      'value_chain_id': valueChainId,
      'quantity_sold': quantitySold,
      'unit_price': unitPrice,
      'farming_season_id': seasonId,
      if (buyerName != null && buyerName.isNotEmpty) 'buyer_name': buyerName,
      if (saleDate != null && saleDate.isNotEmpty) 'sale_date': saleDate,
    };
    final response = await http.post(
      Uri.parse('$baseUrl/commodity-sales'),
      headers: _authHeaders,
      body: json.encode(body),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to record sale');
    }
  }

  // ---------------------------------------------------------------------------
  // PUBLIC FARMER DIRECTORY
  // ---------------------------------------------------------------------------

  Future<List<PublicFarmerProfile>> getPublicFarmerProfiles({
    String? searchQuery,
    String? cropFilter,
    String? regionFilter,
  }) async {
    final queryParams = <String, String>{};
    if (searchQuery != null && searchQuery.isNotEmpty) queryParams['search'] = searchQuery;
    if (cropFilter != null && cropFilter.isNotEmpty) queryParams['crop'] = cropFilter;
    if (regionFilter != null && regionFilter.isNotEmpty) queryParams['region'] = regionFilter;

    // Correct endpoint: /api/v1/farmers (not /public/farmers)
    final uri = Uri.parse('$baseUrl/farmers')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(uri, headers: _publicHeaders);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // The response is { data: [...], meta: {...} }
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((e) => PublicFarmerProfile.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<FarmingSeason>> getPublicFarmerSeasons(int farmerId) async {
    // Correct endpoint: /api/v1/farmers/{id}/profile
    final response = await http.get(
      Uri.parse('$baseUrl/farmers/$farmerId/profile'),
      headers: _publicHeaders,
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Response shape: { farmer: {...}, data: [ season, ... ] }
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((s) => FarmingSeason.fromJson(s)).toList();
    } else {
      return [];
    }
  }
}
