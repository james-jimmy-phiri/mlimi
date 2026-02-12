import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/services.dart';
import 'package:mlimi/models/farmer_models.dart';

class FarmerService {
  FarmerData? _farmerData;

  Future<void> loadFarmers() async {
    if (_farmerData != null) return;
    try {
      final String response =
          await rootBundle.loadString('assets/data/farmers_data.json');
      final data = await json.decode(response);
      _farmerData = FarmerData.fromJson(data);
    } catch (e) {
      print('Error loading farmers data: $e');
      rethrow;
    }
  }

  Farmer? findNearestFarmer(double lat, double long) {
    if (_farmerData == null) return null;

    Farmer? nearestFarmer;
    double minDistance = double.infinity;

    for (var region in _farmerData!.regions) {
      for (var district in region.districts) {
        for (var epa in district.epas) {
          for (var village in epa.villages) {
            for (var farmer in village.farmers) {
              double? farmerLat = double.tryParse(farmer.latitude);
              double? farmerLong = double.tryParse(farmer.longitude);

              if (farmerLat != null && farmerLong != null) {
                double distance = _calculateDistance(
                    lat, long, farmerLat, farmerLong);
                if (distance < minDistance) {
                  minDistance = distance;
                  nearestFarmer = farmer;
                }
              }
            }
          }
        }
      }
    }

    return nearestFarmer;
  }

  // Haversine formula to calculate distance in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
