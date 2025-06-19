import 'package:flutter/material.dart';
import 'package:mlimi/pages/advisory/Single_advisory_view/single_list.dart';
import 'package:mlimi/pages/advisory/components/about_us_view.dart';

import 'package:mlimi/constants/color.dart';

List moreArr = [
  {
    "index": "1",
    "name": "Maize",
    "image": "assets/images/more_payment.png",
    "base": 0
  },
  {
    "index": "2",
    "name": "GroundNuts",
    "image": "assets/images/more_my_order.png",
    "base": 0
  },
  {
    "index": "3",
    "name": "Soybeans",
    "image": "assets/images/more_notification.png",
    "base": 0
  },
  {
    "index": "4",
    "name": "Sunflower",
    "image": "assets/images/more_inbox.png",
    "base": 0
  },
  {
    "index": "5",
    "name": "Rice",
    "image": "assets/images/more_info.png",
    "base": 0
  },
];

class SliverListBldr extends StatelessWidget {
  const SliverListBldr({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            var mObj = moreArr[index] as Map? ?? {};
            var countBase = mObj["base"] as int? ?? 0;
            return InkWell(
              onTap: () {
                switch (mObj["index"].toString()) {
                  case "1":
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutUsView()));
                    break;

                  case "2":
                  case "3":
                  case "4":
                  case "5":
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SingleAdvisoryView()));
                    break;

                  default:
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                          color: TColor.textfield,
                          borderRadius: BorderRadius.circular(5)),
                      margin: const EdgeInsets.only(right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: TColor.placeholder,
                                borderRadius: BorderRadius.circular(25)),
                            alignment: Alignment.center,
                            child: Image.asset(mObj["image"].toString(),
                                width: 25, height: 25, fit: BoxFit.contain),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Text(
                              mObj["name"].toString(),
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          if (countBase > 0)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12.5)),
                              alignment: Alignment.center,
                              child: Text(
                                countBase.toString(),
                                style: TextStyle(
                                    color: TColor.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: TColor.textfield,
                          borderRadius: BorderRadius.circular(15)),
                      child: Image.asset("assets/images/btn_next.png",
                          width: 10, height: 10, color: TColor.primaryText),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: moreArr.length,
        ),
      ),
    );
  }
}
