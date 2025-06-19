import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/gross_margin_model.dart';
import 'package:mlimi/pages/margin_calculator/summary_page.dart';

class SectionInputPage extends StatefulWidget {
  final Crop crop;
  final Category category;

  SectionInputPage({required this.crop, required this.category});

  @override
  _SectionInputPageState createState() => _SectionInputPageState();
}

class _SectionInputPageState extends State<SectionInputPage> {
  final Map<int, String> _inputValues = {};
  final Map<int, TextEditingController> _controllers =
      {}; // Map to hold controllers for each TextField
  final TextEditingController _fieldSizeController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  String _selectedUnitType = 'Hectares';
  String? _fieldSizeError;
  String? _sellingPriceError;

  @override
  void dispose() {
    // Dispose of all controllers to avoid memory leaks
    _fieldSizeController.dispose();
    _sellingPriceController.dispose();
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _showNotesDialog(String notes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Notes'),
          content: Text(notes),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _calculate() {
    // ... existing code ...

    if (_fieldSizeError == null && _sellingPriceError == null) {
      double? fieldSize = double.tryParse(_fieldSizeController.text);
      double? sellingPrice = double.tryParse(_sellingPriceController.text);

      if (fieldSize == null || sellingPrice == null) {
        // ... existing error handling code ...
        return;
      }

      double totalExpenditure = 0.0;
      List<SectionSummary> sectionSummaries = [];

      _inputValues.forEach((id, value) {
        if (value.isNotEmpty) {
          final content = widget.crop.sections
              .expand((section) => section.contents)
              .firstWhere((c) => c.id == id);

          double contentTotal =
              (double.tryParse(value) ?? 0) * content.rateAcre;
          totalExpenditure += contentTotal;

          sectionSummaries.add(SectionSummary(
            sectionName: widget.crop.name,
            contentItem: content.item,
            inputValue: value,
            rateAcre: content.rateAcre,
            total: contentTotal,
          ));
        }
      });

      double totalIncome;
      if (_selectedUnitType == 'Acres') {
        totalIncome =
            widget.category.averageYield * fieldSize * sellingPrice * 2.45;
      } else {
        totalIncome =
            widget.category.averageYield * fieldSize * sellingPrice * 1.0;
      }

      double profitMargin = totalIncome - totalExpenditure;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPage(
            cropName: widget.crop.name,
            fieldSize: fieldSize,
            sellingPrice: sellingPrice,
            sectionSummaries: sectionSummaries,
            totalExpenditure: totalExpenditure,
            totalIncome: totalIncome,
            profitMargin: profitMargin,
            averageYiled: widget.category.averageYield,
            cropImage: widget.crop.image,
          ),
        ),
      );
    } else {
      // ... existing error handling code ...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(
        title: Text('Gross Margin Calculator'),
        backgroundColor: Bgreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Income Input Section
          Text(
            'Income Input',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.green), // Change text color to green
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SimpleTextField(
                  labelText: 'Field Size',
                  controller: _fieldSizeController,
                  prefix: 'Size: ',
                  errorText: _fieldSizeError,
                  keyboardType:
                      TextInputType.number, // Set keyboard type to number
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUnitType,
                  items: ['Hectares', 'Acres'].map((String unitType) {
                    return DropdownMenuItem<String>(
                      value: unitType,
                      child: Text(unitType),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnitType = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Unit Type',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SimpleTextField(
            labelText: 'Selling Price',
            controller: _sellingPriceController,
            prefix: 'MWK ',
            suffix: '/kGs',
            errorText: _sellingPriceError,
            keyboardType: TextInputType.number, // Set keyboard type to number
          ),
          const SizedBox(height: 32),

          // Crop Sections
          ...widget.crop.sections.map((section) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    ...section.contents.map((content) {
                      // Initialize controller for this content if not already done
                      if (_controllers[content.id] == null) {
                        _controllers[content.id] = TextEditingController(
                            text: _inputValues[content.id] ?? '');
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SimpleTextField(
                          labelText:
                              'Enter ${content.item} cost per ${content.unit}',
                          prefix: 'MWK',
                          suffix: content.unit,
                          keyboardType: TextInputType
                              .number, // Set keyboard type to number
                          controller: _controllers[content.id],
                          onChanged: (value) {
                            setState(() {
                              _inputValues[content.id] = value;
                            });
                          },
                          errorText: _inputValues[content.id]?.isEmpty == true
                              ? 'This field is required'
                              : null,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.help_outline),
                            onPressed: () => _showNotesDialog(content.notes),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.calculate),
        onPressed: _calculate,
      ),
    );
  }
}

class SimpleTextField extends StatelessWidget {
  final String? prefix;
  final String? suffix;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final String? errorText;
  final Widget? suffixIcon;

  const SimpleTextField({
    Key? key,
    this.prefix,
    this.suffix,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.errorText,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 12.0),
        hintText: hintText,
        prefix: prefix != null ? Text(prefix!) : null,
        suffix: suffix != null ? Text(suffix!) : null,
        errorText: errorText,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
