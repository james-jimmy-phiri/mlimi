import 'package:flutter/material.dart';
import 'package:mlimi/features/buy_sell/models/commodity_models.dart';
import 'package:mlimi/features/buy_sell/models/requests.dart';
import 'package:mlimi/features/buy_sell/repositories/commodity_repository.dart';

class EditCommodityScreen extends StatefulWidget {
  const EditCommodityScreen({required this.commodity, super.key});
  final Commodity commodity;

  @override
  State<EditCommodityScreen> createState() => _EditCommodityScreenState();
}

class _EditCommodityScreenState extends State<EditCommodityScreen> {
  final _repo = CommodityRepository();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _lowStockCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _priceCtrl =
        TextEditingController(text: (widget.commodity.price ?? 0).toString());
    _qtyCtrl = TextEditingController(
        text: (widget.commodity.quantity ?? 0).toString());
    _descCtrl = TextEditingController(text: widget.commodity.description ?? '');
    _lowStockCtrl = TextEditingController(
        text: widget.commodity.lowStockThreshold?.toString() ?? '');
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _descCtrl.dispose();
    _lowStockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.commodity.valueChainId <= 0 ||
        (widget.commodity.measureId ?? 0) <= 0 ||
        (widget.commodity.districtId ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Missing commodity IDs for update payload')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.updateCommodity(
        widget.commodity.id,
        CommodityUpdateRequest(
          valueChainId: widget.commodity.valueChainId,
          measureId: widget.commodity.measureId!,
          unitPrice: double.parse(_priceCtrl.text),
          quantity: double.parse(_qtyCtrl.text),
          districtId: widget.commodity.districtId!,
          description: _descCtrl.text.trim(),
          lowStockThreshold: _lowStockCtrl.text.trim().isEmpty
              ? null
              : double.tryParse(_lowStockCtrl.text.trim()),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Commodity')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Unit price'),
              validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0
                  ? null
                  : 'Invalid unit price',
            ),
            TextFormField(
              controller: _qtyCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity'),
              validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0
                  ? null
                  : 'Invalid quantity',
            ),
            TextFormField(
              controller: _lowStockCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Low stock threshold (optional)'),
            ),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save')),
          ],
        ),
      ),
    );
  }
}
