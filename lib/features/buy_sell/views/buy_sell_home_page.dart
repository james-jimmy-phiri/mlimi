import 'package:flutter/material.dart';
import 'package:mlimi/features/buy_sell/services/sale_sync_manager.dart';
import 'package:mlimi/features/buy_sell/views/buyers_screen.dart';
import 'package:mlimi/features/buy_sell/views/commodity_list_screen.dart';
import 'package:mlimi/features/buy_sell/views/dashboard_stats_screen.dart';
import 'package:mlimi/features/buy_sell/views/sales_ledger_screen.dart';

class BuySellHomePage extends StatefulWidget {
  const BuySellHomePage({super.key});

  @override
  State<BuySellHomePage> createState() => _BuySellHomePageState();
}

class _BuySellHomePageState extends State<BuySellHomePage> {
  final _syncManager = SaleSyncManager();
  int _index = 0;

  final _pages = const [
    CommodityListScreen(),
    SalesLedgerScreen(),
    BuyersScreen(),
    DashboardStatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _syncManager.start();
  }

  @override
  void dispose() {
    _syncManager.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy / Sell Commodities'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await _syncManager.syncNow();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Synced: ${result.synced}, Failed: ${result.failed}, Remaining: ${result.remaining}')),
              );
            },
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket), label: 'Commodities'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Ledger'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Buyers'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Stats'),
        ],
      ),
    );
  }
}
