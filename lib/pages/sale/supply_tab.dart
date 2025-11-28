import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/pages/sale/onsupply.dart';
import 'package:mlimi/pages/sale/supply.dart';

class SupplyTab extends StatefulWidget {
  const SupplyTab({super.key});

  @override
  State<SupplyTab> createState() => _SupplyTabState();
}

class _SupplyTabState extends State<SupplyTab> {
  String _language = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    final storage = GetStorage();
    _language = storage.read('language') ?? 'en'; // Read language preference
  }

  String _localizedText(String en, String ny) {
    return _language == 'ny' ? ny : en;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(_localizedText("Request Supplier", "Pemphani Ogulitsa")),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(_localizedText("View Products for Supplying",
            "Onani Zogulitsa Zomwe Mungapereke")),
      ),
    ];

    return SizedBox(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 0,
            bottom: TabBar(
              tabs: tabs,
              labelColor: const Color.fromARGB(255, 42, 146, 42),
              unselectedLabelColor: Colors.grey,
            ),
          ),
          body: const TabBarView(
            children: [
              SupplyPage(),
              Onsupply(),
            ],
          ),
        ),
      ),
    );
  }
}
