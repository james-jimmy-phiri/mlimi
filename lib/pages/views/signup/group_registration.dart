/*
  Flutter UI
  ----------
  lib/screens/simple_login.dart
*/

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/pages/product_request/homepage.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:mlimi/pages/views/signup/loginscreen.dart';
import 'package:mlimi/pages/views/signup/registration_tab_view.dart';

class GroupRegisterScreen extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (name, pin)
  final Function(String? name, String? pin)? onSubmitted;
  final bool embedded;

  const GroupRegisterScreen({this.onSubmitted, this.embedded = false, super.key});

  @override
  State<GroupRegisterScreen> createState() => _GroupRegisterScreenState();
}

class _GroupRegisterScreenState extends State<GroupRegisterScreen> with TickerProviderStateMixin {
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();
  final TextEditingController _epaController = TextEditingController();
  final TextEditingController _taController = TextEditingController();
  final TextEditingController _gvhController = TextEditingController();
  final TextEditingController _numMembersController = TextEditingController();
  final TextEditingController _chairPersonController = TextEditingController();
  final TextEditingController _mappingIdController = TextEditingController();
  List<TextEditingController> memberControllers = [TextEditingController()];

  final token = ''.obs;
  final box = GetStorage();
  late String name,
      phone,
      pin,
      confrirmPin,
      epa,
      ta,
      gvh,
      numMembers,
      chairPerson,
      mappingId,
      members;
  String? nameError,
      phoneError,
      districtError,
      pinError,
      epaError,
      taError,
      gvhError,
      numMembersError,
      chairPersonError,
      mappingIdError,
      membersError;
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
    epa = '';
    ta = '';
    gvh = '';
    numMembers = '';
    mappingId = '';
    chairPerson = '';
    members = '';

