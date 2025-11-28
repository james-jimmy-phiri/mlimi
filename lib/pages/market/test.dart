import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

import 'model/champion.dart';
import 'page/detail_view.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    final champions = championsMap.values.toList();
    return Scaffold(
      backgroundColor: Bgreen,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Container(
            //   width: double.infinity,
            //   height: 70,
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(vertical: 15.0),
            //     child: Center(
            //         child: Image.asset(
            //       "images/logo.png",
            //       fit: BoxFit.cover,
            //     )),
            //   ),
            // ),
            Expanded(
              child: Container(
                child: VerticalCardPager(
                  titles: champions.map((e) => e.name.toUpperCase()).toList(),
                  images: champions
                      .map((e) => Hero(
                            tag: e.name.toUpperCase(),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Image.asset(
                                    'assets/logo/${e.imageUrl}.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: Colors.black.withOpacity(
                                        0.4), // Dark overlay with 40% opacity
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  onPageChanged: (page) {},
                  onSelectedItem: (index) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailView(
                                champion: champions[index],
                              )),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
