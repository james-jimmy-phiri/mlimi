import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mlimi/models/farmer_models.dart';

class FarmerService {
  Future<FarmerData> loadFarmers() async {
    final String response =
        await rootBundle.loadString('assets/data/farmers_data.json');
    final data = await json.decode(response);
    return FarmerData.fromJson(data);
  }
}
