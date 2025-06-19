import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/provider/location_provider.dart';
import 'package:provider/provider.dart';

class MyCurrentLocation extends StatelessWidget {
  const MyCurrentLocation({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final district = locationProvider.district;
    final region = locationProvider.region;

    // Retrieve the selected language from GetStorage
    final storage = GetStorage();
    String language = storage.read('language') ?? 'en';

    // Define text based on language
    String getText(String enText, String nyText) {
      return language == 'ny' ? nyText : enText;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(right: 5, left: 5),
      padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(getText("Current District:", "Chigawo Chamakono:"),
                  style: TextStyle(
                    color: Colors.white60,
                  )),
              Text(district ?? "Loading...",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))
            ],
          ),
          VerticalDivider(
            color: Colors.white,
            thickness: 1,
            width: 20, // Adjust the width as needed
            indent: 5, // Adjust the indent as needed
            endIndent: 5, // Adjust the end indent as needed
          ),
          Column(
            children: [
              Text(getText("Region:", "Chigawo:"),
                  style: TextStyle(color: Colors.white60)),
              Text(region ?? "Loading...",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
