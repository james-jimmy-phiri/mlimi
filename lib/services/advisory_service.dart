import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mlimi/models/advisory_model.dart';
import 'package:mlimi/models/finacial_literacy_model.dart';

class DataService {
  Future<List<Sector>> loadSectorsFromJson() async {
    final String response =
        await rootBundle.loadString('assets/data/mlimi_english.json');
    final data = json.decode(response);
    return (data['sectors'] as List).map((i) => Sector.fromJson(i)).toList();
  }

static Future<List<FinancialTheme>> loadFinancialData() async {
    try {
      // Check if file exists and load it
      String jsonString = await rootBundle.loadString('assets/data/fin.json');
      print("JSON Loaded Successfully!");

      // Decode JSON
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      print("Decoded JSON: $jsonData");

      // Parse themes
      List<FinancialTheme> themes = (jsonData['financialthemes'] as List)
          .map((theme) => FinancialTheme.fromJson(theme))
          .toList();
      print("Parsed Themes: ${themes.length}");

      return themes;
    } catch (e) {
      print("🚨 Error loading JSON: $e");
      return [];
    }
  }
  

  Future<Sector> getSectorByType(String sectorType) async {
    // Load sectors from JSON
    List<Sector> sectors = await loadSectorsFromJson();

    // Find and return the sector matching the sectorType
    try {
      return sectors.firstWhere(
        (sector) => sector.name.toLowerCase() == sectorType.toLowerCase(),
      );
    } catch (e) {
      // Handle the case where no sector is found
      throw Exception('Sector not found for type: $sectorType');
    }
  }
}
