import 'package:flutter/material.dart';
import 'package:mlimi/pages/Buy/markert.dart';
import 'package:mlimi/pages/sale/allsupply/supply_app_bar.dart';
import 'package:mlimi/pages/sale/allsupply/to_supply.dart';

class AllSupply extends StatelessWidget {
  const AllSupply({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: supplyAppBar(context),
      body: const ToSupply(),
    );
  }
}
