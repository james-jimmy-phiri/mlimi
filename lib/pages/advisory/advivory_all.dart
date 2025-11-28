import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mlimi/pages/advisory/advisory_widgets/advisory_sector.dart';
import 'package:mlimi/pages/advisory/components/app_bar.dart';
import 'package:mlimi/services/advisory_service.dart';
import 'package:mlimi/models/advisory_model.dart';
import 'package:mlimi/pages/product_request/homepage.dart';
import 'package:mlimi/pages/profile/profile.dart';

class AllAdvisory extends StatelessWidget {
  AllAdvisory({super.key});
  final DataService dataService = DataService();

  @override
  Widget build(BuildContext context) {
    // You should get these from your app's state management solution

    return FutureBuilder<List<Sector>>(
      future: dataService.loadSectorsFromJson(),
      builder: (context, snapshot) {
        Widget bodyContent;

        if (snapshot.connectionState == ConnectionState.waiting) {
          bodyContent = Center(
            child: Lottie.asset(
              'assets/icons/loading1.json',
              width: 80,
              height: 80,
            ),
          );
        } else if (snapshot.hasError) {
          bodyContent = Center(child: Text('Error loading data'));
        } else if (snapshot.hasData) {
          bodyContent = AdvisorySector(
            sectors: snapshot.data!,
            
          );
        } else {
          bodyContent = Center(child: Text('No data found'));
        }

        // Return the HomeAppBarWithDrawer with the appropriate body content
        return HomeAppBarWithDrawer(

          profileScreenBuilder: () => ProfileScreen(),
          homepageBuilder: () => Homepage(),
          body: bodyContent,
        );
      },
    );
  }
}
