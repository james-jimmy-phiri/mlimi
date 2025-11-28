import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/product_request/mlimi_wallet_balance.dart';
import 'package:mlimi/pages/product_request/operationpages/potential_customers.dart';
import 'package:mlimi/pages/product_request/operationpages/sample.dart';
import 'package:mlimi/pages/sale/sale.dart';
import 'package:mlimi/pages/views/signup/loginscreen.dart';
import 'package:mlimi/pages/wallet/wallet.dart';
import 'package:mlimi/provider/http_provider.dart';

List<Map<String, dynamic>> getCardOperations(String language) {
  if (language == 'ny') {
    return [
      {
        "title": "Lembelani Pa mlimi Waleti",
        "page": const Wallet(),
        "icon": Icons.wallet
      },
      {
        "title": "Malonda Mukugulitsa",
        "page": const SalePage(),
        "icon": Icons.shopping_cart
      },
      {
        "title": "Ofuna Kugula",
        "page": const PotentialCustomers(),
        "icon": Icons.people
      },
      {"title": "Othekela Kukugulisani Mukufuna", "page": Sample(), "icon": Icons.business}
    ];
  } else {
    return [
      {
        "title": "Apply Mlimi Wallet",
        "page": const Wallet(),
        "icon": Icons.wallet
      },
      {
        "title": "Product Sale Offs",
        "page": const SalePage(),
        "icon": Icons.shopping_cart
      },
      {
        "title": "Potential Customers",
        "page": const PotentialCustomers(),
        "icon": Icons.people
      },
      {"title": "Potential Suppliers", "page": Sample(), "icon": Icons.business}
    ];
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _ProductRequest createState() => _ProductRequest();
}

class _ProductRequest extends State<Homepage> {
  final box = GetStorage();
  String clientName = 'Loading...';
  String phone = '';
  int potentialCustomers = 0;
  int potentialSuppliers = 0;
  int productSaleOffs = 0;
  int notifications = 0;
  bool isLoading = true;
  bool hasError = false;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    var token = box.read('token');
    if (token != null) {
      user = await HttpProvider().getUser(token);
      debugPrint('User response: ${jsonEncode(user)}');
      if (user != null) {
        if (user!.containsKey('error') && user!['error'] == 'unauthorized') {
          _showLoginDialog(); // Show login dialog if unauthorized
        } else if (user!['client'] != null) {
          setState(() {
            clientName = user!['client']['name'];
            phone = user!['client']['phone'];
            potentialCustomers = user!['potential_customers'] ?? 0;
            potentialSuppliers = user!['potential_suppliers'] ?? 0;
            productSaleOffs = user!['product_sale_offs'] ?? 0;
            notifications = user!['notifications'] ?? 0;
            isLoading = false;
          });
        } else {
          _handleError();
        }
      } else {
        _handleError();
      }
    } else {
      _handleError();
    }
  }

  void _handleError() {
    setState(() {
      isLoading = false;
      hasError = true;
      clientName = 'Failed to load user data';
    });
  }

  void _showLoginDialog() {
    final selectedLanguage = GetStorage().read('language') ?? 'en';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(selectedLanguage == 'en'
              ? 'Login Required'
              : 'Lowani kaye kuti mugwiritse ntchito'),
          content: Text(selectedLanguage == 'en'
              ? 'Your session has expired. Please log in again.'
              : 'Nthawi yanu yatha. Chonde lowaninso.'),
          actions: <Widget>[
            TextButton(
              child: Text(selectedLanguage == 'en' ? 'Login' : 'Lowani'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SimpleLoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = GetStorage().read('language') ?? 'en';
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: isLoading
            ? Center(
                child: Lottie.asset(
                  'assets/icons/loading1.json', // Replace with your Lottie file path
                  width: 100,
                  height: 100,
                ),
              )
            : hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(selectedLanguage == 'en'
                           ?'Failed to load data. Please try again.'
                           : 'Failed to load data. Chonde yesani kachikena .',
                          
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SimpleLoginScreen(),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: selectedLanguage == 'en'
                                  ? 'or your security token has expired,'
                                  : 'Ndinu wogwiritsa ntchito watsopano',
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: selectedLanguage == 'en'
                                      ? ' click to login'
                                      : 'Lowani',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: fetchUserDetails,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        CustomeAppBar(
                          name: clientName,
                          phone: phone,
                          notifications: notifications,
                          user: user!,
                        ),
                        Body(
                          potentialCustomers: potentialCustomers,
                          productSaleOffs: productSaleOffs,
                          potentialSuppliers: potentialSuppliers,
                          user: user!,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  final int potentialCustomers;
  final int productSaleOffs;
  final int potentialSuppliers;
  final Map<String, dynamic> user;

  const Body({
    super.key,
    required this.potentialCustomers,
    required this.productSaleOffs,
    required this.potentialSuppliers,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final members = user['client']['members'];
    final selectedLanguage = GetStorage().read('language') ?? 'en';
    final operations = getCardOperations(selectedLanguage);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 89, 185, 94),
      ),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 10,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        width: double.infinity / 2,
                        height: 55,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: kPrimaryColor, width: 3.5))),
                        child: Center(
                          child: Text(
                            selectedLanguage == 'en' ? "Operations" : "Zichitochito",
                            style: const TextStyle(
                                fontSize: 15,
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: List.generate(operations.length, (index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => operations[index]['page'],
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 10,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: kPrimaryLight.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      operations[index]['icon'],
                                      color: kPrimaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "${operations[index]['title']}: ${_getCardValue(index)}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  "assets/images/btn_next.png",
                                  width: 10,
                                  height: 10,
                                  color: TColor.primaryText,
                                ),
                              ],
                            )),
                      ),
                    ),
                  );
                }),
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  if (members != null && members.isNotEmpty)
                    _buildMembers(members),
                  // const SizedBox(height: 20),
                  // if (commodities != null && commodities.isNotEmpty)
                  //   _buildCommodities(commodities),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCardValue(int index) {
    switch (index) {
      case 2:
        return potentialCustomers.toString();
      case 1:
        return productSaleOffs.toString();
      case 3:
        return potentialSuppliers.toString();
      default:
        return ' ';
    }
  }

  Widget _buildMembers(List<dynamic> members) {
    return Card(
      elevation: 4,
      color: Bgreen,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.group),
        title: Text(
          'Group Members (${members.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        children: members.map<Widget>((member) {
          final position = member['position'];
          final label =
              (position != null && position.toString().trim().isNotEmpty)
                  ? position
                  : "Member";

          return ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(member['name']),
            subtitle: Text(label, style: const TextStyle(color: Colors.grey)),
          );
        }).toList(),
      ),
    );
  }
}

