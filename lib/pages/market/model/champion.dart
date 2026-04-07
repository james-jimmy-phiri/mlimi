import 'package:flutter/material.dart';
import 'package:mlimi/features/buy_sell/views/buy_sell_home_page.dart';
import 'package:mlimi/pages/Buy/markert.dart';
import 'package:mlimi/pages/market/market_actor/market_actors.dart';
import 'package:get_storage/get_storage.dart';

class Champion {
  final String name;
  final String description;
  final String imageUrl;
  final String buttunText;
  final Widget targetPage;

  const Champion({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.buttunText,
    required this.targetPage,
  });
}

// English version of the champions map
final championsMapEn = {
  "E_Marketplaces": Champion(
    name: "E-Market places",
    buttunText: "VISIT THE PAGE",
    targetPage: const BuySellHomePage(),
    imageUrl: "e_markert",
    description:
        "Online platforms connecting farmers directly with buyers, providing real-time fair pricing, and reducing dependency on intermediaries.",
  ),
  "farmgateprices": Champion(
    name: "FarmGatePrices",
    buttunText: "DOWNLOAD FILE",
    targetPage: Markert(),
    imageUrl: "farmgateprices",
    description:
        "Ignorance is as dangerous as death, know the approved prices for selling your produce. Chiefs, advisors, advisory councils, and our leadership are committed to promoting these prices in your respective areas.",
  ),
  "marketactors": Champion(
    name: "Market Actors",
    buttunText: "VISIT THE PAGE",
    targetPage: MarketActors(),
    imageUrl: "market_actors",
    description:
        "Buyers who purchase farmers' harvest play a crucial role in linking producers to markets by acquiring produce either directly from farms or through local markets. These buyers range from small-scale traders and middlemen, who buy at the farm gate or rural markets, to larger entities such as wholesalers, processors, and exporters who deal in bulk for resale or value addition.",
  ),
  "getmarkets": Champion(
    name: "Market Research",
    buttunText: "DOWNLOAD FILE",
    targetPage: Markert(),
    imageUrl: "get_markets",
    description:
        "It is important for farmers who are part of a group to have a small committee assigned the responsibility of leading matters related to markets. When establishing this committee, farmers should understand the importance of having it, and the number of members in the committee should range from three to six people.",
  ),
};

// Chichewa version of the champions map
final championsMapNy = {
  "E_Marketplaces": Champion(
    name: "Pansika wapa Intaneti",
    buttunText: "PITANI KU TSAMBA",
    targetPage: const BuySellHomePage(),
    imageUrl: "e_markert",
    description:
        "Pansika ndi Malo ogulitsira pa intaneti olumikizitsa alimi ndi ogula, opereka mitengo yoyenera komanso yovomeledzeka ndiboma, ndi kuchepetsa kudalira mavenda.",
  ),
  "farmgateprices": Champion(
    name: "Mitengo yovomerezeka ndi boma",
    buttunText: "Download",
    targetPage: Markert(),
    imageUrl: "farmgateprices",
    description:
        "Kusadziwa ndikufa komwe, dziwani zamitengo yovomerezeka ndiboma yogulitsira zokolola zanu. Mafumu, alangizi, mabungwe alangizi, ndi atsogoleri athu akhazikika kutsogolera mitengo iyi m'madera anu.",
  ),
  "marketactors": Champion(
    name: "Ogula Zokolola",
    buttunText: "PITANI KU TSAMBA",
    targetPage: MarketActors(),
    imageUrl: "market_actors",
    description:
        "Ogula amene ali ovomeledzeka ndiboma pokhala ndi certificate yaboma omwe amagula zokolola za alimi amathandiza kwambiri kulumikizira alimi ndi misika pogula zokolola kumene kuli mundawo kapena kudzera m'misika ya m'madera. Ogula amenewa amakhala ogula ang'onoang'ono ndi anthu apakati, amene amagula pamunda kapena m'misika ya kumidzi, mpaka mabungwe aakulu monga ogula kwambiri, opanga zinthu, ndi otumiza kunja amene amagula zambiri kuti agulitsenso kapena kuwonjezera phindu.",
  ),
  "getmarkets": Champion(
    name: "Kafukufuku wa Msika",
    buttunText: "Download",
    targetPage: Markert(),
    imageUrl: "get_markets",
    description:
        "Ndikofunika kuti alimi amene ali mgulu akhale ndi komiti yaing'ono yopatsidwa udindo wotsogolera nkhani zokhudzana ndi misika. Pokhazikitsa komiti iyi, alimi ayenera kumvetsetsa kufunika kwake, ndipo chiwerengero cha mamembala mukomiti chiyenera kukhala pakati pa anthu atatu mpaka asanu ndi mmodzi.",
  ),
};

// Function to get the appropriate champions map based on language
Map<String, Champion> getChampionsMap() {
  final storage = GetStorage();
  final currentLanguage = storage.read<String>('language') ?? 'en';
  return currentLanguage == 'en' ? championsMapEn : championsMapNy;
}

// Use this as the main export
final championsMap = getChampionsMap();
