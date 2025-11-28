import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:get_storage/get_storage.dart';

class DiscountCard extends StatefulWidget {
  const DiscountCard({
    super.key,
  });

  @override
  State<DiscountCard> createState() => _DiscountCardState();
}

class _DiscountCardState extends State<DiscountCard> {
  late String _language;
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    // Retrieve language preference from GetStorage
    _language = storage.read<String>('language') ?? 'en';
  }

  String _localizedText(String enText, String nyText) {
    return _language == 'ny' ? nyText : enText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: double.infinity,
            height: 166,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/beyond-meat-mcdonalds.png"),
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 42, 84, 0).withOpacity(0.9),
                    kPrimaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: _localizedText(
                                "A Farmer with Knowledge is \n",
                                "Mlimi wodziwa komanso wodzisata \n",
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const TextSpan(
                              text: "Ndiye chiyambi \n",
                              style: TextStyle(
                                fontSize: 43,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: _localizedText(
                                "Good towards Good harvest",
                                "Chazokolola zabwino komanso zochuluka",
                              ),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
