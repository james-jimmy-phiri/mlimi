import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';

AppBar homeAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Bgreen,
    elevation: 0,
    // leading: IconButton(

    
    //   icon: SvgPicture.asset("assets/icons/menu.svg"),
    //   onPressed: () {},
    // ),
    title: Center(
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: "On The",
              style: TextStyle(color: ksecondaryColor, fontSize: 22.0),
            ),
            TextSpan(
              text: "Market",
              style: TextStyle(color: kPrimaryColor, fontSize: 22.0),
            ),
          ],
        ),
      ),
    ),
  );
}
