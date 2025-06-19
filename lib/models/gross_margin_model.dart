class Crop {
  final int id;
  final String name;
  final String image;
  final List<Category> categories;
  final List<Section> sections;

  Crop({
    required this.id,
    required this.name,
    required this.image,
    required this.categories,
    required this.sections,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      categories: (json['category'] as List)
          .map((category) => Category.fromJson(category))
          .toList(),
      sections: (json['section'] as List)
          .map((section) => Section.fromJson(section))
          .toList(),
    );
  }
}

class Category {
  final int id;
  final String name;
  final double averageYield;
  final String image;
  final double price;
  final double totalIncome;

  Category({
    required this.id,
    required this.name,
    required this.averageYield,
    required this.image,
    required this.price,
    required this.totalIncome,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0, // Default to 0 if null
      name: json['name'] ?? 'Unknown',
      averageYield: (json['average_yield'] != null)
          ? json['average_yield'].toDouble()
          : 0.0,
      image: json['image'] ?? 'default_image',
      price: (json['price'] != null) ? json['price'].toDouble() : 0.0,
      totalIncome: (json['total_income'] != null)
          ? json['total_income'].toDouble()
          : 0.0,
    );
  }
}

class Section {
  final int id;
  final String name;
  final List<Content> contents;

  Section({
    required this.id,
    required this.name,
    required this.contents,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'],
      contents: (json['content'] as List)
          .map((content) => Content.fromJson(content))
          .toList(),
    );
  }
}

class Content {
  final int id;
  final String item;
  final double rateAcre;
  final String unit;
  final double unitCost;
  final double totalCost;
  final String notes;

  Content({
    required this.id,
    required this.item,
    required this.rateAcre,
    required this.unit,
    required this.unitCost,
    required this.totalCost,
    required this.notes,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] ?? 0, // Default to 0 if null
      item: json['item'] ?? 'Unknown',
      rateAcre:
          (json['rate_acre'] != null) ? json['rate_acre'].toDouble() : 0.0,
      unit: json['unit'] ?? 'Unknown',
      unitCost:
          (json['unit_cost'] != null) ? json['unit_cost'].toDouble() : 0.0,
      totalCost:
          (json['total_cost'] != null) ? json['total_cost'].toDouble() : 0.0,
      notes: json['notes'] ?? '',
    );
  }
}
