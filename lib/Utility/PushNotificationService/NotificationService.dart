import 'dart:io';
import 'package:botaniqmicrogreens/Constants/Constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Logger.dart';
import '../PreferencesManager.dart';

// ✅ Global navigator key (used for navigation on notification tap)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 🔹 Ask notification permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 🔹 Android notification channel setup
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'Used for important notifications.',
      importance: Importance.max,
    );

    // 🔹 Initialize flutter_local_notifications
    const AndroidInitializationSettings initSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: initSettingsAndroid);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        Logger().log('📲 Notification tapped: ${response.payload}');
        // ✅ Clear tapped notification
        await _localNotifications.cancel(response.id ?? 0);
        // (Optional) Navigate to specific screen
        if (response.payload != null) {
          navigatorKey.currentState?.pushNamed('/yourTargetScreen');
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 🔹 Get FCM token & save locally
    final token = await _fcm.getToken();
    Logger().log('🔥 FCM Token: $token');
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PreferenceKeys.fcmToken, token);
    }

    // 🔹 Foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger().log('📩 Foreground message: ${message.notification?.title}');

      // 🧠 Skip local show for native advertisement with image
      final hasNativeImage = message.notification?.android?.imageUrl != null ||
          message.data['type'] == 'advertisement';

        _showLocalNotification(message);

    });

    // 🔹 Notification tapped while in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger().log('📲 Notification tapped (background): ${message.data}');
    });

    // 🔹 Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    Logger().log('✅ Notification Service initialized');
  }

  // 🔹 Display local notification manually
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final imageUrl = notification.android?.imageUrl ??
        notification.apple?.imageUrl ??
        message.data['image'];

    AndroidNotificationDetails androidDetails;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        // 📥 Download image to temp directory
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/notif_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final http.Response response = await http.get(Uri.parse('${ConstantURLs.baseUrl}$imageUrl'));
        Logger().log('### Ad Image URL $imageUrl');

        if (response.statusCode == 200) {
          final File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          final BigPictureStyleInformation bigPictureStyle =
          BigPictureStyleInformation(
            FilePathAndroidBitmap(file.path),
            largeIcon: FilePathAndroidBitmap(file.path),
            contentTitle: notification.title,
            summaryText: notification.body,
          );

          androidDetails = AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'Used for image notifications.',
            styleInformation: bigPictureStyle,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          );
        } else {
          Logger().log('❌ Failed to download image: ${response.statusCode}');
          androidDetails = const AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'Used for text notifications.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          );
        }
      } catch (e) {
        Logger().log('⚠️ Error loading image: $e');
        androidDetails = const AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Used for text notifications.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );
      }
    } else {
      // 📨 Text-only notification
      androidDetails = const AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'Used for text notifications.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );
    }

    final NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      platformDetails,
      payload: message.data.toString(),
    );
  }
}

// 🔹 Background handler (top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger().log('💤 Background message received: ${message.messageId}');
}
