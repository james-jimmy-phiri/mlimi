import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mlimi/constants/color.dart';

AppBar marketAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.green[50],
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
            text: "Buy ",
            style: TextStyle(color: kTextColor),
          ),
          TextSpan(
            text: "Products",
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
