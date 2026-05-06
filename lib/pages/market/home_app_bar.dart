import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:provider/provider.dart';
import 'package:mlimi/provider/notification_provider.dart';
import 'package:mlimi/pages/notifications/notification_list_screen.dart';

AppBar homeAppBar(BuildContext context) {
  // Fetch notifications on load using addPostFrameCallback if not already fetching
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = context.read<NotificationProvider>();
    if (provider.notifications.isEmpty && !provider.isLoading) {
      provider.fetchNotifications();
    }
  });

  return AppBar(
    backgroundColor: Bgreen,
    elevation: 0,
    title: Center(
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: "On The",
              style: TextStyle(color: ksecondaryColor, fontSize: 22.0),
            ),
            TextSpan(
              text: "Market",
              style: TextStyle(color: kPrimaryColor, fontSize: 22.0),
            ),
          ],
        ),
      ),
    ),
    actions: [
      Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          int unreadCount = notificationProvider.unreadCount;
          return IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: Colors.white, size: 28),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationListScreen(),
                ),
              );
            },
          );
        },
      ),
      const SizedBox(width: 10),
    ],
  );
}

