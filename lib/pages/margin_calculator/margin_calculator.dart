import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lottie/lottie.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/gross_margin_model.dart';
import 'package:mlimi/pages/margin_calculator/crop_selection_page.dart';

class MarginCalculator extends StatefulWidget {
  const MarginCalculator({super.key});

  @override
  _MarginCalculatorState createState() => _MarginCalculatorState();
}

class _MarginCalculatorState extends State<MarginCalculator> {
  List<Crop> crops = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/gross_margin.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> cropsJson = jsonMap['crops'];
      setState(() {
        crops = cropsJson.map((json) => Crop.fromJson(json)).toList();
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load crops data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return ErrorDisplay(errorMessage: errorMessage!);
    }

    if (crops.isEmpty) {
      return const LoadingDisplay();
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: CropSelectionPage(crops: crops),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  final String errorMessage;

  const ErrorDisplay({required this.errorMessage, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}

class LoadingDisplay extends StatelessWidget {
  const LoadingDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: Center(
          child: Lottie.asset(
            'assets/icons/loading1.json', // Replace with your Lottie file path
            width: 100,
            height: 100,
          ),
        ));
  }
}
