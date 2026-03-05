import 'package:flutter/material.dart';
import 'package:mlimi/pages/Buy/buy.dart';
import 'package:mlimi/pages/advisory/advisory_method_selection_page.dart';
import 'package:mlimi/pages/business_profile/business_profiles_page.dart';
import 'package:mlimi/pages/margin_calculator/margin_calculator.dart';
import 'package:mlimi/pages/region/region.dart';
import 'package:mlimi/pages/sale/sale.dart';
import 'package:mlimi/pages/views/farming_profile/farming_seasons_page.dart';
import 'package:mlimi/pages/sale/supply.dart';
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

List<Category_featured> getCategoryList(String language) {
  if (language == 'ny') {
    return [
      Category_featured(
        name: 'Gulitsani',
        thumbnail: 'sell',
        targetPage: const SalePage(),
      ),
      Category_featured(
        name: 'Gulani',
        thumbnail: 'buy',
        targetPage: const Buy(),
      ),
      Category_featured(
        name: 'Mabizinesi',
        thumbnail: 'business',
        targetPage: const BusinessProfilesPage(),
      ),
      Category_featured(
        name: 'Ulangizi wa Dera',
        thumbnail: 'geo',
        targetPage: const AdvisoryMethodSelectionPage(),
      ),
      Category_featured(
        name: 'Kuwerengela Phindu',
        thumbnail: 'calculate',
        targetPage: const MarginCalculator(),
      ),
      Category_featured(
        name: 'kufufuza zoti mugule',
        thumbnail: 'search',
        targetPage: const SupplyPage(),
      ),
      Category_featured(
        name: 'Mbiri Ya Mlimi',
        thumbnail: 'farming_profile',
        targetPage: const FarmingSeasonsPage(),
      ),
      Category_featured(
        name: 'Mlimi Waleti',
        thumbnail: 'wallet',
        targetPage: const Wallet(),
      ),
      Category_featured(
        name: 'Dera Langa',
        thumbnail: 'location',
        targetPage: const Region(),
      ),
    ];
  } else {
    return [
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
        name: 'Business Profiles',
        thumbnail: 'business',
        targetPage: const BusinessProfilesPage(),
      ),
      Category_featured(
        name: 'Geo-specific Advisory',
        thumbnail: 'geo',
        targetPage: const AdvisoryMethodSelectionPage(),
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
      Category_featured(
        name: 'Farming Profile',
        thumbnail: 'farming_profile',
        targetPage: const FarmingSeasonsPage(),
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
    ];
  }
}
