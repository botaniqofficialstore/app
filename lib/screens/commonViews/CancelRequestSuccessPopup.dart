
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../constants/ConstantVariables.dart';

class CancelRequestSuccessPopup extends StatelessWidget {
  const CancelRequestSuccessPopup({super.key});

  static Future<void> show(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Order Cancelled',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: const PopScope(
            canPop: false,
            child: CancelRequestSuccessPopup(),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.dp, vertical: 28.dp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.dp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Modern Gradient Success Icon
            Container(
              height: 90.dp,
              width: 90.dp,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4CAF50),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 50.dp,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 24.dp),

            objCommonWidgets.customText(context,
                'Order Cancelled Successfully', 13,
                Colors.black, objConstantFonts.montserratSemiBold
            ),

            SizedBox(height: 10.dp),

            objCommonWidgets.customText(context, "Your order has been cancelled as requested. "
                "If payment was completed, your refund will be processed "
                "to the original payment method within 5–7 business days.", 10, Colors.black, objConstantFonts.montserratMedium,
            textAlign: TextAlign.center),


            SizedBox(height: 30.dp),

            /// Modern CTA Button
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.dp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.dp),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7A18), Color(0xFFFF5722)],
                  ),
                ),
                child: Center(
                  child: objCommonWidgets.customText(context,
                      'Continue Shopping', 13,
                      Colors.white, objConstantFonts.montserratSemiBold
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


