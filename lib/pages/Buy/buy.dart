import 'package:flutter/material.dart';
import 'package:mlimi/pages/Buy/markert.dart';
import 'package:mlimi/pages/Buy/markert_app_bar.dart';

class Buy extends StatelessWidget {
  const Buy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: marketAppBar(context),
      body: const Markert(),
    );
  }
}
