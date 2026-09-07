import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:mlimi/pages/Buy/buy.dart';
import 'package:mlimi/constants/url.dart';
import 'package:flutter/foundation.dart';


class SalePage extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (productName, unitPrice)
  final Function(String? productName, String? unitPrice)? onSubmitted;

  const SalePage({this.onSubmitted, super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  static const decocolor = Color.fromARGB(255, 3, 81, 0);
  late String unitPrice, quantity, description, expectedSupplyDate;
  Function(String? productName, String? unitPrice)? get onSubmitted =>
      widget.onSubmitted;

  _SalePageState() {
    _selectedtype = _types[0];
  }

  final _types = ["1", "2"];
  String? _selectedUnit;
  String? _selectedtype;
  String? _selectedProduct;
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // For web
  List<Map<String, dynamic>> _products = [];
  bool isFetchingDistricts = true;
  List<dynamic> districts = [];
  List<dynamic> measures = [];
  String? selectedDistrictId;
  bool _isLoading = true;
  bool isLoadingSubmit = false;

  @override
  void initState() {
    super.initState();
    unitPrice = '';
    description = '';
    quantity = '';

    expectedSupplyDate = '';

    productNameError = null;
    unitPriceError = null;
    descriptionError = null;
    quantityError = null;

    _fetchProducts();
    fetchDistricts();
    fetchMeasures();
  }

  Future<void> fetchDistricts() async {
    var url = Uri.parse('${apiurl}v1/districts');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          districts = jsonDecode(response.body)['districts'];
          isFetchingDistricts = false;
        });
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      print('Error occurred while fetching districts: $e');
      setState(() {
        isFetchingDistricts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load districts. Please try again.')),
      );
    }
  }

  Future<void> fetchMeasures() async {
    setState(() {
      _isLoading = true;
    });
    var url = Uri.parse('${apiurl}v1/measures');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          measures = jsonDecode(response.body)['measures'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load Measures');
      }
    } catch (e) {
      print('Error occurred while fetching districts: $e');
      setState(() {
        isFetchingDistricts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load Measures. Please try again.')),
      );
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
          'Accept': 'application/json'
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

  String? productNameError, unitPriceError, quantityError, descriptionError, districtError, unitError;

  void resetErrorText() {
    setState(() {
      productNameError = null;
      unitPriceError = null;
      descriptionError = null;
      quantityError = null;
      districtError = null;
      unitError = null;
    });
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
    return 'Server returned error code $statusCode / Seva yabweza zolakwika $statusCode';
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
                'Could not submit form due to the following issue:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Text(
                'Sikwatheka kutumiza fomu chifukwa cha vuto ili:',
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
              backgroundColor: decocolor,
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
        productNameError = 'Please select a product / Chonde sankhani chinthu';
      });
      isValid = false;
    }
    if (unitPrice.trim().isEmpty) {
      setState(() {
        unitPriceError = 'Please enter a unit price / Chonde lowetsani mtengo wa chinthu';
      });
      isValid = false;
    }
    if (_selectedUnit == null || _selectedUnit!.trim().isEmpty) {
      setState(() {
        unitError = 'Please select a unit / Chonde sankhani muyezo';
      });
      isValid = false;
    }
    if (quantity.trim().isEmpty) {
      setState(() {
        quantityError = 'Please enter quantity / Chonde lowetsani kuchuluka';
      });
      isValid = false;
    }
    if (selectedDistrictId == null || selectedDistrictId!.trim().isEmpty) {
      setState(() {
        districtError = 'Please select a district / Chonde sankhani boma';
      });
      isValid = false;
    }
    if (description.trim().isEmpty) {
      setState(() {
        descriptionError = 'Please enter product description / Chonde fotokozani katundu';
      });
      isValid = false;
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields / Chonde dzazani mindandanda yonse yofunika'),
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
        ..fields['district_id'] = selectedDistrictId ?? ''
        ..fields['description'] = description.trim()
        ..fields['expected_supply_date'] = expectedSupplyDate
        ..fields['commodity_type_id'] = _selectedtype ?? '1';

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
          const SnackBar(
            content: Text('Successfully submitted! / Zatumizidwa bwino!'),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Buy()),
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
          title: const Text("Choose an option"),
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
            .toIso8601String()
            .split('T')[0]; // Format the date to 'yyyy-MM-dd'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                  backgroundColor: Color.fromARGB(255, 3, 81, 0),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: const Color.fromARGB(255, 235, 255, 234),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  pinned: true,
                  snap: true,
                  floating: true,
                  expandedHeight: screenHeight * 0.18,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: const Text(
                      'Sale Products',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: Color.fromARGB(255, 235, 255, 234),
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/sell.jpg', // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              
                              Form(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Product Name / Dzina la Katundu',
                                        labelStyle: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: decocolor,
                                        ),
                                        errorText: productNameError,
                                      ),
                                      value: _selectedProduct,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedProduct = newValue;
                                          productNameError = null;
                                        });
                                      },
                                      items: _products.map((product) {
                                        return DropdownMenuItem<String>(
                                          value: product['id']?.toString(),
                                          child: Text(product['name'] ?? ''),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          unitPrice = value;
                                          unitPriceError = null;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Unit Price (MWK) / Mtengo wa Chinthu',
                                        labelStyle: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: decocolor,
                                        ),
                                        errorText: unitPriceError,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Unit / Muyezo',
                                        labelStyle: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: decocolor,
                                        ),
                                        errorText: unitError,
                                      ),
                                      value: _selectedUnit,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedUnit = newValue;
                                          unitError = null;
                                        });
                                      },
                                      items: measures.map((measure) {
                                        return DropdownMenuItem<String>(
                                          value: measure['id'].toString(),
                                          child: Text(measure['name']),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          quantity = value;
                                          quantityError = null;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Quantity / Kuchuluka',
                                        labelStyle: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: decocolor,
                                        ),
                                        errorText: quantityError,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Select District / Sankhani Boma',
                                        labelStyle: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: decocolor,
                                        ),
                                        errorText: districtError,
                                      ),
                                      value: selectedDistrictId,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDistrictId = value;
                                          districtError = null;
                                        });
                                      },
                                      items: districts
                                          .map<DropdownMenuItem<String>>(
                                              (district) {
                                        return DropdownMenuItem<String>(
                                          value: district['id'].toString(),
                                          child: Text(district['name']),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          description = value;
                                          descriptionError = null;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Product Description / Kufotokozera Katundu',
                                        labelStyle: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: decocolor,
                                        ),
                                        errorText: descriptionError,
                                      ),
                                      maxLines:
                                          null, // This makes the text field grow vertically
                                      keyboardType: TextInputType.multiline,
                                    ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: InkWell(
                                        onTap: _pickImage,
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 70,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  offset: Offset(0, 2),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: const Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_a_photo,
                                                    color: Colors.blue,
                                                    size: 35,
                                                  ),
                                                  Text(
                                                    'Add Image / Ikani Chithunzi',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_selectedImage != null ||
                                        _selectedImageBytes != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: kIsWeb
                                            ? Image.memory(
                                                _selectedImageBytes!,
                                                height: 150,
                                              )
                                            : Image.file(
                                                _selectedImage!,
                                                height: 150,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed:
                                          isLoadingSubmit ? null : submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: decocolor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                      ),
                                      child: isLoadingSubmit
                                          ? const CircularProgressIndicator()
                                          : const Text(
                                              'Submit',
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
