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
    return BusinessProfile(
      id: json['id'],
      clientId: json['client_id'],
      businessName: json['business_name'] ?? '',
      description: json['description'],
      location: json['location'],
      contactInfo: json['contact_info'] != null
          ? ContactInfo.fromJson(json['contact_info'])
          : null,
      logo: json['logo'],
      logoUrl: json['logo_url'],
      businessLicenseNumber: json['business_license_number'],
      sectorId: json['sector_id'],
      districtId: json['district_id'],
      addressLine: json['address_line'],
      townCity: json['town_city'],
      gpsLat: json['gps_lat']?.toString(),
      gpsLng: json['gps_lng']?.toString(),
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      verificationNotes: json['verification_notes'],
      sector: json['sector'] != null
          ? BusinessSector.fromJson(json['sector'])
          : null,
      district: json['district'] != null
          ? BusinessDistrict.fromJson(json['district'])
          : null,
      client: json['client'] != null
          ? BusinessClient.fromJson(json['client'])
          : null,
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((c) => BusinessCategory.fromJson(c))
              .toList()
          : null,
      offerings: json['offerings'] != null
          ? (json['offerings'] as List)
              .map((o) => BusinessOffering.fromJson(o))
              .toList()
          : null,
      galleryImages: json['gallery_images'] != null
          ? (json['gallery_images'] as List)
              .map((i) => BusinessGalleryImage.fromJson(i))
              .toList()
          : null,
      galleryVideos: json['gallery_videos'] != null
          ? (json['gallery_videos'] as List)
              .map((v) => BusinessGalleryVideo.fromJson(v))
              .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
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
      'is_verified': isVerified,
    };
  }
}

class ContactInfo {
  final String? email;
  final String? phone;
  final String? website;
  final SocialMedia? socialMedia;

  ContactInfo({
    this.email,
    this.phone,
    this.website,
    this.socialMedia,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      socialMedia: json['social_media'] != null
          ? SocialMedia.fromJson(json['social_media'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'website': website,
      'social_media': socialMedia?.toJson(),
    };
  }
}

class SocialMedia {
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? linkedin;

  SocialMedia({
    this.facebook,
    this.instagram,
    this.twitter,
    this.linkedin,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      facebook: json['facebook'],
      instagram: json['instagram'],
      twitter: json['twitter'],
      linkedin: json['linkedin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'instagram': instagram,
      'twitter': twitter,
      'linkedin': linkedin,
    };
  }
}

class BusinessSector {
  final int? id;
  final String name;
  final String? slug;

  BusinessSector({
    this.id,
    required this.name,
    this.slug,
  });

  factory BusinessSector.fromJson(Map<String, dynamic> json) {
    return BusinessSector(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}

class BusinessCategory {
  final int? id;
  final String name;
  final String? slug;
  final String? description;

  BusinessCategory({
    this.id,
    required this.name,
    this.slug,
    this.description,
  });

  factory BusinessCategory.fromJson(Map<String, dynamic> json) {
    return BusinessCategory(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
    };
  }
}

class BusinessDistrict {
  final int? id;
  final String name;

  BusinessDistrict({
    this.id,
    required this.name,
  });

  factory BusinessDistrict.fromJson(Map<String, dynamic> json) {
    return BusinessDistrict(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class BusinessClient {
  final int? id;
  final String name;
  final String? phone;
  final String? email;

  BusinessClient({
    this.id,
    required this.name,
    this.phone,
    this.email,
  });

  factory BusinessClient.fromJson(Map<String, dynamic> json) {
    return BusinessClient(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class BusinessOffering {
  final int? id;
  final String type; // 'product' or 'service'
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

  factory BusinessOffering.fromJson(Map<String, dynamic> json) {
    return BusinessOffering(
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
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}

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

  factory BusinessGalleryImage.fromJson(Map<String, dynamic> json) {
    return BusinessGalleryImage(
      id: json['id'],
      imagePath: json['image_path'] ?? '',
      imageUrl: json['image_url'],
      caption: json['caption'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}

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

  factory BusinessGalleryVideo.fromJson(Map<String, dynamic> json) {
    return BusinessGalleryVideo(
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
}
