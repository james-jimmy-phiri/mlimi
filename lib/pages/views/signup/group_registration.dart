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
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _maleMembersController = TextEditingController();
  final TextEditingController _femaleMembersController = TextEditingController();

  List<Map<String, dynamic>> membersList = [];

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
      projectName,
      maleMembers,
      femaleMembers;
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
      projectNameError,
      maleMembersError,
      femaleMembersError,
      membersError;
  bool isLoading = false;
  
  bool isFetchingDistricts = true;
  List<dynamic> districts = [];
  String? selectedDistrictId;
  
  bool isFetchingValueChains = true;
  List<dynamic> valueChains = [];
  List<String> selectedGroupValueChains = [];
  
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
    projectName = '';
    maleMembers = '';
    femaleMembers = '';

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
    projectNameError = null;
    maleMembersError = null;
    femaleMembersError = null;
    membersError = null;

    loadLanguagePreference();
    fetchDistricts();
    fetchValueChains();
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
          districts = jsonDecode(response.body)['districts'] ?? [];
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

  Future<void> fetchValueChains() async {
    var url = Uri.parse('${apiurl}v1/value-chains');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            var decoded = jsonDecode(response.body);
            if (decoded is List) {
              valueChains = decoded;
            } else if (decoded is Map && decoded.containsKey('value_chains')) {
              valueChains = decoded['value_chains'];
            } else if (decoded is Map && decoded.containsKey('data')) {
              valueChains = decoded['data'];
            }
            isFetchingValueChains = false;
          });
        }
      } else {
        if (mounted) setState(() => isFetchingValueChains = false);
      }
    } catch (e) {
      if (mounted) setState(() => isFetchingValueChains = false);
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
      projectNameError = null;
      maleMembersError = null;
      femaleMembersError = null;
      membersError = null;
    });
  }

  void showAddMemberModal({int? editIndex}) {
    String mName = editIndex != null ? membersList[editIndex]['name'] : '';
    String? mGender = editIndex != null ? membersList[editIndex]['gender'] : null;
    String? mAgeRange = editIndex != null ? membersList[editIndex]['age_range'] : null;
    String mPhone = editIndex != null ? (membersList[editIndex]['phone'] ?? '') : '';
    String? mPosition = editIndex != null ? membersList[editIndex]['position'] : 'Member';
    bool mDisability = editIndex != null ? membersList[editIndex]['disability'] ?? false : false;
    List<String> mValueChains = [];
    if (editIndex != null && membersList[editIndex]['value_chains'] != null) {
      if (membersList[editIndex]['value_chains'] is List) {
        mValueChains = (membersList[editIndex]['value_chains'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }
        
    final nameCtrl = TextEditingController(text: mName);
    final phoneCtrl = TextEditingController(text: mPhone);
    String errorMessage = '';

    List<String> ageRanges = ['18-25', '26-35', '36-45', '46-55', '56-65', '65+'];
    List<String> genders = ['male', 'female', 'other'];
    List<String> positions = ['Chairman', 'Secretary', 'Treasurer', 'Member'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
             decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))
             ),
             padding: EdgeInsets.only(
               bottom: MediaQuery.of(context).viewInsets.bottom,
             ),
             constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
             child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(editIndex != null ? 'Edit Member' : 'Add New Member', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           if (errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
                              ),
                           TextField(
                             controller: nameCtrl,
                             decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
                           ),
                           const SizedBox(height: 15),
                           TextField(
                             controller: phoneCtrl,
                             keyboardType: TextInputType.phone,
                             decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                           ),
                           const SizedBox(height: 15),
                           DropdownButtonFormField<String>(
                             value: mGender,
                             decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                             items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g.capitalizeFirst!))).toList(),
                             onChanged: (val) => setModalState(() => mGender = val),
                           ),
                           const SizedBox(height: 15),
                           DropdownButtonFormField<String>(
                             value: mAgeRange,
                             decoration: const InputDecoration(labelText: 'Age Range', border: OutlineInputBorder()),
                             items: ageRanges.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                             onChanged: (val) => setModalState(() => mAgeRange = val),
                           ),
                           const SizedBox(height: 15),
                           DropdownButtonFormField<String>(
                             value: mPosition,
                             decoration: const InputDecoration(labelText: 'Position', border: OutlineInputBorder()),
                             items: positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                             onChanged: (val) => setModalState(() => mPosition = val),
                           ),
                           const SizedBox(height: 10),
                           CheckboxListTile(
                             title: const Text('Has Disability?'),
                             value: mDisability,
                             onChanged: (val) => setModalState(() => mDisability = val ?? false),
                             controlAffinity: ListTileControlAffinity.leading,
                             contentPadding: EdgeInsets.zero,
                           ),
                           const SizedBox(height: 20),
                           const Text('Member Specific Value Chains', style: TextStyle(fontWeight: FontWeight.bold)),
                           const SizedBox(height: 10),
                           if (valueChains.isNotEmpty)
                             Wrap(
                                spacing: 6.0,
                                runSpacing: 4.0,
                                children: valueChains.map((vc) {
                                  String vcId = vc['id'].toString();
                                  bool selected = mValueChains.contains(vcId);
                                  return FilterChip(
                                    label: Text(vc['name'], style: const TextStyle(fontSize: 13)),
                                    selected: selected,
                                    selectedColor: kPrimaryColor.withOpacity(0.2),
                                    checkmarkColor: kPrimaryColor,
                                    onSelected: (bool isSelected) {
                                      setModalState(() {
                                        if (isSelected) {
                                          if (!mValueChains.contains(vcId)) {
                                            mValueChains.add(vcId);
                                          }
                                        } else {
                                          mValueChains.remove(vcId);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                             )
                           else 
                             const Text("Loading value chains...", style: TextStyle(color: Colors.grey)),
                           const SizedBox(height: 30),
                           SizedBox(
                             width: double.infinity,
                             height: 50,
                             child: ElevatedButton(
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: kPrimaryColor,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                               ),
                               child: Text(editIndex != null ? 'Save Changes' : 'Add To List', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                               onPressed: () {
                                 if (nameCtrl.text.trim().isEmpty) {
                                   setModalState(() => errorMessage = 'Name is required');
                                   return;
                                 }
                                 
                                 Map<String, dynamic> newMember = {
                                    'name': nameCtrl.text.trim(),
                                    'phone': phoneCtrl.text.trim(),
                                    'gender': mGender,
                                    'age_range': mAgeRange,
                                    'position': mPosition ?? 'Member',
                                    'disability': mDisability,
                                    'value_chains': mValueChains,
                                 };
                                 
                                 setState(() {
                                    if (editIndex != null) {
                                      membersList[editIndex] = newMember;
                                    } else {
                                      membersList.add(newMember);
                                    }
                                 });
                                 Navigator.pop(context);
                               }
                             )
                           )
                        ],
                      )
                    )
                  )
                ]
             )
          );
        });
      }
    );
  }

  bool validate() {
    resetErrorText();
    bool isValid = true;

    final name = _nameController.text.trim();
    if (name.isEmpty || name.length < 3 || name.length > 64) {
      nameError = selectedLanguage == 'en'
          ? 'Group Name is required and must be 3 to 64 characters.'
          : 'Dzina La Guru ndilofunika';
      isValid = false;
    }

    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !RegExp(r'^(09|08)[0-9]{8}$').hasMatch(phone)) {
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

    if (membersList.isEmpty) {
      membersError = 'At least one member required';
      isValid = false;
    } else {
      var names = membersList.map((m) => m['name'] as String).toList();
      if (names.length != names.toSet().length) {
        membersError = 'Member names must be unique';
        isValid = false;
      }
    }

    setState(() {});
    return isValid;
  }

  Future<void> submit() async {
    if (!validate()) {
      showSnackBar('Please fill in all required fields correctly.');
      return;
    }

    final payload = {
      'name': _nameController.text.trim(),
      'pin': _pinController.text,
      'pin_confirmation': _pinConfirmController.text,
      'district_id': selectedDistrictId,
      'phone': _phoneController.text.trim(),
      'type': 'group',
      'project_name': _projectNameController.text.trim(),
      'epa': _epaController.text.trim(),
      't_a': _taController.text.trim(),
      'gvh': _gvhController.text.trim(),
      'number_of_members': int.tryParse(_numMembersController.text) ?? membersList.length,
      'male_group_members': int.tryParse(_maleMembersController.text) ?? 0,
      'female_group_members': int.tryParse(_femaleMembersController.text) ?? 0,
      'chair_person': _chairPersonController.text.trim(),
      'mapping_id': _mappingIdController.text.trim(),
      'members': membersList,
      'value_chains': selectedGroupValueChains,
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
        if (data['client'] != null && data['client']['members'] != null) {
          final members = data['client']['members'];
          GetStorage().write('members', members);
        }

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
            responseBody['message'] ?? (selectedLanguage == 'en'
                ? 'This phone has already been taken '
                : 'Nambala iyi ya foni yapezeka kale');
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
                'assets/icons/loading1.json',
                width: 100,
                height: 100,
              ),
            ));
    }

    final pageContent = CustomScrollView(
        slivers: [
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
                    style: const TextStyle(
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
                      child: const Text(
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
                      labelText: 'Project Name',
                      errorText: projectNameError,
                      maxLength: 50,
                      controller: _projectNameController),
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
                      labelText: 'Total Number of Members',
                      errorText: numMembersError,
                      maxLength: 10,
                      controller: _numMembersController,
                      keyboardType: TextInputType.number),
                  InputField(
                      labelText: 'Male Members',
                      errorText: maleMembersError,
                      maxLength: 10,
                      controller: _maleMembersController,
                      keyboardType: TextInputType.number),
                  InputField(
                      labelText: 'Female Members',
                      errorText: femaleMembersError,
                      maxLength: 10,
                      controller: _femaleMembersController,
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
                    labelText: selectedLanguage == 'en' ? 'Pin (4 Digits)' : 'Pin (Ziwerengero 4)',
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
                    labelText: selectedLanguage == 'en'
                        ? 'Confirm Pin'
                        : 'Vomelezani Pin',
                    errorText: pinError,
                    obscureText: true,
                    maxLength: 4,
                    textInputAction: TextInputAction.done,
                  ),
                  
                  // VALUE CHAINS SECTION
                  SizedBox(height: screenHeight * .025),
                  Text(
                    selectedLanguage == 'en' ? 'Group Practicing Value Chains' : 'Mankhwala A Gulu',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  isFetchingValueChains
                      ? const Center(child: CircularProgressIndicator())
                      : valueChains.isNotEmpty ? Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: valueChains.map((vc) {
                            String vcId = vc['id'].toString();
                            bool selected = selectedGroupValueChains.contains(vcId);
                            return FilterChip(
                              label: Text(vc['name']),
                              selected: selected,
                              selectedColor: kPrimaryColor.withOpacity(0.2),
                              checkmarkColor: kPrimaryColor,
                              onSelected: (bool isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    if (!selectedGroupValueChains.contains(vcId)) {
                                      selectedGroupValueChains.add(vcId);
                                    }
                                  } else {
                                    selectedGroupValueChains.remove(vcId);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ) : const Text('No value chains available.'),

                  // MEMBERS SECTION
                  SizedBox(height: screenHeight * .04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedLanguage == 'en' ? 'Group Members (${membersList.length})' : 'Mamembala Okhala (${membersList.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (membersList.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => showAddMemberModal(),
                          icon: const Icon(Icons.add),
                          label: Text(selectedLanguage == 'en' ? 'Add' : 'Onjezerani'),
                        )
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  if (membersList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                           Icon(Icons.group_off_rounded, color: Colors.grey.shade400, size: 50),
                           const SizedBox(height: 12),
                           const Text('No members added yet', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                           const SizedBox(height: 16),
                           ElevatedButton.icon(
                             onPressed: () => showAddMemberModal(),
                             icon: const Icon(Icons.person_add),
                             label: const Text('Add Member'),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: kPrimaryColor,
                               foregroundColor: Colors.white,
                               elevation: 0,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                             )
                           )
                        ]
                      )
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: membersList.length,
                      itemBuilder: (context, index) {
                        final member = membersList[index];
                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                                  child: Icon(Icons.person, color: kPrimaryColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                        Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            if (member['position'] != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                                child: Text(member['position'], style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                                              ),
                                            if (member['phone'] != null && member['phone'].toString().isNotEmpty)
                                              Text(member['phone'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                          ],
                                        ),
                                        if (member['value_chains'] != null && member['value_chains'].isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text("${member['value_chains'].length} Value Chain(s) selected", style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                                          )
                                     ]
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, color: Colors.blue.shade400, size: 22),
                                      onPressed: () => showAddMemberModal(editIndex: index),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                                      onPressed: () {
                                        setState(() {
                                          membersList.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                  if (membersList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: Center(
                        child: OutlinedButton.icon(
                           onPressed: () => showAddMemberModal(),
                           icon: const Icon(Icons.add),
                           label: const Text("Add Another Member"),
                           style: OutlinedButton.styleFrom(
                             foregroundColor: kPrimaryColor,
                             side: BorderSide(color: kPrimaryColor),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                           ),
                        ),
                      )
                    ),
                    
                  if (membersError != null)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(membersError!,
                            style: const TextStyle(color: Colors.red))),

                  const SizedBox(height: 20),
                  isLoading
                      ? Center(
                          child: Lottie.asset(
                            'assets/icons/loading1.json',
                            width: 80,
                            height: 80,
                          ),
                        )
                      : FormButton(
                          text: selectedLanguage == 'en'
                              ? 'Sign Up Group'
                              : 'Lembetsani Gulu',
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
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: selectedLanguage == 'en'
                                ? 'I am already a member '
                                : ' Ndine membala kale ',
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: selectedLanguage == 'en'
                                    ? 'Sign In'
                                    : 'Lowani',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
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

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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

class AsymmetricClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
