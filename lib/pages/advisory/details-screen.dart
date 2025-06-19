import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/advisory/advivory_all.dart';

import 'package:mlimi/pages/advisory/components/body.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: detailsAppBar(),
      body: AllAdvisory(),
    );
  }

  detailsAppBar() {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset("assets/icons/share.svg"),
          onPressed: () {},
        ),
        IconButton(
          icon: SvgPicture.asset("assets/icons/more.svg"),
          onPressed: () {},
        ),
      ],
    );
  }
}
