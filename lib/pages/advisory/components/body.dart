import 'package:flutter/material.dart';
import 'package:mlimi/models/advisory_model.dart';
import 'package:mlimi/pages/advisory/advisory_widgets/advisory_sector.dart';

import 'package:mlimi/pages/advisory/components/discount_card.dart';

class Body extends StatelessWidget {
  final List<Sector> sectors;
  const Body({
    super.key,
    required this.sectors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DiscountCard(),
            AdvisorySector(
              sectors: sectors,
            ),
          ],
        ),
      ),
    );
  }
}
