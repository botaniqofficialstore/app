import 'package:botaniqmicrogreens/constants/ConstantColors.dart';
import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class CustomToast {
  static void show(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    late OverlayEntry overlayEntry;

    // Animation Controller
    final animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 450),
    );

    // Slide Animation (comes from offscreen bottom, goes out same way)
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2), // Start below screen
      end: const Offset(0, 0), // Fully visible
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    // Fade Animation (smooth in/out)
    final fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 70,
        left: 24,
        right: 24,
        child: SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.dp, vertical: 8.dp),
                decoration: BoxDecoration(
                  color: ConstantColors().white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: ConstantColors().navyBlue,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ConstantColors().navyBlue,
                          fontSize: 10.dp,
                          height: 1,
                          fontFamily: objConstantFonts.montserratSemiBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Animate IN (slide up + fade)
    animationController.forward();

    // Wait, then animate OUT (slide down + fade)
    Future.delayed(duration, () async {
      await animationController.reverse();
      overlayEntry.remove();
      animationController.dispose();
    });
  }
}
