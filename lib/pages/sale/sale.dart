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
import 'package:mlimi/pages/sale/groupSale.dart';

class SalePage extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (productName, unitPrice)
  final Function(String? productName, String? unitPrice)? onSubmitted;

  const SalePage({this.onSubmitted, super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  late String unitPrice, quantity, description, expectedSupplyDate;
  String? productNameError, unitPriceError, quantityError, descriptionError;
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
            return {'id': item['id'], 'name': item['name']};
          }).toList();
          if (_products.isNotEmpty) {
            _selectedProduct = _products[0]['id'];
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

  void resetErrorText() {
    setState(() {
      productNameError = null;
      unitPriceError = null;
      descriptionError = null;
      quantityError = null;
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


  bool validate() {
    resetErrorText();

    bool isValid = true;

    if (unitPrice.isEmpty) {
      setState(() {
        unitPriceError = 'Please enter a unit price';
      });
      isValid = false;
    }
    if (description.isEmpty) {
      setState(() {
        descriptionError = 'Please enter a product description';
      });
      isValid = false;
    }
    if (quantity.isEmpty) {
      setState(() {
        quantityError = 'Please enter Quatity';
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> submit() async {
    if (validate()) {
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
          ..fields['unit_price'] = unitPrice
          ..fields['measure_id'] = _selectedUnit ?? ''
          ..fields['quantity'] = quantity
          ..fields['district_id'] = selectedDistrictId!
          ..fields['description'] = description
          ..fields['expected_supply_date'] = expectedSupplyDate
          ..fields['commodity_type_id'] = _selectedtype ?? '';

        if (_selectedImage != null) {
          if (kIsWeb) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'image', // The field name for the image in the backend
                _selectedImageBytes!,
                filename: 'image.jpg', // You can set a filename for the image
              ),
            );
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

        var response = await request.send();

        setState(() {
          isLoadingSubmit = false;
        });

        if (response.statusCode == 201) {
          if (onSubmitted != null) {
            onSubmitted!(_selectedProduct, unitPrice);
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Buy()),
          );
        } else {
          var responseBody = await response.stream.bytesToString();
          print('Response Body: $responseBody');
          // Handle error response
          var parsedResponse = jsonDecode(responseBody);
          print('parsedResponse: $parsedResponse');
        }
      } catch (e) {
        setState(() {
          isLoadingSubmit = false;
        });
        // Print the error to console
        print('Error occurred: $e');
        // Optionally show an error dialog or a Snackbar to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } else {
      print(
          "failed to validate $_selectedProduct $_selectedUnit $_selectedtype $unitPrice $description $quantity ");
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
    const decocolor = Color.fromARGB(255, 3, 81, 0);

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
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const GroupSalePage()),
                                  );
                                },
                                child: Text(
                                  'Sell Group aggregated Products',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Form(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        labelText: 'Product Name',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: decocolor,
                                        ),
                                      ),
                                      initialValue: _selectedProduct,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedProduct = newValue;
                                        });
                                      },
                                      items: _products.map((product) {
                                        return DropdownMenuItem<String>(
                                          value: product['id'],
                                          child: Text(product['name']),
                                        );
                                      }).toList(),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a product';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          unitPrice = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Unit Price',
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
                                      decoration: const InputDecoration(
                                        labelText: 'Unit',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: decocolor,
                                        ),
                                      ),
                                      initialValue: _selectedUnit,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedUnit = newValue;
                                        });
                                      },
                                      items: measures.map((measure) {
                                        return DropdownMenuItem<String>(
                                          value: measure['id'],
                                          child: Text(measure['name']),
                                        );
                                      }).toList(),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a Measurement';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          quantity = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Quantity',
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
                                      decoration: const InputDecoration(
                                        labelText: 'Select District',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: decocolor,
                                        ),
                                      ),
                                      initialValue: selectedDistrictId,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDistrictId = value;
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a District';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          description = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Product Description',
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
                                                    'Add Image',
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
