import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;

import '../Constants/Constants.dart';
import '../Utility/LoadingBarOverlay.dart';
import '../Utility/NetworkImageLoader.dart';
import '../screens/InnerScreens/ContainerScreen/HomeScreen/HomeScreenModel.dart';
import 'CodeReusability.dart';

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


  void showAddToCartSheet(BuildContext context, ProductData product, ValueChanged<int> addToCart) {
    int quantity = 1; // Default starting quantity

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(20.dp),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.dp),
                  topRight: Radius.circular(20.dp),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar for visual cue
                  Center(
                    child: Container(
                      width: 40.dp,
                      height: 4.dp,
                      margin: EdgeInsets.only(bottom: 20.dp),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.dp),
                        child: SizedBox(
                          height: 90.dp,
                          width: 90.dp,
                          child: NetworkImageLoader(
                            imageUrl: '${ConstantURLs.baseUrl}${product.image}',
                            placeHolder: objConstantAssest.placeHolder,
                            size: 90.dp,
                            imageSize: 90.dp,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.dp),

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            objCommonWidgets.customText(
                                context,
                                CodeReusability().cleanProductName(product.productName),
                                15, Colors.black, objConstantFonts.montserratSemiBold
                            ),
                            SizedBox(height: 4.dp),

                            Row(
                              children: [
                                objCommonWidgets.customText(
                                    context, "₹${product.productSellingPrice}",
                                    16, Colors.black, objConstantFonts.montserratSemiBold
                                ),
                                SizedBox(width: 8.dp),
                                Text(
                                  "₹${product.productPrice}",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15.dp,
                                      decoration: TextDecoration.lineThrough,
                                      fontFamily: objConstantFonts.montserratMedium
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.dp),
                            objCommonWidgets.customText(
                                context, "${product.gram}gm",
                                13, Colors.black.withAlpha(150), objConstantFonts.montserratMedium
                            ),
                            SizedBox(height: 4.dp),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Divider(height: 30.dp, thickness: 1),

                  // Quantity Selector Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      objCommonWidgets.customText(
                          context, "Select Quantity",
                          15, Colors.black, objConstantFonts.montserratSemiBold
                      ),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: objConstantColor.navyBlue.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(8.dp),
                        ),
                        child: Row(
                          children: [
                            _quantityButton(Icons.remove, () {
                              if (quantity > 1) setModalState(() => quantity--);
                            }),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.dp),
                              child: objCommonWidgets.customText(
                                  context, "$quantity",
                                  16, Colors.black, objConstantFonts.montserratSemiBold
                              ),
                            ),
                            _quantityButton(Icons.add, () {
                              setModalState(() => quantity++);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30.dp),

                  // Final Add Button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 13.dp),
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(20.dp),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                      ),
                      child: Center(
                        child: objCommonWidgets.customText(
                            context, "Add to Cart",
                            15, Colors.white, objConstantFonts.montserratSemiBold
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      addToCart(quantity);
                    },
                  ),
                  SizedBox(height: 10.dp),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.dp),
        color: Colors.transparent,
        child: Icon(icon, size: 20.dp, color: objConstantColor.navyBlue),
      ),
    );
  }

}
