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
import 'package:mlimi/pages/profile/edit_profile.dart';
import 'package:mlimi/pages/profile/manage_group_members.dart';
import 'package:mlimi/pages/profile/add_group_members_page.dart';
import 'package:mlimi/pages/notifications/notifications_screen.dart';

List<Map<String, dynamic>> getCardOperations(String language, Map<String, dynamic>? user, VoidCallback onRefresh) {
  List<Map<String, dynamic>> operations = [];

  final String clientType = user?['client']?['type']?.toString().toLowerCase() ??
      GetStorage().read('client_type')?.toString().toLowerCase() ?? '';
  final bool isGroup = clientType == 'group';

  if (language == 'ny') {
    operations = [
      if (isGroup)
        {
          "title": "Wonjezani Mamembala a Gulu",
          "page": AddGroupMembersPage(user: user, onUpdate: onRefresh),
          "icon": Icons.group_add
        }
      else
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
      {"title": "Othekela Kukugulisani Mukufuna", "page": Sample(), "icon": Icons.business},
      {"title": "Sinthani Mbiri Yanu", "page": EditProfilePage(user: user, onUpdate: onRefresh), "icon": Icons.edit},
    ];

    if (isGroup) {
      operations.add({
        "title": "Konzani Mamembala a Gulu",
        "page": ManageGroupMembersPage(user: user, onUpdate: onRefresh),
        "icon": Icons.settings
      });
    }
  } else {
    operations = [
      if (isGroup)
        {
          "title": "Add Group Members",
          "page": AddGroupMembersPage(user: user, onUpdate: onRefresh),
          "icon": Icons.group_add
        }
      else
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
      {"title": "Potential Suppliers", "page": Sample(), "icon": Icons.business},
      {"title": "Edit Profile", "page": EditProfilePage(user: user, onUpdate: onRefresh), "icon": Icons.edit},
    ];

    if (isGroup) {
      operations.add({
        "title": "Manage Group Members",
        "page": ManageGroupMembersPage(user: user, onUpdate: onRefresh),
        "icon": Icons.settings
      });
    }
  }
  return operations;
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
                          onRefresh: fetchUserDetails,
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
  final VoidCallback onRefresh;

  const Body({
    super.key,
    required this.potentialCustomers,
    required this.productSaleOffs,
    required this.potentialSuppliers,
    required this.user,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final members = user['client']['members'];
    final selectedLanguage = GetStorage().read('language') ?? 'en';
    final operations = getCardOperations(selectedLanguage, user, onRefresh);
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
                      builder: (context) => const NotificationsScreen(),
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
          // const MlimiWalletBalance(),
          // const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> client) {
    final String clientType = client['type']?.toString().toLowerCase() ??
        GetStorage().read('client_type')?.toString().toLowerCase() ?? '';
    final bool isGroup = clientType == 'group';
    final selectedLanguage = GetStorage().read('language') ?? 'en';

    final valueChains = client['value_chains'];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isGroup ? Icons.groups_rounded : Icons.person_rounded,
                      color: kPrimaryColor,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              client['name'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isGroup ? Colors.teal.shade50 : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isGroup ? Colors.teal.shade200 : Colors.blue.shade200,
                              ),
                            ),
                            child: Text(
                              isGroup
                                  ? (selectedLanguage == 'ny' ? 'Gulu / Coop' : 'Group')
                                  : (selectedLanguage == 'ny' ? 'Mlimi' : 'Individual'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isGroup ? Colors.teal.shade800 : Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                client['phone'] ?? 'N/A',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                client['district'] ?? 'N/A',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isGroup && client['project_name'] != null && client['project_name'].toString().trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.assignment_outlined, size: 12, color: Colors.amber.shade900),
                              const SizedBox(width: 4),
                              Text(
                                "Project: ${client['project_name']}",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 16),

            // Group-specific details section
            if (isGroup) ...[
              // Section Header: Location & Address
              Text(
                selectedLanguage == 'ny' ? 'Malo Opezekela a Gulu' : 'Location Details',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kPrimaryColor, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _infoBadge(Icons.map_outlined, 'District', client['district'] ?? 'N/A'),
                  if (client['epa'] != null && client['epa'].toString().isNotEmpty)
                    _infoBadge(Icons.holiday_village_outlined, 'EPA', client['epa']),
                  if (client['t_a'] != null && client['t_a'].toString().isNotEmpty)
                    _infoBadge(Icons.account_balance_outlined, 'T/A', client['t_a']),
                  // if (client['gvh'] != null && client['gvh'].toString().isNotEmpty)
                  //   _infoBadge(Icons.home_work_outlined, 'GVH', client['gvh']),
                  // if (client['mapping_id'] != null && client['mapping_id'].toString().isNotEmpty)
                  //   _infoBadge(Icons.qr_code_outlined, 'Mapping ID', client['mapping_id']),
                ],
              ),

              const SizedBox(height: 16),

              // Section Header: Leadership & Membership
              Text(
                selectedLanguage == 'ny' ? 'Utsogoleri ndi Mamembala' : 'Leadership & Membership',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kPrimaryColor, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (client['chair_person'] != null && client['chair_person'].toString().isNotEmpty)
                    _infoBadge(Icons.person_pin_outlined, selectedLanguage == 'ny' ? 'Wampando' : 'Chairperson', client['chair_person']),
                  _infoBadge(
                    Icons.groups_outlined,
                    selectedLanguage == 'ny' ? 'Mamembala Onse' : 'Total Members',
                    (client['number_of_members'] ?? (client['members'] != null ? (client['members'] as List).length : 0)).toString(),
                  ),
                  // if (client['male_group_members'] != null)
                  //   _infoBadge(Icons.male_outlined, selectedLanguage == 'ny' ? 'Amuna' : 'Male Members', client['male_group_members'].toString()),
                  // if (client['female_group_members'] != null)
                  //   _infoBadge(Icons.female_outlined, selectedLanguage == 'ny' ? 'Amayi' : 'Female Members', client['female_group_members'].toString()),
                ],
              ),

              // Section Header: Value Chains
              if (valueChains != null && (valueChains is List) && valueChains.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  selectedLanguage == 'ny' ? 'Mbeu Zazolimidwa pa Gulu' : 'Group Value Chains',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kPrimaryColor, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (valueChains as List).map((vc) {
                    final String name = vc is Map ? (vc['name'] ?? '') : vc.toString();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco_outlined, size: 12, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            name,
                            style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ] else ...[
              // Individual client details
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _infoBadge(Icons.map_outlined, 'District', client['district'] ?? 'N/A'),
                  if (client['gender'] != null) _infoBadge(Icons.wc_outlined, 'Gender', client['gender']),
                  if (client['age_range'] != null) _infoBadge(Icons.cake_outlined, 'Age Range', client['age_range']),
                  if (client['disability'] != null) _infoBadge(Icons.accessible_outlined, 'Disability', client['disability'] == true ? 'Yes' : 'No'),
                  _infoBadge(Icons.calendar_today_outlined, 'Joined', client['joined'] ?? 'N/A'),
                  _infoBadge(Icons.check_circle_outline, 'Status', client['active'] == true ? 'Active' : 'Inactive'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: kPrimaryColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

