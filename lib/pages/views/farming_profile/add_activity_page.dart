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
  final String _language = GetStorage().read('language') ?? 'en';

  bool _isLoading = false;
  List<Map<String, dynamic>> _valueChains = [];
  int? _selectedValueChainId;

  // Controllers
  final _areaController = TextEditingController();
  final _yieldController = TextEditingController();
  final _animalsController = TextEditingController();
  final _varietyController = TextEditingController();
  final _hivesController = TextEditingController();
  final _productionController = TextEditingController();

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
    try {
      final chains = await _service.getValueChains();
      setState(() {
        _valueChains = chains;
      });
    } catch (e) {
      // Ignore if it fails, maybe log it
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedValueChainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(_language == 'en' ? 'Please select a type' : 'Chonde sankhani mtundu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.activityType == 'crop') {
        await _service.addCrop(widget.seasonId, {
          'value_chain_id': _selectedValueChainId,
          'area_cultivated': _areaController.text,
          'expected_yield_per_unit': _yieldController.text.isNotEmpty ? _yieldController.text : null,
          'unit_of_measurement': 'kg',
          'production_method': 'Conventional',
        });
      } else if (widget.activityType == 'livestock') {
        await _service.addLivestock(widget.seasonId, {
          'value_chain_id': _selectedValueChainId,
          'number_of_animals': _animalsController.text,
          'animal_variety': _varietyController.text.isNotEmpty ? _varietyController.text : null,
          'unit_of_measurement': 'head',
        });
      } else if (widget.activityType == 'honey') {
        await _service.addHoney(widget.seasonId, {
          'value_chain_id': _selectedValueChainId,
          'number_of_beehives': _hivesController.text,
          'expected_production_kg': _productionController.text,
        });
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(backgroundColor: Colors.green, content: Text(_language == 'en' ? 'Activity added successfully' : 'Zawonjezedwa bwino')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.activityType == 'crop') {
      title = _language == 'en' ? 'Add Crop' : 'Onjezani Mbewu';
    } else if (widget.activityType == 'livestock') {
      title = _language == 'en' ? 'Add Livestock' : 'Onjezani Chiweto';
    } else {
      title = _language == 'en' ? 'Add Honey' : 'Onjezani Uchi';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
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
                    _buildValueChainDropdown(),
                    const SizedBox(height: 20),
                    if (widget.activityType == 'crop') _buildCropFields(),
                    if (widget.activityType == 'livestock') _buildLivestockFields(),
                    if (widget.activityType == 'honey') _buildHoneyFields(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveActivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _language == 'en' ? 'Save' : 'Sungani',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
    return DropdownButtonFormField<int>(
      value: _selectedValueChainId,
      decoration: InputDecoration(
        labelText: _language == 'en' ? 'Select Type' : 'Sankhani Mtundu',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _valueChains.map((vc) {
        return DropdownMenuItem<int>(
          value: vc['id'],
          child: Text(vc['name']),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedValueChainId = val;
        });
      },
      validator: (value) => value == null ? 'Required' : null,
    );
  }

  Widget _buildCropFields() {
    return Column(
      children: [
        TextFormField(
          controller: _areaController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: _language == 'en' ? 'Area Cultivated (Acres)' : 'Malo Olima (Maekala)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _yieldController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: _language == 'en' ? 'Expected Yield per Acre (kg)' : 'Zoti Mudzakolole pa Ekala (kg)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildLivestockFields() {
    return Column(
      children: [
        TextFormField(
          controller: _animalsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _language == 'en' ? 'Number of Animals' : 'Chiwerengero cha Ziweto',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _varietyController,
          decoration: InputDecoration(
            labelText: _language == 'en' ? 'Variety / Breed (Optional)' : 'Mtundu Wachiweto',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
            labelText: _language == 'en' ? 'Number of Beehives' : 'Chiwerengero cha Ming\'oma',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _productionController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: _language == 'en' ? 'Expected Production (kg)' : 'Uchi wa Girendi Yomwe Mukuyembekezera (kg)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
