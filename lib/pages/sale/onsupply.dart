import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mlimi/common_widget/profile_avatar.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/products_model.dart';
import 'package:mlimi/pages/Buy/product_deteils.dart';

class Onsupply extends StatefulWidget {
  const Onsupply({super.key});

  @override
  _OnSupply createState() => _OnSupply();
}

class _OnSupply extends State<Onsupply> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool hasError = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('${apiurl}v1/commodities/for-supply');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        List<Product> fetchedProducts = [];
        for (var item in jsonData['commodities']) {
          var clientData = item['client'];
          var client = Client(
            name: clientData['name'],
            phone: clientData['phone'],
          );

          fetchedProducts.add(Product(
            id: item['id'],
            name: item['name'],
            imageUrl: item['image'] ?? '',
            unitPrice: item['price'],
            measure: item['measure'],
            quantity: item['quantity'],
            location: item['location'],
            description: item['description'],
            type: item['type'],
            active: item['active'],
            views: item['views'],
            created: item['created'],
            client: client,
          ));
        }

        setState(() {
          products = fetchedProducts;
          filteredProducts = fetchedProducts;
          hasError = false; // Reset error state
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
      print('Error fetching products: $e');
    }
  }

  void filterProducts(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.description
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                product.location.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> pokeSeller(int productId) async {
    final url =
        Uri.parse('${apiurl}v1/commodities/$productId/potential-supplier');
    final storage = GetStorage();
    String? token = storage.read('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully poked the seller')),
        );
      } else {
        var jsonData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${jsonData["error"]}')),
        );
        print('Error: ${jsonData["error"]}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error poking seller: $e')),
      );
      print('Error poking seller: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) => filterProducts(query),
            ),
          ),
          Expanded(
            child: hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Failed to load products.'),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: fetchProducts,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : filteredProducts.isEmpty && searchQuery.isEmpty
                    ? Center(
                        child: Lottie.asset(
                          'assets/icons/loading1.json', // Replace with your Lottie file path
                          width: 80,
                          height: 80,
                        ),
                      )
                    : filteredProducts.isEmpty
                        ? Center(child: Text('No products found'))
                        : ListView.builder(
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                product: filteredProducts[index],
                                onPoke: pokeSeller,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final Function(int) onPoke;

  const ProductCard({required this.product, required this.onPoke});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
              onPoke: onPoke,
            ),
          ),
        );
      },
      child: Card(
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PostHeader(product: product),
                    const SizedBox(height: 4.0),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    product.imageUrl.isEmpty
                        ? const SizedBox.shrink()
                        : const SizedBox(height: 6.0),
                  ],
                ),
              ),
              product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 300.0, // Set the maximum height here
                        ),
                        child: Image.network(
                          '${storageurl}commodities/images/${product.imageUrl}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 6.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: _PostStats(product: product, onPoke: onPoke),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final Product product;

  const _PostHeader({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ProfileAvatar(
            imageUrl:
                'https://e7.pngegg.com/pngimages/84/165/png-clipart-united-states-avatar-organization-information-user-avatar-service-computer-wallpaper-thumbnail.png'),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.client.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    ' ${product.created} • ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                  Icon(
                    Icons.public,
                    color: Colors.grey[600],
                    size: 12.0,
                  )
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () => print('More'),
        ),
      ],
    );
  }
}

class _PostStats extends StatelessWidget {
  final Product product;
  final Function(int) onPoke;

  const _PostStats({
    required this.product,
    required this.onPoke,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.attach_money,
              size: 15.0,
              color: Colors.black,
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                '${product.unitPrice} /${product.measure}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const Icon(
              Icons.location_on_outlined,
              size: 15.0,
              color: Colors.black,
            ),
            Text(
              '${product.location} ',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8.0),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () => print('Comment'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  height: 25.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.eyeOutline,
                        color: Colors.grey[600],
                        size: 20.0,
                      ),
                      const SizedBox(width: 4.0),
                      const Text('View Seller'),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () => print('Comment'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  height: 25.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.share,
                        color: Colors.grey[600],
                        size: 20.0,
                      ),
                      const SizedBox(width: 4.0),
                      const Text('Share'),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () => onPoke(product.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  height: 25.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.handWaveOutline,
                        color: Colors.grey[600],
                        size: 20.0,
                      ),
                      const SizedBox(width: 4.0),
                      const Text('Poke'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
