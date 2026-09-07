import 'package:flutter/material.dart';
import 'package:mlimi/pages/notifications/notifications_screen.dart';

/// Kept for backward compatibility with older navigation calls.
class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) => const NotificationsScreen();
}
