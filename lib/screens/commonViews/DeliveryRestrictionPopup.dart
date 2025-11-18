import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

import '../../Utility/PreferencesManager.dart';

class DeliveryRestrictionPopup extends StatelessWidget {
  const DeliveryRestrictionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.dp),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 25.dp),
      child: Container(
        padding: EdgeInsets.all(20.dp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.dp),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12.dp,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            SizedBox(height: 10.dp),
            // Icon
            Container(
              padding: EdgeInsets.all(18.dp),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 50.dp,
                color: objConstantColor.orange,
              ),
            ),
            SizedBox(height: 30.dp),

            // Title
            objCommonWidgets.customText(context, 'Delivery Not Available', 17,
                objConstantColor.navyBlue, objConstantFonts.montserratBold),
            SizedBox(height: 18.dp),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.dp),
              child: objCommonWidgets.customText(context,
                  'Thank you for checking! Your location is slightly outside our current delivery zone. We’re updating routes soon, and hope to reach your neighbourhood very soon.',
                  12,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratSemiBold,
                  textAlign: TextAlign.justify),
            ),

            SizedBox(height: 25.dp),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: objConstantColor.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.dp),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15.dp),
                ),
                onPressed: () {
                  PreferencesManager.getInstance().then((pref) {
                    pref.setBooleanValue(PreferenceKeys.isDialogOpened, false);
                    Navigator.pop(context);
                  });
                },
                child: objCommonWidgets.customText(context, 'Okay',
                    15,
                    objConstantColor.white,
                    objConstantFonts.montserratBold),
              ),
            )
          ],
        ),
      ),
    );
  }
}


