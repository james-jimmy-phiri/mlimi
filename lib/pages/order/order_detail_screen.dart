import 'package:flutter/material.dart';
import 'package:mlimi/services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _orderService = OrderService();
  Map<String, dynamic>? _order;
  bool _loading = true;
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final order = await _orderService.fetchOrder(widget.orderId);
      setState(() {
        _order = order;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitRating() async {
    try {
      await _orderService.rateOrder(widget.orderId, _rating);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        foregroundColor: const Color(0xFF006B29),
        title: Text(_order?['order_number'] ?? 'Order', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF006B29)))
          : _order == null
              ? const Center(child: Text('Order not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006B29).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _order!['status_label'] ?? _order!['status'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF006B29),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...((_order!['items'] as List?) ?? []).map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['commodity_name'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text('${item['quantity']} ${item['measure']}'),
                                    ],
                                  ),
                                ),
                                Text('MWK ${item['subtotal']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _row('Subtotal', _order!['subtotal']),
                            _row('Delivery', _order!['delivery_fee']),
                            const Divider(),
                            _row('Total', _order!['total_amount'], bold: true),
                          ],
                        ),
                      ),
                      if (_order!['status'] == 'delivered' && _order!['rating'] == null) ...[
                        const SizedBox(height: 24),
                        const Text('Rate your experience',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          children: List.generate(5, (i) {
                            return IconButton(
                              icon: Icon(
                                i < _rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () => setState(() => _rating = i + 1),
                            );
                          }),
                        ),
                        ElevatedButton(
                          onPressed: _submitRating,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006B29)),
                          child: const Text('Submit Rating'),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _row(String label, dynamic value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text('MWK $value',
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: bold ? const Color(0xFF006B29) : null,
              )),
        ],
      ),
    );
  }
}
