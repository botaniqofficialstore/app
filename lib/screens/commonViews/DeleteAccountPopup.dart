import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../Utility/PreferencesManager.dart';
import '../../constants/ConstantVariables.dart';

class DeleteAccountPopup {
  /// Modern animated logout confirmation popup
  static Future<void> showDeleteAccountPopup({
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
            child: _DeleteAccountPopupContent(
              onConfirm: onConfirm,
            ),
          ),
        );
      },
    );
  }
}

class _DeleteAccountPopupContent extends StatelessWidget {
  final VoidCallback onConfirm;
  const _DeleteAccountPopupContent({required this.onConfirm});

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Logout Icon
                Stack(
                  children: [
                    Container(
                      width: 75.dp,
                      height: 75.dp,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0404).withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                    ),

                    Positioned(top: 0, bottom: 5, left: 0, right: 0,
                        child: Icon(
                      Icons.warning_rounded,
                      size: 45.dp,
                      color: const Color(0xFFFF0404),
                    ))
                  ],
                ),
                SizedBox(height: 20.dp),

                // 🔹 Title
                objCommonWidgets.customText(
                  context,
                  'Delete Account',
                  15,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratMedium,
                ),

                SizedBox(height: 8.dp),

                objCommonWidgets.customText(
                    context,
                    'Closing your account will delete your profile and personal data permanently. You will no longer be able to access your purchase history or loyalty points.',
                    10,
                    objConstantColor.black.withAlpha(140),
                    objConstantFonts.montserratRegular,
                  textAlign: TextAlign.justify
                ),

                SizedBox(height: 20.dp),

                objCommonWidgets.customText(
                    context,
                    'Are you sure you want to close your account for permanent?',
                    10,
                    Colors.redAccent,
                    objConstantFonts.montserratRegular,
                    textAlign: TextAlign.center
                ),

                SizedBox(height: 15.dp),

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
                                color: Colors.black.withAlpha(150), width: 1),
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
                              'Confirm',
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