class CustomeAppBar extends StatelessWidget {
  final String name;
  final String phone;
  final int notifications;
  final Map<String, dynamic> user;

  const CustomeAppBar({
    super.key,
    required this.name,
    required this.phone,
    required this.notifications,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = GetStorage().read('language') ?? 'en';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 15, left: 15, bottom: 15, right: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.5],
          colors: [
            Color.fromARGB(255, 129, 199, 132),
            Color.fromARGB(255, 89, 185, 94),
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  label: Text(
                      selectedLanguage == 'en'
                          ? "Back Home"
                          : "Bwelerani Samba loyamba",
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleLoginScreen(),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        selectedLanguage == 'en'
                            ? 'Notification ($notifications)'
                            : 'Uthenga ($notifications)',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: whitecolor),
                      ),
                      const Icon(Icons.notifications, color: Colors.white),
                    ],
                  ),
                )
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedLanguage == 'en' ? 'Welcome :' : 'Takulandirani :',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color.fromARGB(255, 224, 223, 223),
                  ),
                ),
                _buildHeader(user['client']),
                const SizedBox(height: 5),

                // Text(
                //   name,
                //   style: const TextStyle(
                //     fontWeight: FontWeight.w600,
                //     fontSize: 24,
                //     color: Colors.white,
                //   ),
                // ),
                // Text(
                //   phone,
                //   style: const TextStyle(
                //     fontWeight: FontWeight.w400,
                //     fontSize: 16,
                //     color: Colors.white,
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const MlimiWalletBalance(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> client) {
    return Card(
      elevation: 5,
      color: Bgreen, // Light teal background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.teal[600],
                  child:
                      const Icon(Icons.groups, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client['name'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client['phone'] ?? '',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _infoTile('District', client['district'] ?? 'N/A'),
                _infoTile('Joined', client['joined'] ?? 'N/A'),
                _infoTile(
                    'Status', client['active'] == true ? 'Active' : 'Inactive'),
                if (client['epa'] != null) _infoTile('EPA', client['epa']),
                if (client['t_a'] != null) _infoTile('T/A', client['t_a']),
                if (client['gvh'] != null) _infoTile('GVH', client['gvh']),
                if (client['chair_person'] != null)
                  _infoTile('Chairperson', client['chair_person']),
                if (client['number_of_members'] != null)
                  _infoTile('Members', client['number_of_members'].toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
