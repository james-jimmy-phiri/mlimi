import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/pages/product_request/homepage.dart';

class SimpleResetScreen extends StatefulWidget {
  const SimpleResetScreen({super.key});

  @override
  State<SimpleResetScreen> createState() => _SimpleResetScreenState();
}

class _SimpleResetScreenState extends State<SimpleResetScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  String phone = '';
  String newPin = '';
  String confirmPin = '';
  String? phoneError;
  String? newPinError;
  String? confirmPinError;
  bool isLoading = false;
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    loadLanguagePreference();
  }

  Future<void> loadLanguagePreference() async {
    final box = GetStorage();
    setState(() {
      selectedLanguage = box.read('language') ?? 'en';
    });
  }

  void resetErrorText() {
    setState(() {
      phoneError = null;
      newPinError = null;
      confirmPinError = null;
    });
  }

  bool validate() {
    resetErrorText();

    bool isValid = true;
    if (phone.isEmpty || !RegExp(r'^(09|08)[0-9]{8}\$').hasMatch(phone)) {
      setState(() {
        phoneError = selectedLanguage == 'en'
            ? 'Phone Number is invalid'
            : 'Mwalakwisa Nambala';
      });
      isValid = false;
    }

    if (newPin.isEmpty) {
      setState(() {
        newPinError = selectedLanguage == 'en'
            ? 'Please enter your new PIN'
            : 'Lowetsani PIN yatsopano';
      });
      isValid = false;
    }

    if (confirmPin != newPin) {
      setState(() {
        confirmPinError = selectedLanguage == 'en'
            ? 'PINs do not match'
            : 'Manambala sakugwirizana';
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> submit() async {
    if (validate()) {
      setState(() => isLoading = true);

      final url = Uri.parse('${apiurl}v1/auth/reset-pin');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone': phone,
            'new_pin': newPin,
            'new_pin_confirmation': confirmPin,
          }),
        );

        setState(() => isLoading = false);

        final responseBody = jsonDecode(response.body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Successful')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Homepage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseBody['message'] ?? 'An error occurred.')),
          );
          setState(() {
            phoneError = responseBody['errors']?['phone']?.join(', ');
            newPinError = responseBody['errors']?['new_pin']?.join(', ');
            confirmPinError =
                responseBody['errors']?['new_pin_confirmation']?.join(', ');
          });
        }
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
        print('Error: \$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Bgreen,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: screenHeight * .05),
            Text(
              selectedLanguage == 'en'
                  ? 'Reset Your PIN'
                  : 'Bwezerani PIN yanu',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * .01),
            Text(
              selectedLanguage == 'en'
                  ? 'Enter your details to reset your PIN'
                  : 'Lowetsani zambiri kuti mubwezeretse PIN',
              style:
                  TextStyle(fontSize: 18, color: Colors.black.withOpacity(.6)),
            ),
            Center(
              child: Lottie.asset('assets/icons/login.json', width: 150),
            ),
            SizedBox(height: screenHeight * .06),
            InputField(
              controller: _phoneController,
              onChanged: (val) => setState(() => phone = val),
              labelText:
                  selectedLanguage == 'en' ? 'Phone Number' : 'Nambala ya foni',
              errorText: phoneError,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autoFocus: true,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              controller: _newPinController,
              onChanged: (val) => setState(() => newPin = val),
              labelText: selectedLanguage == 'en' ? 'New PIN' : 'PIN yatsopano',
              errorText: newPinError,
              obscureText: true,
              maxLength: 4,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              controller: _confirmPinController,
              onChanged: (val) => setState(() => confirmPin = val),
              labelText:
                  selectedLanguage == 'en' ? 'Confirm PIN' : 'Tsimikizani PIN',
              errorText: confirmPinError,
              obscureText: true,
              maxLength: 4,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: screenHeight * .055),
            isLoading
                ? Center(
                    child: Lottie.asset('assets/icons/loading1.json',
                        width: 80, height: 80),
                  )
                : FormButton(
                    text: selectedLanguage == 'en'
                        ? 'Reset PIN'
                        : 'Bwezerani PIN',
                    onPressed: submit,
                  ),
          ],
        ),
      ),
    );
  }
}

class FormButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const FormButton({this.text = '', this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        padding: EdgeInsets.symmetric(vertical: screenHeight * .02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String? labelText;
  final Function(String)? onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextEditingController controller;
  final bool autoFocus;
  final bool obscureText;
  final int maxLength;

  const InputField({
    this.labelText,
    this.onChanged,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autoFocus = false,
    this.obscureText = false,
    required this.controller,
    required this.maxLength,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autoFocus,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
