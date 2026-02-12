import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/constants/url.dart';

class BusinessProfileService {
  final String baseUrl = '${apiurl}v1';

  Map<String, String> get _headers {
    final token = GetStorage().read('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> get _authHeaders {
    final token = GetStorage().read('token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all business profiles (paginated)
  Future<Map<String, dynamic>> getProfiles({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/business-profiles?page=$page'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> profilesJson = data['business_profiles'] ?? [];
      final profiles = profilesJson.map((json) => BusinessProfile.fromJson(json)).toList();
      
      return {
        'profiles': profiles,
        'pagination': data['pagination'],
      };
    } else {
      throw Exception('Failed to load business profiles');
    }
  }

  /// Get current user's business profile
  Future<BusinessProfile> getMyProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/business-profiles/my-profile'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessProfile.fromJson(data['business_profile']);
    } else if (response.statusCode == 404) {
      throw Exception('No business profile found');
    } else {
      throw Exception('Failed to load profile');
    }
  }

  /// Get a specific business profile by ID
  Future<BusinessProfile> getProfile(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/business-profiles/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessProfile.fromJson(data['business_profile']);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  /// Create a new business profile
  Future<BusinessProfile> createProfile({
    required String businessName,
    required String description,
    required String location,
    required String phone,
    required String email,
    String? website,
    Map<String, String>? socialMedia,
    File? logo,
    String? businessLicenseNumber,
    int? sectorId,
    List<int>? categoryIds,
    int? districtId,
    String? addressLine,
    String? townCity,
    String? gpsLat,
    String? gpsLng,
    List<Map<String, dynamic>>? offerings,
    List<File>? galleryImages,
    List<File>? galleryVideos,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/business-profiles'),
    );

    request.headers.addAll(_authHeaders);

    // Required fields
    request.fields['business_name'] = businessName;
    request.fields['description'] = description;
    request.fields['location'] = location;
    request.fields['contact_info[phone]'] = phone;
    request.fields['contact_info[email]'] = email;

    // Optional fields
    if (website != null) request.fields['contact_info[website]'] = website;
    if (businessLicenseNumber != null) request.fields['business_license_number'] = businessLicenseNumber;
    if (sectorId != null) request.fields['sector_id'] = sectorId.toString();
    if (districtId != null) request.fields['district_id'] = districtId.toString();
    if (addressLine != null) request.fields['address_line'] = addressLine;
    if (townCity != null) request.fields['town_city'] = townCity;
    if (gpsLat != null) request.fields['gps_lat'] = gpsLat;
    if (gpsLng != null) request.fields['gps_lng'] = gpsLng;

    // Social media
    if (socialMedia != null) {
      if (socialMedia['facebook'] != null) request.fields['contact_info[social_media][facebook]'] = socialMedia['facebook']!;
      if (socialMedia['instagram'] != null) request.fields['contact_info[social_media][instagram]'] = socialMedia['instagram']!;
      if (socialMedia['twitter'] != null) request.fields['contact_info[social_media][twitter]'] = socialMedia['twitter']!;
      if (socialMedia['linkedin'] != null) request.fields['contact_info[social_media][linkedin]'] = socialMedia['linkedin']!;
    }

    // Categories
    if (categoryIds != null) {
      for (int i = 0; i < categoryIds.length; i++) {
        request.fields['category_ids[$i]'] = categoryIds[i].toString();
      }
    }

    // Offerings
    if (offerings != null) {
      for (int i = 0; i < offerings.length; i++) {
        final offering = offerings[i];
        request.fields['offerings[$i][type]'] = offering['type'] ?? 'product';
        request.fields['offerings[$i][name]'] = offering['name'] ?? '';
        if (offering['description'] != null) request.fields['offerings[$i][description]'] = offering['description'];
        if (offering['price'] != null) request.fields['offerings[$i][price]'] = offering['price'].toString();
        if (offering['currency'] != null) request.fields['offerings[$i][currency]'] = offering['currency'];
        if (offering['unit'] != null) request.fields['offerings[$i][unit]'] = offering['unit'];
        
        if (offering['image'] != null && offering['image'] is File) {
          request.files.add(await http.MultipartFile.fromPath('offerings[$i][image]', offering['image'].path));
        }
      }
    }

    // Logo
    if (logo != null) {
      request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
    }

    // Gallery images
    if (galleryImages != null) {
      for (var image in galleryImages) {
        request.files.add(await http.MultipartFile.fromPath('gallery_images[]', image.path));
      }
    }

    // Gallery videos
    if (galleryVideos != null) {
      for (var video in galleryVideos) {
        request.files.add(await http.MultipartFile.fromPath('gallery_videos[]', video.path));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessProfile.fromJson(data['business_profile']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create profile');
    }
  }

  /// Update business profile
  Future<BusinessProfile> updateProfile({
    required int id,
    String? businessName,
    String? description,
    String? location,
    String? phone,
    String? email,
    String? website,
    Map<String, String>? socialMedia,
    File? logo,
    String? businessLicenseNumber,
    int? sectorId,
    List<int>? categoryIds,
    int? districtId,
    String? addressLine,
    String? townCity,
    String? gpsLat,
    String? gpsLng,
    List<Map<String, dynamic>>? offerings,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/business-profiles/$id'),
    );

    request.headers.addAll(_authHeaders);
    request.fields['_method'] = 'PUT';

    // Fields
    if (businessName != null) request.fields['business_name'] = businessName;
    if (description != null) request.fields['description'] = description;
    if (location != null) request.fields['location'] = location;
    if (phone != null) request.fields['contact_info[phone]'] = phone;
    if (email != null) request.fields['contact_info[email]'] = email;
    if (website != null) request.fields['contact_info[website]'] = website;
    if (businessLicenseNumber != null) request.fields['business_license_number'] = businessLicenseNumber;
    if (sectorId != null) request.fields['sector_id'] = sectorId.toString();
    if (districtId != null) request.fields['district_id'] = districtId.toString();
    if (addressLine != null) request.fields['address_line'] = addressLine;
    if (townCity != null) request.fields['town_city'] = townCity;
    if (gpsLat != null) request.fields['gps_lat'] = gpsLat;
    if (gpsLng != null) request.fields['gps_lng'] = gpsLng;

    // Social media
    if (socialMedia != null) {
      request.fields['contact_info[social_media][facebook]'] = socialMedia['facebook'] ?? '';
      request.fields['contact_info[social_media][instagram]'] = socialMedia['instagram'] ?? '';
      request.fields['contact_info[social_media][twitter]'] = socialMedia['twitter'] ?? '';
      request.fields['contact_info[social_media][linkedin]'] = socialMedia['linkedin'] ?? '';
    }

    // Categories
    if (categoryIds != null) {
      for (int i = 0; i < categoryIds.length; i++) {
        request.fields['category_ids[$i]'] = categoryIds[i].toString();
      }
    }

    // Offerings
    if (offerings != null) {
      for (int i = 0; i < offerings.length; i++) {
        final offering = offerings[i];
        request.fields['offerings[$i][type]'] = offering['type'] ?? 'product';
        request.fields['offerings[$i][name]'] = offering['name'] ?? '';
        if (offering['description'] != null) request.fields['offerings[$i][description]'] = offering['description'];
        if (offering['price'] != null) request.fields['offerings[$i][price]'] = offering['price'].toString();
        if (offering['currency'] != null) request.fields['offerings[$i][currency]'] = offering['currency'];
        if (offering['unit'] != null) request.fields['offerings[$i][unit]'] = offering['unit'];
        if (offering['is_active'] != null) request.fields['offerings[$i][is_active]'] = offering['is_active'] ? '1' : '0';
        
        if (offering['image'] != null && offering['image'] is File) {
          request.files.add(await http.MultipartFile.fromPath('offerings[$i][image]', offering['image'].path));
        }
      }
    }

    // Logo
    if (logo != null) {
      request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessProfile.fromJson(data['business_profile']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update profile');
    }
  }

  /// Delete business profile
  Future<void> deleteProfile(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/business-profiles/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete profile');
    }
  }

  /// Add gallery image
  Future<BusinessGalleryImage> addGalleryImage({
    required int profileId,
    required File image,
    String? caption,
    int? sortOrder,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/business-profiles/$profileId/gallery/images'),
    );

    request.headers.addAll(_authHeaders);
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    
    if (caption != null) request.fields['caption'] = caption;
    if (sortOrder != null) request.fields['sort_order'] = sortOrder.toString();

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return BusinessGalleryImage.fromJson(data['gallery_image']);
    } else {
      throw Exception('Failed to add image');
    }
  }

  /// Add gallery video
  Future<BusinessGalleryVideo> addGalleryVideo({
    required int profileId,
    required File video,
    String? caption,
    int? sortOrder,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/business-profiles/$profileId/gallery/videos'),
    );

    request.headers.addAll(_authHeaders);
    request.files.add(await http.MultipartFile.fromPath('video', video.path));
    
    if (caption != null) request.fields['caption'] = caption;
    if (sortOrder != null) request.fields['sort_order'] = sortOrder.toString();

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return BusinessGalleryVideo.fromJson(data['gallery_video']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add video');
    }
  }

  /// Delete gallery image
  Future<void> deleteGalleryImage(int profileId, int imageId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/business-profiles/$profileId/gallery/images/$imageId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete image');
    }
  }

  /// Delete gallery video
  Future<void> deleteGalleryVideo(int profileId, int videoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/business-profiles/$profileId/gallery/videos/$videoId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete video');
    }
  }

  /// Get sectors
  Future<List<BusinessSector>> getSectors() async {
    final response = await http.get(
      Uri.parse('$baseUrl/business-sectors'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> sectorsJson = data['data'] ?? data;
      return sectorsJson.map((json) => BusinessSector.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sectors');
    }
  }

  /// Get categories
  Future<List<BusinessCategory>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/business-categories'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> categoriesJson = data['data'] ?? data;
      return categoriesJson.map((json) => BusinessCategory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  /// Get districts
  Future<List<BusinessDistrict>> getDistricts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/districts'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> districtsJson = data['data'] ?? data;
      return districtsJson.map((json) => BusinessDistrict.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load districts');
    }
  }
}
