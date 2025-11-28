import 'package:flutter/material.dart';

/// Centralized icon map for quick actions to keep visuals consistent
const Map<String, IconData> _iconMap = {
  'sell': Icons.monetization_on_outlined,
  'buy': Icons.shopping_cart_checkout,
  'wallet': Icons.account_balance_wallet_rounded,
  'location': Icons.location_on_outlined,
  'calculate': Icons.calculate,
  'search': Icons.search,
  'business': Icons.apartment_outlined,
  'geo': Icons.public,
};

IconData? getIconDataFromString(String iconName) {
  return _iconMap[iconName];
}

