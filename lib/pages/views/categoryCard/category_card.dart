import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/category.dart';
import 'package:mlimi/pages/views/featured_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:http/http.dart' as http;

class CategoryCard extends StatefulWidget {
  final Category_featured category;
  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final box = GetStorage();
  String _language = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    _language = box.read('language') ?? 'en'; // Retrieve stored language
  }

  String getLocalizedText(String enText, String nyText) {
    return _language == 'ny' ? nyText : enText;
  }

  void _showLoginDialog(BuildContext context, Widget targetPage) {
    String? storedPhone = box.read('phone');
    bool isPhoneValid = storedPhone != null &&
        storedPhone.isNotEmpty &&
        storedPhone.length == 10;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.custom,
      barrierDismissible: true,
      confirmBtnText: getLocalizedText('Login', 'Lowani'),
      customAsset: 'assets/images/loginfarmer.jpg',
      widget: Column(
        children: [
          Text(
            isPhoneValid
                ? getLocalizedText('Enter Your Pin', 'Lowetsani Pin Yanu')
                : getLocalizedText(
                    'Login To Proceed', 'Lowani Kuti Mupitirize'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 10,
          ),
          if (!isPhoneValid)
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                hintText: getLocalizedText(
                    'Enter Phone Number', 'Lowetsani Nambala Ya Foni'),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
            ),
          TextFormField(
            controller: _pinController,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              hintText: getLocalizedText('Enter Pin', 'Lowetsani Pin'),
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
      onConfirmBtnTap: () async {
        String phone = isPhoneValid ? storedPhone! : _phoneController.text;
        bool success = await _login(context, phone, _pinController.text);
        if (success) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        }
      },
    );
  }

  Future<bool> _login(BuildContext context, String phone, String pin) async {
    var url = Uri.parse('${apiurl}v1/auth/login');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'pin': pin,
        }),
      );

      if (response.statusCode == 200) {
        var token = jsonDecode(response.body)['token'];
        GetStorage().write('token', token);
        GetStorage()
            .write('phone', phone); // Store phone number if login is successful
        return true;
      } else {
        var responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            responseBody['message'] ??
                getLocalizedText('Login failed', 'Lowani zalephereka'),
          )),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(getLocalizedText(
                'An error occurred. Please try again.',
                'Cholakwika chinachitika. Chonde yesaninso.'))),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (['SalePage', 'Wallet', 'SupplyPage']
            .contains(widget.category.targetPage.runtimeType.toString())) {
          _showLoginDialog(context, widget.category.targetPage);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => widget.category.targetPage,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryLight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                getIconDataFromString(widget.category.thumbnail),
                color: Colors.white,
              ),
            ),
          ),
          Text(
            widget.category.name,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
