import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: c.image == null
                                  ? const Icon(Icons.image_not_supported)
                                  : CachedNetworkImage(
                                      imageUrl: c.image!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                            ),
                          ),
                          if (c.isAggregation)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4F46E5), // Primary Indigo
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                child: const Text('AGG', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ),
                     title: Text(
                       '${c.name} (${c.quantityRemaining ?? c.quantity ?? '-'} ${c.measure ?? ''})',
                       overflow: TextOverflow.ellipsis,
                       maxLines: 1,
                     ),
                    subtitle: Text(
                      '${c.location ?? '-'} • ${c.measure ?? ''}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
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
