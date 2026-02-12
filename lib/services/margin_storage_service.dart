import 'package:get_storage/get_storage.dart';
import 'package:mlimi/models/margin_record.dart';

class MarginStorageService {
  static const String _storageKey = 'saved_margin_records';
  final GetStorage _box = GetStorage();

  List<MarginRecord> getSavedRecords() {
    final List<dynamic>? rawData = _box.read(_storageKey);
    if (rawData == null) return [];
    return rawData.map((e) => MarginRecord.fromJson(e)).toList();
  }

  Future<bool> saveRecord(MarginRecord record) async {
    final List<MarginRecord> currentRecords = getSavedRecords();

    // Check for duplicates (ignoring ID and Date)
    // We check if a record with same crop name, field size, and total income exists (likely unique enough)
    bool isDuplicate = currentRecords.any((existing) =>
        existing.cropName == record.cropName &&
        existing.fieldSize == record.fieldSize &&
        existing.totalIncome == record.totalIncome &&
        existing.totalExpenditure == record.totalExpenditure);

    if (isDuplicate) {
      return false; // Indicate duplication
    }

    currentRecords.add(record);

    // Enforce max 10 records
    if (currentRecords.length > 10) {
      // Remove the oldest record (first in the list since we add to end)
      currentRecords.removeAt(0);
    }

    await _box.write(
        _storageKey, currentRecords.map((e) => e.toJson()).toList());
    return true; // Success
  }

  Future<void> deleteRecord(String id) async {
    final List<MarginRecord> currentRecords = getSavedRecords();
    currentRecords.removeWhere((record) => record.id == id);
    await _box.write(
        _storageKey, currentRecords.map((e) => e.toJson()).toList());
  }
}
