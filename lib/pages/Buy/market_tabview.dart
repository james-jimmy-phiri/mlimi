import 'package:flutter/material.dart';
import 'package:mlimi/pages/Buy/markert.dart';

class MarketTabview extends StatelessWidget {
  const MarketTabview({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text("On Sale"),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text("On supply"),
      )
    ];
    return SizedBox(
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
                elevation: 0,
                toolbarHeight: 0,
                bottom: TabBar(
                  tabs: tabs,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                )),
            body: const TabBarView(
              children: [
                Markert(),
                Markert(),
              ],
            ),
          )),
    );
  }
}
