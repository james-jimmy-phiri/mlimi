import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/nutrient_models.dart';
import 'package:mlimi/services/nutrient/nutrient_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GeoSpecificAdvisoryPage extends StatefulWidget {
  const GeoSpecificAdvisoryPage({super.key});

  @override
  State<GeoSpecificAdvisoryPage> createState() =>
      _GeoSpecificAdvisoryPageState();
}

class _GeoSpecificAdvisoryPageState extends State<GeoSpecificAdvisoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _hhidController = TextEditingController();
  final _phoneController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _landSizeController = TextEditingController(text: '1');

  final _service = NutrientService();
  final _storage = GetStorage();

  String _gender = '';
  String _language = 'en';
  String _landUnit = 'ha';
  bool _shortSms = true;
  bool _isGenerating = false;
  bool _isSending = false;
  String _statusMessage = 'Status updates will appear here.';

  NutrientRecommendationResult? _result;

  List<String> get _genders => ['Female', 'Male', 'Other/Prefer not to say'];
  final _languages = const [
    {'label': 'English', 'value': 'en'},
    {'label': 'Chichewa', 'value': 'ny'},
  ];

  @override
  void initState() {
    super.initState();
    _language = _storage.read('language') ?? 'en';
    _phoneController.text = _storage.read('phone') ?? '';
  }

  @override
  void dispose() {
    _hhidController.dispose();
    _phoneController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _landSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          _language == 'en'
              ? 'Geo-specific Nutrient Advisor'
              : 'Ulangizi wa Dera',
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFE8F5E9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroHeader(language: _language),
                const SizedBox(height: 20),
                _buildFormCard(theme),
                const SizedBox(height: 16),
                _ActionButtons(
                  isGenerating: _isGenerating,
                  isSending: _isSending,
                  hasResult: _result != null,
                  onGenerate: _generateRecommendation,
                  onSendSms: () => _sendMessage('sms'),
                  onSendWhatsApp: () => _sendMessage('whatsapp'),
                  onDownload: _downloadCsv,
                ),
                const SizedBox(height: 16),
                _StatusPanel(message: _statusMessage),
                const SizedBox(height: 16),
                if (_result != null) ...[
                  _RecommendationSummary(result: _result!),
                  const SizedBox(height: 16),
                  _SmsPreview(bundle: _result!.sms),
                  const SizedBox(height: 16),
                  _DataTableCard(result: _result!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _FormSectionTitle(
                title: _language == 'en'
                    ? 'Farmer & Location'
                    : 'Mudzi ndi Malo',
              ),
              TextFormField(
                controller: _hhidController,
                decoration: const InputDecoration(
                  labelText: 'Household ID',
                  prefixIcon: Icon(Icons.qr_code_2_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Household ID is required.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (+265…)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required.';
                  }
                  if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value.trim())) {
                    return 'Enter a valid international number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude (if new)',
                        prefixIcon: Icon(Icons.explore_outlined),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude (if new)',
                        prefixIcon: Icon(Icons.explore),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _FormSectionTitle(
                title: _language == 'en'
                    ? 'Preferences'
                    : 'Zokonda',
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender (new HH only)',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                value: _gender.isEmpty ? null : _gender,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Select gender'),
                  ),
                  ..._genders.map(
                    (gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ),
                  )
                ],
                onChanged: (value) => setState(() => _gender = value ?? ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Language',
                  prefixIcon: Icon(Icons.language),
                ),
                value: _language,
                items: _languages
                    .map(
                      (lang) => DropdownMenuItem(
                        value: lang['value'],
                        child: Text(lang['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _language = value);
                  _storage.write('language', value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _landSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Land size',
                        prefixIcon: Icon(Icons.square_foot),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final numValue =
                            double.tryParse(value?.replaceAll(',', '.') ?? '');
                        if (numValue == null || numValue <= 0) {
                          return 'Enter a valid land size.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Units',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      value: _landUnit,
                      items: const [
                        DropdownMenuItem(value: 'ha', child: Text('Hectares')),
                        DropdownMenuItem(value: 'ac', child: Text('Acres')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _landUnit = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Short SMS (condense text)'),
                value: _shortSms,
                onChanged: (value) => setState(() => _shortSms = value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateRecommendation() async {
    if (_isGenerating) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _statusMessage = 'Please fix the highlighted fields.';
      });
      return;
    }
    setState(() {
      _isGenerating = true;
      _statusMessage = 'Generating recommendation...';
      _result = null;
    });

    try {
      final request = NutrientRecommendationRequest(
        hhid: _hhidController.text.trim(),
        phone: _phoneController.text.trim(),
        language: _language,
        landUnit: _landUnit,
        landValue:
            double.tryParse(_landSizeController.text.replaceAll(',', '.')) ??
                1,
        shortSms: _shortSms,
        gender: _gender,
        newLongitude: _longitudeController.text.trim().isEmpty
            ? null
            : _longitudeController.text.trim(),
        newLatitude: _latitudeController.text.trim().isEmpty
            ? null
            : _latitudeController.text.trim(),
      );

      final response =
          await _service.generateRecommendation(request);
      setState(() {
        _result = response;
        _statusMessage = _language == 'en'
            ? 'Recommendation ready.'
            : 'Ulangizi wapezeka.';
      });
    } on NutrientException catch (error) {
      _showSnack(error.message);
      setState(() => _statusMessage = error.message);
    } catch (error) {
      const fallback = 'Something went wrong. Please try again.';
      _showSnack(fallback);
      setState(() => _statusMessage = fallback);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _sendMessage(String channel) async {
    if (_isSending || _result == null) return;
    final recommendationId = _result?.recommendationId;
    if (recommendationId == null) {
      _showSnack('Generate a recommendation first.');
      return;
    }
    setState(() {
      _isSending = true;
      _statusMessage = 'Sending via ${channel.toUpperCase()}...';
    });
    try {
      final response = await _service.sendRecommendation(
        recommendationId: recommendationId,
        channel: channel,
        language: _language,
        shortSms: _shortSms,
      );
      setState(() => _statusMessage = response.display);
      _showSnack(response.display,
          isError: !response.ok,
          details: response.reason);
    } on NutrientException catch (error) {
      setState(() => _statusMessage = error.message);
      _showSnack(error.message);
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _downloadCsv() async {
    if (_result?.table.isEmpty ?? true) {
      _showSnack('No data to download yet.');
      return;
    }
    try {
      final csv = _result!.toCsv();
      final directory = await getTemporaryDirectory();
      final timestamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File(
          '${directory.path}/nutrient_recommendation_$timestamp.csv');
      await file.writeAsString(csv);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Site-specific nutrient recommendation',
        ),
      );
      setState(() => _statusMessage = 'CSV exported successfully.');
    } catch (error) {
      _showSnack('Failed to export CSV.');
      setState(() => _statusMessage = 'Failed to export CSV.');
    }
  }

  void _showSnack(String message, {bool isError = false, String? details}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) Text(details),
          ],
        ),
        backgroundColor: isError ? Colors.red[400] : kPrimaryColor,
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.language});
  final String language;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0277BD), Color(0xFF00695C)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language == 'en'
                ? 'Site-specific nutrient prescriptions'
                : 'Ulangizi wa mankhwala a nthaka',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            language == 'en'
                ? 'Leverage soil lab data, GPS coordinates and farmer preferences to auto-build fertilizer & lime plans per household.'
                : 'Gwiritsani ntchito deta ya nthaka, GPS ndi zosowa za alimi kuti mupange mapulani a fetereza ndi laimu pa banja lililonse.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isGenerating,
    required this.isSending,
    required this.hasResult,
    required this.onGenerate,
    required this.onSendSms,
    required this.onSendWhatsApp,
    required this.onDownload,
  });

  final bool isGenerating;
  final bool isSending;
  final bool hasResult;
  final VoidCallback onGenerate;
  final VoidCallback onSendSms;
  final VoidCallback onSendWhatsApp;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 220,
          child: FilledButton.icon(
            icon: const Icon(Icons.auto_awesome),
            onPressed: isGenerating ? null : onGenerate,
            label: Text(isGenerating ? 'Generating...' : 'Generate'),
          ),
        ),
        SizedBox(
          width: 150,
          child: FilledButton.icon(
            icon: const Icon(Icons.sms),
            onPressed: (!hasResult || isSending) ? null : onSendSms,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
            ),
            label: Text(isSending ? 'Sending...' : 'Send SMS'),
          ),
        ),
        SizedBox(
          width: 170,
          child: FilledButton.icon(
            icon: const Icon(Icons.wechat_outlined),
            onPressed: (!hasResult || isSending) ? null : onSendWhatsApp,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade600,
            ),
            label: Text(isSending ? 'Sending...' : 'Send WhatsApp'),
          ),
        ),
        SizedBox(
          width: 170,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.download),
            onPressed: hasResult ? onDownload : null,
            label: const Text('Download CSV'),
          ),
        ),
      ],
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.green.shade50),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.podcasts, color: kPrimaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSummary extends StatelessWidget {
  const _RecommendationSummary({required this.result});
  final NutrientRecommendationResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final district = result.stringField('District') ?? '(unknown)';
    final area = result.stringField('Area_ha') ?? '-';
    final yieldLow = result.stringField('Rainfed_Yield_Target_Low_t_ha') ?? '-';
    final yieldHigh =
        result.stringField('Rainfed_Yield_Target_High_t_ha') ?? '-';
    final predicted = result.stringField('Predicted_Yield_t_ha') ?? '-';
    final optionCost =
        result.stringField('Option1_Est_Cost_USD_per_area') ?? '-';

    final chips = [
      _SummaryChip(
        title: 'District',
        value: district,
        icon: Icons.public,
      ),
      _SummaryChip(
        title: 'Area (ha)',
        value: area,
        icon: Icons.square_foot,
      ),
      _SummaryChip(
        title: 'Yield target (t/ha)',
        value: '$yieldLow - $yieldHigh',
        icon: Icons.timeline_outlined,
      ),
      _SummaryChip(
        title: 'Predicted yield',
        value: '$predicted t/ha',
        icon: Icons.grading_outlined,
      ),
      _SummaryChip(
        title: 'Option 1 est. cost',
        value: '\$$optionCost',
        icon: Icons.payments_outlined,
      ),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendation at a glance',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: chips,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      width: 180,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _SmsPreview extends StatelessWidget {
  const _SmsPreview({required this.bundle});
  final NutrientSmsBundle bundle;

  @override
  Widget build(BuildContext context) {
    final previews = [
      if (bundle.smsEn != null)
        _SmsTile(title: 'English (full)', body: bundle.smsEn!),
      if (bundle.smsShortEn != null)
        _SmsTile(title: 'English (short)', body: bundle.smsShortEn!),
      if (bundle.smsNy != null)
        _SmsTile(title: 'Chichewa (full)', body: bundle.smsNy!),
      if (bundle.smsShortNy != null)
        _SmsTile(title: 'Chichewa (short)', body: bundle.smsShortNy!),
    ];

    if (previews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message preview',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...previews,
          ],
        ),
      ),
    );
  }
}

class _SmsTile extends StatelessWidget {
  const _SmsTile({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DataTableCard extends StatelessWidget {
  const _DataTableCard({required this.result});
  final NutrientRecommendationResult result;

  @override
  Widget build(BuildContext context) {
    final rows = result.toDisplayRows();
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full prescription table',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Metric')),
                  DataColumn(label: Text('Value')),
                ],
                rows: rows
                    .map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(Text(entry.key)),
                          DataCell(Text(entry.value)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
