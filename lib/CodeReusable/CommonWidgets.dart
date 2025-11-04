import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

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

}