    nameError = null;
    phoneError = null;
    districtError = null;
    pinError = null;
    epaError = null;
    taError = null;
    gvhError = null;
    numMembersError = null;
    mappingIdError = null;
    chairPersonError = null;
    membersError = null;

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
      epaError = null;
      taError = null;
      gvhError = null;
      numMembersError = null;
      mappingIdError = null;
      chairPersonError = null;
      membersError = null;
    });
  }

  void addMemberField() {
    setState(() {
      memberControllers.add(TextEditingController());
    });
  }

  bool validate() {
    resetErrorText();
    bool isValid = true;

    final name = _nameController.text.trim();
    if (name.isEmpty || name.length < 3 || name.length > 64) {
      nameError = selectedLanguage == 'en'
          ? 'Group Name is required and must be 3 to 64 characters.'
          : 'Dzina La Guru ndilofunika';
    }

    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !RegExp(r'^(09|08)[0-9]{8}\$').hasMatch(phone)) {
      phoneError = selectedLanguage == 'en'
          ? 'Phone Number is invalid, must start with 08 or 09 and be 10 digits.'
          : 'Nambala Ya Foni siyolondola';
      isValid = false;
    }

    if (selectedDistrictId == null) {
      districtError = selectedLanguage == 'en'
          ? 'Please select a district'
          : 'Chonde sankhani dera';
      isValid = false;
    }

    final pin = _pinController.text;
    final confirm = _pinConfirmController.text;
    if (pin.length != 4 || pin != confirm) {
      pinError = selectedLanguage == 'en'
          ? 'PIN must be 4 digits and match confirmation.'
          : 'Chonde lowetsani PIN & Ma PIN sakufanana';
      isValid = false;
    }

    if (_epaController.text.trim().isEmpty) {
      epaError = 'Required';
      isValid = false;
    }
    if (_taController.text.trim().isEmpty) {
      taError = 'Required';
      isValid = false;
    }
    if (_gvhController.text.trim().isEmpty) {
      gvhError = 'Required';
      isValid = false;
    }
    if (_mappingIdController.text.trim().isEmpty) {
      mappingIdError = 'Required';
      isValid = false;
    }
    if (_chairPersonController.text.trim().isEmpty) {
      chairPersonError = 'Required';
      isValid = false;
    }
    final num = _numMembersController.text.trim();
    if (num.isEmpty || int.tryParse(num) == null) {
      numMembersError = 'Must be a number';
      isValid = false;
    }

    final members = memberControllers
        .map((c) => c.text.trim())
        .where((m) => m.isNotEmpty)
        .toList();
    if (members.isEmpty) {
      membersError = 'At least one member required';
      isValid = false;
    } else if (members.length != members.toSet().length) {
      membersError = 'Member names must be unique';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> submit() async {
    if (validate()) {
      showSnackBar('Please fill in all required fields correctly.');
      return;
    }

    final members = memberControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => c.text.trim())
        .toList();

    final payload = {
      'name': _nameController.text.trim(),
      'pin': _pinController.text,
      'pin_confirmation': _pinConfirmController.text,
      'district_id': selectedDistrictId,
      'phone': _phoneController.text.trim(),
      'type': 'group',
      'epa': _epaController.text.trim(),
      't_a': _taController.text.trim(),
      'gvh': _gvhController.text.trim(),
      'number_of_members': int.tryParse(_numMembersController.text) ?? 0,
      'chair_person': _chairPersonController.text.trim(),
      'mapping_id': _mappingIdController.text.trim(),
      'members': members,
    };

    debugPrint("Submitting Payload: ${jsonEncode(payload)}");
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${apiurl}v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      setState(() => isLoading = false);
      debugPrint("Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        GetStorage().write('token', data['token']);
        GetStorage().write('phone', payload['phone']);
        GetStorage().write('name', payload['name']);
        GetStorage().write('district', selectedDistrictId);

                // ✅ Save members list
        final members = data['client']['members'];
        GetStorage().write('members', members);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homepage()),
        );
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Registration failed.';
        showSnackBar(error);
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
      setState(() => isLoading = false);
      showSnackBar('Something went wrong. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final selectedLanguage = GetStorage().read('language') ?? 'en';

    if (isFetchingDistricts) {
      return widget.embedded
          ? Center(
              child: Lottie.asset(
                'assets/icons/loading1.json',
                width: 100,
                height: 100,
              ),
            )
          : Scaffold(
              body: Center(
              child: Lottie.asset(
                'assets/icons/loading1.json', // Replace with your Lottie file path
                width: 100,
                height: 100,
              ),
            ));
    }

    final pageContent = CustomScrollView(
        slivers: [
          // SliverPersistentHeader(
          //   delegate: CustomSilverHeader(),
          //   pinned: true,
          // ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * .01),
                  Text(
                    selectedLanguage == 'en'
                        ? 'Create Your Group Account'
                        : 'Pangani Akaunti',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * .005),
                  Text(
                    selectedLanguage == 'en'
                        ? 'Sign up as a Group, Cooparative or association to get started!'
                        : 'Lembetsani ngat Gulu, cooporative Kapena Association kuti muyambe!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(.6),
                    ),
                  ),
                  if (!widget.embedded)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegistrationTabView()),
                        );
                      },
                      child: Text(
                        'Registration (Tabs)',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  SizedBox(height: screenHeight * .05),
                  InputField(
                    controller: _nameController,
                    labelText: selectedLanguage == 'en'
                        ? 'Group Name'
                        : 'Dzina la Guru',
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
                        ? 'Group Phone Number '
                        : 'Nambala Ya Foni',
                    errorText: phoneError,
                    maxLength: 10,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: screenHeight * .025),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDistrictId,
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
                      labelText: 'EPA',
                      maxLength: 40,
                      errorText: epaError,
                      controller: _epaController),
                  InputField(
                      labelText: 'T/A',
                      maxLength: 40,
                      errorText: taError,
                      controller: _taController),
                  InputField(
                      labelText: 'GVH',
                      maxLength: 40,
                      errorText: gvhError,
                      controller: _gvhController),
                  InputField(
                      labelText: 'Number of Members',
                      errorText: numMembersError,
                      maxLength: 40,
                      controller: _numMembersController,
                      keyboardType: TextInputType.number),
                  InputField(
                      labelText: 'Chairperson',
                      errorText: chairPersonError,
                      maxLength: 40,
                      controller: _chairPersonController),
                  InputField(
                      labelText: 'Mapping ID',
                      errorText: mappingIdError,
                      maxLength: 40,
                      controller: _mappingIdController),
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
                    controller: _pinConfirmController,
                    onChanged: (value) {
                      setState(() {
                        confrirmPin = value;
                      });
                    },
                    onSubmitted: (value) => submit(),
                    labelText: selectedLanguage == 'en'
                        ? 'Confirm Pin'
                        : 'Vomelezani Pin',
                    errorText: pinError,
                    obscureText: true,
                    maxLength: 4,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(
                    height: screenHeight * .050,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Members'),
                      TextButton(
                        onPressed: addMemberField,
                        child: const Text('Add Member'),
                      ),
                    ],
                  ),
                  ...memberControllers
                      .asMap()
                      .entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InputField(
                              labelText: 'Member ${entry.key + 1}',
                              maxLength: 40,
                              controller: entry.value,
                            ),
                          ))
                      .toList(),
                  if (membersError != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(membersError!,
                            style: TextStyle(color: Colors.red))),
                  const SizedBox(height: 20),
                  isLoading
                      ? Center(
                          child: Lottie.asset(
                            'assets/icons/loading1.json', // Replace with your Lottie file path
                            width: 80,
                            height: 80,
                          ),
                        )
                      : FormButton(
                          text: selectedLanguage == 'en'
                              ? 'Sign Up'
                              : 'Lembetsani',
                          onPressed: submit,
                        ),
                  if (!widget.embedded)
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
                              text: selectedLanguage == 'en'
                                  ? 'Sign In'
                                  : ' Lowani',
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
          )
        ],
      );

    if (widget.embedded) {
      return pageContent;
    }

    return Scaffold(
      backgroundColor: Bgreen,
      body: pageContent,
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

// class CustomSilverHeader extends SliverPersistentHeaderDelegate {
//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return ClipPath(
//       clipper: AsymmetricClipper(),
//       child: Container(
//         height: maxExtent,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/group.jpg'),
//             fit: BoxFit.cover,
//           ),
//           color: Colors.green[300],
//         ),
//         alignment: Alignment.centerLeft,
//         padding: EdgeInsets.only(left: 30),
//         child: Text(
//           'Group Registration',
//           style: TextStyle(
//             fontSize: 28,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   double get maxExtent => 250;
//   @override
//   double get minExtent => 80;
//   @override
//   bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
// }

class AsymmetricClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height); // bottom left
    path.lineTo(size.width, size.height * 0.8); // lower on right
    path.lineTo(size.width, 0); // top right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
