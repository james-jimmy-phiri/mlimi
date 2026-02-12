import 'package:get_storage/get_storage.dart';
import 'package:mlimi/models/nutrient_models.dart';

class NutrientStorageService {
  static const String _storageKey = 'saved_nutrient_recommendations';
  final GetStorage _box = GetStorage();

  List<NutrientRecommendationResult> getSavedRecords() {
    final List<dynamic>? rawData = _box.read(_storageKey);
    if (rawData == null) return [];
    return rawData.map((e) => NutrientRecommendationResult.fromJson(e)).toList();
  }

  Future<bool> saveRecord(NutrientRecommendationResult record) async {
    final List<NutrientRecommendationResult> currentRecords = getSavedRecords();

    // Check for duplicates using the uniqueKey
    bool isDuplicate = currentRecords.any((existing) => existing.uniqueKey == record.uniqueKey);

    if (isDuplicate) {
      return false; // Indicate duplication
    }

    // Add to the beginning of the list (newest first)
    currentRecords.insert(0, record);

    // Enforce max 20 records
    if (currentRecords.length > 20) {
      currentRecords.removeLast();
    }

    await _box.write(
        _storageKey, currentRecords.map((e) => e.toJson()).toList());
    return true; // Success
  }

  Future<void> deleteRecord(int recommendationId) async {
    final List<NutrientRecommendationResult> currentRecords = getSavedRecords();
    currentRecords.removeWhere((record) => record.recommendationId == recommendationId);
    await _box.write(
        _storageKey, currentRecords.map((e) => e.toJson()).toList());
  }

  bool isSaved(int? recommendationId) {
    if (recommendationId == null) return false;
    final List<NutrientRecommendationResult> currentRecords = getSavedRecords();
    return currentRecords.any((record) => record.recommendationId == recommendationId);
  }
}
