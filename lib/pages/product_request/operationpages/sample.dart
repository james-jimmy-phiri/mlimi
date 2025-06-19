import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/pages/product_request/operationpages/single_potential_customer_page.dart';
import 'package:lottie/lottie.dart';
import 'package:mlimi/pages/product_request/operationpages/singlesample.dart';
import 'dart:convert';

import 'package:mlimi/pages/views/signup/loginscreen.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  _PotentialCustomersPageState createState() => _PotentialCustomersPageState();
}

class _PotentialCustomersPageState extends State<Sample> {
  List<dynamic> commodities = [];
  List<dynamic> filteredCommodities = [];
  bool isLoading = true;
  bool hasError = false;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    fetchCommodities();
  }

  Future<void> fetchCommodities() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      String? token = box.read('token');
      final response = await http.get(
        Uri.parse('${apiurl}v1/profile/product-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          commodities = data['commodities'];
          filteredCommodities = commodities;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
        });
        _showSignInDialog();
      } else {
        throw Exception('Failed to load commodities');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error occurred: $error');
    }
  }

  void filterCommodities(String query) {
    final filtered = commodities.where((commodity) {
      final nameLower = commodity['name'].toLowerCase();
      final descriptionLower = commodity['description'].toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) ||
          descriptionLower.contains(searchLower);
    }).toList();
    setState(() {
      filteredCommodities = filtered;
    });
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Session Expired'),
        content: Text('Your session has expired. Please sign in again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const SimpleLoginScreen()),
              );
            },
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(
        backgroundColor: Bgreen,
        title: Text('Select the product you posted to see potential Suppliers'),
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset('assets/icons/loading1.json'),
            )
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/lottie/error.json'),
                      SizedBox(height: 20),
                      Text('Failed to load data'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchCommodities,
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: filterCommodities,
                        decoration: InputDecoration(
                          labelText: 'Search Commodities',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCommodities.length,
                        itemBuilder: (context, index) {
                          final commodity = filteredCommodities[index];
                          return Card(
                            color: whitecolor,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: commodity['image'] != null
                                      ? Image.network(
                                          '${storageurl}commodities/images/${commodity['image']}',
                                          width: 100,
                                          height: 100)
                                      : Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey,
                                        ),
                                  title: Text(commodity['name']),
                                  subtitle: Text(commodity['description']),
                                  trailing: Icon(Icons.arrow_forward),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SinglePotentialSupplierPage(
                                                commodity: commodity),
                                      ),
                                    );
                                  },
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                          'Potential suppliers (${commodity['suppliers'].length})'),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child:
                                          Text('Views (${commodity['views']})'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
