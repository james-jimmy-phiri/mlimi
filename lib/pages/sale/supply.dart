import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:flutter/foundation.dart';
import 'package:mlimi/pages/sale/allsupply/all_supply.dart';
import 'package:mlimi/pages/sale/onsupply.dart';

class SupplyPage extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (productName, unitPrice)
  final Function(String? productName, String? unitPrice)? onSubmitted;

  const SupplyPage({this.onSubmitted, super.key});

  @override
  State<SupplyPage> createState() => _SupplyPageState();
}

class _SupplyPageState extends State<SupplyPage>
    with SingleTickerProviderStateMixin {
  late String _language;
  late String unitPrice, quantity, district, description, expectedSupplyDate;
  String? productNameError,
      unitPriceError,
      quantityError,
      districtError,
      typeError,
      descriptionError;
  Function(String? productName, String? unitPrice)? get onSubmitted =>
      widget.onSubmitted;

  _SupplyPageState() {
    _selectedtype = _types[1];
  }

  final _types = ["1", "2"];
  String? _selectedUnit;
  String? _selectedtype;
  String? _selectedProduct;
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // For web
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _units = [];
  List<Map<String, dynamic>> _districts = [];

  bool _isLoading = true;
  bool isLoadingSubmit = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchLanguagePreference();
    unitPrice = '';
    description = '';
    quantity = '';
    district = '';

    expectedSupplyDate = '';

    productNameError = null;
    unitPriceError = null;
    descriptionError = null;
    quantityError = null;
    districtError = null;
    typeError = null;

    _tabController = TabController(length: 2, vsync: this);
    _fetchProducts();
    _fetchUnits();
    _fetchDistricts();
  }

  Future<void> _fetchLanguagePreference() async {
    final storage = GetStorage();
    _language = storage.read('language') ?? 'en';
  }

  String _localizedText(String enText, String nyText) {
    return _language == 'ny' ? nyText : enText;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  String? _getMimeType(String path) {
  final extension = path.split('.').last.toLowerCase();
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'jpeg';
    case 'png':
      return 'png';
    case 'webp':
      return 'webp';
    default:
      return null;
  }
}

  Future<void> _fetchUnits() async {
    setState(() {
      _isLoading = true;
    });

    final storage = GetStorage();
    String? token = storage.read('token');

    try {
      final response = await http.get(
        Uri.parse('${apiurl}v1/measures'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['measures'];
        setState(() {
          _units = data.map((item) {
            return {'id': item['id'], 'name': item['name']};
          }).toList();
          if (_units.isNotEmpty) {
            _selectedUnit = _units[0]['id'];
          }
        });
      } else {
        print(
            'Failed to load units: ${response.statusCode} ${response.reasonPhrase}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load units');
      }
    } catch (e) {
      print('Error fetching units: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    final storage = GetStorage();
    String? token = storage.read('token');

    try {
      final response = await http.get(
        Uri.parse('${apiurl}v1/value-chains'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['value_chains'];
        setState(() {
          _products = data.map((item) {
            return {'id': item['id']?.toString(), 'name': item['name']};
          }).toList();
          if (_products.isNotEmpty) {
            _selectedProduct = _products[0]['id']?.toString();
          }
        });
      } else {
        print(
            'Failed to load products: ${response.statusCode} ${response.reasonPhrase}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDistricts() async {
    setState(() {
      _isLoading = true;
    });

    final storage = GetStorage();
    String? token = storage.read('token');

    try {
      final response = await http.get(
        Uri.parse('${apiurl}v1/districts'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['districts'];
        setState(() {
          _districts = data.map((item) {
            return {'id': item['id'], 'name': item['name']};
          }).toList();
          if (_districts.isNotEmpty) {
            district = _districts[0]['id'];
          }
        });
      } else {
        print(
            'Failed to load districts: ${response.statusCode} ${response.reasonPhrase}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      print('Error fetching districts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? unitError;

  void resetErrorText() {
    setState(() {
      productNameError = null;
      unitPriceError = null;
      descriptionError = null;
      quantityError = null;
      districtError = null;
      typeError = null;
      unitError = null;
    });
  }

  String _extractErrorMessage(dynamic parsedResponse, int statusCode) {
    if (parsedResponse is Map) {
      if (parsedResponse.containsKey('errors') && parsedResponse['errors'] is Map) {
        final errors = parsedResponse['errors'] as Map;
        List<String> errList = [];
        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            errList.add('${key}: ${value.join(', ')}');
          } else if (value is String) {
            errList.add('${key}: $value');
          }
        });
        if (errList.isNotEmpty) {
          return errList.join('\n');
        }
      }
      if (parsedResponse.containsKey('message') && parsedResponse['message'] != null) {
        return parsedResponse['message'].toString();
      }
      if (parsedResponse.containsKey('error') && parsedResponse['error'] != null) {
        return parsedResponse['error'].toString();
      }
    }
    return 'Server error code: $statusCode / Zolakwika pa Seva: $statusCode';
  }

  void _showBilingualErrorDialog(BuildContext context, String rawError) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Submission Error / Zolakwika Pakutumiza',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Could not submit supply due to the following issue:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Text(
                'Sikwatheka kutumiza katundu chifukwa cha vuto ili:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  rawError,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK / Chabwino', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  bool validate() {
    resetErrorText();
    bool isValid = true;

    if (_selectedProduct == null || _selectedProduct!.trim().isEmpty) {
      setState(() {
        productNameError = _localizedText(
            'Please select a product', 'Chonde sankhani katundu');
      });
      isValid = false;
    }
    if (unitPrice.trim().isEmpty) {
      setState(() {
        unitPriceError = _localizedText('Please enter a unit price',
            'Chonde lowetsani mtengo wa chinthu chimodzi');
      });
      isValid = false;
    }
    if (_selectedUnit == null || _selectedUnit!.trim().isEmpty) {
      setState(() {
        unitError = _localizedText(
            'Please select a unit', 'Chonde sankhani muyezo');
      });
      isValid = false;
    }
    if (quantity.trim().isEmpty) {
      setState(() {
        quantityError = _localizedText(
            'Please enter quantity', 'Chonde lowetsani kuchuluka kwa zinthu');
      });
      isValid = false;
    }
    if (district.trim().isEmpty) {
      setState(() {
        districtError = _localizedText(
            'Please select a location/district', 'Chonde sankhani dera/boma');
      });
      isValid = false;
    }
    if (description.trim().isEmpty) {
      setState(() {
        descriptionError = _localizedText('Please enter a description',
            'Chonde lowetsani kufotokozera kwa chinthu');
      });
      isValid = false;
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizedText(
              'Please fill all required fields',
              'Chonde dzazani mindandanda yonse yofunika')),
          backgroundColor: Colors.red,
        ),
      );
    }

    return isValid;
  }

  Future<void> submit() async {
    if (!validate()) {
      return;
    }

    setState(() {
      isLoadingSubmit = true;
    });

    var url = Uri.parse('${apiurl}v1/commodities');
    final storage = GetStorage();
    String? token = storage.read('token');

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['value_chain_id'] = _selectedProduct ?? ''
        ..fields['unit_price'] = unitPrice.trim()
        ..fields['measure_id'] = _selectedUnit ?? ''
        ..fields['quantity'] = quantity.trim()
        ..fields['district_id'] = district
        ..fields['description'] = description.trim()
        ..fields['expected_supply_date'] = expectedSupplyDate
        ..fields['commodity_type_id'] = _selectedtype ?? '2';

      if (_selectedImage != null) {
        if (kIsWeb) {
          if (_selectedImageBytes != null) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'image',
                _selectedImageBytes!,
                filename: 'image.jpg',
              ),
            );
          }
        } else {
          final mimeSubtype = _getMimeType(_selectedImage!.path);
          if (mimeSubtype != null) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'image',
                _selectedImage!.path,
                contentType: MediaType('image', mimeSubtype),
              ),
            );
          } else {
            print('⚠️ Unsupported image format. Upload skipped.');
          }
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      setState(() {
        isLoadingSubmit = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (onSubmitted != null) {
          onSubmitted!(_selectedProduct, unitPrice);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_localizedText(
                'Successfully submitted supply!', 'Zatumizidwa bwino!')),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AllSupply()),
          );
        }
      } else {
        String errorMsg = 'Server status code: ${response.statusCode}';
        try {
          final parsedResponse = jsonDecode(response.body);
          errorMsg = _extractErrorMessage(parsedResponse, response.statusCode);
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMsg = response.body;
          }
        }
        if (mounted) {
          _showBilingualErrorDialog(context, errorMsg);
        }
      }
    } catch (e) {
      setState(() {
        isLoadingSubmit = false;
      });
      print('Error occurred: $e');
      if (mounted) {
        _showBilingualErrorDialog(
          context,
          'Network connection error / Vuto la Intaneti kapena kulumikizana: $e',
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_localizedText('Choose an option', 'Sankhani')),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text("Camera"),
                  onTap: () async {
                    if (kIsWeb) {
                      // Web does not support camera
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Camera is not supported on the web')),
                      );
                    } else {
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        setState(() {
                          _selectedImage = File(image.path);
                        });
                      }
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Gallery"),
                  onTap: () async {
                    if (kIsWeb) {
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        final Uint8List imageBytes = await image.readAsBytes();
                        setState(() {
                          _selectedImageBytes = imageBytes;
                        });
                      }
                    } else {
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _selectedImage = File(image.path);
                        });
                      }
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        expectedSupplyDate = pickedDate
            .toIso8601String(); // Format the date as you need (e.g., 'yyyy-MM-dd')
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? Center(
                child: Lottie.asset(
                  'assets/icons/loading1.json', // Replace with your Lottie file path
                  width: 100,
                  height: 100,
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    backgroundColor: Color.fromARGB(255, 42, 146, 42),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    expandedHeight: screenHeight * 0.18,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        _localizedText(
                            'Product Suppliers', 'Katundu Ogulitsidwa'),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      background: Image.network(
                        'https://oxfarm.co.ke/wp-content/uploads/2018/10/Fresh-produce.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(
                              text: _localizedText('Request Supplier',
                                  'Sakani Oti Akupedzeseni Katundu')),
                          Tab(
                              text: _localizedText('Products for Supplying',
                                  'Katundu Ogulisidwa')),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView(
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedProduct,
                                items: _products
                                    .map((product) => DropdownMenuItem<String>(
                                          value: product['id'].toString(),
                                          child: Text(product['name']),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProduct = value;
                                    productNameError = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: _localizedText('Product / Katundu', 'Katundu / Product'),
                                  errorText: productNameError,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    unitPrice = value;
                                    unitPriceError = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: _localizedText('Unit Price (MWK) / Mtengo wa Chinthu', 'Mtengo wa Chinthu / Unit Price'),
                                  errorText: unitPriceError,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16.0),
                              DropdownButtonFormField<String>(
                                value: _selectedUnit,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedUnit = newValue;
                                    unitError = null;
                                  });
                                },
                                items: _units.map((unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit['id'].toString(),
                                    child: Text(unit['name']),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText: _localizedText('Unit / Muyezo', 'Muyezo / Unit'),
                                  errorText: unitError,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    quantity = value;
                                    quantityError = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: _localizedText('Quantity / Kuchuluka', 'Kuchuluka / Quantity'),
                                  errorText: quantityError,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16.0),
                              DropdownButtonFormField<String>(
                                value: district.isNotEmpty ? district : null,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    district = newValue ?? '';
                                    districtError = null;
                                  });
                                },
                                items: _districts.map((district) {
                                  return DropdownMenuItem<String>(
                                    value: district['id'].toString(),
                                    child: Text(district['name']),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText: _localizedText('Select District / Sankhani Dera', 'Sankhani Dera / Select District'),
                                  errorText: districtError,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    description = value;
                                    descriptionError = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: _localizedText('Description / Kufotokozera', 'Kufotokozera / Description'),
                                  errorText: descriptionError,
                                ),
                                maxLines: null,
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                onTap: _pickDate,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: _localizedText('Expected Supply Date / Tsiku Lokonzekera Kupereka', 'Tsiku Lokonzekera Kupereka / Expected Supply Date'),
                                  hintText: expectedSupplyDate.isNotEmpty
                                      ? expectedSupplyDate
                                      : _localizedText('Pick a date / Sankhani tsiku', 'Sankhani tsiku / Pick a date'),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  _selectedImage != null
                                      ? Image.file(
                                          _selectedImage!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : const Text('No image selected'),
                                  ElevatedButton(
                                    onPressed: _pickImage,
                                    child: const Text('Pick Image'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32.0),
                              ElevatedButton(
                                onPressed: isLoadingSubmit ? null : submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                ),
                                child: isLoadingSubmit
                                    ? const CircularProgressIndicator()
                                    : Text(
                                        _localizedText('Submit', 'Tumizani'),
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Color.fromARGB(
                                              255, 235, 255, 234),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(.0),
                          child: Onsupply(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
