import 'package:flutter/material.dart';
import 'package:mlimi/features/buy_sell/models/commodity_models.dart';
import 'package:mlimi/features/buy_sell/repositories/commodity_repository.dart';
import 'package:mlimi/features/buy_sell/views/commodity_detail_screen.dart';

class MyPostedCommoditiesScreen extends StatefulWidget {
  const MyPostedCommoditiesScreen({super.key});

  @override
  State<MyPostedCommoditiesScreen> createState() =>
      _MyPostedCommoditiesScreenState();
}

class _MyPostedCommoditiesScreenState extends State<MyPostedCommoditiesScreen> {
  final _repo = CommodityRepository();
  bool _loading = true;
  List<Commodity> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.getMyPostedForSale();
      if (!mounted) return;
      setState(() => _items = items);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Posted Commodities')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (_loading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator()))
            else if (_items.isEmpty)
              const Card(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No posted commodities for sale found')))
            else
              ..._items.map((c) => Card(
                    child: ListTile(
                      title: Text(c.name),
                      subtitle: Text(
                          'Status: ${c.availabilityStatus ?? '-'} • Remaining: ${c.quantityRemaining ?? c.quantity ?? '-'}'),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CommodityDetailScreen(commodityId: c.id)),
                        );
                        _load();
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
