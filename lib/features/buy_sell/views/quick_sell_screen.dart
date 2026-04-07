import 'package:flutter/material.dart';
import 'package:mlimi/features/buy_sell/models/commodity_models.dart';
import 'package:mlimi/features/buy_sell/models/requests.dart';
import 'package:mlimi/features/buy_sell/repositories/commodity_repository.dart';
import 'package:mlimi/features/buy_sell/services/sale_queue_service.dart';

class QuickSellScreen extends StatefulWidget {
  const QuickSellScreen({
    required this.commodity,
    this.initialQuantitySold,
    super.key,
  });
  final Commodity commodity;
  final double? initialQuantitySold;

  @override
  State<QuickSellScreen> createState() => _QuickSellScreenState();
}

class _QuickSellScreenState extends State<QuickSellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _buyerNameCtrl = TextEditingController();
  final _buyerPhoneCtrl = TextEditingController();
  final _amountPaidCtrl = TextEditingController(text: '0');

  final _repository = CommodityRepository();
  final _queue = SaleQueueService();

  String _paymentStatus = 'pending';
  bool _saving = false;
  List<Buyer> _buyers = [];
  int? _selectedBuyerId;

  @override
  void initState() {
    super.initState();
    _priceCtrl.text = (widget.commodity.price ?? 0).toString();
    if ((widget.initialQuantitySold ?? 0) > 0) {
      _qtyCtrl.text = widget.initialQuantitySold!.toString();
    }
    _loadBuyers();
  }

  Future<void> _loadBuyers() async {
    try {
      final buyers = await _repository.getBuyers();
      if (mounted) setState(() => _buyers = buyers);
    } catch (_) {}
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _buyerNameCtrl.dispose();
    _buyerPhoneCtrl.dispose();
    _amountPaidCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final request = SaleUpsertRequest(
      commodityId: widget.commodity.id,
      valueChainId: widget.commodity.valueChainId,
      quantitySold: double.parse(_qtyCtrl.text),
      unitPrice: double.parse(_priceCtrl.text),
      saleDate: DateTime.now().toIso8601String().split('T').first,
      buyerId: _selectedBuyerId,
      buyerName: _buyerNameCtrl.text.trim(),
      buyerPhone: _buyerPhoneCtrl.text.trim(),
      paymentStatus: _paymentStatus,
      amountPaid: double.tryParse(_amountPaidCtrl.text) ?? 0,
    );

    try {
      await _repository.createSale(request);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sale recorded')));
      Navigator.pop(context, true);
    } catch (_) {
      await _queue.enqueue(request);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Offline/network issue: sale queued for auto-sync')),
      );
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Sell')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Commodity: ${widget.commodity.name}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
                'Remaining: ${widget.commodity.quantityRemaining ?? '-'} ${widget.commodity.measure ?? ''}'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _qtyCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity sold'),
              validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0
                  ? null
                  : 'Enter valid quantity',
            ),
            TextFormField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Unit price'),
              validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0
                  ? null
                  : 'Enter valid price',
            ),
            DropdownButtonFormField<int?>(
              value: _selectedBuyerId,
              decoration:
                  const InputDecoration(labelText: 'Existing buyer (optional)'),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text('Select buyer')),
                ..._buyers.map((b) =>
                    DropdownMenuItem<int?>(value: b.id, child: Text(b.name))),
              ],
              onChanged: (v) => setState(() => _selectedBuyerId = v),
            ),
            TextFormField(
                controller: _buyerNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Buyer name (optional)')),
            TextFormField(
                controller: _buyerPhoneCtrl,
                decoration:
                    const InputDecoration(labelText: 'Buyer phone (optional)')),
            DropdownButtonFormField<String>(
              value: _paymentStatus,
              decoration: const InputDecoration(labelText: 'Payment status'),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'partial', child: Text('Partial')),
                DropdownMenuItem(value: 'paid', child: Text('Paid')),
              ],
              onChanged: (v) => setState(() => _paymentStatus = v ?? 'pending'),
            ),
            TextFormField(
              controller: _amountPaidCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount paid'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: Text(_saving ? 'Saving...' : 'Save Sale'),
            ),
          ],
        ),
      ),
    );
  }
}
