import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mlimi/pages/region/region_components/region_app_bar.dart';
import 'package:mlimi/pages/region/region_components/region_body.dart';

class Region extends StatelessWidget {
  const Region({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: regionAppBar(context),
      body: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: const RegionBody(),
      ),
    );
  }
}
