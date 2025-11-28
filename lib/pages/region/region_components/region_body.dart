import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/region/region_components/region_location.dart';
import 'package:mlimi/pages/region/region_components/special_for_region.dart';

class RegionBody extends StatelessWidget {
  const RegionBody({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Container(
      color: Bgreen,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.025),
            const RegionLocation(),
            SizedBox(height: screenHeight * 0.025),
            // const SliderScreen(),
            SizedBox(height: screenHeight * 0.025),
            const SpecialForRegion(),
            SizedBox(height: screenHeight * 0.055),
            // const Favourite(),
          ],
        ),
      ),
    ));
  }
}
