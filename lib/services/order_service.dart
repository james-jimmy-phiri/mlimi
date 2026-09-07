import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mlimi/constants/url.dart';

class OrderService {
  final _storage = GetStorage();

  Map<String, String> _headers({bool auth = true}) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = _storage.read('token');
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryMethod,
    String? deliveryAddress,
    required String deliveryPhone,
    required String paymentMethod,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${apiurl}v1/orders'),
      headers: _headers(),
      body: json.encode({
        'items': items,
        'delivery_method': deliveryMethod,
        'delivery_address': deliveryAddress,
        'delivery_phone': deliveryPhone,
        'payment_method': paymentMethod,
        'notes': notes,
      }),
    );

    final body = json.decode(response.body);
    if (response.statusCode == 201) {
      return body;
    }
    throw Exception(body['message'] ?? body['error'] ?? 'Failed to place order');
  }

  Future<List<dynamic>> fetchOrders({String role = 'buyer'}) async {
    final response = await http.get(
      Uri.parse('${apiurl}v1/orders?role=$role'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['orders']['data'] ?? body['orders'] ?? [];
    }
    throw Exception('Failed to load orders');
  }

  Future<Map<String, dynamic>> fetchOrder(int id) async {
    final response = await http.get(
      Uri.parse('${apiurl}v1/orders/$id'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['order'];
    }
    throw Exception('Failed to load order');
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    int orderId, {
    required String status,
    String? rejectionReason,
    String? sellerNotes,
    String? paymentReference,
  }) async {
    final response = await http.put(
      Uri.parse('${apiurl}v1/orders/$orderId/status'),
      headers: _headers(),
      body: json.encode({
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        if (sellerNotes != null) 'seller_notes': sellerNotes,
        if (paymentReference != null) 'payment_reference': paymentReference,
      }),
    );

    final body = json.decode(response.body);
    if (response.statusCode == 200) return body;
    throw Exception(body['message'] ?? 'Failed to update order');
  }

  Future<Map<String, dynamic>> rateOrder(int orderId, int rating, {String? review}) async {
    final response = await http.post(
      Uri.parse('${apiurl}v1/orders/$orderId/rate'),
      headers: _headers(),
      body: json.encode({'rating': rating, 'review': review}),
    );

    final body = json.decode(response.body);
    if (response.statusCode == 200) return body;
    throw Exception(body['message'] ?? 'Failed to submit rating');
  }
}
