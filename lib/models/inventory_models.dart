class InventorySupplier {
  final int? id;
  final int? businessProfileId;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final bool isActive;
  final int? productsCount;

  InventorySupplier({
    this.id,
    this.businessProfileId,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.isActive = true,
    this.productsCount,
  });

  factory InventorySupplier.fromJson(Map<String, dynamic> json) {
    return InventorySupplier(
      id: json['id'],
      businessProfileId: json['business_profile_id'],
      name: json['name'] ?? '',
      contactPerson: json['contact_person'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      notes: json['notes'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      productsCount: json['products_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
    };
  }
}

class InventoryProduct {
  final int? id;
  final int? businessProfileId;
  final int? supplierId;
  final String name;
  final String? sku;
  final String? barcode;
  final String? category;
  final String unit;
  final double currentStock;
  final double? lowStockThreshold;
  final double? buyingPrice;
  final double? sellingPrice;
  final bool isActive;
  final String? notes;
  final String? imageUrl;
  final String? stockStatus;
  final double? stockValue;
  final InventorySupplier? supplier;

  InventoryProduct({
    this.id,
    this.businessProfileId,
    this.supplierId,
    required this.name,
    this.sku,
    this.barcode,
    this.category,
    required this.unit,
    this.currentStock = 0.0,
    this.lowStockThreshold,
    this.buyingPrice,
    this.sellingPrice,
    this.isActive = true,
    this.notes,
    this.imageUrl,
    this.stockStatus,
    this.stockValue,
    this.supplier,
  });

  factory InventoryProduct.fromJson(Map<String, dynamic> json) {
    return InventoryProduct(
      id: json['id'],
      businessProfileId: json['business_profile_id'],
      supplierId: json['supplier_id'],
      name: json['name'] ?? '',
      sku: json['sku'],
      barcode: json['barcode'],
      category: json['category'],
      unit: json['unit'] ?? 'units',
      currentStock: (json['current_stock'] ?? 0).toDouble(),
      lowStockThreshold: json['low_stock_threshold'] != null ? json['low_stock_threshold'].toDouble() : null,
      buyingPrice: json['buying_price'] != null ? double.tryParse(json['buying_price'].toString()) : null,
      sellingPrice: json['selling_price'] != null ? double.tryParse(json['selling_price'].toString()) : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      notes: json['notes'],
      imageUrl: json['image_url'],
      stockStatus: json['stock_status'],
      stockValue: json['stock_value'] != null ? double.tryParse(json['stock_value'].toString()) : null,
      supplier: json['supplier'] != null ? InventorySupplier.fromJson(json['supplier']) : null,
    );
  }
}

class InventoryStockMove {
  final int? id;
  final String type;
  final double quantity;
  final double? unitPrice;
  final String? reference;
  final String? notes;
  final String? movedAt;
  final InventoryProduct? product;

  InventoryStockMove({
    this.id,
    required this.type,
    required this.quantity,
    this.unitPrice,
    this.reference,
    this.notes,
    this.movedAt,
    this.product,
  });

  factory InventoryStockMove.fromJson(Map<String, dynamic> json) {
    return InventoryStockMove(
      id: json['id'],
      type: json['type'] ?? 'adjusted',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitPrice: json['unit_price'] != null ? double.tryParse(json['unit_price'].toString()) : null,
      reference: json['reference'],
      notes: json['notes'],
      movedAt: json['moved_at'],
      product: json['product'] != null ? InventoryProduct.fromJson(json['product']) : null,
    );
  }
}

class InventoryDashboardStats {
  final int totalProducts;
  final int activeProducts;
  final double totalStockValue;
  final int lowStockItems;
  final int outOfStock;
  final double todaySalesValue;

  InventoryDashboardStats({
    this.totalProducts = 0,
    this.activeProducts = 0,
    this.totalStockValue = 0.0,
    this.lowStockItems = 0,
    this.outOfStock = 0,
    this.todaySalesValue = 0.0,
  });

  factory InventoryDashboardStats.fromJson(Map<String, dynamic> json) {
    return InventoryDashboardStats(
      totalProducts: json['total_products'] ?? 0,
      activeProducts: json['active_products'] ?? 0,
      totalStockValue: (json['total_stock_value'] ?? 0).toDouble(),
      lowStockItems: json['low_stock_items'] ?? 0,
      outOfStock: json['out_of_stock'] ?? 0,
      todaySalesValue: (json['today_sales_value'] ?? 0).toDouble(),
    );
  }
}
