import 'package:botaniqmicrogreens/screens/Authentication/SplashScreen.dart';
import 'package:botaniqmicrogreens/screens/commonViews/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(
    const ProviderScope(
      child: BotaniQ(),
    ),
  );
}

class BotaniQ extends StatelessWidget {
  const BotaniQ({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSizer(   // <-- Add this
      builder: (context, orientation, deviceType) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        );
      },
    );
  }
}
