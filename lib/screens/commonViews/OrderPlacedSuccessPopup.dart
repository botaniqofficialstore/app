import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:lottie/lottie.dart';


class OrderPlacedSuccessPopup extends StatelessWidget {
  final VoidCallback onDonePressed;

  const OrderPlacedSuccessPopup(
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30.dp),

            // Success Animation
            Lottie.asset(
              objConstantAssest.orderSuccess,
              animate: true,
              repeat: false,
              height: 120.dp,
            ),
            SizedBox(height: 10.dp),

            // Headline
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.dp),
          child:
            objCommonWidgets.customText(
              context,
              'Your Microgreens Are On The Way! 🌱',
              18,
              objConstantColor.navyBlue,
              objConstantFonts.montserratSemiBold,
              textAlign: TextAlign.center
            ),
        ),
            SizedBox(height: 10.dp),

            // Subtext
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.dp),
              child: objCommonWidgets.customText(
                  context,
                  'Thank you for your order! We’ll harvest your greens fresh and notify you once they are ready for delivery.',
                  13,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratMedium,
                  textAlign: TextAlign.center
              )
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



  static void showOrderConfirmationPopup(BuildContext context,
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
              child: OrderPlacedSuccessPopup(onDonePressed: onDonePressed ?? () {}),
            );
          },
        );
      }

  }


}
