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

  String _parseError(http.Response response, String defaultMessage) {
    try {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstErrorList = errors.values.first;
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              return '${data['message'] ?? defaultMessage}: ${firstErrorList.first}';
            }
          }
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data.containsKey('error')) {
          return data['error'].toString();
        }
      }
    } catch (_) {}
    return '$defaultMessage (Status: ${response.statusCode})';
  }

  // ---------------------------------------------------------------------------
  // PROFILES
  // ---------------------------------------------------------------------------

  /// Get all business profiles (paginated, filterable)
  Future<Map<String, dynamic>> getProfiles({
    int page = 1,
    String? search,
    int? districtId,
    int? sectorId,
    int? valueChainId,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (districtId != null) params['district_id'] = districtId.toString();
    if (sectorId != null) params['sector_id'] = sectorId.toString();
    if (valueChainId != null) params['value_chain_id'] = valueChainId.toString();

    final uri = Uri.parse('$baseUrl/business-profiles').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> profilesJson = data['business_profiles'] ?? data['data'] ?? [];
      final profiles = profilesJson
          .map((j) => BusinessProfile.fromJson(j as Map<String, dynamic>))
          .toList();
      return {
        'profiles': profiles,
        'pagination': data['pagination'] ?? data['meta'],
      };
    } else {
      throw Exception(_parseError(response, 'Failed to load business profiles'));
    }
  }

  /// Get current user's business profile
  Future<BusinessProfile> getMyProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/my-business-profile'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessProfile.fromJson(data['business_profile'] as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw Exception('No business profile found');
    } else {
      throw Exception(_parseError(response, 'Failed to load profile'));
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
      return BusinessProfile.fromJson(data['business_profile'] as Map<String, dynamic>);
    } else {
      throw Exception(_parseError(response, 'Failed to load profile'));
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
    String? customSector,
    List<int>? categoryIds,
    List<String>? customCategories,
    int? districtId,
    String? addressLine,
    String? townCity,
    String? gpsLat,
    String? gpsLng,
    int? yearFounded,
    int? employeesCount,
    String? operatingHours,
    List<String>? paymentMethods,
    List<String>? deliveryOptions,
    List<String>? tags,
    List<int>? valueChainIds,
    List<String>? customValueChains,
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
    if (website != null && website.isNotEmpty) request.fields['contact_info[website]'] = website;
    if (businessLicenseNumber != null && businessLicenseNumber.isNotEmpty) {
      request.fields['business_license_number'] = businessLicenseNumber;
    }
    if (sectorId != null) request.fields['sector_id'] = sectorId.toString();
    if (customSector != null && customSector.isNotEmpty) request.fields['sector_id'] = customSector;
    if (districtId != null) request.fields['district_id'] = districtId.toString();
    if (addressLine != null && addressLine.isNotEmpty) request.fields['address_line'] = addressLine;
    if (townCity != null && townCity.isNotEmpty) request.fields['town_city'] = townCity;
    if (gpsLat != null && gpsLat.isNotEmpty) request.fields['gps_lat'] = gpsLat;
    if (gpsLng != null && gpsLng.isNotEmpty) request.fields['gps_lng'] = gpsLng;
    if (yearFounded != null) request.fields['year_founded'] = yearFounded.toString();
    if (employeesCount != null) request.fields['employees_count'] = employeesCount.toString();
    if (operatingHours != null && operatingHours.isNotEmpty) {
      request.fields['operating_hours'] = operatingHours;
    }

    // Social media
    if (socialMedia != null) {
      if (socialMedia['facebook']?.isNotEmpty == true) {
        request.fields['contact_info[social_media][facebook]'] = socialMedia['facebook']!;
      }
      if (socialMedia['instagram']?.isNotEmpty == true) {
        request.fields['contact_info[social_media][instagram]'] = socialMedia['instagram']!;
      }
      if (socialMedia['twitter']?.isNotEmpty == true) {
        request.fields['contact_info[social_media][twitter]'] = socialMedia['twitter']!;
      }
      if (socialMedia['linkedin']?.isNotEmpty == true) {
        request.fields['contact_info[social_media][linkedin]'] = socialMedia['linkedin']!;
      }
    }

    // Arrays
    if (categoryIds != null) {
      for (int i = 0; i < categoryIds.length; i++) {
        request.fields['category_ids[$i]'] = categoryIds[i].toString();
      }
    }
    if (customCategories != null) {
      final offset = categoryIds?.length ?? 0;
      for (int i = 0; i < customCategories.length; i++) {
        request.fields['category_ids[${offset + i}]'] = customCategories[i];
      }
    }
    if (valueChainIds != null) {
      for (int i = 0; i < valueChainIds.length; i++) {
        request.fields['value_chains[$i]'] = valueChainIds[i].toString();
      }
    }
    if (customValueChains != null) {
      final offset = valueChainIds?.length ?? 0;
      for (int i = 0; i < customValueChains.length; i++) {
        request.fields['value_chains[${offset + i}]'] = customValueChains[i];
      }
    }
    if (paymentMethods != null) {
      for (int i = 0; i < paymentMethods.length; i++) {
        request.fields['payment_methods[$i]'] = paymentMethods[i];
      }
    }
    if (deliveryOptions != null) {
      for (int i = 0; i < deliveryOptions.length; i++) {
        request.fields['delivery_options[$i]'] = deliveryOptions[i];
      }
    }
    if (tags != null) {
      for (int i = 0; i < tags.length; i++) {
        request.fields['tags[$i]'] = tags[i];
      }
    }

    // Offerings
    if (offerings != null) {
      for (int i = 0; i < offerings.length; i++) {
        final offering = offerings[i];
        request.fields['offerings[$i][type]'] = offering['type'] ?? 'product';
        request.fields['offerings[$i][name]'] = offering['name'] ?? '';
        if (offering['description'] != null) {
          request.fields['offerings[$i][description]'] = offering['description'];
        }
        if (offering['price'] != null) {
          request.fields['offerings[$i][price]'] = offering['price'].toString();
        }
        if (offering['currency'] != null) {
          request.fields['offerings[$i][currency]'] = offering['currency'];
        }
        if (offering['unit'] != null) request.fields['offerings[$i][unit]'] = offering['unit'];

        if (offering['image'] != null && offering['image'] is File) {
          request.files.add(
            await http.MultipartFile.fromPath('offerings[$i][image]', offering['image'].path),
          );
        }
      }
    }

    // Files
    if (logo != null) {
      request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
    }
    if (galleryImages != null) {
      for (var image in galleryImages) {
        request.files.add(await http.MultipartFile.fromPath('gallery_images[]', image.path));
      }
    }
    if (galleryVideos != null) {
      for (var video in galleryVideos) {
        request.files.add(await http.MultipartFile.fromPath('gallery_videos[]', video.path));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessProfile.fromJson(data['business_profile'] as Map<String, dynamic>);
    } else {
      throw Exception(_parseError(response, 'Failed to create profile'));
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
    String? customSector,
    List<int>? categoryIds,
    List<String>? customCategories,
    int? districtId,
    String? addressLine,
    String? townCity,
    String? gpsLat,
    String? gpsLng,
    int? yearFounded,
    int? employeesCount,
    String? operatingHours,
    List<String>? paymentMethods,
    List<String>? deliveryOptions,
    List<String>? tags,
    List<int>? valueChainIds,
    List<String>? customValueChains,
    List<Map<String, dynamic>>? offerings,
    List<File>? galleryImages,
    List<File>? galleryVideos,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/business-profiles/$id'),
    );
    request.headers.addAll(_authHeaders);
    request.fields['_method'] = 'PUT';

    if (businessName != null) request.fields['business_name'] = businessName;
    if (description != null) request.fields['description'] = description;
    if (location != null) request.fields['location'] = location;
    if (phone != null) request.fields['contact_info[phone]'] = phone;
    if (email != null) request.fields['contact_info[email]'] = email;
    if (website != null) request.fields['contact_info[website]'] = website;
    if (businessLicenseNumber != null) request.fields['business_license_number'] = businessLicenseNumber;
    if (sectorId != null) request.fields['sector_id'] = sectorId.toString();
    if (customSector != null && customSector.isNotEmpty) request.fields['sector_id'] = customSector;
    if (districtId != null) request.fields['district_id'] = districtId.toString();
    if (addressLine != null) request.fields['address_line'] = addressLine;
    if (townCity != null) request.fields['town_city'] = townCity;
    if (gpsLat != null) request.fields['gps_lat'] = gpsLat;
    if (gpsLng != null) request.fields['gps_lng'] = gpsLng;
    if (yearFounded != null) request.fields['year_founded'] = yearFounded.toString();
    if (employeesCount != null) request.fields['employees_count'] = employeesCount.toString();
    if (operatingHours != null) request.fields['operating_hours'] = operatingHours;

    if (socialMedia != null) {
      request.fields['contact_info[social_media][facebook]'] = socialMedia['facebook'] ?? '';
      request.fields['contact_info[social_media][instagram]'] = socialMedia['instagram'] ?? '';
      request.fields['contact_info[social_media][twitter]'] = socialMedia['twitter'] ?? '';
      request.fields['contact_info[social_media][linkedin]'] = socialMedia['linkedin'] ?? '';
    }

    if (categoryIds != null) {
      for (int i = 0; i < categoryIds.length; i++) {
        request.fields['category_ids[$i]'] = categoryIds[i].toString();
      }
    }
    if (customCategories != null) {
      final offset = categoryIds?.length ?? 0;
      for (int i = 0; i < customCategories.length; i++) {
        request.fields['category_ids[${offset + i}]'] = customCategories[i];
      }
    }
    if (valueChainIds != null) {
      for (int i = 0; i < valueChainIds.length; i++) {
        request.fields['value_chains[$i]'] = valueChainIds[i].toString();
      }
    }
    if (customValueChains != null) {
      final offset = valueChainIds?.length ?? 0;
      for (int i = 0; i < customValueChains.length; i++) {
        request.fields['value_chains[${offset + i}]'] = customValueChains[i];
      }
    }
    if (paymentMethods != null) {
      for (int i = 0; i < paymentMethods.length; i++) {
        request.fields['payment_methods[$i]'] = paymentMethods[i];
      }
    }
    if (deliveryOptions != null) {
      for (int i = 0; i < deliveryOptions.length; i++) {
        request.fields['delivery_options[$i]'] = deliveryOptions[i];
      }
    }
    if (tags != null) {
      for (int i = 0; i < tags.length; i++) {
        request.fields['tags[$i]'] = tags[i];
      }
    }

    if (offerings != null) {
      for (int i = 0; i < offerings.length; i++) {
        final offering = offerings[i];
        request.fields['offerings[$i][type]'] = offering['type'] ?? 'product';
        request.fields['offerings[$i][name]'] = offering['name'] ?? '';
        if (offering['id'] != null) request.fields['offerings[$i][id]'] = offering['id'].toString();
        if (offering['description'] != null) {
          request.fields['offerings[$i][description]'] = offering['description'];
        }
        if (offering['price'] != null) {
          request.fields['offerings[$i][price]'] = offering['price'].toString();
        }
        if (offering['currency'] != null) {
          request.fields['offerings[$i][currency]'] = offering['currency'];
        }
        if (offering['unit'] != null) request.fields['offerings[$i][unit]'] = offering['unit'];
        if (offering['is_active'] != null) {
          request.fields['offerings[$i][is_active]'] = offering['is_active'] ? '1' : '0';
        }
        if (offering['image'] != null && offering['image'] is File) {
          request.files.add(
            await http.MultipartFile.fromPath('offerings[$i][image]', offering['image'].path),
          );
        }
      }
    }

    if (logo != null) {
      request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
    }

    if (galleryImages != null) {
      for (int i = 0; i < galleryImages.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('gallery_images[$i]', galleryImages[i].path),
        );
      }
    }

    if (galleryVideos != null) {
      for (int i = 0; i < galleryVideos.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('gallery_videos[$i]', galleryVideos[i].path),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessProfile.fromJson(data['business_profile'] as Map<String, dynamic>);
    } else {
      throw Exception(_parseError(response, 'Failed to update profile'));
    }
  }

  /// Delete business profile
  Future<void> deleteProfile(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/business-profiles/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_parseError(response, 'Failed to delete profile'));
    }
  }

  // ---------------------------------------------------------------------------
  // GALLERY
  // ---------------------------------------------------------------------------

  Future<BusinessGalleryImage> addGalleryImage({
    required int profileId,
    required File image,
    String? caption,
    int? sortOrder,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/business-profiles/$profileId/gallery-images'),
    );
    request.headers.addAll(_authHeaders);
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    if (caption != null) request.fields['caption'] = caption;
    if (sortOrder != null) request.fields['sort_order'] = sortOrder.toString();

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessGalleryImage.fromJson(data['gallery_image'] as Map<String, dynamic>);
    } else {
      throw Exception(_parseError(response, 'Failed to add gallery image'));
    }
  }

  Future<BusinessGalleryVideo> addGalleryVideo({
    required int profileId,
    required File video,
    String? caption,
    int? sortOrder,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/business-profiles/$profileId/gallery-videos'),
    );
    request.headers.addAll(_authHeaders);
    request.files.add(await http.MultipartFile.fromPath('video', video.path));
    if (caption != null) request.fields['caption'] = caption;
    if (sortOrder != null) request.fields['sort_order'] = sortOrder.toString();

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessGalleryVideo.fromJson(data['gallery_video'] as Map<String, dynamic>);
    } else {
      throw Exception(_parseError(response, 'Failed to add gallery video'));
    }
  }

  Future<void> deleteGalleryImage(int profileId, int imageId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/business-profiles/$profileId/gallery-images/$imageId'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_parseError(response, 'Failed to delete gallery image'));
    }
  }

  Future<void> deleteGalleryVideo(int profileId, int videoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/business-profiles/$profileId/gallery-videos/$videoId'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_parseError(response, 'Failed to delete gallery video'));
    }
  }

  Future<List<BusinessSector>> getSectors() async {
    final response = await http.get(Uri.parse('$baseUrl/lookups/sectors'), headers: _headers);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data'] ?? [];
      return data.map((json) => BusinessSector.fromJson(json)).toList();
    }
    throw Exception(_parseError(response, 'Failed to load sectors'));
  }

  Future<List<BusinessCategory>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/lookups/categories'), headers: _headers);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data'] ?? [];
      return data.map((json) => BusinessCategory.fromJson(json)).toList();
    }
    throw Exception(_parseError(response, 'Failed to load categories'));
  }

  Future<List<BusinessDistrict>> getDistricts() async {
    final response = await http.get(Uri.parse('$baseUrl/lookups/districts'), headers: _headers);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data'] ?? [];
      return data.map((json) => BusinessDistrict.fromJson(json)).toList();
    }
    throw Exception(_parseError(response, 'Failed to load districts'));
  }

  Future<List<dynamic>> getValueChains() async {
    final response = await http.get(Uri.parse('$baseUrl/lookups/value-chains'), headers: _headers);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data'] ?? [];
      return data;
    }
    throw Exception(_parseError(response, 'Failed to load value chains'));
  }
}
