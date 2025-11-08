import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
<<<<<<< HEAD
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;
=======
>>>>>>> dfdff9d8cd23a9cdbbd4a1bc6a20349b46a4ff7a

import '../Utility/LoadingBarOverlay.dart';

class CommonWidgets {

  Widget buttonWithImage(
      BuildContext context,
      double vertical,
      double horizontal,
      String image,
      double imageWidth,
      double imageHeight,
      VoidCallback onPressed,
      ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vertical.dp, horizontal: horizontal.dp),
        child: SizedBox(
          width: imageWidth.dp,
          height: imageHeight.dp,
          child: Image.asset(image),
        ),
      ),
    );
  }

  Widget buttonWithTopImageBottomText(
      BuildContext context,
      double vertical,
      double horizontal,
      String image,
      double imageWidth,
      double imageHeight,
      String title,
      double size,
      Color? color,
      String family,
      VoidCallback onPressed,
      ) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: vertical.dp, horizontal: horizontal.dp),
            child: SizedBox(
              width: imageWidth.dp,
              height: imageHeight.dp,
              child: Image.asset(image),
            ),
          ),
        ),
        customText(context, title, size, color, family), // fixed reference
        SizedBox(height: 5.dp),
      ],
    );
  }

  Widget customText(
      BuildContext context,
      String title,
      double size,
      Color? color,
      String family,
     {TextAlign textAlign = TextAlign.start,}
      ) {
    return Text(
      title,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: family,
        fontSize: size.dp,
        color: color,
          decoration: TextDecoration.none
      ),
    );
  }


  Widget orWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade500,
            thickness: 1,
            endIndent: 8,
          ),
        ),
        customText(context, 'or', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
        Expanded(
          child: Divider(
            color: Colors.grey.shade500,
            thickness: 1,
            indent: 8,
          ),
        ),
      ],
    );
  }


  ///Method to show Loading bar in the center of screen
  ///[startLoading] - param to indicate whether the loading bar needs to start or end
  ///[context] - build context of the mapped widgets
  showLoadingBar(bool startLoading, BuildContext context,
      {bool showText = false, String title = ''}) async {
    if (!context.mounted) return;
    if (startLoading) {
      LoadingBarOverlay.show(context);
    } else {
      LoadingBarOverlay.hide();
    }
  }

<<<<<<< HEAD


  void showLocationSettingsAlert(BuildContext context,
      {VoidCallback? onCancel, VoidCallback? openSettings}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: objConstantColor.white,
        title: objCommonWidgets.customText(context, 'Location Services Disabled', 17, objConstantColor.navyBlue, objConstantFonts.montserratBold),
        content: objCommonWidgets.customText(context, 'Please enable location services in Settings.', 14, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
        actions: [
          TextButton(
            onPressed: () async {
              Future.delayed(const Duration(milliseconds: 200), () {
                Navigator.pop(context);
                (OpenSettingsPlus.shared as OpenSettingsPlusIOS)
                    .locationServices();
              });

              if (openSettings != null) {
                openSettings();
              }

              /// Add a slight delay before dismissing the dialog
            },
            child: objCommonWidgets.customText(context, 'Open Settings', 14, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onCancel != null) {
                onCancel();
              }
            },
            child: objCommonWidgets.customText(context, 'Cancel', 14, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
          ),
        ],
      ),
    );
  }


  Future<void> showPermissionDialog(BuildContext context,
      {VoidCallback? onOpenSettings}) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: objConstantColor.white,
        title: objCommonWidgets.customText(context, 'Location Permission Required', 20, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
        content: objCommonWidgets.customText(context, 'Please enable location permission in Settings', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: objCommonWidgets.customText(context, 'Cancel', 14, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onOpenSettings != null) {
                onOpenSettings();
              }
              AppSettings.openAppSettings();
            },
            child: objCommonWidgets.customText(context, 'Open Settings', 14, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
          ),
        ],
      ),
    );
  }

=======
>>>>>>> dfdff9d8cd23a9cdbbd4a1bc6a20349b46a4ff7a
}
