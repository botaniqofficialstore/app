import 'package:botaniqmicrogreens/screens/Authentication/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Utility/Logger.dart';
import 'Utility/PushNotificationService/NotificationService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

  runApp(
    const ProviderScope(child: BotaniQ()),
  );
}

Future<void> _backgroundHandler(RemoteMessage message) async {
  Logger().log('##_backgroundHandler ----> $message');
}

class BotaniQ extends StatelessWidget {
  const BotaniQ({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          home: const SplashScreen(),
        );
      },
    );
  }
}
