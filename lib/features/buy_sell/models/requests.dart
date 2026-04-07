class SaleUpsertRequest {
  SaleUpsertRequest({
    required this.commodityId,
    required this.valueChainId,
    required this.quantitySold,
    required this.unitPrice,
    this.saleDate,
    this.buyerId,
    this.buyerName,
    this.buyerPhone,
    this.paymentStatus = 'pending',
    this.amountPaid = 0,
    this.paymentDueDate,
    this.paymentNotes,
    this.farmingSeasonId,
    this.groupMemberId,
  });

  final int commodityId;
  final int valueChainId;
  final double quantitySold;
  final double unitPrice;
  final String? saleDate;
  final int? buyerId;
  final String? buyerName;
  final String? buyerPhone;
  final String paymentStatus;
  final double amountPaid;
  final String? paymentDueDate;
  final String? paymentNotes;
  final int? farmingSeasonId;
  final int? groupMemberId;

  Map<String, dynamic> toJson() {
    return {
      'commodity_id': commodityId,
      'value_chain_id': valueChainId,
      'quantity_sold': quantitySold,
      'unit_price': unitPrice,
      if (saleDate != null && saleDate!.isNotEmpty) 'sale_date': saleDate,
      if (buyerId != null) 'buyer_id': buyerId,
      if (buyerName != null && buyerName!.isNotEmpty) 'buyer_name': buyerName,
      if (buyerPhone != null && buyerPhone!.isNotEmpty)
        'buyer_phone': buyerPhone,
      'payment_status': paymentStatus,
      'amount_paid': amountPaid,
      if (paymentDueDate != null && paymentDueDate!.isNotEmpty)
        'payment_due_date': paymentDueDate,
      if (paymentNotes != null && paymentNotes!.isNotEmpty)
        'payment_notes': paymentNotes,
      if (farmingSeasonId != null) 'farming_season_id': farmingSeasonId,
      if (groupMemberId != null) 'group_member_id': groupMemberId,
    };
  }
}

class BuyerCreateRequest {
  BuyerCreateRequest({
    required this.name,
    this.phone,
    this.district,
    this.notes,
  });

  final String name;
  final String? phone;
  final String? district;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (district != null && district!.isNotEmpty) 'district': district,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class CommodityUpdateRequest {
  CommodityUpdateRequest({
    required this.valueChainId,
    required this.measureId,
    required this.unitPrice,
    required this.quantity,
    required this.districtId,
    required this.description,
    this.expectedSupplyDate,
    this.lowStockThreshold,
  });

  final int valueChainId;
  final int measureId;
  final double unitPrice;
  final double quantity;
  final int districtId;
  final String description;
  final String? expectedSupplyDate;
  final double? lowStockThreshold;

  Map<String, dynamic> toJson() {
    return {
      'value_chain_id': valueChainId,
      'measure_id': measureId,
      'unit_price': unitPrice,
      'quantity': quantity,
      'district_id': districtId,
      'description': description,
      if (expectedSupplyDate != null && expectedSupplyDate!.isNotEmpty)
        'expected_supply_date': expectedSupplyDate,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
    };
  }
}
