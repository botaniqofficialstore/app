import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'PreferencesManager.dart';

class LoadingBarOverlay {
  static OverlayEntry? _overlayEntry;

  /// ✅ Show a global loading overlay centered on screen
  static void show(BuildContext context, {bool showText = false, String title = ''}) {
    if (_overlayEntry != null) return; // Prevent multiple overlays

    PreferencesManager.getInstance().then((pref) {
      pref.setBooleanValue(PreferenceKeys.isLoadingBarStarted, true);

      // ✅ Always attach to root overlay for full-screen coverage
      final overlay = Navigator.of(context, rootNavigator: true).overlay!;

      _overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            // ✅ Transparent blocker to prevent background touches
            ModalBarrier(
              color: Colors.black.withOpacity(0.1),
              dismissible: false,
            ),

            // ✅ Centered Loading Animation
            Center(
              child: Container(
                padding: EdgeInsets.all(16.dp),
                decoration: BoxDecoration(
                  color: showText ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.dp),
                  boxShadow: [
                    if (showText)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(2, 3),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🌈 Beautiful Animated Loader
                    LoadingAnimationWidget.fourRotatingDots(
                      color: objConstantColor.orange,
                      size: 35.dp,
                    ),

                    if (showText) ...[
                      SizedBox(height: 12.dp),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.dp,
                          fontWeight: FontWeight.w500,
                          color: objConstantColor.navyBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );

      overlay.insert(_overlayEntry!);
    });
  }

  /// ✅ Hide the loading overlay safely
  static void hide() {
    PreferencesManager.getInstance().then((pref) {
      pref.setBooleanValue(PreferenceKeys.isLoadingBarStarted, false);
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }
}

/// ✅ Helper method for toggling loading state
showLoadingBar(
    bool startLoading,
    BuildContext context, {
      bool showText = false,
      String title = '',
    }) async {
  if (!context.mounted) return;
  if (startLoading) {
    LoadingBarOverlay.show(context, showText: showText, title: title);
  } else {
    LoadingBarOverlay.hide();
  }
}
