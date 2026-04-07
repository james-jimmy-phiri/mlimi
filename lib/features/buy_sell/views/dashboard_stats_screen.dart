import 'package:flutter/material.dart';
import 'package:mlimi/features/buy_sell/models/commodity_models.dart';
import 'package:mlimi/features/buy_sell/repositories/commodity_repository.dart';

class DashboardStatsScreen extends StatefulWidget {
  const DashboardStatsScreen({super.key});

  @override
  State<DashboardStatsScreen> createState() => _DashboardStatsScreenState();
}

class _DashboardStatsScreenState extends State<DashboardStatsScreen> {
  final _repo = CommodityRepository();
  StatsSummary? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final stats = await _repo.getStatsSummary();
      if (!mounted) return;
      setState(() => _stats = stats);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_stats == null) return const Center(child: Text('No stats available'));
    final s = _stats!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Commodity Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          _tile('Total commodities', '${s.totalCommodities}'),
          _tile('Total sales', '${s.totalSales}'),
          _tile('Total supplies', '${s.totalSupplies}'),
          _tile('Total revenue', 'MWK ${s.totalRevenue.toStringAsFixed(2)}'),
          _tile('Best selling crop', s.bestSellingCrop ?? '-'),
          _tile('Best selling quantity', '${s.bestSellingQty}'),
          _tile('Low stock count', '${s.lowStockCount}'),
        ],
      ),
    );
  }

  Widget _tile(String title, String value) => Card(
        child: ListTile(
          title: Text(title),
          trailing:
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
}
