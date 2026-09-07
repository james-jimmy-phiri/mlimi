import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/notifications/notifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:mlimi/provider/notification_provider.dart';

AppBar homeAppBar(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = context.read<NotificationProvider>();
    if (provider.notifications.isEmpty && !provider.loading) {
      provider.refresh(showAlerts: false);
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
          final unreadCount = notificationProvider.unreadCount;
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
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
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
