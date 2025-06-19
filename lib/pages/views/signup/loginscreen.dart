/*
  Flutter UI
  ----------
  lib/screens/simple_login.dart
*/

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/pages/product_request/homepage.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:mlimi/pages/views/signup/group_registration.dart';

class SimpleLoginScreen extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (name, pin)
  final Function(String? phone, String? pin)? onSubmitted;

  const SimpleLoginScreen({this.onSubmitted, super.key});
  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  late String phone, pin;
  String? phoneError, pinError;
  Function(String? name, String? pin)? get onSubmitted => widget.onSubmitted;
  bool isLoading = false;
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    loadLanguagePreference();
    phone = '';
    pin = '';

    phoneError = null;
    pinError = null;
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
      pinError = null;
    });
  }

  bool validate() {
    resetErrorText();

    bool isValid = true;
    if (phone.isEmpty || !RegExp(r'^(09|08)[0-9]{8}$').hasMatch(phone)) {
      setState(() {
        phoneError = selectedLanguage == 'en'
            ? 'Phone Number is invalid'
            : 'Mwalakwisa Nambala';
      });
      isValid = false;
    }

    if (pin.isEmpty) {
      setState(() {
        pinError = selectedLanguage == 'en'
            ? 'Please Enter your Pin'
            : 'Lowesani Nambala Yachinsinsi';
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> submit() async {
    if (validate()) {
      setState(() {
        isLoading = true;
      });

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

        // Print the response headers
        print('Response Headers: ${response.headers}');

        // Print the response body
        print('Response Body: ${response.body}');

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          var token = jsonDecode(response.body)['token'];
          var client = jsonDecode(response.body)['client'];

          // Store user details
          GetStorage().write('token', token);
          GetStorage().write('phone', phone);
          GetStorage().write('name', client['name']);
          GetStorage().write('district', client['district']);
          print('Stored name: ${client['name']}');
          print('Stored district: ${client['district']}');

          // Handle successful response
          if (onSubmitted != null) {
            onSubmitted!(phone, pin);
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage()),
          );
        } else {
          // Handle error response
          var responseBody = jsonDecode(response.body);
          String errorMessage =
              responseBody['message'] ?? 'An error occurred. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          setState(() {
            phoneError = responseBody['errors']['phone']?.join(', ');
            pinError = responseBody['errors']['pin']?.join(', ');
          });
          throw Exception(
              'Failed to log in. Status code: ${response.statusCode}');
        }
      } on SocketException catch (_) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No Internet connection. Please try again.')),
        );
      } on FormatException catch (_) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bad response format. Please try again.')),
        );
      } on HttpException catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: $e')),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        // Print the error to console
        print('Error occurred: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
        rethrow; // Optionally rethrow the exception if you need it for further handling
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final selectedLanguage = GetStorage().read('language') ?? 'en';

    return Scaffold(
      backgroundColor: Bgreen,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: screenHeight * .05),
            const Text(
              ' ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * .01),
            Text(
              selectedLanguage == 'en'
                  ? 'Sign in to continue!'
                  : ' Lowani kuti mupitirize!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withOpacity(.6),
              ),
            ),
            Center(
              child: Lottie.asset('assets/icons/login.json', width: 150),
            ),
            SizedBox(height: screenHeight * .06),
            InputField(
              controller: _phoneController,
              onChanged: (value) {
                setState(() {
                  phone = value;
                });
              },
              labelText: selectedLanguage == 'en'
                  ? 'Phone Number '
                  : 'Nambala Ya Foni',
              errorText: phoneError,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autoFocus: true,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              controller: _pinController,
              onChanged: (value) {
                setState(() {
                  pin = value;
                });
              },
              onSubmitted: (val) => submit(),
              labelText: selectedLanguage == 'en' ? 'Pin' : 'Pin',
              errorText: pinError,
              obscureText: true,
              maxLength: 4,
              textInputAction: TextInputAction.next,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  selectedLanguage == 'en' ? 'Forgot Pin? ' : 'Mwayiwala Pin?',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * .055,
            ),
            isLoading
                ? Center(
                    child: Lottie.asset(
                      'assets/icons/loading1.json', // Replace with your Lottie file path
                      width: 80,
                      height: 80,
                    ),
                  )
                : FormButton(
                    text: selectedLanguage == 'en' ? 'Log In' : 'Lowani',
                    onPressed: submit,
                  ),
            SizedBox(
              height: screenHeight * .15,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SimpleRegisterScreen(),
                ),
              ),
              child: RichText(
                text: TextSpan(
                  text: selectedLanguage == 'en'
                      ? 'I am a new user'
                      : 'Ndine wogwiritsa ntchito watsopano',
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: selectedLanguage == 'en' ? 'Sign Up' : 'Lembetsani',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SimpleRegisterScreen extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (name, pin)
  final Function(String? name, String? pin)? onSubmitted;

  const SimpleRegisterScreen({this.onSubmitted, super.key});

  @override
  State<SimpleRegisterScreen> createState() => _SimpleRegisterScreenState();
}

class _SimpleRegisterScreenState extends State<SimpleRegisterScreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinconfirmController = TextEditingController();

  final token = ''.obs;
  final box = GetStorage();
  late String name, phone, pin, confrirmPin;
  String? nameError, phoneError, districtError, pinError;
  bool isLoading = false;
  bool isFetchingDistricts = true;
  List<dynamic> districts = [];
  String? selectedDistrictId;
  String selectedLanguage = 'en';

  Function(String? name, String? pin)? get onSubmitted => widget.onSubmitted;

  @override
  void initState() {
    super.initState();
    name = '';
    phone = '';
    pin = '';
    confrirmPin = '';

    nameError = null;
    phoneError = null;
    districtError = null;
    pinError = null;
    loadLanguagePreference();
    fetchDistricts();
  }

  Future<void> loadLanguagePreference() async {
    final box = GetStorage();
    setState(() {
      selectedLanguage = box.read('language') ?? 'en';
    });
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
        showSnackBar('Failed to load districts. Please try again.');
        setState(() => isFetchingDistricts = false);
      }
    } catch (e) {
      showSnackBar('An error occurred while fetching districts.');
      setState(() => isFetchingDistricts = false);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void resetErrorText() {
    setState(() {
      nameError = null;
      phoneError = null;
      districtError = null;
      pinError = null;
    });
  }

  bool validate() {
    resetErrorText();

    bool isValid = true;
    if (name.isEmpty) {
      setState(() {
        nameError = selectedLanguage == 'en'
            ? 'Full Name is required'
            : 'Dzina Lonse ndilofunika';
      });
      isValid = false;
    }
    if (phone.isEmpty || !RegExp(r'^(09|08)[0-9]{8}$').hasMatch(phone)) {
      setState(() {
        phoneError = selectedLanguage == 'en'
            ? 'Phone Number is invalid'
            : 'Nambala Ya Foni siyolondola';
      });
      isValid = false;
    }
    if (selectedDistrictId == null) {
      setState(() {
        districtError = selectedLanguage == 'en'
            ? 'Please select a district'
            : 'Chonde sankhani dera';
      });
      isValid = false;
    }
    if (pin.isEmpty || confrirmPin.isEmpty) {
      setState(() {
        pinError = selectedLanguage == 'en'
            ? 'PINs do not match'
            : 'Ma PIN sakufanana';
      });
      isValid = false;
    } else if (pin != confrirmPin) {
      setState(() {
        pinError = selectedLanguage == 'en'
            ? 'Please enter a PIN'
            : 'Chonde lowetsani PIN';
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> submit() async {
    if (validate()) {
      setState(() {
        isLoading = true;
      });

      var url = Uri.parse('${apiurl}v1/auth/register');
      try {
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'phone': phone,
            'district_id': selectedDistrictId,
            'pin': pin,
            'pin_confirmation': confrirmPin,
          }),
        );

        print('Response Headers: ${response.headers}');
        print('Response Body: ${response.body}');

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          var token = jsonDecode(response.body)['token'];
          var client = jsonDecode(response.body)['client'];

          GetStorage().write('token', token);
          GetStorage().write('phone', phone);
          GetStorage().write('name', client['name']);
          GetStorage().write('district', client['district']);

          if (onSubmitted != null) {
            onSubmitted!(name, pin);
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage()),
          );
        }
        if (response.statusCode == 422) {
          var responseBody = jsonDecode(response.body);
          String errorMessage =
              responseBody['message'] ?? selectedLanguage == 'en'
                  ? 'This phone has already been taken '
                  : 'Nambala iyi ya foni yapezeka kale';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          setState(() {
            nameError = responseBody['errors']['name']?.join(', ');
            phoneError = responseBody['errors']['phone']?.join(', ');
            districtError = responseBody['errors']['district_id']?.join(', ');
            pinError = responseBody['errors']['pin']?.join(', ');
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error occurred: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final selectedLanguage = GetStorage().read('language') ?? 'en';

    if (isFetchingDistricts) {
      return Scaffold(
          backgroundColor: Bgreen,
          body: Center(
            child: Lottie.asset(
              'assets/icons/loading1.json', // Replace with your Lottie file path
              width: 100,
              height: 100,
            ),
          ));
    }

    return Scaffold(
      backgroundColor: Bgreen,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: screenHeight * .06),
            Text(
              selectedLanguage == 'en' ? 'Create Account' : 'Pangani Akaunti',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * .01),
            Text(
              selectedLanguage == 'en'
                  ? 'Sign up to get started!'
                  : 'Lembetsani kuti muyambe!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withOpacity(.6),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GroupRegisterScreen()),
                );
              },
              child: Text(
                'Register as a Group',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Lottie.asset('assets/icons/signup.json', width: 120),
            ),
            SizedBox(height: screenHeight * .001),
            InputField(
              controller: _fullnameController,
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              labelText: selectedLanguage == 'en' ? 'Full Name' : 'Dzina Lonse',
              errorText: nameError,
              maxLength: 40,
              textInputAction: TextInputAction.next,
              autoFocus: true,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              controller: _phoneController,
              onChanged: (value) {
                setState(() {
                  phone = value;
                });
              },
              labelText: selectedLanguage == 'en'
                  ? 'Phone Number '
                  : 'Nambala Ya Foni',
              errorText: phoneError,
              maxLength: 10,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: screenHeight * .025),
            DropdownButtonFormField<String>(
              value: selectedDistrictId,
              onChanged: (value) {
                setState(() {
                  selectedDistrictId = value;
                });
              },
              items: districts.map<DropdownMenuItem<String>>((district) {
                return DropdownMenuItem<String>(
                  value: district['id'].toString(),
                  child: Text(district['name']),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: selectedLanguage == 'en'
                    ? 'Select District'
                    : 'Sankhani Dera',
                errorText: districtError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              controller: _pinController,
              onChanged: (value) {
                setState(() {
                  pin = value;
                });
              },
              labelText: selectedLanguage == 'en' ? 'Pin' : 'Pin',
              errorText: pinError,
              obscureText: true,
              maxLength: 4,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              controller: _pinconfirmController,
              onChanged: (value) {
                setState(() {
                  confrirmPin = value;
                });
              },
              onSubmitted: (value) => submit(),
              labelText:
                  selectedLanguage == 'en' ? 'Confirm Pin' : 'Vomelezani Pin',
              errorText: pinError,
              obscureText: true,
              maxLength: 4,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(
              height: screenHeight * .050,
            ),
            isLoading
                ? Center(
                    child: Lottie.asset(
                      'assets/icons/loading1.json', // Replace with your Lottie file path
                      width: 80,
                      height: 80,
                    ),
                  )
                : FormButton(
                    text: selectedLanguage == 'en' ? 'Sign Up' : 'Lembetsani',
                    onPressed: submit,
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
                      ? 'I am already a member'
                      : ' Ndine membala kale',
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: selectedLanguage == 'en' ? 'Sign In' : ' Lowani',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FormButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  const FormButton({this.text = '', this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: onPressed as void Function()?,
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
  final Function(String)? onSubmitted;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextEditingController controller;
  final bool autoFocus;
  final bool obscureText;
  final int maxLength;
  const InputField(
      {this.labelText,
      this.onChanged,
      this.onSubmitted,
      this.errorText,
      this.keyboardType,
      this.textInputAction,
      this.autoFocus = false,
      this.obscureText = false,
      required this.controller,
      required this.maxLength,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autoFocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
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
