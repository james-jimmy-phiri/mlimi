import 'package:flutter/material.dart';
import 'package:mlimi/features/buy_sell/models/commodity_models.dart';
import 'package:mlimi/features/buy_sell/models/requests.dart';
import 'package:mlimi/features/buy_sell/repositories/commodity_repository.dart';

class BuyersScreen extends StatefulWidget {
  const BuyersScreen({super.key});

  @override
  State<BuyersScreen> createState() => _BuyersScreenState();
}

class _BuyersScreenState extends State<BuyersScreen> {
  final _repo = CommodityRepository();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = true;
  List<Buyer> _buyers = [];
  List<CommoditySale> _history = [];
  Buyer? _selectedBuyer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final buyers = await _repo.getBuyers();
      if (!mounted) return;
      setState(() => _buyers = buyers);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createBuyer() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    await _repo.createBuyer(BuyerCreateRequest(
        name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim()));
    _nameCtrl.clear();
    _phoneCtrl.clear();
    await _load();
  }

  Future<void> _loadHistory(Buyer buyer) async {
    final history = await _repo.getBuyerHistory(buyer.id);
    if (!mounted) return;
    setState(() {
      _selectedBuyer = buyer;
      _history = history;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('Buyer Profiles',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: TextField(
                    controller: _nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Buyer name'))),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone'))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _createBuyer, child: const Text('Add')),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else
          ..._buyers.map((b) => Card(
                child: ListTile(
                  title: Text(b.name),
                  subtitle: Text(b.phone ?? 'No phone'),
                  onTap: () => _loadHistory(b),
                ),
              )),
        if (_selectedBuyer != null) ...[
          const SizedBox(height: 12),
          Text('${_selectedBuyer!.name} purchase history',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          ..._history.map((s) => ListTile(
                dense: true,
                title: Text(
                    '${s.saleDate ?? '-'} • ${s.quantitySold} x ${s.unitPrice}'),
                trailing: Text('MWK ${s.totalAmount.toStringAsFixed(2)}'),
              )),
          if (_history.isEmpty) const Text('No buyer history found'),
        ],
      ],
    );
  }
}
