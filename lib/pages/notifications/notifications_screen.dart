import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/provider/notification_provider.dart';
import 'package:mlimi/utils/notification_navigation.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String get _language => GetStorage().read('language') ?? 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refresh(showAlerts: false);
    });
  }

  // ─── Event icon mapping ───────────────────────────────────────────────────

  IconData _iconForEvent(String event) {
    return switch (event) {
      'commodity_order'          => Icons.shopping_bag_outlined,
      'commodity_posted'         => Icons.storefront_outlined,
      'potential_customer'       => Icons.person_add_alt_1,
      'potential_supplier'       => Icons.local_shipping_outlined,
      'trending_story'           => Icons.local_fire_department_outlined,
      'trending_story_published' => Icons.local_fire_department_outlined,
      'new_user_registered'      => Icons.person_outline,
      'welcome_new_user'         => Icons.waving_hand_outlined,
      'market_actor_added'       => Icons.store_outlined,
      'business_profile_created' => Icons.business_outlined,
      'aggregation_finalized'    => Icons.inventory_2_outlined,
      'low_stock_alert'          => Icons.warning_amber_outlined,
      'daily_tip'                => Icons.tips_and_updates_outlined,
      'weekly_summary'           => Icons.bar_chart_outlined,
      'monthly_advisory'         => Icons.cloud_outlined,
      _                          => Icons.notifications_outlined,
    };
  }

  Color _colorForEvent(String event) {
    return switch (event) {
      'commodity_order'          => const Color(0xFF006B29),
      'commodity_posted'         => const Color(0xFF1B7C3E),
      'potential_customer'       => Colors.blue,
      'potential_supplier'       => Colors.indigo,
      'trending_story'           => const Color(0xFF006B29),
      'trending_story_published' => const Color(0xFFD97706),
      'new_user_registered'      => Colors.teal,
      'welcome_new_user'         => const Color(0xFF006B29),
      'market_actor_added'       => Colors.deepOrange,
      'business_profile_created' => Colors.purple,
      'aggregation_finalized'    => Colors.brown,
      'low_stock_alert'          => Colors.red,
      'daily_tip'                => const Color(0xFF0284C7),
      'weekly_summary'           => Colors.indigo,
      'monthly_advisory'         => Colors.blueGrey,
      _                          => Colors.orange,
    };
  }

  // ─── "Mark all read" and "settings" labels ────────────────────────────────

  String get _markAllLabel =>
      _language == 'ny' ? 'Werengani zonse' : 'Mark all read';

  String get _noNotificationsLabel =>
      _language == 'ny' ? 'Palibe zomuwuza' : 'No notifications yet';

  String get _appBarTitle =>
      _language == 'ny' ? 'Zomuwuza' : 'Notifications';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF006B29),
        title: Text(
          _appBarTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Mark all read
          TextButton(
            onPressed: () =>
                context.read<NotificationProvider>().markAllRead(),
            child: Text(
              _markAllLabel,
              style: const TextStyle(
                  color: Color(0xFF006B29), fontSize: 12),
            ),
          ),
          // Notification permission / settings shortcut
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.permissionGranted) return const SizedBox.shrink();
              return IconButton(
                tooltip: _language == 'ny'
                    ? 'Enable notifications'
                    : 'Enable notifications',
                onPressed: () =>
                    provider.checkAndRequestPermission(context),
                icon: const Icon(
                  Icons.notifications_off_outlined,
                  color: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.notifications.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF006B29)));
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 72, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _noNotificationsLabel,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF006B29),
            onRefresh: () => provider.refresh(showAlerts: false),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final n = provider.notifications[index];
                final color = _colorForEvent(n.event);
                final displayTitle = n.localizedTitle(_language);
                final displayMessage = n.localizedMessage(_language);

                return Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => provider.markRead(n),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: const Color(0xFF006B29),
                    child: const Icon(Icons.done, color: Colors.white),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      await provider.markRead(n);
                      if (context.mounted) {
                        NotificationNavigation.handleTap(n);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: n.isViewed
                            ? Colors.white
                            : const Color(0xFF006B29).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: n.isViewed
                              ? Colors.grey.shade200
                              : const Color(0xFF006B29).withValues(alpha: 0.2),
                        ),
                        boxShadow: n.isViewed
                            ? []
                            : [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _iconForEvent(n.event),
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayTitle,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: n.isViewed
                                              ? Colors.black87
                                              : const Color(0xFF006B29),
                                        ),
                                      ),
                                    ),
                                    if (!n.isViewed)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayMessage,
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      height: 1.4),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  n.received,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
