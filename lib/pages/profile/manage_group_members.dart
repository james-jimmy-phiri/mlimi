import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/provider/http_provider.dart';
import 'package:mlimi/constants/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class ManageGroupMembersPage extends StatefulWidget {
  final Map<String, dynamic>? user;
  final VoidCallback onUpdate;

  const ManageGroupMembersPage({super.key, required this.user, required this.onUpdate});

  @override
  State<ManageGroupMembersPage> createState() => _ManageGroupMembersPageState();
}

class _ManageGroupMembersPageState extends State<ManageGroupMembersPage> {
  List<Map<String, dynamic>> membersToAdd = [];
  bool isLoading = false;
  String selectedLanguage = 'en';

  List<dynamic> valueChainsList = [];

  @override
  void initState() {
    super.initState();
    selectedLanguage = GetStorage().read('language') ?? 'en';
    fetchValueChains();
  }

  Future<void> fetchValueChains() async {
    var url = Uri.parse('${apiurl}v1/value-chains');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          valueChainsList = jsonDecode(response.body)['data']; // assuming paginated or wrapped in data
        });
      }
    } catch (e) {
      print('Error fetching value chains: $e');
    }
  }

  void showAddMemberModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddMemberModal(
        valueChainsList: valueChainsList,
        onAdd: (member) {
          setState(() {
            membersToAdd.add(member);
          });
        },
      )
    );
  }

  Future<void> submit() async {
    if (membersToAdd.isEmpty) return;

    setState(() => isLoading = true);
    final client = widget.user?['client'];
    if (client == null) return;
    
    String token = GetStorage().read('token');
    Map<String, dynamic> data = {
      'add_members': membersToAdd,
    };

    var result = await HttpProvider().updateProfile(token, client['id'], data);

    setState(() => isLoading = false);

    if (result != null && result['client'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(selectedLanguage == 'ny' ? 'Mamembala awonjezedwa bwino' : 'Members added successfully')),
      );
      setState(() {
        membersToAdd.clear();
      });
      widget.onUpdate();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(selectedLanguage == 'ny' ? 'Kuwonjezela kwalephera' : 'Failed to add members')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedLanguage == 'ny' ? 'Mamembala a Gulu' : 'Manage Members'),
        backgroundColor: Bgreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: membersToAdd.isEmpty
                ? Center(child: Text(selectedLanguage == 'ny' ? 'Palibe ofuna kuwonjezedwa' : 'No members to add yet'))
                : ListView.builder(
                    itemCount: membersToAdd.length,
                    itemBuilder: (context, index) {
                      final member = membersToAdd[index];
                      return ListTile(
                        leading: CircleAvatar(child: Icon(Icons.person)),
                        title: Text(member['name']),
                        subtitle: Text('${member['age_range'] ?? ''} - ${member['position'] ?? 'Member'}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              membersToAdd.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (membersToAdd.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoading
                  ? Center(child: Lottie.asset('assets/icons/loading1.json', width: 60))
                  : ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Bgreen, 
                        minimumSize: Size(double.infinity, 50)
                      ),
                      child: Text(selectedLanguage == 'ny' ? 'Tumizani' : 'Submit Members', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Bgreen,
        onPressed: showAddMemberModal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddMemberModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  final List<dynamic> valueChainsList;

  const AddMemberModal({super.key, required this.onAdd, required this.valueChainsList});

  @override
  State<AddMemberModal> createState() => _AddMemberModalState();
}

class _AddMemberModalState extends State<AddMemberModal> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController positionController;

  String? selectedGender;
  String? selectedAgeRange;
  bool disability = false;
  List<int> selectedValueChains = [];
  String selectedLanguage = 'en';

  final List<String> genders = ['male', 'female', 'other'];
  final List<String> ageRanges = ['18-24', '25-34', '35-44', '45-54', '55+'];

  @override
  void initState() {
    super.initState();
    selectedLanguage = GetStorage().read('language') ?? 'en';
    nameController = TextEditingController();
    phoneController = TextEditingController();
    positionController = TextEditingController(text: 'Member');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(selectedLanguage == 'ny' ? 'Wowonjezela Membala' : 'Add Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => selectedGender = val),
                 decoration: InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedAgeRange,
                items: ageRanges.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => selectedAgeRange = val),
                 decoration: InputDecoration(labelText: 'Age Range', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: positionController,
                decoration: InputDecoration(labelText: 'Position', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text("Has Disability"),
                value: disability,
                onChanged: (val) {
                  setState(() {
                    disability = val ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (widget.valueChainsList.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('Value Chains', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: widget.valueChainsList.map((vc) {
                    bool isSelected = selectedValueChains.contains(vc['id']);
                    return FilterChip(
                      label: Text(vc['name']),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            selectedValueChains.add(vc['id']);
                          } else {
                            selectedValueChains.remove(vc['id']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd({
                      'name': nameController.text,
                      'gender': selectedGender,
                      'age_range': selectedAgeRange,
                      'phone': phoneController.text,
                      'disability': disability,
                      'position': positionController.text,
                      'value_chains': selectedValueChains,
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Bgreen, minimumSize: Size(double.infinity, 50)),
                child: Text('Add to List', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
