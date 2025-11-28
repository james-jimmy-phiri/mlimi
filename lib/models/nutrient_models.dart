class NutrientRecommendationRequest {
  final String hhid;
  final String phone;
  final String? newLongitude;
  final String? newLatitude;
  final String? gender;
  final String language;
  final String landUnit;
  final double landValue;
  final bool shortSms;

  NutrientRecommendationRequest({
    required this.hhid,
    required this.phone,
    required this.language,
    required this.landUnit,
    required this.landValue,
    required this.shortSms,
    this.newLongitude,
    this.newLatitude,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'hhid': hhid,
      'phone': phone,
      if (newLongitude?.isNotEmpty ?? false) 'new_long': newLongitude,
      if (newLatitude?.isNotEmpty ?? false) 'new_lat': newLatitude,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      'language': language,
      'land_unit': landUnit,
      'land_value': landValue,
      'short_sms': shortSms,
    };
  }
}

class NutrientRecommendationResult {
  final Map<String, dynamic> table;
  final NutrientSmsBundle sms;
  final int? recommendationId;

  NutrientRecommendationResult({
    required this.table,
    required this.sms,
    required this.recommendationId,
  });

  factory NutrientRecommendationResult.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    final table = Map<String, dynamic>.from(data['table'] ?? {});
    final smsPayload = Map<String, dynamic>.from(data['sms'] ?? {});
    return NutrientRecommendationResult(
      table: table,
      sms: NutrientSmsBundle.fromJson(smsPayload),
      recommendationId: data['recommendation_id'] as int?,
    );
  }

  String? stringField(String key) {
    final value = table[key];
    return value?.toString();
  }

  double? doubleField(String key) {
    final value = table[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  List<MapEntry<String, String>> toDisplayRows() {
    return table.entries
        .map(
          (entry) => MapEntry(
            entry.key,
            entry.value == null ? '' : entry.value.toString(),
          ),
        )
        .toList();
  }

  String toCsv() {
    if (table.isEmpty) return '';
    final buffer = StringBuffer();
    final keys = table.keys.map(csvEscape).join(',');
    final values = table.values.map(csvEscape).join(',');
    buffer.writeln(keys);
    buffer.writeln(values);
    return buffer.toString();
  }
}

class NutrientSmsBundle {
  final String? smsEn;
  final String? smsNy;
  final String? smsShortEn;
  final String? smsShortNy;

  NutrientSmsBundle({
    this.smsEn,
    this.smsNy,
    this.smsShortEn,
    this.smsShortNy,
  });

  factory NutrientSmsBundle.fromJson(Map<String, dynamic> json) {
    return NutrientSmsBundle(
      smsEn: json['en'] as String? ?? json['sms_en'] as String?,
      smsNy: json['ny'] as String? ?? json['sms_ny'] as String?,
      smsShortEn: json['short_en'] as String? ?? json['sms_short_en'] as String?,
      smsShortNy: json['short_ny'] as String? ?? json['sms_short_ny'] as String?,
    );
  }
}

class NutrientSendResponse {
  final bool ok;
  final String display;
  final String? reason;

  NutrientSendResponse({
    required this.ok,
    required this.display,
    this.reason,
  });

  factory NutrientSendResponse.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? json);
    return NutrientSendResponse(
      ok: data['ok'] as bool? ?? false,
      display: data['display']?.toString() ?? '',
      reason: data['reason']?.toString(),
    );
  }
}

class NutrientException implements Exception {
  final String message;
  NutrientException(this.message);

  @override
  String toString() => message;
}

String csvEscape(dynamic value) {
  if (value == null) return '';
  final str = value.toString();
  if (str.contains(',') || str.contains('"') || str.contains('\n')) {
    return '"${str.replaceAll('"', '""')}"';
  }
  return str;
}

