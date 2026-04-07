import 'package:flutter/material.dart';
import 'package:mlimi/features/buy_sell/models/commodity_models.dart';
import 'package:mlimi/features/buy_sell/repositories/commodity_repository.dart';
import 'package:mlimi/features/buy_sell/views/commodity_detail_screen.dart';
import 'package:mlimi/features/buy_sell/views/my_posted_commodities_screen.dart';
import 'package:mlimi/features/buy_sell/views/quick_sell_screen.dart';

class CommodityListScreen extends StatefulWidget {
  const CommodityListScreen({super.key});

  @override
  State<CommodityListScreen> createState() => _CommodityListScreenState();
}

class _CommodityListScreenState extends State<CommodityListScreen> {
  final _repo = CommodityRepository();
  bool _loading = true;
  bool _forSale = true;
  List<Commodity> _commodities = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list =
          _forSale ? await _repo.getForSale() : await _repo.getForSupply();
      if (!mounted) return;
      setState(() => _commodities = list);
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
          Row(
            children: [
              const Text('Commodities',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              ChoiceChip(
                  label: const Text('For sale'),
                  selected: _forSale,
                  onSelected: (_) => setState(() => _forSale = true)),
              const SizedBox(width: 8),
              ChoiceChip(
                  label: const Text('For supply'),
                  selected: !_forSale,
                  onSelected: (_) => setState(() => _forSale = false)),
              IconButton(
                tooltip: 'My posted commodities',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyPostedCommoditiesScreen()),
                ),
                icon: const Icon(Icons.list_alt),
              ),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_commodities.isEmpty)
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No commodities available')))
          else
            ..._commodities.map((c) => Card(
                  child: ListTile(
                    leading: c.image == null
                        ? const Icon(Icons.image_not_supported)
                        : Image.network(c.image!, width: 48, fit: BoxFit.cover),
                    title: Text(c.name),
                    subtitle: Text(
                        '${c.location ?? '-'} • ${c.quantityRemaining ?? c.quantity ?? '-'} ${c.measure ?? ''}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CommodityDetailScreen(commodityId: c.id)),
                    ),
                    trailing: c.ownPost && (c.quantityRemaining ?? 0) > 0
                        ? IconButton(
                            icon: const Icon(Icons.shopping_bag,
                                color: Colors.green),
                            onPressed: () async {
                              final created = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        QuickSellScreen(commodity: c)),
                              );
                              if (created == true) _load();
                            },
                          )
                        : null,
                  ),
                )),
        ],
      ),
    );
  }
}
