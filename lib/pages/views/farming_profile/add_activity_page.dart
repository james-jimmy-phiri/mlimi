import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/services/farming_profile_service.dart';

class AddActivityPage extends StatefulWidget {
  final int seasonId;
  final String activityType; // 'crop', 'livestock', 'honey'

  const AddActivityPage({
    Key? key,
    required this.seasonId,
    required this.activityType,
  }) : super(key: key);

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final FarmingProfileService _service = FarmingProfileService();
  final String _lang = GetStorage().read('language') ?? 'en';

  bool _isLoading = false;
  bool _isLoadingChains = true;
  List<Map<String, dynamic>> _allValueChains = [];
  List<Map<String, dynamic>> _filteredValueChains = [];
  int? _selectedValueChainId;
  String _selectedUnitCrop = 'kg';
  String _selectedUnitLivestock = 'head';

  // Controllers
  final _areaController = TextEditingController();
  final _yieldController = TextEditingController();
  final _animalsController = TextEditingController();
  final _varietyController = TextEditingController();
  final _hivesController = TextEditingController();
  final _productionController = TextEditingController();

  // Sector keywords used to filter value chains by activityType
  // These match the 'sector' field or 'name' of value chains in the backend.
  static const Map<String, List<String>> _sectorKeywords = {
    'crop': ['crop', 'grain', 'vegetable', 'fruit', 'horticulture', 'legume',
              'maize', 'soya', 'groundnut', 'bean', 'rice', 'cassava', 'cotton',
              'sunflower', 'tobacco', 'sorghum', 'pigeon pea'],
    'livestock': ['livestock', 'animal', 'cattle', 'goat', 'pig', 'poultry',
                  'fish', 'dairy', 'sheep', 'chicken'],
    'honey': ['honey', 'bee', 'apiculture', 'hive'],
  };

  @override
  void initState() {
    super.initState();
    _loadValueChains();
  }

  @override
  void dispose() {
    _areaController.dispose();
    _yieldController.dispose();
    _animalsController.dispose();
    _varietyController.dispose();
    _hivesController.dispose();
    _productionController.dispose();
    super.dispose();
  }

  Future<void> _loadValueChains() async {
    setState(() => _isLoadingChains = true);
    try {
      final chains = await _service.getValueChains();
      setState(() {
        _allValueChains = chains;
        _filteredValueChains = _filterByType(chains);
        _isLoadingChains = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingChains = false;
        // Fallback: show all chains if filtering fails
        _filteredValueChains = _allValueChains;
      });
    }
  }

