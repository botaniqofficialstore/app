import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:lottie/lottie.dart';


class ProfileUpdateSuccesspopup extends StatelessWidget {
  final VoidCallback onDonePressed;

  const ProfileUpdateSuccesspopup(
      {super.key, required this.onDonePressed});


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.dp),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: objConstantColor.white,
          borderRadius: BorderRadius.circular(25.dp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30.dp),

            // Success Animation
            Lottie.asset(
              objConstantAssest.profileSuccess,
              animate: true,
              repeat: false,
              height: 120.dp,
            ),
            SizedBox(height: 10.dp),

            // Headline
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.dp),
              child: objCommonWidgets.customText(
                context,
                'Profile Updated!',
                20,
                objConstantColor.navyBlue,
                objConstantFonts.montserratSemiBold,
              ),
            ),
            SizedBox(height: 20.dp),

            // Motivational / positive subtext
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.dp),
              child: objCommonWidgets.customText(
                context,
                'Great! Your journey just got a fresh update.',
                15,
                objConstantColor.navyBlue,
                objConstantFonts.montserratMedium,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8.dp),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.dp),
              child: objCommonWidgets.customText(
                context,
                'Keep going, the best is yet to come!',
                13,
                objConstantColor.navyBlue,
                objConstantFonts.montserratRegular,
                textAlign: TextAlign.center,
                //textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 30.dp),

            // Full-width CTA button
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25.dp),
                  bottomRight: Radius.circular(25.dp),
                ),
                color: objConstantColor.navyBlue,
                padding: EdgeInsets.symmetric(vertical: 18.dp),
                child: objCommonWidgets.customText(
                  context,
                  'Got It',
                  18,
                  objConstantColor.white,
                  objConstantFonts.montserratBold,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }




  Widget customText(
      BuildContext context,
      String title,
      double size,
      Color? color,
      String family,
      ) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: family,
        fontSize: size.dp,
        color: color,
      ),
    );
  }



  static void showSuccessConfirmationPopup(BuildContext context,
      {VoidCallback? onDonePressed}) {
    if (!context.mounted) return;

      if (context.mounted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return PopScope(
              onPopInvokedWithResult: (v, b) async {

              },
              child: ProfileUpdateSuccesspopup(onDonePressed: onDonePressed ?? () {}),
            );
          },
        );
      }

  }


}
