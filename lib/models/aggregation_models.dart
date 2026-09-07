/// Safely converts a dynamic value (String, int, double, or null) to double.
/// The backend sometimes sends numbers as strings (e.g. "1711.00") so we
/// must handle both types to avoid NoSuchMethodError.
double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

// ─── ValueChainItem ───────────────────────────────────────────────────────────

class ValueChainItem {
  final int id;
  final String name;
  final String category;
  final String sector;

  ValueChainItem({
    required this.id,
    required this.name,
    required this.category,
    required this.sector,
  });

  factory ValueChainItem.fromJson(Map<String, dynamic> json) {
    return ValueChainItem(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      sector: json['sector']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}

// ─── Aggregation ──────────────────────────────────────────────────────────────

class Aggregation {
  final int? id;
  final int? groupId;
  final int? commodityId;
  final double totalQuantity;
  final double remainingQuantity;
  final String status;
  final int? createdBy;
  final String? publishedAt;  // null means not yet finalized/broadcast
  final String? createdAt;
  final String? updatedAt;

  // Extra fields that come from the aggregation record directly
  final double? unitPrice;
  final String? description;
  final String? expectedSupplyDate;

  // Relations
  final AggregationGroup? group;
  final AggregationCommodity? commodity;
  final AggregationCreator? creator;
  final List<AggregationContribution> contributions;
  final List<AggregationSale> sales;
  final List<MemberEarnings> memberEarningsBreakdown;

  Aggregation({
    this.id,
    this.groupId,
    this.commodityId,
    this.totalQuantity = 0.0,
    this.remainingQuantity = 0.0,
    this.status = 'open',
    this.createdBy,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.unitPrice,
    this.description,
    this.expectedSupplyDate,
    this.group,
    this.commodity,
    this.creator,
    this.contributions = const [],
    this.sales = const [],
    this.memberEarningsBreakdown = const [],
  });

  factory Aggregation.fromJson(Map<String, dynamic> json) {
    AggregationCommodity? comm;
    if (json['commodity_details'] != null) {
      comm = AggregationCommodity.fromJson(json['commodity_details']);
    } else if (json['commodity'] != null) {
      comm = AggregationCommodity.fromJson(json['commodity']);
    }

    // Top-level aggregation fields that may supplement commodity data
    final topPrice = _toDouble(json['unit_price']);
    final topImage = json['image_url'] ?? json['image'];
    final topDesc = json['description'];

    if (comm != null && (comm.unitPrice == 0.0 && topPrice > 0 || comm.imageUrl == null && topImage != null)) {
      comm = AggregationCommodity(
        id: comm.id,
        valueChainId: comm.valueChainId,
        valueChainName: comm.valueChainName,
        measureName: comm.measureName,
        quantity: comm.quantity,
        unitPrice: comm.unitPrice > 0 ? comm.unitPrice : topPrice,
        description: comm.description ?? topDesc,
        imageUrl: comm.imageUrl ?? topImage,
        districtName: comm.districtName,
      );
    }

    return Aggregation(
      id: json['id'],
      groupId: json['group_id'],
      commodityId: json['commodity_id'],
      totalQuantity: _toDouble(json['total_quantity']),
      remainingQuantity: _toDouble(json['remaining_quantity']),
      status: json['status'] ?? 'open',
      createdBy: json['created_by'],
      publishedAt: json['published_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      unitPrice: topPrice > 0 ? topPrice : null,
      description: json['description'],
      expectedSupplyDate: json['expected_supply_date'],
      group: json['group'] != null ? AggregationGroup.fromJson(json['group']) : null,
      commodity: comm,
      creator: json['creator'] != null ? AggregationCreator.fromJson(json['creator']) : null,
      contributions: json['contributions'] != null
          ? (json['contributions'] as List).map((i) => AggregationContribution.fromJson(i)).toList()
          : [],
      sales: json['sales'] != null
          ? (json['sales'] as List).map((i) => AggregationSale.fromJson(i)).toList()
          : [],
      memberEarningsBreakdown: json['member_earnings_breakdown'] != null
          ? (json['member_earnings_breakdown'] as List).map((i) => MemberEarnings.fromJson(i)).toList()
          : [],
    );
  }
}

// ─── MemberEarnings ───────────────────────────────────────────────────────────

class MemberEarnings {
  final int? memberId;
  final String memberName;
  final double contributionQuantity;
  final double sharePercentage;
  final double earnedAmount;

  MemberEarnings({
    required this.memberId,
    required this.memberName,
    required this.contributionQuantity,
    required this.sharePercentage,
    required this.earnedAmount,
  });

  factory MemberEarnings.fromJson(Map<String, dynamic> json) {
    return MemberEarnings(
      memberId: json['member_id'],
      memberName: json['member_name'] ?? 'Unknown',
      contributionQuantity: _toDouble(json['contribution_quantity']),
      sharePercentage: _toDouble(json['share_percentage']),
      earnedAmount: _toDouble(json['earned_amount'] ?? json['earnings_amount']),
    );
  }
}

// ─── AggregationContribution ─────────────────────────────────────────────────

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
      quantity: _toDouble(json['quantity']),
      createdAt: json['created_at'],
      groupMember: json['group_member'] != null ? AggregationGroupMember.fromJson(json['group_member']) : null,
    );
  }
}

