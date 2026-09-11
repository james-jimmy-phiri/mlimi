import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/pages/views/base_screen.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:mlimi/provider/cart_provider.dart';
import 'package:mlimi/provider/location_provider.dart';
import 'package:mlimi/provider/notification_provider.dart';
import 'package:mlimi/utils/navigation_service.dart';
import 'package:mlimi/provider/radio_provider.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

// ---------------------------------------------------------------------------
// Upgrader singleton — initialized once before runApp so the store version
// is fetched eagerly.  Using a singleton avoids creating multiple HTTP
// requests when the widget tree rebuilds.
// ---------------------------------------------------------------------------
final _upgrader = Upgrader(
  // Show the dialog again after 1 day if the user tapped "Later".
  durationUntilAlertAgain: const Duration(days: 1),
  // Enable this temporarily during development to diagnose issues:
  // debugLogging: true,
  // debugDisplayAlways: true,
);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove();
  await GetStorage.init();

  final notificationProvider = NotificationProvider();
  await notificationProvider.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => AggregationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RadioProvider()),
        ChangeNotifierProvider.value(value: notificationProvider),
      ],
      child: const MyApp(),
    ));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = GetStorage().read('token');
      if (token != null) {
        final provider = context.read<NotificationProvider>();
        provider.refresh().then((_) {
          // Show permission dialog if notifications aren't enabled
          if (context.mounted) {
            provider.checkAndRequestPermission(context);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final notifProvider = context.read<NotificationProvider>();
      notifProvider.clearSystemNotifications();
      final token = GetStorage().read('token');
      if (token != null) {
        notifProvider.refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Mlimi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          displayMedium: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      // -----------------------------------------------------------------------
      // UpgradeAlert MUST be inside MaterialApp (below it in the widget tree)
      // so it can access the Navigator.  Wrapping MaterialApp itself breaks it.
      // We pass the same navigatorKey so the dialog uses the correct context.
      // -----------------------------------------------------------------------
      home: UpgradeAlert(
        upgrader: _upgrader,
        navigatorKey: NavigationService.navigatorKey,
        // Prevent users from permanently dismissing the prompt — they can
        // still tap "Later" and be reminded again after durationUntilAlertAgain.
        showIgnore: false,
        // barrierDismissible: false — uncomment to make the dialog mandatory.
        child: const BaseScreen(),
      ),
    );
  }
}
