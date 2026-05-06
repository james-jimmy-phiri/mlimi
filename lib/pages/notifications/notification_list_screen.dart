import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mlimi/provider/notification_provider.dart';
import 'package:mlimi/constants/color.dart';
import 'package:intl/intl.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Bgreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Bgreen));
          }

          if (provider.errorMessage != null && provider.notifications.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.notifications.isEmpty) {
            return const Center(child: Text('No notifications at this time.'));
          }

          return RefreshIndicator(
            color: Bgreen,
            onRefresh: () => provider.fetchNotifications(),
            child: ListView.separated(
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                final isUnread = !notification.isRead;

                return ColoredBox(
                  color: isUnread ? Colors.green.withOpacity(0.05) : Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isUnread ? kPrimaryColor : Colors.grey.shade300,
                      child: Icon(
                        Icons.notifications_active,
                        color: isUnread ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    title: Text(
                      notification.message,
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(notification.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (isUnread) {
                        await provider.markAsRead(notification.id);
                      }
                      
                      // Navigate to market screen for aggregation finalized
                      if (notification.event == 'aggregation_finalized') {
                        // Assuming market screen routing logic here
                        // Let's implement navigation logic if a specific screen exists.
                        // Pop back to home if we came from there or navigate to specific tab.
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    },
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
