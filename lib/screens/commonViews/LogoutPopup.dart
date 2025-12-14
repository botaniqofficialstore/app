import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../Utility/PreferencesManager.dart';
import '../../constants/ConstantAssests.dart';
import '../../constants/ConstantVariables.dart';

class LogoutPopup {
  /// Modern animated logout confirmation popup
  static Future<void> showLogoutPopup({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    showGeneralDialog(
      context: context,
      barrierLabel: "Logout",
      barrierDismissible: false,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue =
            Curves.easeInOut.transform(anim1.value) - 1.0;

        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * -50, 0.0),
          child: Opacity(
            opacity: anim1.value,
            child: _LogoutPopupContent(
              onConfirm: onConfirm,
            ),
          ),
        );
      },
    );
  }
}

class _LogoutPopupContent extends StatelessWidget {
  final VoidCallback onConfirm;
  const _LogoutPopupContent({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Logout Icon
                Container(
                  decoration: BoxDecoration(
                    color: objConstantColor.redd.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(16.dp),
                  child: Icon(
                    CupertinoIcons.power,
                    size: 35.dp,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: 15.dp),

                // 🔹 Title
                objCommonWidgets.customText(
                  context,
                  'Logout',
                  20,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratSemiBold,
                ),

                SizedBox(height: 8.dp),

                objCommonWidgets.customText(
                  context,
                  'Are you sure you want to logout?',
                  12,
                  objConstantColor.black,
                  objConstantFonts.montserratRegular,
                  textAlign: TextAlign.center
                ),

                SizedBox(height: 40.dp),

                // 🔹 Buttons
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          final pref = await PreferencesManager.getInstance();
                          pref.setBooleanValue(PreferenceKeys.isDialogOpened, false);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: objConstantColor.navyBlue, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                          child: objCommonWidgets.customText(
                            context,
                            'Cancel',
                            14,
                            objConstantColor.black,
                            objConstantFonts.montserratSemiBold,
                                                  ),
                      ),
                    ),
                    ),
                     SizedBox(width: 10.dp),
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                          alignment: Alignment.center,
                          child: objCommonWidgets.customText(
                              context,
                              'Logout',
                              14,
                              objConstantColor.white,
                              objConstantFonts.montserratSemiBold,
                          )
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
