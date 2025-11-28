import 'package:flutter/material.dart';

const double kSpacingUnit = 10.0;

const Color kDarkPrimaryColor = Color(0xFF212121);
const Color kDarkSecondaryColor = Color.fromARGB(255, 89, 185, 94);
const Color kLightPrimaryColor = Color(0xFFFFFFFF);
const Color kLightSecondaryColor = Color(0xFFF3F7FB);
const Color kAccentColor = Color(0xFFFFC107);

final TextStyle kTitleTextStyle = TextStyle(
  fontSize: kSpacingUnit * 1.7,
  fontWeight: FontWeight.w600,
);

final TextStyle kCaptionTextStyle = TextStyle(
  fontSize: kSpacingUnit * 1.3,
  fontWeight: FontWeight.w100,
);

final TextStyle kButtonTextStyle = TextStyle(
  fontSize: kSpacingUnit * 1.85,
  fontWeight: FontWeight.w400,
  color: kDarkPrimaryColor,
);
