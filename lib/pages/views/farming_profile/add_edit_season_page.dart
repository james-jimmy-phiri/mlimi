import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/farming_profile_models.dart';
import 'package:mlimi/services/farming_profile_service.dart';

class AddEditSeasonPage extends StatefulWidget {
  final FarmingSeason? season;

  const AddEditSeasonPage({Key? key, this.season}) : super(key: key);

  @override
  State<AddEditSeasonPage> createState() => _AddEditSeasonPageState();
}

class _AddEditSeasonPageState extends State<AddEditSeasonPage> {
  final _formKey = GlobalKey<FormState>();
  final FarmingProfileService _service = FarmingProfileService();
  final String _language = GetStorage().read('language') ?? 'en';
  
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _notesController;
  
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _status = 'Active';

  final List<String> _statuses = ['Active', 'Harvesting', 'Completed'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.season?.name ?? 'Season ${DateTime.now().year}');
    _notesController = TextEditingController(text: widget.season?.notes ?? '');
    
    if (widget.season != null) {
      _startDate = widget.season!.startDate;
      _endDate = widget.season!.endDate;
      _status = widget.season!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveSeason() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final startYear = _startDate.year.toString();
      
      if (widget.season == null) {
        // Create
        await _service.createSeason(
          name: _nameController.text.trim(),
          startYear: startYear,
          startDate: dateFormat.format(_startDate),
          endDate: _endDate != null ? dateFormat.format(_endDate!) : null,
          status: _status,
          notes: _notesController.text.trim(),
        );
      } else {
        // Update
        await _service.updateSeason(
          widget.season!.id,
          name: _nameController.text.trim(),
          startYear: startYear,
          startDate: dateFormat.format(_startDate),
          endDate: _endDate != null ? dateFormat.format(_endDate!) : null,
          status: _status,
          notes: _notesController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(_language == 'en' ? 'Season saved successfully' : 'Nyengo yasungidwa bwino'),
          ),
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
    final isEditing = widget.season != null;
    final title = isEditing 
        ? (_language == 'en' ? 'Edit Season' : 'Sinthani Nyengo')
        : (_language == 'en' ? 'Add Season' : 'Onjezani Nyengo');

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
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: _language == 'en' ? 'Season Name' : 'Dzina La Nyengo',
                        hintText: 'e.g., Summer 2026',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(
                        labelText: _language == 'en' ? 'Status' : 'Mkhalidwe',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: _language == 'en' ? 'Start Date' : 'Tsiku Loyamba',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: _language == 'en' ? 'End Date (Optional)' : 'Tsiku Lomaliza (Sikofunikira)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Select'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: _language == 'en' ? 'Notes' : 'Ndemanga',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveSeason,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _language == 'en' ? 'Save Season' : 'Sungani Nyengo',
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
}
