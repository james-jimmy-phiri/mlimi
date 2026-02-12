class MarginRecord {
  final String id;
  final DateTime date;
  final String cropName;
  final double fieldSize;
  final double sellingPrice;
  final double totalIncome;
  final double totalExpenditure;
  final double profitMargin;
  final double averageYield;
  final String cropImage;
  final List<SectionSummaryRecord> sectionSummaries;

  MarginRecord({
    required this.id,
    required this.date,
    required this.cropName,
    required this.fieldSize,
    required this.sellingPrice,
    required this.totalIncome,
    required this.totalExpenditure,
    required this.profitMargin,
    required this.averageYield,
    required this.cropImage,
    required this.sectionSummaries,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'cropName': cropName,
      'fieldSize': fieldSize,
      'sellingPrice': sellingPrice,
      'totalIncome': totalIncome,
      'totalExpenditure': totalExpenditure,
      'profitMargin': profitMargin,
      'averageYield': averageYield,
      'cropImage': cropImage,
      'sectionSummaries': sectionSummaries.map((s) => s.toJson()).toList(),
    };
  }

  factory MarginRecord.fromJson(Map<String, dynamic> json) {
    return MarginRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      cropName: json['cropName'],
      fieldSize: (json['fieldSize'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpenditure: (json['totalExpenditure'] as num).toDouble(),
      profitMargin: (json['profitMargin'] as num).toDouble(),
      averageYield: (json['averageYield'] as num).toDouble(),
      cropImage: json['cropImage'] ?? 'maize', // Default fallback
      sectionSummaries: (json['sectionSummaries'] as List)
          .map((s) => SectionSummaryRecord.fromJson(s))
          .toList(),
    );
  }
}

class SectionSummaryRecord {
  final String sectionName;
  final String contentItem;
  final String inputValue;
  final double rateAcre;
  final double total;

  SectionSummaryRecord({
    required this.sectionName,
    required this.contentItem,
    required this.inputValue,
    required this.rateAcre,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'sectionName': sectionName,
      'contentItem': contentItem,
      'inputValue': inputValue,
      'rateAcre': rateAcre,
      'total': total,
    };
  }

  factory SectionSummaryRecord.fromJson(Map<String, dynamic> json) {
    return SectionSummaryRecord(
      sectionName: json['sectionName'],
      contentItem: json['contentItem'],
      inputValue: json['inputValue'],
      rateAcre: (json['rateAcre'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}