// ─── AggregationSale ──────────────────────────────────────────────────────────

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
      quantitySold: _toDouble(json['quantity_sold']),
      pricePerUnit: _toDouble(json['price_per_unit']),
      totalAmount: _toDouble(json['total_amount']),
      dateSold: json['date_sold'],
      createdAt: json['created_at'],
      buyer: json['buyer'] != null ? AggregationBuyer.fromJson(json['buyer']) : null,
    );
  }
}

// ─── AggregationGroup ────────────────────────────────────────────────────────

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

// ─── AggregationCommodity ────────────────────────────────────────────────────

class AggregationCommodity {
  final int? id;
  final int? valueChainId;
  final String? valueChainName;
  final String? measureName;
  final double quantity;
  final double unitPrice;
  final String? description;
  final String? imageUrl;
  final String? districtName;

  AggregationCommodity({
    this.id,
    this.valueChainId,
    this.valueChainName,
    this.measureName,
    this.quantity = 0.0,
    this.unitPrice = 0.0,
    this.description,
    this.imageUrl,
    this.districtName,
  });

  factory AggregationCommodity.fromJson(Map<String, dynamic> json) {
    return AggregationCommodity(
      id: json['id'],
      valueChainId: json['value_chain_id'],
      valueChainName: json['name'] ?? (json['value_chain'] != null ? json['value_chain']['name'] : null),
      measureName: json['measure'] is Map ? json['measure']['name'] : json['measure']?.toString(),
      quantity: _toDouble(json['quantity']),
      unitPrice: _toDouble(json['price'] ?? json['unit_price']),
      description: json['description'],
      imageUrl: json['image'] ?? json['image_url'],
      districtName: json['district'] is Map ? json['district']['name'] : json['district']?.toString(),
    );
  }
}

// ─── AggregationCreator ──────────────────────────────────────────────────────

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

// ─── AggregationGroupMember ──────────────────────────────────────────────────

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

// ─── AggregationBuyer ────────────────────────────────────────────────────────

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

// ─── AggregationMetrics ──────────────────────────────────────────────────────

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
      totalVolume: _toDouble(json['total_volume']),
      remainingVolume: _toDouble(json['remaining_volume']),
      totalSoldVolume: _toDouble(json['total_sold_volume']),
      totalRevenue: _toDouble(json['total_revenue']),
      uniqueFarmerCount: json['unique_farmer_count'] ?? 0,
    );
  }
}
