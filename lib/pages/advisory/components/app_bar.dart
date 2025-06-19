import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mlimi/constants/color.dart';

AppBar homeAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Bgreen,
    elevation: 0,
    leading: IconButton(
      icon: SvgPicture.asset("assets/icons/menu.svg"),
      onPressed: () {},
    ),
    title: RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: "All ",
            style: TextStyle(color: ksecondaryColor),
          ),
          TextSpan(
            text: "Advisory",
            style: TextStyle(color: kPrimaryColor),
          ),
        ],
      ),
    ),
    actions: <Widget>[
      IconButton(
        icon: SvgPicture.asset("assets/icons/notification.svg"),
        onPressed: () {},
      ),
    ],
  );
}
