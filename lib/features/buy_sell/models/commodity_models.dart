class Commodity {
  Commodity({
    required this.id,
    required this.valueChainId,
    required this.name,
    required this.image,
    required this.price,
    required this.measure,
    required this.quantity,
    required this.quantityRemaining,
    required this.availabilityStatus,
    required this.location,
    required this.description,
    required this.type,
    required this.ownPost,
    required this.lowStockAlert,
    required this.lowStockThreshold,
    this.clientId,
    this.commodityTypeId,
    this.districtId,
    this.measureId,
    this.isAggregation = false,
    this.aggregationId,
    this.expectedSupplyDate,
    this.views,
    this.clientName,
    this.clientPhone,
    this.clientIsGroup = false,
    this.customersCount,
    this.suppliersCount,
    this.totalMemberQuantity,
    this.active = true,
    this.date,
    this.businessProfile,
    this.totalSold,
    this.poked = false,
  });

  final int id;
  final int valueChainId;
  final String name;
  final String? image;
  final double? price;
  final String? measure;
  final double? quantity;
  final double? quantityRemaining;
  final String? availabilityStatus;
  final String? location;
  final String? description;
  final String? type;
  final bool ownPost;
  final bool lowStockAlert;
  final double? lowStockThreshold;
  final int? clientId;
  final int? commodityTypeId;
  final int? districtId;
  final int? measureId;
  final bool isAggregation;
  final int? aggregationId;
  final String? expectedSupplyDate;
  final int? views;
  final String? clientName;
  final String? clientPhone;
  final bool clientIsGroup;
  final int? customersCount;
  final int? suppliersCount;
  final double? totalMemberQuantity;
  final bool active;
  final String? date;
  final Map<String, dynamic>? businessProfile;
  final double? totalSold;
  final bool poked;

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: (json['id'] ?? 0) as int,
      valueChainId: (json['value_chain_id'] ?? 0) as int,
      name: (json['name'] ?? '').toString(),
      image: json['image']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      measure: json['measure']?.toString(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      quantityRemaining: (json['quantity_remaining'] as num?)?.toDouble(),
      totalSold: (json['total_sold'] as num?)?.toDouble(),
      availabilityStatus: json['availability_status']?.toString(),
      location: json['location']?.toString(),
      description: json['description']?.toString(),
      type: json['type']?.toString(),
      ownPost: json['own_post'] == true,
      poked: json['poked'] == true,
      lowStockAlert: json['low_stock_alert'] == true,
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toDouble(),
      clientId: json['client_id'] as int?,
      commodityTypeId: json['commodity_type_id'] as int?,
      districtId: json['district_id'] as int?,
      measureId: json['measure_id'] as int?,
      isAggregation: json['is_aggregation'] == true,
      aggregationId: json['aggregation_id'] as int?,
      expectedSupplyDate: json['expected_supply_date']?.toString(),
      views: json['views'] as int?,
      clientName: json['client']?['name']?.toString(),
      clientPhone: json['client']?['phone']?.toString(),
      clientIsGroup: json['client']?['group'] == true,
      customersCount: json['customers_count'] as int?,
      suppliersCount: json['suppliers_count'] as int?,
      totalMemberQuantity: (json['total_member_quantity'] as num?)?.toDouble(),
      active: json['active'] != false, // default to true if missing
      date: json['date']?.toString() ?? json['created']?.toString(),
      businessProfile: json['client']?['business_profile'] as Map<String, dynamic>?,
    );
  }
}

class CommodityDetails {
  CommodityDetails({
    required this.commodity,
    required this.sales,
    required this.salesSummary,
    required this.buyers,
    required this.groupMembers,
    required this.farmingSeasons,
  });

  final Commodity commodity;
  final List<CommoditySale> sales;
  final Map<String, dynamic> salesSummary;
  final List<Buyer> buyers;
  final List<Map<String, dynamic>> groupMembers;
  final List<Map<String, dynamic>> farmingSeasons;

