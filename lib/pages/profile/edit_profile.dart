import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/provider/http_provider.dart';
import 'package:mlimi/constants/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? user;
  final VoidCallback onUpdate;

  const EditProfilePage({super.key, required this.user, required this.onUpdate});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController epaController;
  late TextEditingController taController;
  late TextEditingController gvhController;
  
  // Group specific
  late TextEditingController chairPersonController;
  late TextEditingController mappingIdController;
  late TextEditingController numberMembersController;

  String? selectedDistrictId;
  List<dynamic> districts = [];
  bool isFetchingDistricts = true;
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    selectedLanguage = GetStorage().read('language') ?? 'en';
    final client = widget.user?['client'] ?? {};

    nameController = TextEditingController(text: client['name']);
    phoneController = TextEditingController(text: client['phone']);
    epaController = TextEditingController(text: client['epa']);
    taController = TextEditingController(text: client['t_a']);
    gvhController = TextEditingController(text: client['gvh']);

    chairPersonController = TextEditingController(text: client['chair_person']);
    mappingIdController = TextEditingController(text: client['mapping_id']);
    numberMembersController = TextEditingController(text: client['number_of_members']?.toString());
    
    selectedDistrictId = client['district_id']?.toString();

    fetchDistricts();
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
        setState(() => isFetchingDistricts = false);
      }
    } catch (e) {
      setState(() => isFetchingDistricts = false);
    }
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      
      final client = widget.user?['client'];
      if (client == null) return;
      
      String token = GetStorage().read('token');
      Map<String, dynamic> data = {
        'name': nameController.text,
        'phone': phoneController.text,
        'district_id': selectedDistrictId,
        'epa': epaController.text,
        't_a': taController.text,
        'gvh': gvhController.text,
      };

      if (client['type'] == 'group') {
        data['chair_person'] = chairPersonController.text;
        data['mapping_id'] = mappingIdController.text;
        if (numberMembersController.text.isNotEmpty) {
          data['number_of_members'] = int.tryParse(numberMembersController.text);
        }
      }

      var result = await HttpProvider().updateProfile(token, client['id'], data);

      setState(() => isLoading = false);

      if (result != null && result['client'] != null) {
        GetStorage().write('name', result['client']['name']);
        GetStorage().write('phone', result['client']['phone']);
        GetStorage().write('district', result['client']['district']);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(selectedLanguage == 'ny' ? 'Zasinthidwa bwino' : 'Profile updated successfully')),
        );
        widget.onUpdate();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(selectedLanguage == 'ny' ? 'Kusintha kwalephera' : 'Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isGroup = widget.user?['client']?['type'] == 'group';
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedLanguage == 'ny' ? 'Sinthani Mbiri Yanu' : 'Edit Profile'),
        backgroundColor: Bgreen,
      ),
      body: isFetchingDistricts 
          ? Center(child: Lottie.asset('assets/icons/loading1.json', width: 80))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: selectedLanguage == 'ny' ? 'Dzina Lonse' : 'Full Name', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: selectedLanguage == 'ny' ? 'Nambala Ya Foni' : 'Phone Number', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDistrictId,
                      items: districts.map<DropdownMenuItem<String>>((d) => DropdownMenuItem(value: d['id'].toString(), child: Text(d['name']))).toList(),
                      onChanged: (val) => setState(() => selectedDistrictId = val),
                      decoration: InputDecoration(labelText: selectedLanguage == 'ny' ? 'Sankhani Dera' : 'District', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: epaController,
                      decoration: InputDecoration(labelText: 'EPA', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: taController,
                      decoration: InputDecoration(labelText: 'T/A', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: gvhController,
                      decoration: InputDecoration(labelText: 'GVH', border: OutlineInputBorder()),
                    ),
                    if (isGroup) ...[
                      SizedBox(height: 16),
                      TextFormField(
                        controller: chairPersonController,
                        decoration: InputDecoration(labelText: 'Chair Person', border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: mappingIdController,
                        decoration: InputDecoration(labelText: 'Mapping ID', border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: numberMembersController,
                        decoration: InputDecoration(labelText: 'Number of Members', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    SizedBox(height: 32),
                    isLoading 
                        ? Center(child: Lottie.asset('assets/icons/loading1.json', width: 60))
                        : ElevatedButton(
                            onPressed: submit,
                            style: ElevatedButton.styleFrom(backgroundColor: Bgreen, padding: EdgeInsets.symmetric(vertical: 16)),
                            child: Text(selectedLanguage == 'ny' ? 'Sungani' : 'Save Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                  ],
                ),
              ),
            )
    );
  }
}
