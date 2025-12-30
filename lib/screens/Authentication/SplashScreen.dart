
import 'package:botaniqmicrogreens/constants/ConstantColors.dart';
import 'package:botaniqmicrogreens/constants/Constants.dart';
import 'package:botaniqmicrogreens/screens/Authentication/LoginScreen/LoginScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/Mainscreen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

import '../../Utility/PreferencesManager.dart';
import '../../constants/ConstantVariables.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _qMoveAnimation;
  late Animation<Offset> _botaniSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Q starts from center and moves to right
    _qMoveAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.77, -0.03),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Botani slides from right → center
    _botaniSlideAnimation = Tween<Offset>(
      begin: const Offset(3.5, 0),
      end: const Offset(-0.15, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // ✅ Add listener for animation completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigate when animation is done
        _callNavigation();
      }
    });

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _callNavigation() {
    PreferencesManager.getInstance().then((pref) async {
      bool isLoggedIn = pref.getBooleanValue(PreferenceKeys.isUserLogged);


      pref.setStringValue(PreferenceKeys.userID, 'user-1763288528185');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );

      /*if (isLoggedIn){
        Navigator.pushReplacement(
          context,|
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }*/
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors().navyBlue,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Botani slides from right → center
            SlideTransition(
              position: _botaniSlideAnimation,
              child: Image.asset(
                objConstantAssest.splashBotani,
                width: 210.dp,
              ),
            ),

            // Background block that moves along with Q
            SlideTransition(
              position: _qMoveAnimation,
              child: Container(
                width: 180.dp,
                height: 150.dp,
                color: ConstantColors().navyBlue,
              ),
            ),

            // Q moves center → right
            SlideTransition(
              position: _qMoveAnimation,
              child: Image.asset(
                objConstantAssest.splashQ,
                width: 60.dp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
