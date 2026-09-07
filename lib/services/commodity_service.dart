import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/products_model.dart';
import 'package:get_storage/get_storage.dart';

class CommodityService {
  final _storage = GetStorage();

  Map<String, String> _headers() {
    final headers = {'Accept': 'application/json'};
    final token = _storage.read('token');
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<Map<String, dynamic>> fetchCommodityDetail(int id) async {
    final response = await http.get(
      Uri.parse('${apiurl}v1/commodities/$id'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load product details');
  }

  Future<Map<String, dynamic>> fetchReviews(int commodityId) async {
    final response = await http.get(
      Uri.parse('${apiurl}v1/commodities/$commodityId/reviews'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['reviews'] ?? {};
    }
    return {'average_rating': 0, 'total_reviews': 0, 'items': []};
  }

  Future<List<Product>> fetchRelated(int commodityId) async {
    final response = await http.get(
      Uri.parse('${apiurl}v1/commodities/$commodityId/related'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final list = body['commodities'] as List? ?? body['data'] as List? ?? [];
      return list.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }
}
