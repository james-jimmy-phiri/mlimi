import 'package:flutter/material.dart';
import 'package:mlimi/pages/Buy/buy.dart';
import 'package:mlimi/pages/Buy/markert.dart';
import 'package:mlimi/pages/market/market_actor/market_actors.dart';

import '../constant/constant.dart';

class Champion {
  final String name;

  final String description;
  final String imageUrl;
  final String buttunText;
  final Widget targetPage;

  const Champion(
      {required this.name,
      required this.imageUrl,
      required this.description,
      required this.buttunText,
      required this.targetPage});
}

final championsMap = {
  "E_Marketplaces": Champion(
      name: "E-Market places",
      buttunText: "VISIT THE PAGE",
      targetPage: const Buy(),
      imageUrl: "e_markert",
      description:
          " Online platforms connecting farmers directly with buyers, providing real-time fair pricing, and reducing dependency on intermediaries."),
  "farmgateprices": Champion(
      name: "FarmGatePrices",
      buttunText: "DOWNLOAD FILE",
      targetPage: Markert(),
      imageUrl: "farmgateprices",
      description:
          "Ignorance is as dangerous as death, know the approved prices for selling your produce. Chiefs, advisors, advisory councils, and our leadership are committed to promoting these prices in your respective areas."),
  "marketactors": Champion(
      name: "Markert Actors",
      buttunText: "VISIT THE PAGE",
      targetPage: MarketActors(),
      imageUrl: "market_actors",
      description:
          "Buyers who purchase farmers’ harvest play a crucial role in linking producers to markets by acquiring produce either directly from farms or through local markets. These buyers range from small-scale traders and middlemen, who buy at the farm gate or rural markets, to larger entities such as wholesalers, processors, and exporters who deal in bulk for resale or value addition. "),
  "getmarkets": Champion(
      name: "Market Research",
      buttunText: "DOWNLOAD FILE",
      targetPage: Markert(),
      imageUrl: "get_markets",
      description:
          "It is important for farmers who are part of a group to have a small committee assigned the responsibility of leading matters related to markets. When establishing this committee, farmers should understand the importance of having it, and the number of members in the committee should range from three to six people."),
};
