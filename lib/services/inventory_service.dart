import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/inventory_models.dart';

class InventoryService {
  final String baseUrl = '${apiurl}v1';

  Map<String, String> get _headers {
    final token = GetStorage().read('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _parseError(http.Response response, String defaultMessage) {
    try {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstErrorList = errors.values.first;
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              return '${data['message'] ?? defaultMessage}: ${firstErrorList.first}';
            }
          }
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
      }
    } catch (_) {}
    return '$defaultMessage (Status: ${response.statusCode})';
  }

  // ---------------------------------------------------------------------------
  // DASHBOARD
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getDashboard(int businessProfileId) async {
    final uri = Uri.parse('$baseUrl/business-profiles/$businessProfileId/inventory/dashboard');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'stats': InventoryDashboardStats.fromJson(data['stats'] ?? {}),
        'recentMoves': (data['recentMoves'] as List?)
                ?.map((e) => InventoryStockMove.fromJson(e))
                .toList() ??
            [],
        'lowStockProducts': (data['lowStockProducts'] as List?)
                ?.map((e) => InventoryProduct.fromJson(e))
                .toList() ??
            [],
      };
    } else {
      throw Exception(_parseError(response, 'Failed to load inventory dashboard'));
    }
  }

  // ---------------------------------------------------------------------------
  // PRODUCTS
  // ---------------------------------------------------------------------------

  Future<List<InventoryProduct>> getProducts(int businessProfileId, {String? search, String? status}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final uri = Uri.parse('$baseUrl/business-profiles/$businessProfileId/inventory/products').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List productsJson = data['data'] ?? data;
      return productsJson.map((j) => InventoryProduct.fromJson(j)).toList();
    } else {
      throw Exception(_parseError(response, 'Failed to load products'));
    }
  }

  Future<InventoryProduct> saveProduct(int businessProfileId, Map<String, dynamic> data, {int? productId}) async {
    Uri uri;
    http.Response response;
    
    if (productId == null) {
      // Create
      uri = Uri.parse('$baseUrl/business-profiles/$businessProfileId/inventory/products');
      response = await http.post(uri, headers: _headers, body: json.encode(data));
    } else {
      // Update
      uri = Uri.parse('$baseUrl/business-profiles/$businessProfileId/inventory/products/$productId');
      response = await http.put(uri, headers: _headers, body: json.encode(data));
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return InventoryProduct.fromJson(responseData['product']);
    } else {
      throw Exception(_parseError(response, 'Failed to save product'));
    }
  }

  Future<void> deleteProduct(int businessProfileId, int productId) async {
    final uri = Uri.parse('$baseUrl/business-profiles/$businessProfileId/inventory/products/$productId');
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception(_parseError(response, 'Failed to delete product'));
    }
  }

  // ---------------------------------------------------------------------------
  // STOCK MOVEMENTS
  // ---------------------------------------------------------------------------

  Future<List<InventoryStockMove>> getStockMoves(int businessProfileId) async {
    final uri = Uri.parse('$baseUrl/business-profiles/$businessProfileId/inventory/movements');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List movesJson = data['data'] ?? data;
      return movesJson.map((j) => InventoryStockMove.fromJson(j)).toList();
    } else {
      throw Exception(_parseError(response, 'Failed to load stock movements'));
    }
  }

  Future<InventoryStockMove> recordStockMove(int businessProfileId, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/business-profiles/$businessProfileId/inventory/movements');
    final response = await http.post(uri, headers: _headers, body: json.encode(data));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return InventoryStockMove.fromJson(responseData['movement']);
    } else {
      throw Exception(_parseError(response, 'Failed to record stock movement'));
    }
  }

  // ---------------------------------------------------------------------------
  // SUPPLIERS
  // ---------------------------------------------------------------------------

  Future<List<InventorySupplier>> getSuppliers(int businessProfileId) async {
    final uri = Uri.parse('$baseUrl/business-profiles/$businessProfileId/inventory/suppliers');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List suppliersJson = data;
      return suppliersJson.map((j) => InventorySupplier.fromJson(j)).toList();
    } else {
      throw Exception(_parseError(response, 'Failed to load suppliers'));
    }
  }
}