  factory CommodityDetails.fromJson(Map<String, dynamic> json) {
    final commodityJson = (json['commodity'] ??
        json['selectedCommodity']?['data'] ??
        json['selectedCommodity']) as Map<String, dynamic>;
    final salesData =
        (json['sales']?['data'] ?? json['sales'] ?? []) as List<dynamic>;
    final buyersData = (json['buyers'] ?? []) as List<dynamic>;
    final groupMembersData =
        (json['group_members'] ?? json['groupMembers'] ?? []) as List<dynamic>;
    final seasonsData = (json['farming_seasons'] ??
        json['farmingSeasons'] ??
        []) as List<dynamic>;

    return CommodityDetails(
      commodity: Commodity.fromJson(commodityJson),
      sales: salesData
          .map((e) => CommoditySale.fromJson(e as Map<String, dynamic>))
          .toList(),
      salesSummary: Map<String, dynamic>.from(
          json['sales_summary'] ?? json['salesSummary'] ?? const {}),
      buyers: buyersData
          .map((e) => Buyer.fromJson(e as Map<String, dynamic>))
          .toList(),
      groupMembers: groupMembersData
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      farmingSeasons:
          seasonsData.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );
  }
}

class Buyer {
  Buyer({
    required this.id,
    required this.name,
    this.phone,
    this.district,
    this.notes,
  });

  final int id;
  final String name;
  final String? phone;
  final String? district;
  final String? notes;

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '').toString(),
      phone: json['phone']?.toString(),
      district: json['district']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}

class CommoditySale {
  CommoditySale({
    required this.id,
    required this.commodityId,
    required this.valueChainId,
    required this.quantitySold,
    required this.unitPrice,
    required this.totalAmount,
    required this.amountPaid,
    required this.balanceDue,
    required this.paymentStatus,
    this.saleDate,
    this.paymentDueDate,
    this.buyerName,
    this.valueChainName,
    this.commodityName,
  });

  final int id;
  final int commodityId;
  final int valueChainId;
  final double quantitySold;
  final double unitPrice;
  final double totalAmount;
  final double amountPaid;
  final double balanceDue;
  final String paymentStatus;
  final String? saleDate;
  final String? paymentDueDate;
  final String? buyerName;
  final String? valueChainName;
  final String? commodityName;

  factory CommoditySale.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity_sold'] as num?)?.toDouble() ?? 0;
    final price = (json['unit_price'] as num?)?.toDouble() ?? 0;
    final total = (json['total_amount'] as num?)?.toDouble() ?? (qty * price);
    return CommoditySale(
      id: (json['id'] ?? 0) as int,
      commodityId: (json['commodity_id'] ?? 0) as int,
      valueChainId: (json['value_chain_id'] ?? 0) as int,
      quantitySold: qty,
      unitPrice: price,
      totalAmount: total,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0,
      paymentStatus: (json['payment_status'] ?? 'pending').toString(),
      saleDate: json['sale_date']?.toString(),
      paymentDueDate: json['payment_due_date']?.toString(),
      buyerName: (json['buyer_profile']?['name'] ??
              json['buyer']?['name'] ??
              json['buyer_name'])
          ?.toString(),
      valueChainName: json['value_chain']?['name']?.toString(),
      commodityName: json['commodity']?['id']?.toString(),
    );
  }
}

class ValueChainOption {
  ValueChainOption({required this.id, required this.name});
  final int id;
  final String name;

  factory ValueChainOption.fromJson(Map<String, dynamic> json) {
    return ValueChainOption(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '').toString(),
    );
  }
}

class StatsSummary {
  StatsSummary({
    required this.totalCommodities,
    required this.totalSales,
    required this.totalSupplies,
    required this.totalRevenue,
    required this.bestSellingCrop,
    required this.bestSellingQty,
    required this.lowStockCount,
  });

  final int totalCommodities;
  final int totalSales;
  final int totalSupplies;
  final double totalRevenue;
  final String? bestSellingCrop;
  final double bestSellingQty;
  final int lowStockCount;

  factory StatsSummary.fromJson(Map<String, dynamic> json) {
    return StatsSummary(
      totalCommodities: (json['totalCommodities'] ?? 0) as int,
      totalSales: (json['totalSales'] ?? 0) as int,
      totalSupplies: (json['totalSupplies'] ?? 0) as int,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      bestSellingCrop: json['bestSellingCrop']?.toString(),
      bestSellingQty: (json['bestSellingQty'] as num?)?.toDouble() ?? 0,
      lowStockCount: (json['lowStockCount'] ?? 0) as int,
    );
  }
}
