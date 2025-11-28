import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  String? _district;
  String? _region;

  String get district => _district ?? 'Unknown';
  String get region => _region ?? 'Unknown';

  void setLocation({required String district, required String region}) {
    _district = district;
    _region = region;
    notifyListeners();
  }

  // Future<void> fetchAndSetLocation() async {
  //   try {
  //     Position position = await LocationService().getCurrentLocation();
  //     // Use the latitude and longitude to get the district and region
  //     // This part is pseudo code, you need an API or a local database
  //     String district = 'Mchinji'; // Replace with actual lookup
  //     String region = 'Southern'; // Replace with actual lookup

  //     _district = district;
  //     _region = region;

  //     // Save to SharedPreferences
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('district', district);
  //     await prefs.setString('region', region);

  //     notifyListeners();
  //   } catch (error) {
  //     print('Error fetching location: $error');
  //   }
  // }

  Future<void> loadLocationFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _district = prefs.getString('district') ?? 'Unknown';
    _region = prefs.getString('region') ?? 'Unknown';
    notifyListeners();
  }
}
