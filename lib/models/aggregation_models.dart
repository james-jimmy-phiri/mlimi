class Aggregation {
  final int? id;
  final int? groupId;
  final int? commodityId;
  final double totalQuantity;
  final double remainingQuantity;
  final String status;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  // Relations
  final AggregationGroup? group;
  final AggregationCommodity? commodity;
  final AggregationCreator? creator;
  final List<AggregationContribution> contributions;
  final List<AggregationSale> sales;

  Aggregation({
    this.id,
    this.groupId,
    this.commodityId,
    this.totalQuantity = 0.0,
    this.remainingQuantity = 0.0,
    this.status = 'open',
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.group,
    this.commodity,
    this.creator,
    this.contributions = const [],
    this.sales = const [],
  });

  factory Aggregation.fromJson(Map<String, dynamic> json) {
    return Aggregation(
      id: json['id'],
      groupId: json['group_id'],
      commodityId: json['commodity_id'],
      totalQuantity: (json['total_quantity'] ?? 0.0).toDouble(),
      remainingQuantity: (json['remaining_quantity'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'open',
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      group: json['group'] != null ? AggregationGroup.fromJson(json['group']) : null,
      commodity: json['commodity'] != null ? AggregationCommodity.fromJson(json['commodity']) : null,
      creator: json['creator'] != null ? AggregationCreator.fromJson(json['creator']) : null,
      contributions: json['contributions'] != null
          ? (json['contributions'] as List).map((i) => AggregationContribution.fromJson(i)).toList()
          : [],
      sales: json['sales'] != null
          ? (json['sales'] as List).map((i) => AggregationSale.fromJson(i)).toList()
          : [],
    );
  }
}

class AggregationContribution {
  final int? id;
  final int? aggregationId;
  final int? groupMemberId;
  final double quantity;
  final String? createdAt;

  final AggregationGroupMember? groupMember;

  AggregationContribution({
    this.id,
    this.aggregationId,
    this.groupMemberId,
    this.quantity = 0.0,
    this.createdAt,
    this.groupMember,
  });

  factory AggregationContribution.fromJson(Map<String, dynamic> json) {
    return AggregationContribution(
      id: json['id'],
      aggregationId: json['aggregation_id'],
      groupMemberId: json['group_member_id'],
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      createdAt: json['created_at'],
      groupMember: json['group_member'] != null ? AggregationGroupMember.fromJson(json['group_member']) : null,
    );
  }
}

class AggregationSale {
  final int? id;
  final int? aggregationId;
  final int? buyerId;
  final double quantitySold;
  final double pricePerUnit;
  final double totalAmount;
  final String? dateSold;
  final String? createdAt;

  final AggregationBuyer? buyer;

  AggregationSale({
    this.id,
    this.aggregationId,
    this.buyerId,
    this.quantitySold = 0.0,
    this.pricePerUnit = 0.0,
    this.totalAmount = 0.0,
    this.dateSold,
    this.createdAt,
    this.buyer,
  });

  factory AggregationSale.fromJson(Map<String, dynamic> json) {
    return AggregationSale(
      id: json['id'],
      aggregationId: json['aggregation_id'],
      buyerId: json['buyer_id'],
      quantitySold: (json['quantity_sold'] ?? 0.0).toDouble(),
      pricePerUnit: (json['price_per_unit'] ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      dateSold: json['date_sold'],
      createdAt: json['created_at'],
      buyer: json['buyer'] != null ? AggregationBuyer.fromJson(json['buyer']) : null,
    );
  }
}

class AggregationGroup {
  final int? id;
  final String name;

  AggregationGroup({this.id, required this.name});

  factory AggregationGroup.fromJson(Map<String, dynamic> json) {
    return AggregationGroup(
      id: json['id'],
      name: json['name'] ?? json['business_name'] ?? 'Unknown Group',
    );
  }
}

class AggregationCommodity {
  final int? id;
  final int? valueChainId;
  final double quantity;

  AggregationCommodity({this.id, this.valueChainId, this.quantity = 0.0});

  factory AggregationCommodity.fromJson(Map<String, dynamic> json) {
    return AggregationCommodity(
      id: json['id'],
      valueChainId: json['value_chain_id'],
      quantity: (json['quantity'] ?? 0.0).toDouble(),
    );
  }
}

class AggregationCreator {
  final int? id;
  final String name;

  AggregationCreator({this.id, required this.name});

  factory AggregationCreator.fromJson(Map<String, dynamic> json) {
    return AggregationCreator(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
    );
  }
}

class AggregationGroupMember {
  final int? id;
  final String name;

  AggregationGroupMember({this.id, required this.name});

  factory AggregationGroupMember.fromJson(Map<String, dynamic> json) {
    return AggregationGroupMember(
      id: json['id'],
      name: json['name'] ?? 'Unknown Member',
    );
  }
}

class AggregationBuyer {
  final int? id;
  final String name;
  final String? phone;

  AggregationBuyer({this.id, required this.name, this.phone});

  factory AggregationBuyer.fromJson(Map<String, dynamic> json) {
    return AggregationBuyer(
      id: json['id'],
      name: json['name'] ?? 'Unknown Buyer',
      phone: json['phone'],
    );
  }
}

class AggregationMetrics {
  final int totalAggregations;
  final int activeAggregations;
  final int completedAggregations;
  final double totalVolume;
  final double remainingVolume;
  final double totalSoldVolume;
  final double totalRevenue;
  final int uniqueFarmerCount;

  AggregationMetrics({
    this.totalAggregations = 0,
    this.activeAggregations = 0,
    this.completedAggregations = 0,
    this.totalVolume = 0.0,
    this.remainingVolume = 0.0,
    this.totalSoldVolume = 0.0,
    this.totalRevenue = 0.0,
    this.uniqueFarmerCount = 0,
  });

  factory AggregationMetrics.fromJson(Map<String, dynamic> json) {
    return AggregationMetrics(
      totalAggregations: json['total_aggregations'] ?? 0,
      activeAggregations: json['active_aggregations'] ?? 0,
      completedAggregations: json['completed_aggregations'] ?? 0,
      totalVolume: (json['total_volume'] ?? 0.0).toDouble(),
      remainingVolume: (json['remaining_volume'] ?? 0.0).toDouble(),
      totalSoldVolume: (json['total_sold_volume'] ?? 0.0).toDouble(),
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      uniqueFarmerCount: json['unique_farmer_count'] ?? 0,
    );
  }
}
