
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../constants/ConstantVariables.dart';

class ReturnRequestSuccessPopup extends StatelessWidget {
  const ReturnRequestSuccessPopup({super.key});

  /// Static method to show the popup
  static Future<void> show(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Request Submitted',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: const PopScope(
            canPop: false,
            child: ReturnRequestSuccessPopup(),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curvedValue,
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
        padding: EdgeInsets.all(22.dp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.dp),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Success Icon
            Container(
              height: 85.dp,
              width: 85.dp,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green
              ),
              child: Icon(
                Icons.check_rounded,
                size: 45.dp,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 22.dp),

            /// Title
            objCommonWidgets.customText(
              context,
              "Return Request Submitted Successfully!",
              15,
              Colors.black,
              objConstantFonts.montserratSemiBold,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.dp),

            /// Description
            objCommonWidgets.customText(
              context,
              "Your return request has been received and is currently under review. Our delivery partner will contact you shortly to schedule the pickup from your doorstep.",
              10,
              Colors.black87,
              objConstantFonts.montserratMedium,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.dp),

            objCommonWidgets.customText(
              context,
              "Please ensure the product is securely packed and that you are available during the pickup. Once the item is received and verified, your refund will be processed within 5–7 business days.",
              10,
              Colors.black.withAlpha(150),
              objConstantFonts.montserratMedium,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 26.dp),

            /// CTA Button
            CupertinoButton(
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.dp),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.dp),
                    color: Colors.deepOrange
                ),
                child: Center(
                  child: objCommonWidgets.customText(
                    context,
                    "Continue Shopping",
                    13,
                    Colors.white,
                    objConstantFonts.montserratSemiBold,
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
