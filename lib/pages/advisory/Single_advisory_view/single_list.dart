import 'package:flutter/material.dart';
import 'package:mlimi/pages/advisory/components/about_us_view.dart';
import 'package:mlimi/pages/advisory/single_advisory_view/Widgets/sliver_app_bar.dart';

class SingleAdvisoryView extends StatelessWidget {
  const SingleAdvisoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBarBldr(),
          AboutUsView(),
        ],
      ),
    );
  }
}
