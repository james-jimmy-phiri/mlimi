import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/provider/http_provider.dart';

class AddGroupMembersPage extends StatefulWidget {
  final Map<String, dynamic>? user;
  final VoidCallback onUpdate;

  const AddGroupMembersPage({
    super.key,
    required this.user,
    required this.onUpdate,
  });

  @override
  State<AddGroupMembersPage> createState() => _AddGroupMembersPageState();
}

class _AddGroupMembersPageState extends State<AddGroupMembersPage> {
  List<Map<String, dynamic>> membersToAdd = [];
  bool isSubmitting = false;
  bool isFetchingValueChains = true;
  List<dynamic> valueChains = [];
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    selectedLanguage = GetStorage().read('language') ?? 'en';
    _fetchValueChains();
  }

  Future<void> _fetchValueChains() async {
    try {
      final response = await http.get(Uri.parse('${apiurl}v1/value-chains'));
      if (response.statusCode == 200 && mounted) {
        final decoded = jsonDecode(response.body);
        List<dynamic> chains = [];
        if (decoded is List) {
          chains = decoded;
        } else if (decoded is Map && decoded.containsKey('value_chains')) {
          chains = decoded['value_chains'];
        } else if (decoded is Map && decoded.containsKey('data')) {
          chains = decoded['data'];
        }
        setState(() {
          valueChains = chains;
          isFetchingValueChains = false;
        });
      } else {
        if (mounted) setState(() => isFetchingValueChains = false);
      }
    } catch (_) {
      if (mounted) setState(() => isFetchingValueChains = false);
    }
  }

  // ── Add / Edit member modal ────────────────────────────────────────────────

  void _showAddMemberModal({int? editIndex}) {
    String mName = editIndex != null ? membersToAdd[editIndex]['name'] : '';
    String? mGender = editIndex != null ? membersToAdd[editIndex]['gender'] : null;
    String? mAgeRange = editIndex != null ? membersToAdd[editIndex]['age_range'] : null;
    String mPhone = editIndex != null ? (membersToAdd[editIndex]['phone'] ?? '') : '';
    String? mPosition = editIndex != null ? membersToAdd[editIndex]['position'] : 'Member';
    bool mDisability = editIndex != null ? (membersToAdd[editIndex]['disability'] ?? false) : false;
    List<String> mValueChains = [];
    if (editIndex != null && membersToAdd[editIndex]['value_chains'] != null) {
      if (membersToAdd[editIndex]['value_chains'] is List) {
        mValueChains = (membersToAdd[editIndex]['value_chains'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    final nameCtrl = TextEditingController(text: mName);
    final phoneCtrl = TextEditingController(text: mPhone);
    final customGenderCtrl = TextEditingController();
    final customValueChainCtrl = TextEditingController();
    String errorMessage = '';

    const ageRanges = ['18-25', '26-35', '36-45', '46-55', '56-65', '65+'];
    const genders = ['male', 'female', 'other'];
    const positions = ['Chairman', 'Secretary', 'Treasurer', 'Member'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.92),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),

                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        editIndex != null
                            ? (selectedLanguage == 'ny' ? 'Sinthani Membala' : 'Edit Member')
                            : (selectedLanguage == 'ny' ? 'Wowonjezela Membala Watsopano' : 'Add New Member'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),

                // Scrollable body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(errorMessage,
                                        style: TextStyle(color: Colors.red.shade700)),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Full Name
                        TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: selectedLanguage == 'ny' ? 'Dzina Lonse *' : 'Full Name *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Phone
                        TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: selectedLanguage == 'ny' ? 'Nambala Ya Foni' : 'Phone Number',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Gender
                        DropdownButtonFormField<String>(
                          value: mGender,
                          decoration: InputDecoration(
                            labelText: selectedLanguage == 'ny' ? 'Mwamuna / Mayi' : 'Gender',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.wc_outlined),
                          ),
                          items: genders
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g[0].toUpperCase() + g.substring(1)),
                                  ))
                              .toList(),
                          onChanged: (val) => setModalState(() => mGender = val),
                        ),
                        if (mGender == 'other') ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: customGenderCtrl,
                            decoration: InputDecoration(
                              labelText: selectedLanguage == 'ny' ? 'Nenani Mwamuna / Mayi' : 'Specify Gender',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Age Range
                        DropdownButtonFormField<String>(
                          value: mAgeRange,
                          decoration: InputDecoration(
                            labelText: selectedLanguage == 'ny' ? 'Zamakalero za Zaka' : 'Age Range',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.cake_outlined),
                          ),
                          items: ageRanges
                              .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                              .toList(),
                          onChanged: (val) => setModalState(() => mAgeRange = val),
                        ),
                        const SizedBox(height: 14),

                        // Position
                        DropdownButtonFormField<String>(
                          value: mPosition,
                          decoration: InputDecoration(
                            labelText: selectedLanguage == 'ny' ? 'Udindo' : 'Position',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                          items: positions
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (val) => setModalState(() => mPosition = val),
                        ),
                        const SizedBox(height: 10),

                        // Disability checkbox
                        CheckboxListTile(
                          title: Text(selectedLanguage == 'ny' ? 'Ali ndi Vuto la Thupi?' : 'Has Disability?'),
                          value: mDisability,
                          onChanged: (val) => setModalState(() => mDisability = val ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: kPrimaryColor,
                        ),
                        const SizedBox(height: 14),

                        // Value Chains
                        Text(
                          selectedLanguage == 'ny' ? 'Mbeu zomwe Membala Alima' : 'Member Value Chains',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        isFetchingValueChains
                            ? const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : valueChains.isNotEmpty
                                ? Wrap(
                                    spacing: 6.0,
                                    runSpacing: 4.0,
                                    children: [
                                      ...valueChains.map((vc) {
                                        String vcId = vc['id'].toString();
                                        bool selected = mValueChains.contains(vcId);
                                        return FilterChip(
                                          label: Text(vc['name'], style: const TextStyle(fontSize: 13)),
                                          selected: selected,
                                          selectedColor: kPrimaryColor.withOpacity(0.2),
                                          checkmarkColor: kPrimaryColor,
                                          onSelected: (isSelected) {
                                            setModalState(() {
                                              if (isSelected) {
                                                if (!mValueChains.contains(vcId)) mValueChains.add(vcId);
                                              } else {
                                                mValueChains.remove(vcId);
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                      ...mValueChains
                                          .where((id) => !valueChains.any((vc) => vc['id'].toString() == id))
                                          .map((customVal) {
                                        return FilterChip(
                                          label: Text(customVal, style: const TextStyle(fontSize: 13)),
                                          selected: true,
                                          selectedColor: kPrimaryColor.withOpacity(0.2),
                                          checkmarkColor: kPrimaryColor,
                                          onSelected: (_) {
                                            setModalState(() => mValueChains.remove(customVal));
                                          },
                                        );
                                      }).toList(),
                                    ],
                                  )
                                : Text(
                                    selectedLanguage == 'ny' ? 'Palibe mbeu zolembedwa' : 'No value chains available',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                        const SizedBox(height: 8),

                        // Custom value chain
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: customValueChainCtrl,
                                decoration: InputDecoration(
                                  hintText: selectedLanguage == 'ny' ? 'Onjezerani mbeu ina...' : 'Add other value chain...',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (customValueChainCtrl.text.trim().isNotEmpty) {
                                  setModalState(() {
                                    mValueChains.add(customValueChainCtrl.text.trim());
                                    customValueChainCtrl.clear();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(selectedLanguage == 'ny' ? 'Onjezerani' : 'Add'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Confirm button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              if (nameCtrl.text.trim().isEmpty) {
                                setModalState(() => errorMessage =
                                    selectedLanguage == 'ny' ? 'Dzina ndilofunika' : 'Name is required');
                                return;
                              }

                              final newMember = {
                                'name': nameCtrl.text.trim(),
                                'phone': phoneCtrl.text.trim(),
                                'gender': (mGender == 'other' && customGenderCtrl.text.isNotEmpty)
                                    ? customGenderCtrl.text.trim()
                                    : mGender,
                                'age_range': mAgeRange,
                                'position': mPosition ?? 'Member',
                                'disability': mDisability,
                                'value_chains': mValueChains,
                              };

                              setState(() {
                                if (editIndex != null) {
                                  membersToAdd[editIndex] = newMember;
                                } else {
                                  membersToAdd.add(newMember);
                                }
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              editIndex != null
                                  ? (selectedLanguage == 'ny' ? 'Sinthani Zolemba' : 'Save Changes')
                                  : (selectedLanguage == 'ny' ? 'Onjezerani ku Mndandanda' : 'Add To List'),
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Submit to backend ──────────────────────────────────────────────────────

  Future<void> _submitMembers() async {
    if (membersToAdd.isEmpty) return;

    setState(() => isSubmitting = true);

    try {
      final client = widget.user?['client'];
      if (client == null) {
        setState(() => isSubmitting = false);
        return;
      }

      final String token = GetStorage().read('token') ?? '';
      final dynamic clientId = client['id'];

      final payload = {
        'add_members': membersToAdd.map((m) {
          final rawVc = m['value_chains'] as List<dynamic>? ?? [];
          final intVc = rawVc
              .map((id) => int.tryParse(id.toString()))
              .whereType<int>()
              .toList();

          return {
            'name': m['name'],
            'phone': m['phone'],
            'gender': (m['gender'] == 'male' || m['gender'] == 'female' || m['gender'] == 'other') ? m['gender'] : 'other',
            'age_range': m['age_range'],
            'position': m['position'] ?? 'Member',
            'disability': m['disability'] ?? false,
            if (intVc.isNotEmpty) 'value_chains': intVc,
          };
        }).toList(),
      };

      debugPrint('Submitting add_members payload: ${jsonEncode(payload)} for client: $clientId');

      final result = await HttpProvider().updateProfile(token, clientId, payload);

      if (!mounted) return;

      if (result != null && result['client'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Text(selectedLanguage == 'ny'
                    ? 'Mamembala awonjezedwa bwino!'
                    : 'Members added successfully!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        setState(() => membersToAdd.clear());
        widget.onUpdate(); // Refresh homepage
        Navigator.pop(context);
      } else {
        final details = result?['details'] ?? result?['error'] ?? '';
        debugPrint('Add members error: $details');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(selectedLanguage == 'ny'
                      ? 'Kuwonjezela kwalephera. Yesaninso.'
                      : 'Failed to add members. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('Exception in _submitMembers: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final client = widget.user?['client'];
    final List<dynamic> existingMembers =
        client != null && client['members'] != null ? client['members'] as List<dynamic> : [];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          selectedLanguage == 'ny' ? 'Wonjezani Mamembala' : 'Add Group Members',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white24),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Existing members header ────────────────────────────────────────
          if (existingMembers.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Icon(Icons.group, color: kPrimaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      selectedLanguage == 'ny'
                          ? 'Mamembala Okhalapo (${existingMembers.length})'
                          : 'Current Members (${existingMembers.length})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (existingMembers.isNotEmpty) const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // ── Existing members list ──────────────────────────────────────────
          if (existingMembers.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final member = existingMembers[i];
                  final nameStr = member['name'] as String? ?? '?';
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kPrimaryColor.withOpacity(0.1),
                          child: Text(
                            nameStr.isNotEmpty ? nameStr[0].toUpperCase() : '?',
                            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(nameStr, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          member['position'] ?? 'Member',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        trailing: member['gender'] != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  member['gender'],
                                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                },
                childCount: existingMembers.length,
              ),
            ),

          // ── Divider ───────────────────────────────────────────────────────
          if (existingMembers.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Divider(color: Colors.grey.shade300),
              ),
            ),

          // ── "To Be Added" section header ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_add_alt_1, color: kPrimaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        selectedLanguage == 'ny'
                            ? 'Ofunidwa Kuwonjezedwa (${membersToAdd.length})'
                            : 'To Be Added (${membersToAdd.length})',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (membersToAdd.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _showAddMemberModal(),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(selectedLanguage == 'ny' ? 'Onjezerani' : 'Add'),
                      style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                    ),
                ],
              ),
            ),
          ),

          // ── Empty state ────────────────────────────────────────────────────
          if (membersToAdd.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.group_add_outlined, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 14),
                      Text(
                        selectedLanguage == 'ny'
                            ? 'Palibe mamembala ofunidwa kuwonjezedwa'
                            : 'No members queued to add yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selectedLanguage == 'ny'
                            ? 'Gwirani batani la + pansipa kuwonjezera membala'
                            : 'Tap the + button below to add members',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () => _showAddMemberModal(),
                        icon: const Icon(Icons.person_add_outlined),
                        label: Text(selectedLanguage == 'ny' ? 'Onjezerani Membala' : 'Add Member'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimaryColor,
                          side: BorderSide(color: kPrimaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Pending members list ───────────────────────────────────────────
          if (membersToAdd.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) {
                  final member = membersToAdd[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: kPrimaryColor.withOpacity(0.35), width: 1.5),
                      ),
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
                                  Text(member['name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (member['position'] != null)
                                        _chip(member['position'], Colors.blue),
                                      if (member['gender'] != null)
                                        _chip(member['gender'], Colors.purple),
                                      if (member['age_range'] != null)
                                        _chip(member['age_range'], Colors.orange),
                                      if (member['phone'] != null && member['phone'].toString().isNotEmpty)
                                        Text(
                                          member['phone'],
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                    ],
                                  ),
                                  if ((member['value_chains'] as List<dynamic>?)?.isNotEmpty == true)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${(member['value_chains'] as List).length} ${selectedLanguage == 'ny' ? 'Mbeu' : 'Value Chain(s)'}',
                                        style: const TextStyle(
                                            color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_outlined, color: Colors.blue.shade400, size: 20),
                                  onPressed: () => _showAddMemberModal(editIndex: index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                                  onPressed: () {
                                    setState(() => membersToAdd.removeAt(index));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: membersToAdd.length,
              ),
            ),

          // ── Add Another button ─────────────────────────────────────────────
          if (membersToAdd.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: OutlinedButton.icon(
                  onPressed: () => _showAddMemberModal(),
                  icon: const Icon(Icons.add),
                  label: Text(selectedLanguage == 'ny' ? 'Onjezerani Membala Wina' : 'Add Another Member'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    side: BorderSide(color: kPrimaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

          // ── Submit button ──────────────────────────────────────────────────
          if (membersToAdd.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: isSubmitting
                    ? Center(
                        child: Lottie.asset('assets/icons/loading1.json', width: 80, height: 80),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          onPressed: _submitMembers,
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: Text(
                            selectedLanguage == 'ny'
                                ? 'Tumizani Mamembala (${membersToAdd.length})'
                                : 'Submit Members (${membersToAdd.length})',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        onPressed: () => _showAddMemberModal(),
        icon: const Icon(Icons.person_add_outlined),
        label: Text(
          selectedLanguage == 'ny' ? 'Onjezerani' : 'Add Member',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _chip(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color.shade700, fontWeight: FontWeight.w600),
      ),
    );
  }
}
