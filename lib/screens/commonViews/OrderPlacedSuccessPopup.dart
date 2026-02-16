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
              height: 100.dp,
            ),
            SizedBox(height: 10.dp),

            // Headline
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.dp),
          child:
            objCommonWidgets.customText(
              context,
              'Order Purchased Successfully',
              15,
              Colors.black,
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
                  'Thank you for your order!, and keep going on...',
                  11,
                  Colors.black,
                  objConstantFonts.montserratMedium,
                  textAlign: TextAlign.center
              )
            ),

            SizedBox(height: 30.dp),

            // Full-width CTA button
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 50.dp),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(20.dp)
                ),
                child: objCommonWidgets.customText(
                  context,
                  'Got It',
                  15,
                  objConstantColor.white,
                  objConstantFonts.montserratSemiBold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            SizedBox(height: 15.dp),
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
