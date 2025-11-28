// sector_model.dart
class Sector {
  final int id;
  final String name;
  final String? nameNy; // Chichewa name
  final String image;
  final String sectorimage;
  final List<Category> categories;

  Sector({
    required this.id,
    required this.name,
    this.nameNy,
    required this.image,
    required this.categories,
    required this.sectorimage,
  });

  factory Sector.fromJson(Map<String, dynamic> json) {
    var list = json['categories'] as List;
    List<Category> categoriesList =
        list.map((i) => Category.fromJson(i)).toList();

    return Sector(
      id: json['id'],
      name: json['name'],
      nameNy: json['nameNy'], // Add this line
      image: json['image'],
      sectorimage: json['sectorimage'],
      categories: categoriesList,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String image;
  final String description;
  final List<Product> products;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.products,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var list = json['products'] as List;
    List<Product> productsList = list.map((i) => Product.fromJson(i)).toList();
    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      products: productsList,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String image;
  final List<Section> sections;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.sections,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var list = json['section'] as List;
    List<Section> sectionsList = list.map((i) => Section.fromJson(i)).toList();
    return Product(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      sections: sectionsList,
    );
  }
}

class Section {
  final int id;
  final String title;
  final String image;
  final String audio;
  final List<String> content;

  Section({
    required this.id,
    required this.title,
    required this.image,
    required this.audio,
    required this.content,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    var list = json['content'] as List;
    List<String> contentList = list.map((i) => i.toString()).toList();
    return Section(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      audio: json['audio'],
      content: contentList,
    );
  }
}
