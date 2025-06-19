import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/models/products_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:mlimi/constants/url.dart';

class ProductEditPage extends StatefulWidget {
  final Product product;

  const ProductEditPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductEditPageState createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _location;
  late String _measure;
  late String _unitPrice; // Changed type to String for form input
  late String _quantity; // Changed type to String for form input
  File? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _description = widget.product.description;
    _location = widget.product.location;
    _measure = widget.product.measure;
    _unitPrice =
        widget.product.unitPrice.toString(); // Convert initial value to String
    _quantity =
        widget.product.quantity.toString(); // Convert initial value to String
    _image = null; // Assuming the initial image is not stored as a File
  }

  Future<void> _chooseImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final storage = GetStorage();
      String? token = storage.read('token');
      final url = Uri.parse('${apiurl}v1/commodities/${widget.product.id}');

      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });
      request.fields['name'] = _name;
      request.fields['description'] = _description;
      request.fields['location'] = _location;
      request.fields['measure'] = _measure;
      request.fields['price'] = _unitPrice;
      request.fields['quantity'] = _quantity;

      if (_image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product updated successfully')),
          );
          Navigator.of(context).pop(); // Go back to the previous page
        } else {
          throw Exception('Failed to update product');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                initialValue: _location,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product location';
                  }
                  return null;
                },
                onSaved: (value) {
                  _location = value!;
                },
              ),
              TextFormField(
                initialValue: _measure,
                decoration: InputDecoration(labelText: 'Measure'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product measure';
                  }
                  return null;
                },
                onSaved: (value) {
                  _measure = value!;
                },
              ),
              TextFormField(
                initialValue: _unitPrice,
                decoration: InputDecoration(labelText: 'Unit Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product unit price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _unitPrice = value!;
                },
              ),
              TextFormField(
                initialValue: _quantity,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _quantity = value!;
                },
              ),
              SizedBox(height: 20),
              _image != null ? Image.file(_image!) : Text('No image selected.'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _chooseImage,
                child: Text('Choose Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
