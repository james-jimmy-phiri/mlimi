class BusinessProfile {
  final int id;
  final String businessName;
  final String? description;
  final String? location;
  final String? logoUrl;
  final bool isVerified;

  BusinessProfile({
    required this.id,
    required this.businessName,
    this.description,
    this.location,
    this.logoUrl,
    this.isVerified = false,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['id'] ?? 0,
      businessName: json['business_name'] ?? '',
      description: json['description'],
      location: json['location'],
      logoUrl: json['logo_url'],
      isVerified: json['is_verified'] == true,
    );
  }
}

class Seller {
  final String type;
  final String name;
  final String? phone;
  final String? photoUrl;
  final String? location;
  final String? description;
  final bool isVerified;
  final int? businessProfileId;
  final int clientId;
  final List<String>? paymentMethods;
  final List<Map<String, dynamic>> contactChannels;

  Seller({
    required this.type,
    required this.name,
    this.phone,
    this.photoUrl,
    this.location,
    this.description,
    this.isVerified = false,
    this.businessProfileId,
    required this.clientId,
    this.paymentMethods,
    this.contactChannels = const [],
  });

  factory Seller.fromJson(Map<String, dynamic>? json, {Map<String, dynamic>? client}) {
    if (json != null && json['name'] != null) {
      return Seller(
        type: json['type'] ?? 'client',
        name: json['name'] ?? '',
        phone: json['phone']?.toString(),
        photoUrl: json['photo_url'],
        location: json['location'],
        description: json['description'],
        isVerified: json['is_verified'] == true,
        businessProfileId: json['business_profile_id'],
        clientId: json['client_id'] ?? 0,
        paymentMethods: (json['payment_methods'] as List?)?.map((e) => e.toString()).toList(),
        contactChannels: (json['contact_channels'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
      );
    }

    final profile = client?['business_profile'];
    if (profile != null) {
      return Seller(
        type: 'business',
        name: profile['business_name'] ?? client?['name'] ?? '',
        phone: profile['contact_info']?['phone']?.toString() ?? client?['phone']?.toString(),
        photoUrl: profile['logo_url'],
        location: profile['location'],
        description: profile['description'],
        isVerified: profile['is_verified'] == true,
        businessProfileId: profile['id'],
        clientId: client?['id'] ?? 0,
      );
    }

    return Seller(
      type: 'client',
      name: client?['name'] ?? 'Seller',
      phone: client?['phone']?.toString(),
      clientId: client?['id'] ?? 0,
    );
  }

  bool get isBusiness => type == 'business';
}

class Product {
  final int id;
  final String name;
  final String imageUrl;
  final String unitPrice;
  final String measure;
  final String quantity;
  final double? quantityRemaining;
  final String location;
  final String description;
  final String type;
  final bool active;
  final int views;
  final String created;
  final Client client;
  final Seller seller;
  final bool isAggregation;
  final String? totalSold;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.measure,
    required this.quantity,
    this.quantityRemaining,
    required this.location,
    required this.description,
    required this.type,
    required this.active,
    required this.views,
    required this.created,
    required this.client,
    Seller? seller,
    this.isAggregation = false,
    this.totalSold,
  }) : seller = seller ??
            Seller(
              type: 'client',
              name: client.name,
              phone: client.phone,
              clientId: 0,
            );

  double get priceAsDouble => double.tryParse(unitPrice.replaceAll(',', '')) ?? 0;

  factory Product.fromJson(Map<String, dynamic> item) {
    final clientData = item['client'] as Map<String, dynamic>? ?? {};
    final seller = Seller.fromJson(
      item['seller'] as Map<String, dynamic>?,
      client: clientData,
    );

    final client = Client(
      name: clientData['name'] ?? seller.name,
      phone: clientData['phone']?.toString() ?? seller.phone ?? '',
      avatarUrl: seller.photoUrl,
      businessProfile: clientData['business_profile'] != null
          ? BusinessProfile.fromJson(clientData['business_profile'])
          : null,
    );

    return Product(
      id: item['id'],
      name: item['name'] ?? '',
      imageUrl: item['image'] ?? '',
      unitPrice: item['price']?.toString() ?? '0',
      measure: item['measure'] ?? '',
      quantity: item['quantity']?.toString() ?? '0',
      quantityRemaining: item['quantity_remaining'] != null
          ? double.tryParse(item['quantity_remaining'].toString())
          : null,
      location: item['location'] ?? seller.location ?? '',
      description: item['description'] ?? '',
      type: item['type'] ?? '',
      active: item['active'] == true,
      views: item['views'] ?? 0,
      created: item['created'] ?? '',
      client: client,
      seller: seller,
      isAggregation: item['is_aggregation'] == 1 || item['type'] == 'aggregation',
      totalSold: item['total_sold']?.toString(),
    );
  }
}

class Client {
  final String name;
  final String phone;
  final String? avatarUrl;
  final BusinessProfile? businessProfile;

  Client({
    required this.name,
    required this.phone,
    this.avatarUrl,
    this.businessProfile,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.priceAsDouble * quantity;
}
