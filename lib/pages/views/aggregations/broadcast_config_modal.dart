import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/aggregation_models.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/services/language_service.dart';

void showBroadcastConfigModal(BuildContext context, Aggregation aggregation) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BroadcastConfigModal(aggregation: aggregation),
  );
}

class BroadcastConfigModal extends StatefulWidget {
  final Aggregation aggregation;
  const BroadcastConfigModal({Key? key, required this.aggregation}) : super(key: key);

  @override
  State<BroadcastConfigModal> createState() => _BroadcastConfigModalState();
}

class _BroadcastConfigModalState extends State<BroadcastConfigModal> {
  final Set<int> _selectedMarketActors = {};
  final Set<int> _selectedBusinessProfiles = {};
  final List<String> _extraSms = [];
  final List<String> _extraEmails = [];
  
  final TextEditingController _smsController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AggregationProvider>(context, listen: false);
      provider.fetchBroadcastRecipients(widget.aggregation.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = GetStorage().read('language') ?? 'en';
    final provider = Provider.of<AggregationProvider>(context);
    final recipients = provider.broadcastRecipients;
    final marketActors = recipients['market_actors'] as List? ?? [];
    final businessProfiles = recipients['business_profiles'] as List? ?? [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHeader(language),
          Expanded(
            child: provider.isLoadingRecipients
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildSectionHeader(LanguageService.getText('matchedMarketActors', language), Icons.store_rounded),
                      const SizedBox(height: 12),
                      if (marketActors.isEmpty)
                        _buildEmptySection(LanguageService.getText('noMatchedActors', language))
                      else
                        ...marketActors.map((ma) => _buildRecipientTile(
                          id: ma['id'],
                          title: ma['name'],
                          subtitle: '${ma['phone'] ?? 'No phone'} • ${ma['location'] ?? 'Unknown'}',
                          isSelected: _selectedMarketActors.contains(ma['id']),
                          onTap: () => setState(() => _selectedMarketActors.contains(ma['id']) 
                              ? _selectedMarketActors.remove(ma['id']) 
                              : _selectedMarketActors.add(ma['id'])),
                        )),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader(LanguageService.getText('businessProfiles', language), Icons.business_rounded),
                      const SizedBox(height: 12),
                      if (businessProfiles.isEmpty)
                        _buildEmptySection(LanguageService.getText('noMatchedBusinesses', language))
                      else
                        ...businessProfiles.map((bp) => _buildRecipientTile(
                          id: bp['id'],
                          title: bp['name'],
                          subtitle: bp['email'] ?? bp['phone'] ?? 'No contact info',
                          isSelected: _selectedBusinessProfiles.contains(bp['id']),
                          onTap: () => setState(() => _selectedBusinessProfiles.contains(bp['id']) 
                              ? _selectedBusinessProfiles.remove(bp['id']) 
                              : _selectedBusinessProfiles.add(bp['id'])),
                        )),

                      const SizedBox(height: 32),
                      _buildSectionHeader(LanguageService.getText('extraContacts', language), Icons.add_link_rounded),
                      const SizedBox(height: 12),
                      _buildExtraInput(
                        controller: _smsController,
                        hint: LanguageService.getText('addExtraPhone', language),
                        icon: Icons.phone_android,
                        onAdd: (val) => setState(() { _extraSms.add(val); _smsController.clear(); }),
                      ),
                      if (_extraSms.isNotEmpty) _buildChipList(_extraSms, (idx) => setState(() => _extraSms.removeAt(idx))),
                      const SizedBox(height: 12),
                      _buildExtraInput(
                        controller: _emailController,
                        hint: LanguageService.getText('addExtraEmail', language),
                        icon: Icons.email_outlined,
                        onAdd: (val) => setState(() { _extraEmails.add(val); _emailController.clear(); }),
                      ),
                      if (_extraEmails.isNotEmpty) _buildChipList(_extraEmails, (idx) => setState(() => _extraEmails.removeAt(idx))),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
          ),
          _buildBottomActions(provider, language),
        ],
      ),
    );
  }

  Widget _buildHeader(String language) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(LanguageService.getText('broadcastAggregation', language), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(LanguageService.getText('selectRecipientDesc', language), style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kPrimaryColor),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildRecipientTile({required int id, required String title, required String subtitle, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor.withValues(alpha: 0.05) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? kPrimaryColor.withValues(alpha: 0.3) : Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: isSelected ? kPrimaryColor : Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: Text(message, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400], fontStyle: FontStyle.italic)),
    );
  }

  Widget _buildExtraInput({required TextEditingController controller, required String hint, required IconData icon, required Function(String) onAdd}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => controller.text.isNotEmpty ? onAdd(controller.text) : null),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      onSubmitted: (val) => val.isNotEmpty ? onAdd(val) : null,
    );
  }

  Widget _buildChipList(List<String> items, Function(int) onDelete) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: List.generate(items.length, (index) => Chip(
          label: Text(items[index], style: GoogleFonts.poppins(fontSize: 12)),
          onDeleted: () => onDelete(index),
          backgroundColor: Colors.grey[100],
          deleteIconColor: Colors.red[300],
        )),
      ),
    );
  }

  Widget _buildBottomActions(AggregationProvider provider, String language) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: provider.isActionLoading ? null : _handleBroadcast,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: provider.isActionLoading 
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(LanguageService.getText('finalizeSendAlerts', language), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  void _handleBroadcast() async {
    final language = GetStorage().read('language') ?? 'en';
    final provider = Provider.of<AggregationProvider>(context, listen: false);
    
    final data = {
      'selected_market_actor_ids': _selectedMarketActors.toList(),
      'selected_business_profile_ids': _selectedBusinessProfiles.toList(),
      'extra_sms_numbers': _extraSms,
      'extra_emails': _extraEmails,
    };
 
    final success = await provider.finalizeAndBroadcast(widget.aggregation.id!, data);
 
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.getText('successBroadcast', language)), backgroundColor: Colors.green),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? LanguageService.getText('failedBroadcast', language)), backgroundColor: Colors.red),
      );
    }
  }
}
