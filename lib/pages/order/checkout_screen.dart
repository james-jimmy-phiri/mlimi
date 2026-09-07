import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/pages/order/order_detail_screen.dart';
import 'package:mlimi/provider/cart_provider.dart';
import 'package:mlimi/services/order_service.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _orderService = OrderService();
  final _storage = GetStorage();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _deliveryMethod = 'pickup';
  String _paymentMethod = 'airtel_money';
  bool _loading = false;

  static const double _deliveryFee = 3500;

  @override
  void initState() {
    super.initState();
    _phoneController.text = _storage.read('phone')?.toString() ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _total(CartProvider cart) =>
      cart.subtotal + (_deliveryMethod == 'home_delivery' ? _deliveryFee : 0);

  Future<void> _placeOrder(CartProvider cart) async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    if (_deliveryMethod == 'home_delivery' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await _orderService.placeOrder(
        items: cart.items
            .map((i) => {'commodity_id': i.product.id, 'quantity': i.quantity})
            .toList(),
        deliveryMethod: _deliveryMethod,
        deliveryAddress: _deliveryMethod == 'home_delivery' ? _addressController.text.trim() : null,
        deliveryPhone: _phoneController.text.trim(),
        paymentMethod: _paymentMethod,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      cart.clear();
      if (!mounted) return;

      final order = result['order'];
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order['id'])),
        (route) => route.isFirst,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order ${order['order_number']} placed successfully!')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Preference',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _deliveryChip('pickup', 'Pickup', Icons.storefront)),
                    const SizedBox(width: 8),
                    Expanded(child: _deliveryChip('home_delivery', 'Home Delivery', Icons.local_shipping)),
                  ],
                ),
                if (_deliveryMethod == 'home_delivery') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: [
                    _paymentChip('airtel_money', 'Airtel Money'),
                    _paymentChip('tnm_mpamba', 'TNM Mpamba'),
                    _paymentChip('bank_transfer', 'Bank Transfer'),
                    _paymentChip('paychangu', 'PayChangu'),
                    _paymentChip('cash_on_delivery', 'Cash on Delivery (COD)'),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Order Notes (optional)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Subtotal', cart.subtotal),
                      _summaryRow(
                        'Delivery Fee',
                        _deliveryMethod == 'home_delivery' ? _deliveryFee : 0,
                      ),
                      const Divider(height: 24),
                      _summaryRow('Total', _total(cart), bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : () => _placeOrder(cart),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B29),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _deliveryChip(String value, String label, IconData icon) {
    final selected = _deliveryMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _deliveryMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF118738) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF118738) : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }

  Widget _paymentChip(String value, String label) {
    final selected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF006B29).withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF006B29) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? const Color(0xFF006B29) : Colors.grey.shade700,
              fontSize: 12,
            )),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(
            'MWK ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: bold ? const Color(0xFF006B29) : null,
              fontSize: bold ? 20 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
