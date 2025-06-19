import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mlimi/constants/color.dart';

AppBar regionAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: SvgPicture.asset("assets/icons/back.svg"),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    title: RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: "My",
            style: TextStyle(color: ksecondaryColor),
          ),
          TextSpan(
            text: "Region",
            style: TextStyle(color: kPrimaryColor),
          ),
        ],
      ),
    ),
    centerTitle: true,
    actions: <Widget>[
      IconButton(
        icon: SvgPicture.asset("assets/icons/notification.svg"),
        onPressed: () {},
      ),
    ],
  );
}
