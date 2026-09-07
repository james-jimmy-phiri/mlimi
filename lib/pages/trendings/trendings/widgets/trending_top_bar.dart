import 'package:flutter/material.dart';
import 'package:mlimi/constants/trending_theme.dart';
import 'package:mlimi/pages/notifications/notifications_screen.dart';

class TrendingTopBar extends StatelessWidget {
  final bool showBack;
  final List<Widget>? actions;

  const TrendingTopBar({super.key, this.showBack = false, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: TrendingTheme.appBarHeight + MediaQuery.paddingOf(context).top,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top, left: 16, right: 16),
      decoration: BoxDecoration(
        color: TrendingTheme.background.withValues(alpha: 0.8),
        border: Border(bottom: BorderSide(color: TrendingTheme.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: TrendingTheme.primary),
            )
          else
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, color: TrendingTheme.onSurface),
            ),
          Text('Trending', style: TrendingTheme.displayLgMobile().copyWith(fontSize: 22)),
          const Spacer(),
          ...?actions,
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            icon: const Icon(Icons.notifications_outlined, color: TrendingTheme.onSurface),
          ),
        ],
      ),
    );
  }
}
