import 'package:flutter/material.dart';
import 'package:mlimi/features/buy_sell/models/commodity_models.dart';
import 'package:mlimi/features/buy_sell/repositories/commodity_repository.dart';
import 'package:mlimi/features/buy_sell/views/edit_commodity_screen.dart';
import 'package:mlimi/features/buy_sell/views/quick_sell_screen.dart';

class CommodityDetailScreen extends StatefulWidget {
  const CommodityDetailScreen({required this.commodityId, super.key});
  final int commodityId;

  @override
  State<CommodityDetailScreen> createState() => _CommodityDetailScreenState();
}

class _CommodityDetailScreenState extends State<CommodityDetailScreen> {
  final _repo = CommodityRepository();
  bool _loading = true;
  CommodityDetails? _details;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final details = await _repo.getCommodityDetails(widget.commodityId);
      if (!mounted) return;
      setState(() => _details = details);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markNotSold() async {
    if (_details == null) return;
    final c = _details!.commodity;
    await _repo.toggleCommodityStatus(
      commodityId: c.id,
      availabilityStatus: 'available',
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_details == null) {
      return const Scaffold(
          body: Center(child: Text('Commodity details unavailable')));
    }
    final c = _details!.commodity;
    return Scaffold(
      appBar: AppBar(
        title: Text(c.name),
        actions: [
          if (c.ownPost)
            TextButton(
              onPressed: () async {
                if ((c.availabilityStatus ?? 'available') == 'sold') {
                  await _markNotSold();
                  return;
                }
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuickSellScreen(
                      commodity: c,
                      initialQuantitySold: c.quantityRemaining,
                    ),
                  ),
                );
                if (created == true) {
                  _load();
                }
              },
              child: Text(
                (c.availabilityStatus ?? 'available') == 'sold'
                    ? 'Mark Not Sold'
                    : 'Mark Sold',
              ),
            ),
          if (c.ownPost)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditCommodityScreen(commodity: c)),
                );
                if (updated == true) _load();
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text(c.description ?? '-', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 8),
            Text('Status: ${c.availabilityStatus ?? '-'}'),
            Text('Quantity: ${c.quantity ?? '-'} ${c.measure ?? ''}'),
            Text('Remaining: ${c.quantityRemaining ?? '-'} ${c.measure ?? ''}'),
            Text('Location: ${c.location ?? '-'}'),
            const SizedBox(height: 10),
            if (c.ownPost && (c.quantityRemaining ?? 0) > 0)
              ElevatedButton.icon(
                onPressed: () async {
                  final created = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => QuickSellScreen(commodity: c)),
                  );
                  if (created == true) _load();
                },
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Quick Sell'),
              ),
            const SizedBox(height: 12),
            const Text('Sales', style: TextStyle(fontWeight: FontWeight.bold)),
            if (_details!.sales.isEmpty)
              const Text('No sales yet')
            else
              ..._details!.sales.map(
                (s) => ListTile(
                  dense: true,
                  title: Text(
                      '${s.saleDate ?? '-'} • ${s.quantitySold} x ${s.unitPrice}'),
                  subtitle:
                      Text('Buyer: ${s.buyerName ?? '-'} • ${s.paymentStatus}'),
                  trailing: Text('MWK ${s.totalAmount.toStringAsFixed(2)}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
