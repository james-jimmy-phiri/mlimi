class ValueChain {
  final int id;
  final String name;

  ValueChain({required this.id, required this.name});

  factory ValueChain.fromJson(Map<String, dynamic> json) {
    return ValueChain(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class SeasonCrop {
  final int id;
  final int seasonId;
  final int valueChainId;
  final double areaCultivated;
  final double? expectedYieldPerUnit;
  final String? unitOfMeasurement;
  final double? totalExpectedHarvestQuantity;
  final DateTime? expectedHarvestDate;
  final DateTime? harvestWindowEnd;
  final String productionMethod;
  final double? availableQuantityForSale;
  final ValueChain? valueChain;

  SeasonCrop({
    required this.id,
    required this.seasonId,
    required this.valueChainId,
    required this.areaCultivated,
    this.expectedYieldPerUnit,
    this.unitOfMeasurement,
    this.totalExpectedHarvestQuantity,
    this.expectedHarvestDate,
    this.harvestWindowEnd,
    required this.productionMethod,
    this.availableQuantityForSale,
    this.valueChain,
  });

  factory SeasonCrop.fromJson(Map<String, dynamic> json) {
    return SeasonCrop(
      id: json['id'],
      seasonId: json['season_id'],
      valueChainId: json['value_chain_id'],
      areaCultivated: double.tryParse(json['area_cultivated']?.toString() ?? '0') ?? 0.0,
      expectedYieldPerUnit: json['expected_yield_per_unit'] != null ? double.tryParse(json['expected_yield_per_unit'].toString()) : null,
      unitOfMeasurement: json['unit_of_measurement'],
      totalExpectedHarvestQuantity: json['total_expected_harvest_quantity'] != null ? double.tryParse(json['total_expected_harvest_quantity'].toString()) : null,
      expectedHarvestDate: json['expected_harvest_date'] != null ? DateTime.tryParse(json['expected_harvest_date']) : null,
      harvestWindowEnd: json['harvest_window_end'] != null ? DateTime.tryParse(json['harvest_window_end']) : null,
      productionMethod: json['production_method'] ?? 'Conventional',
      availableQuantityForSale: json['available_quantity_for_sale'] != null ? double.tryParse(json['available_quantity_for_sale'].toString()) : null,
      valueChain: json['value_chain'] != null ? ValueChain.fromJson(json['value_chain']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value_chain_id': valueChainId,
      'area_cultivated': areaCultivated,
      'expected_yield_per_unit': expectedYieldPerUnit,
      'unit_of_measurement': unitOfMeasurement,
      'expected_harvest_date': expectedHarvestDate?.toIso8601String().split('T')[0],
      'harvest_window_end': harvestWindowEnd?.toIso8601String().split('T')[0],
      'production_method': productionMethod,
    };
  }
}

class SeasonLivestock {
  final int id;
  final int seasonId;
  final int valueChainId;
  final int numberOfAnimals;
  final String? animalVariety;
  final String? unitOfMeasurement;
  final ValueChain? valueChain;

  SeasonLivestock({
    required this.id,
    required this.seasonId,
    required this.valueChainId,
    required this.numberOfAnimals,
    this.animalVariety,
    this.unitOfMeasurement,
    this.valueChain,
  });

  factory SeasonLivestock.fromJson(Map<String, dynamic> json) {
    return SeasonLivestock(
      id: json['id'],
      seasonId: json['season_id'],
      valueChainId: json['value_chain_id'],
      numberOfAnimals: int.tryParse(json['number_of_animals']?.toString() ?? '0') ?? 0,
      animalVariety: json['animal_variety'],
      unitOfMeasurement: json['unit_of_measurement'],
      valueChain: json['value_chain'] != null ? ValueChain.fromJson(json['value_chain']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value_chain_id': valueChainId,
      'number_of_animals': numberOfAnimals,
      'animal_variety': animalVariety,
      'unit_of_measurement': unitOfMeasurement,
    };
  }
}

class SeasonHoney {
  final int id;
  final int seasonId;
  final int valueChainId;
  final int numberOfBeehives;
  final double expectedProductionKg;
  final ValueChain? valueChain;

  SeasonHoney({
    required this.id,
    required this.seasonId,
    required this.valueChainId,
    required this.numberOfBeehives,
    required this.expectedProductionKg,
    this.valueChain,
  });

  factory SeasonHoney.fromJson(Map<String, dynamic> json) {
    return SeasonHoney(
      id: json['id'],
      seasonId: json['season_id'],
      valueChainId: json['value_chain_id'],
      numberOfBeehives: int.tryParse(json['number_of_beehives']?.toString() ?? '0') ?? 0,
      expectedProductionKg: double.tryParse(json['expected_production_kg']?.toString() ?? '0') ?? 0.0,
      valueChain: json['value_chain'] != null ? ValueChain.fromJson(json['value_chain']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value_chain_id': valueChainId,
      'number_of_beehives': numberOfBeehives,
      'expected_production_kg': expectedProductionKg,
    };
  }
}

class FarmingSeason {
  final int id;
  final int clientId;
  final String name;
  final String startYear;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final String? notes;
  final List<SeasonCrop> crops;
  final List<SeasonLivestock> livestock;
  final List<SeasonHoney> honey;

  FarmingSeason({
    required this.id,
    required this.clientId,
    required this.name,
    required this.startYear,
    required this.startDate,
    this.endDate,
    required this.status,
    this.notes,
    this.crops = const [],
    this.livestock = const [],
    this.honey = const [],
  });

  factory FarmingSeason.fromJson(Map<String, dynamic> json) {
    return FarmingSeason(
      id: json['id'],
      clientId: json['client_id'],
      name: json['name'],
      startYear: json['start_year']?.toString() ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      status: json['status'] ?? 'Active',
      notes: json['notes'],
      crops: (json['crops'] as List<dynamic>?)?.map((c) => SeasonCrop.fromJson(c)).toList() ?? [],
      livestock: (json['livestock'] as List<dynamic>?)?.map((l) => SeasonLivestock.fromJson(l)).toList() ?? [],
      honey: (json['honey'] as List<dynamic>?)?.map((h) => SeasonHoney.fromJson(h)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_year': startYear,
      'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T')[0],
      'status': status,
      'notes': notes,
    };
  }
}

class SeasonSalesSummary {
  final double totalQuantitySold;
  final double totalRevenue;
  final int salesCount;
  final List<Map<String, dynamic>> byValueChain;

  SeasonSalesSummary({
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.salesCount,
    required this.byValueChain,
  });

  factory SeasonSalesSummary.fromJson(Map<String, dynamic> json) {
    return SeasonSalesSummary(
      totalQuantitySold: double.tryParse(json['total_quantity_sold']?.toString() ?? '0') ?? 0.0,
      totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
      salesCount: json['sales_count'] ?? 0,
      byValueChain: List<Map<String, dynamic>>.from(json['by_value_chain'] ?? []),
    );
  }
}

class CommoditySale {
  final int id;
  final int? seasonId;
  final int commodityOfferId;
  final int buyerId;
  final double quantitySold;
  final double unitPrice;
  final DateTime saleDate;
  final String? receiptPhoto;
  final String status;

  CommoditySale({
    required this.id,
    this.seasonId,
    required this.commodityOfferId,
    required this.buyerId,
    required this.quantitySold,
    required this.unitPrice,
    required this.saleDate,
    this.receiptPhoto,
    required this.status,
  });

  factory CommoditySale.fromJson(Map<String, dynamic> json) {
    return CommoditySale(
      id: json['id'],
      seasonId: json['season_id'],
      commodityOfferId: json['commodity_offer_id'],
      buyerId: json['buyer_id'],
      quantitySold: double.tryParse(json['quantity_sold']?.toString() ?? '0') ?? 0.0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      saleDate: DateTime.parse(json['sale_date']),
      receiptPhoto: json['receipt_photo'],
      status: json['status'] ?? 'Completed',
    );
  }
}
