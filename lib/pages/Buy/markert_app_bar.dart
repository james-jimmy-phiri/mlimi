import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/order/cart_screen.dart';
import 'package:mlimi/pages/order/order_history_screen.dart';
import 'package:mlimi/pages/notifications/notifications_screen.dart';
import 'package:mlimi/provider/cart_provider.dart';
import 'package:mlimi/provider/notification_provider.dart';
import 'package:provider/provider.dart';

AppBar marketAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.green[50],
    elevation: 0,
    leading: IconButton(
      icon: SvgPicture.asset("assets/icons/back.svg"),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    title: RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: "Agro",
            style: TextStyle(color: kTextColor),
          ),
          TextSpan(
            text: "Market",
            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
    actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.receipt_long, color: kPrimaryColor),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
          );
        },
      ),
      Consumer<CartProvider>(
        builder: (context, cart, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: kPrimaryColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF006B29),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.notifications_outlined, color: kPrimaryColor),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
      ),
      Consumer<NotificationProvider>(
        builder: (context, notifications, _) {
          if (notifications.unreadCount <= 0) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${notifications.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}
