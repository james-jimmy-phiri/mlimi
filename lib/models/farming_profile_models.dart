class ValueChain {
  final int id;
  final String name;
  final String? sector;

  ValueChain({required this.id, required this.name, this.sector});

  factory ValueChain.fromJson(Map<String, dynamic> json) {
    return ValueChain(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      sector: json['sector'],
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
    // Support both 'season_id' and 'farming_season_id' keys
    final rawSeasonId = json['season_id'] ?? json['farming_season_id'];
    return SeasonCrop(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      seasonId: rawSeasonId is int ? rawSeasonId : int.tryParse(rawSeasonId?.toString() ?? '0') ?? 0,
      valueChainId: json['value_chain_id'] is int ? json['value_chain_id'] : int.tryParse(json['value_chain_id'].toString()) ?? 0,
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
    final rawSeasonId = json['season_id'] ?? json['farming_season_id'];
    return SeasonLivestock(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      seasonId: rawSeasonId is int ? rawSeasonId : int.tryParse(rawSeasonId?.toString() ?? '0') ?? 0,
      valueChainId: json['value_chain_id'] is int ? json['value_chain_id'] : int.tryParse(json['value_chain_id'].toString()) ?? 0,
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
    final rawSeasonId = json['season_id'] ?? json['farming_season_id'];
    return SeasonHoney(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      seasonId: rawSeasonId is int ? rawSeasonId : int.tryParse(rawSeasonId?.toString() ?? '0') ?? 0,
      valueChainId: json['value_chain_id'] is int ? json['value_chain_id'] : int.tryParse(json['value_chain_id'].toString()) ?? 0,
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

// Farming Activity — tracks work done during a season
class FarmingActivity {
  final int id;
  final int seasonId;
  final String activityName;
  final String? description;
  final DateTime? dateCompleted;
  final double? cost;
  final String? notes;

  FarmingActivity({
    required this.id,
    required this.seasonId,
    required this.activityName,
    this.description,
    this.dateCompleted,
    this.cost,
    this.notes,
  });

  factory FarmingActivity.fromJson(Map<String, dynamic> json) {
    return FarmingActivity(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      seasonId: json['farming_season_id'] is int ? json['farming_season_id'] : int.tryParse(json['farming_season_id'].toString()) ?? 0,
      activityName: json['activity_name'] ?? '',
      description: json['description'],
      dateCompleted: json['date_completed'] != null ? DateTime.tryParse(json['date_completed']) : null,
      cost: json['cost'] != null ? double.tryParse(json['cost'].toString()) : null,
      notes: json['notes'],
    );
  }
}

// Expenditure - records a single expense entry for a farming season
class SeasonExpenditure {
  final int id;
  final int seasonId;
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  SeasonExpenditure({
    required this.id,
    required this.seasonId,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory SeasonExpenditure.fromJson(Map<String, dynamic> json) {
    return SeasonExpenditure(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      seasonId: json['farming_season_id'] is int ? json['farming_season_id'] : int.tryParse(json['farming_season_id'].toString()) ?? 0,
      category: json['category'] ?? 'Other',
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: json['date'] != null ? DateTime.tryParse(json['date']) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
    };
  }

  static const List<String> categories = [
    'Seeds',
    'Fertilizer',
    'Pesticides/Herbicides',
    'Labor',
    'Equipment/Machinery',
    'Transport',
    'Irrigation',
    'Land Rent',
    'Other',
  ];
}

// Financial Summary - computed P&L for a season
class SeasonFinancialSummary {
  final double totalRevenue;
  final double totalExpenses;
  final int salesCount;
  final int expenditureCount;

  const SeasonFinancialSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.salesCount,
    required this.expenditureCount,
  });

  double get netProfit => totalRevenue - totalExpenses;
  bool get isProfitable => netProfit >= 0;

  factory SeasonFinancialSummary.empty() => const SeasonFinancialSummary(
        totalRevenue: 0,
        totalExpenses: 0,
        salesCount: 0,
        expenditureCount: 0,
      );
}

class FarmingSeason {
  final int id;
  final int clientId;
  final String name;
  final String type;
  final String startYear;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final String? notes;
  final String? description;
  final String? benefits;
  final List<SeasonCrop> crops;
  final List<SeasonLivestock> livestock;
  final List<SeasonHoney> honey;
  final List<FarmingActivity> activities;

  FarmingSeason({
    required this.id,
    required this.clientId,
    required this.name,
    required this.type,
    required this.startYear,
    required this.startDate,
    this.endDate,
    required this.status,
    this.notes,
    this.description,
    this.benefits,
    this.crops = const [],
    this.livestock = const [],
    this.honey = const [],
    this.activities = const [],
  });

  factory FarmingSeason.fromJson(Map<String, dynamic> json) {
    // start_year is optional — derive from start_date if missing
    final rawStartYear = json['start_year']?.toString() ?? '';
    final rawStartDate = json['start_date'];
    final startDate = rawStartDate != null ? DateTime.tryParse(rawStartDate.toString()) ?? DateTime.now() : DateTime.now();
    final startYear = rawStartYear.isNotEmpty ? rawStartYear : startDate.year.toString();

    return FarmingSeason(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      clientId: json['client_id'] is int ? json['client_id'] : int.tryParse(json['client_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'Rain-fed',
      startYear: startYear,
      startDate: startDate,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null,
      status: json['status'] ?? 'Active',
      notes: json['notes'],
      description: json['description'],
      benefits: json['benefits'],
      crops: (json['crops'] as List<dynamic>?)?.map((c) => SeasonCrop.fromJson(c)).toList() ?? [],
      livestock: (json['livestock'] as List<dynamic>?)?.map((l) => SeasonLivestock.fromJson(l)).toList() ?? [],
      honey: (json['honey'] as List<dynamic>?)?.map((h) => SeasonHoney.fromJson(h)).toList() ?? [],
      activities: (json['activities'] as List<dynamic>?)?.map((a) => FarmingActivity.fromJson(a)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
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
      salesCount: json['sales_count'] is int ? json['sales_count'] : int.tryParse(json['sales_count'].toString()) ?? 0,
      byValueChain: List<Map<String, dynamic>>.from(json['by_value_chain'] ?? []),
    );
  }
}

/// A single commodity sale record (linked to a farming season)
class SeasonSale {
  final int id;
  final int? seasonId;
  final double quantitySold;
  final double unitPrice;
  final DateTime saleDate;
  final String? buyerName;
  final String? valueChainName;
  final String status;

  SeasonSale({
    required this.id,
    this.seasonId,
    required this.quantitySold,
    required this.unitPrice,
    required this.saleDate,
    this.buyerName,
    this.valueChainName,
    required this.status,
  });

  double get totalAmount => quantitySold * unitPrice;

  factory SeasonSale.fromJson(Map<String, dynamic> json) {
    // buyer can be a nested object or a string
    String? buyerName;
    if (json['buyer'] is Map) {
      buyerName = json['buyer']['name'];
    } else {
      buyerName = json['buyer_name'];
    }

    String? valueChainName;
    if (json['value_chain'] is Map) {
      valueChainName = json['value_chain']['name'];
    }

    return SeasonSale(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      seasonId: json['farming_season_id'] is int ? json['farming_season_id'] : int.tryParse(json['farming_season_id']?.toString() ?? ''),
      quantitySold: double.tryParse(json['quantity_sold']?.toString() ?? '0') ?? 0.0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      saleDate: json['sale_date'] != null ? DateTime.tryParse(json['sale_date'].toString()) ?? DateTime.now() : DateTime.now(),
      buyerName: buyerName,
      valueChainName: valueChainName,
      status: json['status'] ?? 'Completed',
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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      seasonId: json['season_id'] is int ? json['season_id'] : int.tryParse(json['season_id']?.toString() ?? ''),
      commodityOfferId: json['commodity_offer_id'] is int ? json['commodity_offer_id'] : int.tryParse(json['commodity_offer_id'].toString()) ?? 0,
      buyerId: json['buyer_id'] is int ? json['buyer_id'] : int.tryParse(json['buyer_id'].toString()) ?? 0,
      quantitySold: double.tryParse(json['quantity_sold']?.toString() ?? '0') ?? 0.0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      saleDate: DateTime.tryParse(json['sale_date']?.toString() ?? '') ?? DateTime.now(),
      receiptPhoto: json['receipt_photo'],
      status: json['status'] ?? 'Completed',
    );
  }
}

// Public Farmer Profile - for the Farmer Directory (public-facing)
class PublicFarmerProfile {
  final int id;
  final String name;
  final String? district;
  final String? region;
  final String? phone;
  final int seasonCount;
  final int activeSeasonCount;
  final List<String> primaryCrops;
  final List<String> primaryLivestock;
  final String? currentSeasonStatus;

  PublicFarmerProfile({
    required this.id,
    required this.name,
    this.district,
    this.region,
    this.phone,
    required this.seasonCount,
    required this.activeSeasonCount,
    required this.primaryCrops,
    required this.primaryLivestock,
    this.currentSeasonStatus,
  });

  factory PublicFarmerProfile.fromJson(Map<String, dynamic> json) {
    return PublicFarmerProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown Farmer',
      district: json['district'],
      region: json['region'],
      phone: json['phone'],
      seasonCount: json['season_count'] is int ? json['season_count'] : int.tryParse(json['season_count']?.toString() ?? '0') ?? 0,
      activeSeasonCount: json['active_season_count'] is int ? json['active_season_count'] : int.tryParse(json['active_season_count']?.toString() ?? '0') ?? 0,
      primaryCrops: (json['primary_crops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      primaryLivestock: (json['primary_livestock'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      currentSeasonStatus: json['current_season_status'],
    );
  }

  String get maskedPhone {
    if (phone == null || phone!.length < 7) return 'N/A';
    final p = phone!.replaceAll(' ', '');
    return '${p.substring(0, 4)} *** ${p.substring(p.length - 3)}';
  }
}
