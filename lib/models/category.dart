import 'package:flutter/material.dart';
import 'package:mlimi/pages/Buy/buy.dart';
import 'package:mlimi/pages/margin_calculator/margin_calculator.dart';
import 'package:mlimi/pages/region/region.dart';
import 'package:mlimi/pages/sale/sale.dart';
import 'package:mlimi/pages/sale/supply.dart';
import 'package:mlimi/pages/sale/supply_tab.dart';
import 'package:mlimi/pages/wallet/wallet.dart';

class Category_featured {
  String thumbnail;
  String name;
  final Widget targetPage;

  Category_featured({
    required this.name,
    required this.thumbnail,
    required this.targetPage,
  });
}

List<Category_featured> categoryList = [
  Category_featured(
    name: 'Sale',
    thumbnail: 'sell',
    targetPage: const SalePage(),
  ),
  Category_featured(
    name: 'Buy',
    thumbnail: 'buy',
    targetPage: const Buy(),
  ),
  Category_featured(
    name: 'Mlimi Wallet',
    thumbnail: 'wallet',
    targetPage: const Wallet(),
  ),
  Category_featured(
    name: 'My Region',
    thumbnail: 'location',
    targetPage: const Region(),
  ),
  Category_featured(
    name: 'Gross Margin Calculator',
    thumbnail: 'calculate',
    targetPage: const MarginCalculator(),
  ),
  Category_featured(
    name: 'Product Request',
    thumbnail: 'search',
    targetPage: const SupplyPage(),
  ),
];
