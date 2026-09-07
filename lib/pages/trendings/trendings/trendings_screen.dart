import 'package:flutter/material.dart';
import 'package:mlimi/constants/trending_theme.dart';
import 'package:mlimi/pages/trendings/trending_explore_tab.dart';
import 'package:mlimi/pages/trendings/trending_feed_tab.dart';
import 'package:mlimi/pages/trendings/widgets/trending_top_bar.dart';

class TrendingsScreen extends StatefulWidget {
  const TrendingsScreen({super.key});

  @override
  State<TrendingsScreen> createState() => _TrendingsScreenState();
}

class _TrendingsScreenState extends State<TrendingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: TrendingTheme.background,
        splashColor: TrendingTheme.primary.withValues(alpha: 0.1),
      ),
      child: Scaffold(
        backgroundColor: TrendingTheme.background,
        body: Column(
          children: [
            const TrendingTopBar(),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: TrendingTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: TrendingTheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: TrendingTheme.primary,
                unselectedLabelColor: TrendingTheme.onSurfaceVariant,
                labelStyle: TrendingTheme.labelMd(),
                tabs: const [
                  Tab(text: 'Feed'),
                  Tab(text: 'Explore'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const TrendingFeedTab(),
                  TrendingExploreTab(
                    onCategorySelected: (_) => _tabController.animateTo(0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
