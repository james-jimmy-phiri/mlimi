import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mlimi/common_widget/profile_avatar.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/products_model.dart';
import 'package:mlimi/pages/Buy/product_deteils.dart';
import 'package:mlimi/pages/Buy/product_edit.dart';
import 'package:url_launcher/url_launcher.dart';

class Markert extends StatefulWidget {
  const Markert({Key? key}) : super(key: key);

  @override
  _MarkertState createState() => _MarkertState();
}

class _MarkertState extends State<Markert> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool hasError = false;
  String searchQuery = '';
  
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isFetchingMore && _hasMoreData) {
        setState(() {
          _currentPage++;
          _isFetchingMore = true;
        });
        fetchProducts();
      }
    }
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('${apiurl}v1/commodities/for-sale?page=$_currentPage');

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

          var product = Product(
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
          );

          fetchedProducts.add(product);
        }

      setState(() {
        if (_currentPage == 1) {
          products = fetchedProducts;
          filteredProducts = fetchedProducts;
        } else {
          products.addAll(fetchedProducts);
          // Re-apply filter if there's an active search query
          if (searchQuery.isNotEmpty) {
            filteredProducts.addAll(fetchedProducts.where((p) =>
                p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                p.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
                p.location.toLowerCase().contains(searchQuery.toLowerCase())));
          } else {
            filteredProducts = List.from(products);
          }
        }
        
        // If we fetched less than 5 items, we've reached the end
        if (jsonData['commodities'].length < 5) {
          _hasMoreData = false;
        }
        
        _isFetchingMore = false;
        hasError = false; 
      });
    } else {
      throw Exception('Failed to load products');
    }
  } catch (e) {
    setState(() {
      hasError = true;
      _isFetchingMore = false;
    });
    print('Error fetching products: $e');
  }
}

Future<void> _refreshProducts() async {
  setState(() {
    _currentPage = 1;
    _hasMoreData = true;
  });
  await fetchProducts();
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
        Uri.parse('${apiurl}v1/commodities/$productId/potential-customer');
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your Session Expired, Login to Proceed')),
      );
    }
  }

  void showSellerDetails(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top section with avatar and name
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16.0)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: client.avatarUrl != null
                          ? NetworkImage(client.avatarUrl!)
                          : null,
                      child: client.avatarUrl == null
                          ? Icon(Icons.person,
                              size: 40, color: Colors.blueAccent)
                          : null,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      client.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Middle section with details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.blueAccent),
                      title: Text(client.phone),
                      onTap: () => launch("tel://${client.phone}"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProduct(int productId) async {
    final url = Uri.parse('${apiurl}v1/commodities/$productId');
    final storage = GetStorage();
    String? token = storage.read('token');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product deleted successfully.'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                // Implement undo functionality
                undoDeleteProduct(productId);
              },
            ),
          ),
        );
        fetchProducts(); // Refresh the list after deletion
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
      print('Error deleting product: $e');
    }
  }

  Future<void> undoDeleteProduct(int productId) async {
    // Re-fetch or recover the deleted product
    // This is a placeholder; you may need to implement a mechanism to
    // actually undo the deletion, like storing the last deleted item.
    fetchProducts(); // Refresh the list
  }

  void editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductEditPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
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
                      ))
                    : filteredProducts.isEmpty
                        ? Center(child: Text('No products found'))
                        : RefreshIndicator(
                            onRefresh: _refreshProducts,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: filteredProducts.length + (_isFetchingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == filteredProducts.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                return FadeInUp(
                                  duration: const Duration(milliseconds: 500),
                                  delay: Duration(milliseconds: 100 * (index % 5)),
                                  child: ProductCard(
                                    product: filteredProducts[index],
                                    onPoke: pokeSeller,
                                    onViewSeller: showSellerDetails,
                                    onDelete: deleteProduct,
                                    onEdit: editProduct,
                                  ),
                                );
                              },
                            ),
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
  final Function(BuildContext, Client) onViewSeller;
  final Function(int) onDelete;
  final Function(Product) onEdit;

  const ProductCard(
      {required this.product,
      required this.onPoke,
      required this.onViewSeller,
      required this.onDelete,
      required this.onEdit});

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
                    _PostHeader(
                      product: product,
                      onDelete: onDelete,
                      onEdit: onEdit,
                    ),
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
                          product.imageUrl,
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
                child: _PostStats(
                  product: product,
                  onPoke: onPoke,
                  onViewSeller: onViewSeller,
                ),
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
  final Function(int) onDelete;
  final Function(Product) onEdit;

  const _PostHeader({
    required this.product,
    required this.onDelete,
    required this.onEdit,
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
                    '${product.created}• ',
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
        PopupMenuButton<String>(
          color: whitecolor,
          onSelected: (String value) {
            if (value == 'Edit') {
              onEdit(product);
            } else if (value == 'Delete') {
              onDelete(product.id);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Edit',
              child: Text('Edit Post'),
            ),
            const PopupMenuItem<String>(
              value: 'Delete',
              child: Text('Delete Post'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PostStats extends StatelessWidget {
  final Product product;
  final Function(int) onPoke;
  final Function(BuildContext, Client) onViewSeller;

  const _PostStats({
    required this.product,
    required this.onPoke,
    required this.onViewSeller,
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
                onTap: () => onViewSeller(context, product.client),
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
