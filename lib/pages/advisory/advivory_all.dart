import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/advisory/advisory_widgets/advisory_sector.dart';
import 'package:mlimi/pages/advisory/components/app_bar.dart';
import 'package:mlimi/services/advisory_service.dart';
import 'package:mlimi/models/advisory_model.dart';

class AllAdvisory extends StatelessWidget {
  AllAdvisory({super.key});
  final DataService dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Sector>>(
      future: dataService.loadSectorsFromJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: homeAppBar(context),
            body: Center(
                child: Lottie.asset(
              'assets/icons/loading1.json', // Replace with your Lottie file path
              width: 80,
              height: 80,
            )),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: homeAppBar(context),
            body: Center(child: Text('Error loading data')),
          );
        } else if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: Bgreen,
            appBar: homeAppBar(context),
            body: AdvisorySector(sectors: snapshot.data!),
          );
        } else {
          return Scaffold(
            appBar: homeAppBar(context),
            body: Center(child: Text('No data found')),
          );
        }
      },
    );
  }
}
