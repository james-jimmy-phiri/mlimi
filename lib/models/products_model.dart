class Product {
  final int id;
  final String name;
  final String imageUrl;
  final String unitPrice;
  final String measure;
  final String quantity;
  final String location;
  final String description;
  final String type;
  final bool active;
  final int views;
  final String created;
  final Client client;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.measure,
    required this.quantity,
    required this.location,
    required this.description,
    required this.type,
    required this.active,
    required this.views,
    required this.created,
    required this.client,
  });
}

class Client {
  final String name;
  final String phone;
  final String? avatarUrl;

  Client({required this.name, required this.phone, this.avatarUrl});
}
