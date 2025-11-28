import 'package:flutter/material.dart';
import 'package:mlimi/pages/advisory/single_advisory_list/Widgets/sliver_app_bar.dart';
import 'package:mlimi/pages/advisory/single_advisory_list/Widgets/sliver_list.dart';

class SingleList extends StatelessWidget {
  const SingleList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBarBldr(),
          SliverListBldr(),
        ],
      ),
    );
  }
}
