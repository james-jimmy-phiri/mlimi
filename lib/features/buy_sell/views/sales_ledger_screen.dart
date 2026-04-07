import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/features/buy_sell/models/commodity_models.dart';
import 'package:mlimi/features/buy_sell/repositories/commodity_repository.dart';

class SalesLedgerScreen extends StatefulWidget {
  const SalesLedgerScreen({super.key});

  @override
  State<SalesLedgerScreen> createState() => _SalesLedgerScreenState();
}

class _SalesLedgerScreenState extends State<SalesLedgerScreen> {
  final _repo = CommodityRepository();
  bool _loading = true;
  List<CommoditySale> _sales = [];
  List<Commodity> _commodities = [];
  List<ValueChainOption> _valueChains = [];
  List<Buyer> _buyers = [];
  int? _commodityId;
  int? _valueChainId;
  int? _buyerId;
  String _paymentStatus = '';
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sale = await _repo.getForSale();
      final supply = await _repo.getForSupply();
      final sales = await _repo.getMySales(
        commodityId: _commodityId,
        valueChainId: _valueChainId,
        buyerId: _buyerId,
        paymentStatus: _paymentStatus.isEmpty ? null : _paymentStatus,
        fromDate:
            _from == null ? null : DateFormat('yyyy-MM-dd').format(_from!),
        toDate: _to == null ? null : DateFormat('yyyy-MM-dd').format(_to!),
      );
      final valueChains = await _repo.getValueChains();
      final buyers = await _repo.getBuyers();
      if (!mounted) return;
      setState(() {
        _commodities = [...sale, ...supply];
        _sales = sales;
        _valueChains = valueChains;
        _buyers = buyers;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Sales Ledger',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _idFilter<int?>(
                  'Commodity',
                  _commodityId,
                  [
                    for (final c in _commodities)
                      DropdownMenuItem<int?>(value: c.id, child: Text(c.name))
                  ],
                  (v) => setState(() => _commodityId = v)),
              _idFilter<int?>(
                  'Value chain',
                  _valueChainId,
                  [
                    for (final v in _valueChains)
                      DropdownMenuItem<int?>(value: v.id, child: Text(v.name))
                  ],
                  (v) => setState(() => _valueChainId = v)),
              _idFilter<int?>(
                  'Buyer',
                  _buyerId,
                  [
                    for (final b in _buyers)
                      DropdownMenuItem<int?>(value: b.id, child: Text(b.name))
                  ],
                  (v) => setState(() => _buyerId = v)),
              _idFilter<String?>(
                  'Payment',
                  _paymentStatus.isEmpty ? null : _paymentStatus,
                  const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'partial', child: Text('Partial')),
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                  ],
                  (v) => setState(() => _paymentStatus = v ?? '')),
              OutlinedButton(
                  onPressed: () async {
                    final picked = await _pickDate(context);
                    if (!mounted) return;
                    setState(() => _from = picked);
                  },
                  child: Text(_from == null
                      ? 'From date'
                      : DateFormat('yyyy-MM-dd').format(_from!))),
              OutlinedButton(
                  onPressed: () async {
                    final picked = await _pickDate(context);
                    if (!mounted) return;
                    setState(() => _to = picked);
                  },
                  child: Text(_to == null
                      ? 'To date'
                      : DateFormat('yyyy-MM-dd').format(_to!))),
              ElevatedButton(onPressed: _load, child: const Text('Apply')),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator()))
          else if (_sales.isEmpty)
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No sales found for selected filters')))
          else
            ..._sales.map((s) => Card(
                  child: ListTile(
                    title: Text(
                        '${s.buyerName ?? 'Buyer'} • ${s.quantitySold} @ ${s.unitPrice}'),
                    subtitle: Text(
                        'Date: ${s.saleDate ?? '-'} | Status: ${s.paymentStatus}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('MWK ${s.totalAmount.toStringAsFixed(2)}'),
                        Text('Bal: ${s.balanceDue.toStringAsFixed(2)}')
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _idFilter<T>(String label, T? value, List<DropdownMenuItem<T?>> items,
      ValueChanged<T?> onChanged) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<T?>(
        value: value,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        items: [
          DropdownMenuItem<T?>(value: null, child: Text('All $label')),
          ...items
        ],
        onChanged: onChanged,
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context) => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
}