  /// Filter value chains relevant to the activityType.
  /// Uses sector field first, then falls back to keyword matching on name.
  List<Map<String, dynamic>> _filterByType(List<Map<String, dynamic>> chains) {
    final keywords = _sectorKeywords[widget.activityType] ?? [];

    // If there's a sector field, prioritize matching it
    final bySector = chains.where((vc) {
      final sector = (vc['sector'] ?? '').toString().toLowerCase();
      return keywords.any((k) => sector.contains(k));
    }).toList();

    if (bySector.isNotEmpty) return bySector;

    // Fallback: match on name
    final byName = chains.where((vc) {
      final name = (vc['name'] ?? '').toString().toLowerCase();
      return keywords.any((k) => name.contains(k));
    }).toList();

    // If we still couldn't filter (value chains don't have sector info),
    // return all chains so the farmer can still select one.
    return byName.isNotEmpty ? byName : chains;
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedValueChainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(_lang == 'en'
            ? 'Please select a type'
            : 'Chonde sankhani mtundu'),
      ));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.activityType == 'crop') {
        await _service.addCrop(widget.seasonId, {
          'value_chain_id': _selectedValueChainId,
          'area_cultivated': double.tryParse(_areaController.text.trim()) ?? 0,
          'expected_yield_per_unit': _yieldController.text.trim().isNotEmpty
              ? double.tryParse(_yieldController.text.trim())
              : null,
          'unit_of_measurement': _selectedUnitCrop,
          'production_method': 'Conventional',
        });
      } else if (widget.activityType == 'livestock') {
        await _service.addLivestock(widget.seasonId, {
          'value_chain_id': _selectedValueChainId,
          'number_of_animals':
              int.tryParse(_animalsController.text.trim()) ?? 0,
          'animal_variety': _varietyController.text.trim().isNotEmpty
              ? _varietyController.text.trim()
              : null,
          'unit_of_measurement': _selectedUnitLivestock,
        });
      } else if (widget.activityType == 'honey') {
        await _service.addHoney(widget.seasonId, {
          'value_chain_id': _selectedValueChainId,
          'number_of_beehives':
              int.tryParse(_hivesController.text.trim()) ?? 0,
          'expected_production_kg':
              double.tryParse(_productionController.text.trim()) ?? 0,
        });
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(_lang == 'en'
              ? 'Added successfully!'
              : 'Zawonjezedwa bwino!'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.activityType == 'crop'
        ? (_lang == 'en' ? 'Add Crop' : 'Onjezani Mbewu')
        : widget.activityType == 'livestock'
            ? (_lang == 'en' ? 'Add Livestock' : 'Onjezani Chiweto')
            : (_lang == 'en' ? 'Add Honey/Beehive' : 'Onjezani Uchi');

    final sectorIcon = widget.activityType == 'crop'
        ? Icons.grass
        : widget.activityType == 'livestock'
            ? Icons.pets
            : Icons.hive;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: kPrimaryColor.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(sectorIcon, color: kPrimaryColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.activityType == 'crop'
                                  ? (_lang == 'en'
                                      ? 'Select the crop type you are growing this season'
                                      : 'Sankhani mbewu yomwe mukukula nyengo ino')
                                  : widget.activityType == 'livestock'
                                      ? (_lang == 'en'
                                          ? 'Select the type of animal you are raising'
                                          : 'Sankhani chiweto chimene mukukuza')
                                      : (_lang == 'en'
                                          ? 'Record your honey production setup'
                                          : 'Lemba mazao anu a uchi'),
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: kPrimaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Value chain dropdown (filtered by type)
                    _buildValueChainDropdown(),
                    const SizedBox(height: 20),

                    // Type-specific fields
                    if (widget.activityType == 'crop') _buildCropFields(),
                    if (widget.activityType == 'livestock')
                      _buildLivestockFields(),
                    if (widget.activityType == 'honey') _buildHoneyFields(),

                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saveActivity,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: Text(
                          _lang == 'en' ? 'Save' : 'Sungani',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildValueChainDropdown() {
    if (_isLoadingChains) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filteredValueChains.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Text(
          _lang == 'en'
              ? 'No types available. Please contact support.'
              : 'Palibe mtundu wokhazikika. Talankhulani ndi thandizo.',
          style: GoogleFonts.poppins(color: Colors.orange[800], fontSize: 13),
        ),
      );
    }
    return DropdownButtonFormField<int>(
      initialValue: _selectedValueChainId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: widget.activityType == 'crop'
            ? (_lang == 'en' ? 'Crop Type' : 'Mtundu wa Mbewu')
            : widget.activityType == 'livestock'
                ? (_lang == 'en' ? 'Animal Type' : 'Mtundu wa Chiweto')
                : (_lang == 'en' ? 'Honey Type' : 'Mtundu wa Uchi'),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        prefixIcon: Icon(
          widget.activityType == 'crop'
              ? Icons.grass
              : widget.activityType == 'livestock'
                  ? Icons.pets
                  : Icons.hive,
          color: kPrimaryColor,
        ),
      ),
      items: _filteredValueChains.map((vc) {
        return DropdownMenuItem<int>(
          value: vc['id'] is int ? vc['id'] : int.tryParse(vc['id'].toString()) ?? 0,
          child: Text(
            vc['name']?.toString() ?? '',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedValueChainId = val),
      validator: (value) => value == null
          ? (_lang == 'en' ? 'Required' : 'Chofunikira')
          : null,
    );
  }

  Widget _buildCropFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Area
        TextFormField(
          controller: _areaController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText:
                _lang == 'en' ? 'Area Cultivated' : 'Malo Olima',
            hintText: '0.5',
            suffixText: _lang == 'en' ? 'acres' : 'maekala',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: kPrimaryColor, width: 2),
            ),
            prefixIcon:
                const Icon(Icons.map_outlined, color: kPrimaryColor),
          ),
          validator: (v) => (v == null || v.isEmpty)
              ? (_lang == 'en' ? 'Required' : 'Chofunikira')
              : (double.tryParse(v) == null)
                  ? (_lang == 'en'
                      ? 'Enter a valid number'
                      : 'Lowetsani nambala yolondola')
                  : null,
        ),
        const SizedBox(height: 20),

        // Expected yield per unit
        TextFormField(
          controller: _yieldController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: _lang == 'en'
                ? 'Expected Yield per Acre (Optional)'
                : 'Zomwe Mukuyembekezera Kukolola pa Ekala',
            hintText: '500',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: kPrimaryColor, width: 2),
            ),
            prefixIcon:
                const Icon(Icons.bar_chart, color: kPrimaryColor),
          ),
        ),
        const SizedBox(height: 16),

        // Unit of measurement
        Text(
          _lang == 'en' ? 'Unit of Measurement' : 'Muyezo',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: ['kg', 'MT', 'bags', 'crates'].map((unit) {
            final selected = _selectedUnitCrop == unit;
            return GestureDetector(
              onTap: () => setState(() => _selectedUnitCrop = unit),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? kPrimaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? kPrimaryColor : Colors.grey[300]!),
                ),
                child: Text(
                  unit,
                  style: GoogleFonts.poppins(
                      color: selected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLivestockFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _animalsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _lang == 'en'
                ? 'Number of Animals'
                : 'Chiwerengero cha Ziweto',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: kPrimaryColor, width: 2),
            ),
            prefixIcon:
                const Icon(Icons.pets, color: kPrimaryColor),
          ),
          validator: (v) => (v == null || v.isEmpty)
              ? (_lang == 'en' ? 'Required' : 'Chofunikira')
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _varietyController,
          decoration: InputDecoration(
            labelText: _lang == 'en'
                ? 'Breed / Variety (Optional)'
                : 'Mtundu wa Chiweto (Osafunikira)',
            hintText: _lang == 'en' ? 'e.g., Malawi Zebu' : 'mwachitsanzo, Malawi Zebu',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: kPrimaryColor, width: 2),
            ),
            prefixIcon:
                const Icon(Icons.info_outline, color: kPrimaryColor),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _lang == 'en' ? 'Unit' : 'Muyezo',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: ['head', 'pairs', 'herds'].map((unit) {
            final selected = _selectedUnitLivestock == unit;
            return GestureDetector(
              onTap: () => setState(() => _selectedUnitLivestock = unit),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? kPrimaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? kPrimaryColor : Colors.grey[300]!),
                ),
                child: Text(
                  unit,
                  style: GoogleFonts.poppins(
                      color: selected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHoneyFields() {
    return Column(
      children: [
        TextFormField(
          controller: _hivesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _lang == 'en'
                ? 'Number of Beehives'
                : 'Chiwerengero cha Ming\'oma',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: kPrimaryColor, width: 2),
            ),
            prefixIcon: const Icon(Icons.hive, color: kPrimaryColor),
          ),
          validator: (v) => (v == null || v.isEmpty)
              ? (_lang == 'en' ? 'Required' : 'Chofunikira')
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _productionController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: _lang == 'en'
                ? 'Expected Honey Production (kg)'
                : 'Uchi Wokholera (kg)',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: kPrimaryColor, width: 2),
            ),
            prefixIcon:
                const Icon(Icons.scale_outlined, color: kPrimaryColor),
          ),
          validator: (v) => (v == null || v.isEmpty)
              ? (_lang == 'en' ? 'Required' : 'Chofunikira')
              : null,
        ),
      ],
    );
  }
}
