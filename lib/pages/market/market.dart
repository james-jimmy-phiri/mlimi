import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/market/home_app_bar.dart';
import 'package:mlimi/pages/market/market_menu.dart';
import 'package:mlimi/pages/market/test.dart';

class Market extends StatelessWidget {
  const Market({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar(context),
      body: Test(),
    );
  }
}
