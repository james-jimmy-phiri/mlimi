import 'dart:convert';

class BusinessProfile {
  final int? id;
  final int? clientId;
  final String businessName;
  final String? description;
  final String? location;
  final ContactInfo? contactInfo;
  final String? logo;
  final String? logoUrl;
  final String? businessLicenseNumber;
  final int? sectorId;
  final int? districtId;
  final String? addressLine;
  final String? townCity;
  final String? gpsLat;
  final String? gpsLng;
  final int? yearFounded;
  final int? employeesCount;
  final dynamic operatingHours;
  final List<String>? paymentMethods;
  final List<String>? deliveryOptions;
  final List<String>? tags;
  final List<dynamic>? valueChains;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String? verificationNotes;
  final BusinessSector? sector;
  final BusinessDistrict? district;
  final BusinessClient? client;
  final List<BusinessCategory>? categories;
  final List<BusinessOffering>? offerings;
  final List<BusinessGalleryImage>? galleryImages;
  final List<BusinessGalleryVideo>? galleryVideos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BusinessProfile({
    this.id,
    this.clientId,
    required this.businessName,
    this.description,
    this.location,
    this.contactInfo,
    this.logo,
    this.logoUrl,
    this.businessLicenseNumber,
    this.sectorId,
    this.districtId,
    this.addressLine,
    this.townCity,
    this.gpsLat,
    this.gpsLng,
    this.yearFounded,
    this.employeesCount,
    this.operatingHours,
    this.paymentMethods,
    this.deliveryOptions,
    this.tags,
    this.valueChains,
    this.isVerified = false,
    this.verifiedAt,
    this.verificationNotes,
    this.sector,
    this.district,
    this.client,
    this.categories,
    this.offerings,
    this.galleryImages,
    this.galleryVideos,
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    // contact_info may arrive as a raw JSON string (some backends encode it)
    ContactInfo? contactInfo;
    final rawContact = json['contact_info'];
    if (rawContact != null) {
      if (rawContact is String) {
        try {
          final decoded = jsonDecode(rawContact);
          if (decoded is Map<String, dynamic>) {
            contactInfo = ContactInfo.fromJson(decoded);
          }
        } catch (_) {}
      } else if (rawContact is Map<String, dynamic>) {
        contactInfo = ContactInfo.fromJson(rawContact);
      }
    }

    return BusinessProfile(
      id: json['id'],
      clientId: json['client_id'],
      businessName: json['business_name'] ?? '',
      description: json['description'],
      location: json['location'],
      contactInfo: contactInfo,
      logo: json['logo'],
      logoUrl: json['logo_url'],
      businessLicenseNumber: json['business_license_number'],
      sectorId: json['sector_id'],
      districtId: json['district_id'],
      addressLine: json['address_line'],
      townCity: json['town_city'],
      gpsLat: json['gps_lat']?.toString(),
      gpsLng: json['gps_lng']?.toString(),
      yearFounded: json['year_founded'],
      employeesCount: json['employees_count'],
      operatingHours: json['operating_hours'],
      paymentMethods: json['payment_methods'] != null
          ? List<String>.from(json['payment_methods'])
          : null,
      deliveryOptions: json['delivery_options'] != null
          ? List<String>.from(json['delivery_options'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      valueChains: json['value_chains'] is List ? List<dynamic>.from(json['value_chains']) : null,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'])
          : null,
      verificationNotes: json['verification_notes'],
      sector: json['sector'] != null
          ? BusinessSector.fromJson(json['sector'] as Map<String, dynamic>)
          : null,
      district: json['district'] != null
          ? BusinessDistrict.fromJson(json['district'] as Map<String, dynamic>)
          : (json['district_id'] != null
              ? BusinessDistrict(id: json['district_id'], name: '')
              : null),
      client: json['client'] != null
          ? BusinessClient.fromJson(json['client'] as Map<String, dynamic>)
          : null,
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((c) => BusinessCategory.fromJson(c as Map<String, dynamic>))
              .toList()
          : null,
      offerings: json['offerings'] != null
          ? (json['offerings'] as List)
              .map((o) => BusinessOffering.fromJson(o as Map<String, dynamic>))
              .toList()
          : null,
      galleryImages: json['gallery_images'] != null
          ? (json['gallery_images'] as List)
              .map((i) => BusinessGalleryImage.fromJson(i as Map<String, dynamic>))
              .toList()
          : null,
      galleryVideos: json['gallery_videos'] != null
          ? (json['gallery_videos'] as List)
              .map((v) => BusinessGalleryVideo.fromJson(v as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'business_name': businessName,
      'description': description,
      'location': location,
      'contact_info': contactInfo?.toJson(),
      'logo': logo,
      'business_license_number': businessLicenseNumber,
      'sector_id': sectorId,
      'district_id': districtId,
      'address_line': addressLine,
      'town_city': townCity,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
      'year_founded': yearFounded,
      'employees_count': employeesCount,
      'operating_hours': operatingHours,
      'payment_methods': paymentMethods,
      'delivery_options': deliveryOptions,
      'tags': tags,
      'is_verified': isVerified,
    };
  }
}

// ---------------------------------------------------------------------------

class ContactInfo {
  final String? email;
  final String? phone;
  final String? website;
  final SocialMedia? socialMedia;

  ContactInfo({this.email, this.phone, this.website, this.socialMedia});

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      socialMedia: json['social_media'] != null
          ? SocialMedia.fromJson(json['social_media'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'phone': phone,
        'website': website,
        'social_media': socialMedia?.toJson(),
      };
}

// ---------------------------------------------------------------------------

class SocialMedia {
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? linkedin;

  SocialMedia({this.facebook, this.instagram, this.twitter, this.linkedin});

  factory SocialMedia.fromJson(Map<String, dynamic> json) => SocialMedia(
        facebook: json['facebook'],
        instagram: json['instagram'],
        twitter: json['twitter'],
        linkedin: json['linkedin'],
      );

  Map<String, dynamic> toJson() => {
        'facebook': facebook,
        'instagram': instagram,
        'twitter': twitter,
        'linkedin': linkedin,
      };
}

// ---------------------------------------------------------------------------

class BusinessSector {
  final int? id;
  final String name;
  final String? slug;

  BusinessSector({this.id, required this.name, this.slug});

  factory BusinessSector.fromJson(Map<String, dynamic> json) => BusinessSector(
        id: json['id'],
        name: json['name'] ?? '',
        slug: json['slug'],
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  @override
  bool operator ==(Object other) => other is BusinessSector && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------

class BusinessCategory {
  final int? id;
  final String name;
  final String? slug;
  final String? description;

  BusinessCategory({this.id, required this.name, this.slug, this.description});

  factory BusinessCategory.fromJson(Map<String, dynamic> json) =>
      BusinessCategory(
        id: json['id'],
        name: json['name'] ?? '',
        slug: json['slug'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'slug': slug, 'description': description};

  @override
  bool operator ==(Object other) => other is BusinessCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------

class BusinessDistrict {
  final int? id;
  final String name;

  BusinessDistrict({this.id, required this.name});

  factory BusinessDistrict.fromJson(Map<String, dynamic> json) =>
      BusinessDistrict(id: json['id'], name: json['name'] ?? '');

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) => other is BusinessDistrict && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------

class BusinessClient {
  final int? id;
  final String name;
  final String? phone;
  final String? email;

  BusinessClient({this.id, required this.name, this.phone, this.email});

  factory BusinessClient.fromJson(Map<String, dynamic> json) => BusinessClient(
        id: json['id'],
        name: json['name'] ?? '',
        phone: json['phone'],
        email: json['email'],
      );
}

// ---------------------------------------------------------------------------

class BusinessOffering {
  final int? id;
  final String type; // 'product' | 'service'
  final String name;
  final String? description;
  final double? price;
  final String? currency;
  final String? unit;
  final String? image;
  final String? imageUrl;
  final bool isActive;

  BusinessOffering({
    this.id,
    this.type = 'product',
    required this.name,
    this.description,
    this.price,
    this.currency = 'MWK',
    this.unit,
    this.image,
    this.imageUrl,
    this.isActive = true,
  });

  factory BusinessOffering.fromJson(Map<String, dynamic> json) =>
      BusinessOffering(
        id: json['id'],
        type: json['type'] ?? 'product',
        name: json['name'] ?? '',
        description: json['description'],
        price: json['price'] != null
            ? double.tryParse(json['price'].toString())
            : null,
        currency: json['currency'] ?? 'MWK',
        unit: json['unit'],
        image: json['image'],
        imageUrl: json['image_url'],
        isActive: json['is_active'] == true || json['is_active'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'description': description,
        'price': price,
        'currency': currency,
        'unit': unit,
        'is_active': isActive,
      };
}

// ---------------------------------------------------------------------------

class BusinessGalleryImage {
  final int? id;
  final String imagePath;
  final String? imageUrl;
  final String? caption;
  final int sortOrder;

  BusinessGalleryImage({
    this.id,
    required this.imagePath,
    this.imageUrl,
    this.caption,
    this.sortOrder = 0,
  });

  factory BusinessGalleryImage.fromJson(Map<String, dynamic> json) =>
      BusinessGalleryImage(
        id: json['id'],
        imagePath: json['image_path'] ?? '',
        imageUrl: json['image_url'],
        caption: json['caption'],
        sortOrder: json['sort_order'] ?? 0,
      );
}

// ---------------------------------------------------------------------------

class BusinessGalleryVideo {
  final int? id;
  final String videoPath;
  final String? videoUrl;
  final String? caption;
  final String? thumbnailPath;
  final String? thumbnailUrl;
  final int? fileSize;
  final String? fileSizeHuman;
  final int? duration;
  final String? durationHuman;
  final int sortOrder;

  BusinessGalleryVideo({
    this.id,
    required this.videoPath,
    this.videoUrl,
    this.caption,
    this.thumbnailPath,
    this.thumbnailUrl,
    this.fileSize,
    this.fileSizeHuman,
    this.duration,
    this.durationHuman,
    this.sortOrder = 0,
  });

  factory BusinessGalleryVideo.fromJson(Map<String, dynamic> json) =>
      BusinessGalleryVideo(
        id: json['id'],
        videoPath: json['video_path'] ?? '',
        videoUrl: json['video_url'],
        caption: json['caption'],
        thumbnailPath: json['thumbnail_path'],
        thumbnailUrl: json['thumbnail_url'],
        fileSize: json['file_size'],
        fileSizeHuman: json['file_size_human'],
        duration: json['duration'],
        durationHuman: json['duration_human'],
        sortOrder: json['sort_order'] ?? 0,
      );
}
