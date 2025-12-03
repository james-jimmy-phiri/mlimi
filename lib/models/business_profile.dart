class BusinessProfile {
  final int? id;
  final int? clientId;
  final String businessName;
  final String? description;
  final String? location;
  final ContactInfo? contactInfo;
  final String? logo;
  final String? logoUrl;
  final int? sectorId;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String? verificationNotes;
  final BusinessSector? sector;
  final List<BusinessGalleryImage>? galleryImages;
  final List<BusinessGalleryVideo>? galleryVideos;

  BusinessProfile({
    this.id,
    this.clientId,
    required this.businessName,
    this.description,
    this.location,
    this.contactInfo,
    this.logo,
    this.logoUrl,
    this.sectorId,
    this.isVerified = false,
    this.verifiedAt,
    this.verificationNotes,
    this.sector,
    this.galleryImages,
    this.galleryVideos,
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
      sectorId: json['sector_id'],
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      verificationNotes: json['verification_notes'],
      sector: json['sector'] != null
          ? BusinessSector.fromJson(json['sector'])
          : null,
      galleryImages: json['gallery_images'] != null
          ? (json['gallery_images'] as List)
              .map((i) => BusinessGalleryImage.fromJson(i))
              .toList()
          : null,
      galleryVideos: json['gallery_videos'] != null
          ? (json['gallery_videos'] as List)
              .map((i) => BusinessGalleryVideo.fromJson(i))
              .toList()
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
      'sector_id': sectorId,
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

class BusinessGalleryImage {
  final int? id;
  final String imagePath;
  final String? imageUrl;
  final int sortOrder;

  BusinessGalleryImage({
    this.id,
    required this.imagePath,
    this.imageUrl,
    this.sortOrder = 0,
  });

  factory BusinessGalleryImage.fromJson(Map<String, dynamic> json) {
    return BusinessGalleryImage(
      id: json['id'],
      imagePath: json['image_path'] ?? '',
      imageUrl: json['image_url'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}

class BusinessGalleryVideo {
  final int? id;
  final String videoPath;
  final String? videoUrl;
  final String? thumbnailPath;
  final String? thumbnailUrl;
  final int sortOrder;

  BusinessGalleryVideo({
    this.id,
    required this.videoPath,
    this.videoUrl,
    this.thumbnailPath,
    this.thumbnailUrl,
    this.sortOrder = 0,
  });

  factory BusinessGalleryVideo.fromJson(Map<String, dynamic> json) {
    return BusinessGalleryVideo(
      id: json['id'],
      videoPath: json['video_path'] ?? '',
      videoUrl: json['video_url'],
      thumbnailPath: json['thumbnail_path'],
      thumbnailUrl: json['thumbnail_url'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}
