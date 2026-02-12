class FarmerData {
  final List<Region> regions;

  FarmerData({required this.regions});

  factory FarmerData.fromJson(Map<String, dynamic> json) {
    return FarmerData(
      regions: (json['list_district_farmers'] as List)
          .map((e) => Region.fromJson(e))
          .toList(),
    );
  }
}

class Region {
  final String region;
  final List<District> districts;

  Region({required this.region, required this.districts});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      region: json['region'],
      districts: (json['districts'] as List)
          .map((e) => District.fromJson(e))
          .toList(),
    );
  }
}

class District {
  final String district;
  final List<Epa> epas;

  District({required this.district, required this.epas});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      district: json['district'],
      epas: (json['epas'] as List).map((e) => Epa.fromJson(e)).toList(),
    );
  }
}

class Epa {
  final String epa;
  final List<Village> villages;

  Epa({required this.epa, required this.villages});

  factory Epa.fromJson(Map<String, dynamic> json) {
    return Epa(
      epa: json['epa'],
      villages: (json['villages'] as List)
          .map((e) => Village.fromJson(e))
          .toList(),
    );
  }
}

class Village {
  final String village;
  final List<Farmer> farmers;

  Village({required this.village, required this.farmers});

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      village: json['village'],
      farmers: (json['farmers'] as List)
          .map((e) => Farmer.fromJson(e))
          .toList(),
    );
  }
}

class Farmer {
  final String farmerName;
  final String householdId;
  final String gender;
  final String longitude;
  final String latitude;

  Farmer({
    required this.farmerName,
    required this.householdId,
    required this.gender,
    required this.longitude,
    required this.latitude,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      farmerName: json['farmer_name'],
      householdId: json['household_id'],
      gender: json['gender'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }
}
