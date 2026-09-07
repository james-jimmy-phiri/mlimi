import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/services/notification_service.dart';
import 'package:mlimi/utils/notification_navigation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final _storage = GetStorage();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;
  bool _permissionGranted = false;
  Set<String> _knownIds = {};

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  bool get permissionGranted => _permissionGranted;

  /// Current language code from storage — default to English (en).
  String get _language => _storage.read('language') ?? 'en';

  Future<void> init() async {
    // Load known IDs from GetStorage
    final stored = _storage.read<List<dynamic>>('shown_notification_ids');
    if (stored != null) {
      _knownIds = stored.map((e) => e.toString()).toSet();
    }

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        NotificationNavigation.handlePayload(response.payload);
      },
    );

    // Check and request Android notification permission
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      _permissionGranted = granted ?? false;
    } else {
      _permissionGranted = true;
    }

    if (_permissionGranted) {
      await initFCM();
      await clearSystemNotifications();
      await scheduleRandomFarmerNotifications();
    }
  }

  /// Clears all system notification banners from status bar once app is opened/resumed
  Future<void> clearSystemNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to clear system notifications: $e');
    }
  }

  static final List<Map<String, String>> _randomFarmerAdvisories = [
    {
      'title_ny': 'Mitengo ya Chimanga',
      'body_ny': 'Mtengo wa chimanga wakwera pa msika wa Lilongwe. Bwerani pa Mlimi App kuti muwone mitengo yapasachedwapa!',
      'title_en': 'Maize Market Update',
      'body_en': 'Maize prices increased at Lilongwe market. Open Mlimi App to check latest updates!',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Malangizo a Feteleza',
      'body_ny': 'Thirani feteleza wa Basal mu nthaka yowuma musanadze mbewu kuti zikule bwino.',
      'title_en': 'Fertilizer Advisory',
      'body_en': 'Apply Basal fertilizer early before planting for optimal crop root development.',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Malonda a Gulu',
      'body_ny': 'Sonkhanitsani Soya yanu ngati gulu la Mlimi kuti mugulitse pa mtengo wapamwamba!',
      'title_en': 'Group Aggregation Tip',
      'body_en': 'Aggregate your soya beans as a farmer cluster to command premium bulk prices!',
      'event': 'aggregation_finalized',
    },
    {
      'title_ny': 'Samalirani Macadamia & Khofi',
      'body_ny': 'Yang\'anirani tizilombo ta thrips ndi stinkbugs mu munda mwanu mwezi uno.',
      'title_en': 'Macadamia & Coffee Pest Alert',
      'body_en': 'Monitor for thrips and stinkbugs in macadamia and coffee fields this month.',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Ulimi wa Nsomba',
      'body_ny': 'Onjezerani zakudya m\'madzi a nsomba m\'mawa kwambiri kuti zikule msanga.',
      'title_en': 'Aquaculture Tip',
      'body_en': 'Feed fish ponds early in the morning for maximum growth rate and higher yields.',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Ogula Mpunga wa Kilombero',
      'body_ny': 'Ogula ambiri akusaka mpunga wa Kilombero wapamwamba pa Mlimi App!',
      'title_en': 'High Demand for Kilombero Rice',
      'body_en': 'Verified buyers are actively looking for premium Kilombero rice on Mlimi App!',
      'event': 'potential_customer',
    },
    {
      'title_ny': 'Kukolola Mtedza wa CG7',
      'body_ny': 'Kanganani kupukusa mtedza woyera pamene mukukolola kupewa aflatoxin.',
      'title_en': 'Groundnut Post-Harvest Tip',
      'body_en': 'Properly dry CG7 groundnuts on raised tarpaulins to prevent aflatoxin contamination.',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Katemera wa Ziweto',
      'body_ny': 'Pasani nkhuku zanu katemera wa chidoko pamene nyengo ikusintha.',
      'title_en': 'Poultry Health Alert',
      'body_en': 'Vaccinate your chickens against Newcastle disease as the seasonal temperature shifts.',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Malipiro pa Mobile Money',
      'body_ny': 'Mlimi App imagwiritsa ntchito Airtel Money & Mpamba pothandiza malonda momasuka!',
      'title_en': 'Instant Mobile Money Payments',
      'body_en': 'Receive instant crop payments directly to Airtel Money or Mpamba on Mlimi App!',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Mtengo wa Mbatata',
      'body_ny': 'Mitengo ya mbatata yafika pa peak mu Dedza & Ntchisi. Dinani kuti muwone ogula!',
      'title_en': 'Irish Potato Demand Peak',
      'body_en': 'Irish potato demand is peaking in Dedza & Ntchisi. Tap to view active buyers!',
      'event': 'potential_customer',
    },
    {
      'title_ny': 'Ulimi wa Thonje',
      'body_ny': 'Ulimi wa thonje wa m\'mthunzi ukuyenda bwino m\'chigwa cha Shire Valley.',
      'title_en': 'Cotton Farming Advisory',
      'body_en': 'Irrigation advisory and pest control guidance available for Shire Valley cotton growers.',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Mbewu za Zipatso & Masamba',
      'body_ny': 'Limbikitsani mitengo ya zipatso m\'munda mwanu kudzera mu Mlimi Hub!',
      'title_en': 'Horticulture & Tree Nursery',
      'body_en': 'List your fruit tree nursery and fresh vegetables on Mlimi Hub directory today!',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Kuthira Urea pa Chimanga',
      'body_ny': 'Gwiritsani ntchito feteleza wa Urea pa masabata 3 mpaka 4 mukadzala chimanga.',
      'title_en': 'Maize Top-Dressing Tip',
      'body_en': 'Top-dress maize crops with Urea fertilizer 3 to 4 weeks after crop emergence.',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Lembetsani Gulu Lanu',
      'body_ny': 'Lembetsani gulu lanu la alimi pa Mlimi App kuti muphatikize katundu ndi kupeza msika!',
      'title_en': 'Register Your Farmer Group',
      'body_en': 'Register your cooperative on Mlimi App to combine produce and access bulk markets!',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Mbewu Zotsimikizika',
      'body_ny': 'Gwiritsani ntchito ma seed certificates odalirika m\'malo ogulitsira ovomerezeka.',
      'title_en': 'Certified Seed Selection',
      'body_en': 'Always buy certified seeds from verified seed producers to guarantee germination.',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Mtengo wa Nyemba',
      'body_ny': 'Mtengo wa Nyemba zofiira uli pa MWK 1,800/kg m\'msika waukulu lero!',
      'title_en': 'Red Kidney Bean Prices',
      'body_en': 'Red kidney bean market prices are hovering at MWK 1,800/kg across major hubs!',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Chitetezo cha Nthaka',
      'body_ny': 'Pangani ma ridging m\'munda mwanu kupewa kukokoloka kwa nthaka m\'mvula.',
      'title_en': 'Soil Conservation Practice',
      'body_en': 'Contour ridging and mulching retains moisture and prevents topsoil erosion.',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Samalirani Mbatata pa Blight',
      'body_ny': 'Chenjerani ndi matenda a blight pa mbatata ndi phwetekere pamene mvula ikugwa.',
      'title_en': 'Late Blight Alert',
      'body_en': 'Shield tomato and potato crops against late blight using recommended fungicides.',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Ulimi wa Zimbuzi za Mkaka',
      'body_ny': 'Zimbuzi zamkaka zikuchulukitsa ndalama za amayi m\'magulu a Mlimi App!',
      'title_en': 'Dairy Goat Enterprise',
      'body_en': 'Dairy goat farming boosts daily income for women farmer groups across Malawi!',
      'event': 'daily_tip',
    },
    {
      'title_ny': 'Zosonkhanitsa Zatsopano za Mbewu',
      'body_ny': 'Onani zosonkhanitsa zatsopano zimene alimi akupanga pafupi ndi district yanu!',
      'title_en': 'New Produce Aggregations',
      'body_en': 'Explore new group aggregation pools active near your district on Mlimi App!',
      'event': 'aggregation_finalized',
    },

    // ─── App Awareness / Promotional ────────────────────────────────────────
    {
      'title_ny': 'Mlimi App? 🌱',
      'body_ny': 'Mlimi App ndi platform yothandizira alimi ku Malawi kupeza msika, mitengo ya mbewu, ndi malangizo a ulimi. Lowani lero!',
      'title_en': 'What Is Mlimi App? 🌱',
      'body_en': 'Mlimi App is a platform helping Malawian farmers access markets, crop prices, and expert farming guidance. Join today!',
      'event': 'app_promo',
    },
    {
      'title_ny': 'Sasani Malonda a Munda anu pa Mlimi App 📒',
      'body_ny': 'Gwiritsani ntchito Mlimi App kusasa ndi kugurisa malonda ndi zokolola za munda wanu. Onani phindu lanu lililonse!',
      'title_en': 'Track Your Farm Sales 📒',
      'body_en': 'Use Mlimi App to record your farm sales and harvest income. Monitor your profits anytime!',
      'event': 'app_promo',
    },
    {
      'title_ny': 'Onani Mitengo ya Msika Lero 📈',
      'body_ny': 'Peza mitengo yamakono ya chimanga, soya, mtedza, ndi mbewu zina pa Mlimi App — pa foni yanu!',
      'title_en': 'Get Live Market Prices 📈',
      'body_en': "Check today's real-time prices for maize, soya, groundnuts, and more — right on Mlimi App!",
      'event': 'app_promo',
    },
    {
      'title_ny': 'lumikizanani ndi Ogula Odalirika 🤝',
      'body_ny': 'Mlimi App imakumanganitsani ndi ogula ovomerezeka kuti mupeze mtengo wabwino wa katundu wanu!',
      'title_en': 'Connect with Verified Buyers 🤝',
      'body_en': 'Mlimi App connects you directly with trusted, verified buyers so you get the best price for your produce!',
      'event': 'app_promo',
    },
    {
      'title_ny': 'Sungani Zolemba za Katundu yemwe mukugulisa📦',
      'body_ny': 'Gwiritsani ntchito Inventory Manager ya Mlimi App kulemba katundu wanu, zotsalira, ndi zinthu zogulitsa!',
      'title_en': 'Manage Your Farm Inventory 📦',
      'body_en': "Use Mlimi App's Inventory Manager to record your farm stock, movements, and products for sale!",
      'event': 'app_promo',
    },
    {
      'title_ny': 'Landirani Malangizo a zaulimi pa Mlimi App 🎓',
      'body_ny': 'Pezani malangizo  a ulimi, zachilengedwe, ndi njira zabwino za zokolola pa Mlimi App!',
      'title_en': 'Get Expert Farming Advice 🎓',
      'body_en': 'Access professional agricultural advisory, agronomy tips, and best farming practices on Mlimi App!',
      'event': 'app_promo',
    },
    {
      'title_ny': 'Lowani Gulu la Alimi Otsogola Lero! 👨‍👩‍👧‍👦',
      'body_ny': 'Lowani gulu la alimi pa Mlimi App kuti musonkhanitse katundu ndi kupeza mtengo wapamwamba pamodzi!',
      'title_en': 'Join a Farmer Group Today! 👨‍👩‍👧‍👦',
      'body_en': 'Join a farmer cluster on Mlimi App to pool your produce and command premium bulk market prices together!',
      'event': 'app_promo',
    },
    {
      'title_ny': 'Landira Malipiro pa Foni Mwamsanga 💸',
      'body_ny': 'Mlimi App imagwiritsa ntchito Airtel Money ndi Mpamba kuti mulandire ndalama za malonda mwachipsire!',
      'title_en': 'Receive Payments via Mobile Money 💸',
      'body_en': 'Mlimi App supports Airtel Money and Mpamba so you receive instant crop sale payments on your phone!',
      'event': 'app_promo',
    },
    {
      'title_ny': 'Werengani Nkhani Zatsopano pa Mlimi App 🔥',
      'body_ny': 'Pezani nkhani zaposachedwa za ulimi, msika, ndi chilengedwe pa Trending Stories ya Mlimi App!',
      'title_en': 'Read the Latest Farming Stories 🔥',
      'body_en': 'Stay informed with the latest agriculture news, market trends, and success stories on Mlimi App Trending!',
      'event': 'app_promo',
    },
    {
      'title_ny': "Yang'anirani Ziweto Zanu pa App 🐄",
      'body_ny': 'Mlimi App ikuthandizani kulembera ziweto, mkaka, ndi zokolola za ziweto zanu mwavuto!',
      'title_en': 'Monitor Your Livestock on App 🐄',
      'body_en': 'Mlimi App helps you track your cattle, dairy production, and livestock records all in one place!',
      'event': 'app_promo',
    },
    {
      'title_ny': 'Onani Thanzi la Nthaka Yanu 🌍',
      'body_ny': 'Gwiritsani ntchito Nutrient Advisor ya Mlimi App kudziwa zomwe nthaka yanu ikufunikira kuti mbewu zikule bwino!',
      'title_en': 'Check Your Soil Health Today 🌍',
      'body_en': "Use Mlimi App's Nutrient Advisor to understand what your soil needs for maximum crop yields!",
      'event': 'app_promo',
    },
    {
      'title_ny': 'Pezani Thandizo la Zokolola 🏦',
      'body_ny': 'Mlimi App imakuphunzitsani za ngongole ndi thandizo la zokolola. Pitani pa app kuti muone zomwe mulipo!',
      'title_en': 'Explore Farm Input Support 🏦',
      'body_en': 'Mlimi App informs you about available loans and farm input support programs. Open the app to learn more!',
      'event': 'app_promo',
    },
    {
      'title_ny': 'Mlimi App Ndi Yaulere Kwathunthu! 🎉',
      'body_ny': 'Inde! Mlimi App ndi yaulere. Lowani, lembetsani, ndi gwiritsani ntchito zinthu zonse popanda ndalama!',
      'title_en': '100% Free to Use — No Hidden Costs! 🎉',
      'body_en': 'Yes! Mlimi App is completely free. Download, register, and use all features without paying a thing!',
      'event': 'app_promo',
    },
    {
      'title_ny': 'Londolani Abwenzi Anu pa Mlimi App! 📲',
      'body_ny': 'Kondolani anzanu alimi pa Mlimi App kuti nao apindule ndi mitengo ya msika, malangizo, ndi zambiri!',
      'title_en': 'Invite Your Farmer Friends to Join! 📲',
      'body_en': 'Share Mlimi App with your fellow farmers so they too can access market prices, tips, and buyer connections!',
      'event': 'app_promo',
    },
    {
      'title_ny': 'Mlimi App ili mu Chichewa ndi Chingerezi 🇲🇼',
      'body_ny': 'Mlimi App imagwira ntchito mu Chichewa ndi Chingerezi. Sankhani chiyankhulo chanu mu Settings tsopano!',
      'title_en': 'Mlimi App Supports Chichewa & English 🇲🇼',
      'body_en': 'Mlimi App works in both Chichewa and English. Choose your preferred language in Settings today!',
      'event': 'app_promo',
    },
  ];

  /// Schedule random background farming notifications at varied daily times so
  /// the user sees different advisories throughout the day even when offline.
  Future<void> scheduleRandomFarmerNotifications() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'mlimi_alerts',
        'Mlimi Alerts',
        channelDescription:
            'Zomuwuza za msika, mbewu, ndi zambiri / Market, farming and app notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      );
      const details = NotificationDetails(android: androidDetails);
      final isNy = _language == 'ny';

      // Shuffle a copy so we pick 8 distinct advisories (farming + promo mix)
      final shuffled = List.of(_randomFarmerAdvisories)..shuffle();

      // IDs 7780-7787 are reserved for Mlimi advisory & promo notifications.
      // Mix of daily and weekly intervals for variety across the week.
      final intervals = [
        RepeatInterval.daily,
        RepeatInterval.daily,
        RepeatInterval.daily,
        RepeatInterval.weekly,
        RepeatInterval.weekly,
        RepeatInterval.weekly,
        RepeatInterval.weekly,
        RepeatInterval.weekly,
      ];

      for (int i = 0; i < 8; i++) {
        final item = shuffled[i % shuffled.length];
        final title = isNy ? item['title_ny']! : item['title_en']!;
        final body = isNy ? item['body_ny']! : item['body_en']!;
        final payload = json.encode({'event': item['event'] ?? 'daily_tip'});

        await _localNotifications.periodicallyShow(
          7780 + i,
          title,
          body,
          intervals[i],
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to schedule random farmer notifications: $e');
    }
  }

  /// Call this from the app shell after login to show the permission dialog
  /// if permission was not granted. Pass the BuildContext.
  Future<void> checkAndRequestPermission(BuildContext context) async {
    if (_permissionGranted) return;

    final lang = _language;
    final isNy = lang == 'ny';

    final title = isNy
        ? 'Mulole Mlimi App Kutumiza Zomuwuza!'
        : 'Allow Mlimi App Notifications';

    final message = isNy
        ? 'Chonde mulole ma notification kuti mulandire zankhani za msika, mbewu, ndi zina zambiri padzulo lanu lililonse.\n\nKonzani: Mapangidwe > Mlimi App > Notifications.'
        : 'Please enable notifications so you can receive market prices, farming tips, and important updates on your phone.\n\nGo to: Settings > Mlimi App > Notifications.';

    final confirmLabel = isNy ? 'Ndikuvomereza' : 'Allow';
    final skipLabel = isNy ? 'Lekani' : 'Later';

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.notifications_active_outlined,
            size: 52, color: Color(0xFF006B29)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF006B29)),
        ),
        content: Text(message, textAlign: TextAlign.center,
            style: const TextStyle(height: 1.5)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(skipLabel,
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              // Re-request permission
              if (defaultTargetPlatform == TargetPlatform.android) {
                final granted = await _localNotifications
                    .resolvePlatformSpecificImplementation<
                        AndroidFlutterLocalNotificationsPlugin>()
                    ?.requestNotificationsPermission();
                _permissionGranted = granted ?? false;
                if (_permissionGranted) {
                  await initFCM();
                }
                notifyListeners();
              }
            },
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(confirmLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B29),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> refresh({bool showAlerts = true}) async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    try {
      // Register FCM token if permission is granted and user is logged in
      if (_permissionGranted && _storage.read('token') != null) {
        await _registerFCMToken();
      }

      final result = await _service.fetchNotifications();
      final items = result['items'] as List<AppNotification>;
      final unread = result['unread_count'] as int? ?? 0;

      // Lazy load just in case init wasn't completed or to ensure we have the latest
      if (_knownIds.isEmpty) {
        final stored = _storage.read<List<dynamic>>('shown_notification_ids');
        if (stored != null) {
          _knownIds = stored.map((e) => e.toString()).toSet();
        }
      }

      bool updated = false;
      if (showAlerts) {
        for (final n in items) {
          if (!n.isViewed && !_knownIds.contains(n.id)) {
            _knownIds.add(n.id);
            updated = true;
            await _showLocalNotification(n);
          }
        }
      } else {
        final originalLength = _knownIds.length;
        _knownIds.addAll(items.map((n) => n.id));
        if (_knownIds.length != originalLength) {
          updated = true;
        }
      }

      if (updated) {
        await _storage.write('shown_notification_ids', _knownIds.toList());
      }

      _notifications = items;
      _unreadCount = unread;
    } catch (_) {
      // Keep UI usable offline
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(AppNotification notification) async {
    await _service.markAsRead(notification.id);
    await refresh(showAlerts: false);
  }

  Future<void> markAllRead() async {
    await _service.markAllRead();
    await refresh(showAlerts: false);
  }

  /// Show a local notification banner using the user's preferred language.
  /// Chichewa (ny) is the highest priority.
  Future<void> _showLocalNotification(AppNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'mlimi_alerts',
      'Mlimi Alerts',
      channelDescription:
          'Zomuwuza za msika, mbewu, ndi zambiri / Market, farming and app notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    final lang = _language;
    final displayTitle = notification.localizedTitle(lang);
    final displayMessage = notification.localizedMessage(lang);

    final payload = json.encode({
      'event': notification.event,
      if (notification.trendingStoryId != null)
        'trending_story_id': notification.trendingStoryId,
    });

    await _localNotifications.show(
      notification.id.hashCode,
      displayTitle,
      displayMessage,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  Future<void> initFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _permissionGranted = true;
        notifyListeners();

        await _registerFCMToken();

        messaging.onTokenRefresh.listen((newToken) {
          _service.registerDeviceToken(newToken);
        });
      }

      // Foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final notification = message.notification;
        final data = message.data;
        if (notification != null) {
          final id = message.messageId ?? '${notification.title.hashCode}_${notification.body.hashCode}';
          if (!_knownIds.contains(id)) {
            _knownIds.add(id);
            await _storage.write('shown_notification_ids', _knownIds.toList());

            const androidDetails = AndroidNotificationDetails(
              'mlimi_alerts',
              'Mlimi Alerts',
              channelDescription:
                  'Zomuwuza za msika, mbewu, ndi zambiri / Market, farming and app notifications',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
            );

            final payload = json.encode({
              'event': data['event'] ?? 'general',
              if (data['trending_story_id'] != null)
                'trending_story_id': data['trending_story_id'],
            });

            await _localNotifications.show(
              id.hashCode,
              notification.title,
              notification.body,
              const NotificationDetails(android: androidDetails),
              payload: payload,
            );
          }
        }
        await refresh(showAlerts: false);
      });

      // App opened from background/terminated via notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final data = message.data;
        final appNotif = AppNotification(
          id: message.messageId ?? '',
          title: message.notification?.title ?? '',
          message: message.notification?.body ?? '',
          event: data['event'] ?? 'general',
          isViewed: true,
          received: '',
          data: data,
        );
        NotificationNavigation.handleTap(appNotif);
      });

      // Handle app opened from terminated state
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        final data = initialMessage.data;
        final appNotif = AppNotification(
          id: initialMessage.messageId ?? '',
          title: initialMessage.notification?.title ?? '',
          message: initialMessage.notification?.body ?? '',
          event: data['event'] ?? 'general',
          isViewed: true,
          received: '',
          data: data,
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          NotificationNavigation.handleTap(appNotif);
        });
      }
    } catch (e) {
      debugPrint('[NotificationProvider] FCM init failed: $e');
    }
  }

  Future<void> _registerFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
        await _service.registerDeviceToken(token, platform: platform);
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Error getting/registering FCM token: $e');
    }
  }
}
