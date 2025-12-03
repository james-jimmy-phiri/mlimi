import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/models/business_profile.dart';

import 'package:mlimi/constants/url.dart';

class BusinessProfileService {
  // Use the apiurl from constants
  final String baseUrl = '${apiurl}v1';

  Map<String, String> get _headers {
    final token = GetStorage().read('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<BusinessProfile>> getProfiles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/business-profiles'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Adjust based on actual API response structure (e.g., if wrapped in 'data')
      final List<dynamic> profilesJson = data['data'] ?? data; 
      return profilesJson.map((json) => BusinessProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load business profiles');
    }
  }

  Future<BusinessProfile> getMyProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/business-profiles/my-profile'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessProfile.fromJson(data['data'] ?? data);
    } else {
      throw Exception('Failed to load my profile');
    }
  }

  Future<BusinessProfile> createProfile(BusinessProfile profile, File? logo) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/business-profiles'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': _headers['Authorization'] ?? '',
    });

    request.fields['business_name'] = profile.businessName;
    if (profile.description != null) request.fields['description'] = profile.description!;
    if (profile.location != null) request.fields['location'] = profile.location!;
    if (profile.sectorId != null) request.fields['sector_id'] = profile.sectorId.toString();
    
    // Add contact info fields as array/json if needed, or flat fields depending on API
    // The PHP model casts contact_info to array, so we might need to send it as JSON string or individual fields
    // For MultipartRequest, we usually send simple fields. If the API expects JSON for contact_info:
    if (profile.contactInfo != null) {
       // Flattening or sending as JSON string depending on backend expectation. 
       // Laravel validation often handles array inputs like contact_info[email]
       if (profile.contactInfo!.email != null) request.fields['contact_info[email]'] = profile.contactInfo!.email!;
       if (profile.contactInfo!.phone != null) request.fields['contact_info[phone]'] = profile.contactInfo!.phone!;
       if (profile.contactInfo!.website != null) request.fields['contact_info[website]'] = profile.contactInfo!.website!;
    }

    if (logo != null) {
      request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return BusinessProfile.fromJson(data['data'] ?? data);
    } else {
      throw Exception('Failed to create profile: ${response.body}');
    }
  }
  
  Future<List<BusinessSector>> getSectors() async {
    final response = await http.get(
      Uri.parse('$baseUrl/business-sectors'), // Assuming this endpoint exists
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
}
