import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mlimi/pages/trendings/trending_detail_screen.dart';
import 'package:mlimi/services/notification_service.dart';
import 'package:mlimi/utils/navigation_service.dart';

class NotificationNavigation {
  static void handleTap(AppNotification notification) {
    switch (notification.event) {
      // Trending stories
      case 'trending_story':
      case 'trending_story_published':
        final storyId = notification.trendingStoryId;
        if (storyId != null && storyId.isNotEmpty) {
          NavigationService.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => TrendingDetailScreen(storyId: storyId),
            ),
          );
        }
        break;

      // Aggregation — pop to root (home / aggregations tab)
      case 'aggregation_finalized':
        NavigationService.navigatorKey.currentState
            ?.popUntil((route) => route.isFirst);
        break;

      // Commodity events — pop to root so user lands on market tab
      case 'commodity_posted':
      case 'commodity_order':
      case 'potential_customer':
      case 'potential_supplier':
        NavigationService.navigatorKey.currentState
            ?.popUntil((route) => route.isFirst);
        break;

      // Business / market actor events — pop to root
      case 'business_profile_created':
      case 'market_actor_added':
        NavigationService.navigatorKey.currentState
            ?.popUntil((route) => route.isFirst);
        break;

      // Scheduled tips / advisory — just dismiss (already on right page)
      case 'daily_tip':
      case 'weekly_summary':
      case 'monthly_advisory':
        NavigationService.navigatorKey.currentState
            ?.popUntil((route) => route.isFirst);
        break;

      default:
        break;
    }
  }

  static void handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = json.decode(payload) as Map<String, dynamic>;
      final event = data['event']?.toString() ?? '';
      final storyId = data['trending_story_id']?.toString();

      // Handle deep-link from local notification banner
      if ((event == 'trending_story' || event == 'trending_story_published') &&
          storyId != null &&
          storyId.isNotEmpty) {
        NavigationService.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => TrendingDetailScreen(storyId: storyId),
          ),
        );
        return;
      }

      // For all other events, pop to root so user sees the relevant section
      if (event.isNotEmpty) {
        NavigationService.navigatorKey.currentState
            ?.popUntil((route) => route.isFirst);
      }
    } catch (_) {}
  }
}
