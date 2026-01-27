import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:lottie/lottie.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../Utility/NetworkImageLoader.dart';
import '../../../../constants/ConstantAssests.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'OrderSummaryScreenState.dart';


class OrderSummaryScreen extends ConsumerStatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  OrderSummaryScreenState createState() => OrderSummaryScreenState();
}

class OrderSummaryScreenState extends ConsumerState<OrderSummaryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final summaryScreenNotifier = ref.read(OrderSummaryScreenGlobalStateProvider.notifier);
      summaryScreenNotifier.updateCartListAndUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);
    var userScreenState = ref.watch(OrderSummaryScreenGlobalStateProvider);
    final orderSummaryScreenNotifier = ref.watch(OrderSummaryScreenGlobalStateProvider.notifier);
    final cartItems = userScreenState.cartItems;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFFFFFFF),
        body: Column(
          children: [

        Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.dp),
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// Back button (left aligned)
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                minimumSize: const Size(0, 0),
                padding: EdgeInsets.zero,
                onPressed: () {
                  userScreenNotifier.callNavigation(ScreenName.cart);
                },
                child: Image.asset(
                  objConstantAssest.backIcon,
                  height: 20.dp,
                  color: objConstantColor.navyBlue,
                ),
              ),
            ),

            /// Center title
            objCommonWidgets.customText(
              context,
              'Checkout',
              18,
              objConstantColor.navyBlue,
              ConstantAssests.montserratSemiBold,
            ),
          ],
        ),
      ),

            SizedBox(height: 10.dp),


      /// Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
      
                    SizedBox(height: 5.dp),
      
                    /// Purchase Details Card
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.dp),
                      decoration: BoxDecoration(
                        color: objConstantColor.white,
                        borderRadius: BorderRadius.circular(10.dp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// Expandable Purchase Details
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF373737),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.dp),
                                topLeft: Radius.circular(10.dp),
                                bottomLeft: Radius.circular(_isExpanded ? 2.dp : 10.dp),
                                bottomRight: Radius.circular(_isExpanded ? 2.dp : 10.dp),
                              ),
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.dp),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: 2.dp),
                                    objCommonWidgets.customText(
                                      context,
                                      'Purchase Details',
                                      15,
                                      objConstantColor.white,
                                      ConstantAssests.montserratSemiBold,
                                    ),
                                    const Spacer(),
                                    AnimatedRotation(
                                      turns: _isExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 300),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 35.dp,
                                        color: objConstantColor.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
      
                          (_isExpanded)
                              ? Divider(
                            color: objConstantColor.gray.withOpacity(0.4),
                            thickness: 1.5,
                            height: 1.5,
                          )
                              : const SizedBox.shrink(),
      
                          SizedBox(height: _isExpanded ? 10.dp : 0.dp),
      
                          AnimatedSize(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInCubic,
                            child: _isExpanded
                                ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.dp),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  final details = item.productDetails!;
                                  bool isNotLast = index != cartItems.length - 1;
      
                                  return cell(
                                    context,
                                    index,
                                    details.productName,
                                    details.productSellingPrice.toString(),
                                    details.productPrice.toString(),
                                    details.gram.toString(),
                                    item.productCount,
                                    details.image,
                                    isNotLast,
                                  );
                                },
                              ),
                            )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
      
                    SizedBox(height: 18.dp),
      
                    /// Payment
                    Column(
                      children: [
      
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.dp),
                          child: paymentType(context),
                        ),
                        SizedBox(height: 15.dp),
                      ],
                    ),
      
      
                    SizedBox(height: 10.dp),
      
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.dp),
                      child: Divider(color: objConstantColor.navyBlue,
                        height: 0.5, thickness: 0.5.dp,),
                    ),
      
      
      
                    /// Shipping Address Card
                    ShippingAddressCard(
                      name: userScreenState.userName,
                      phone: "+91 ${userScreenState.mobileNumber}",
                      email: userScreenState.email,
                      address: userScreenState.address,
                      onEdit: () {
                        userScreenNotifier.callNavigation(ScreenName.editProfile);
                      },
                    ),
      
      
                    SizedBox(height: 10.dp),
      
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.dp),
                      child: Divider(color: objConstantColor.navyBlue,
                      height: 0.5, thickness: 0.5.dp,),
                    ),
      
                    /// Price Details
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.dp, vertical: 10.dp),
                      child: priceDetail(context, userScreenState),
                    ),
      
      
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.dp, vertical: 10.dp),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          orderSummaryScreenNotifier.callPlaceOrderAPI(context, userScreenNotifier);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15.dp, horizontal: 20.dp),
                          decoration: BoxDecoration(
                            color: objConstantColor.navyBlue,
                            borderRadius: BorderRadius.circular(25.dp),
                          ),
                          child: Center(
                            child: objCommonWidgets.customText(
                              context,
                              'Place Order',
                              16,
                              Colors.white,
                              ConstantAssests.montserratSemiBold,
                            ),
                          ),
                        ),
                      ),
                    ),
      
                    SizedBox(height: 10.dp),
      
                  ],
                ),
              ),
            ),
      
          ],
        ),
      ),
    );
  }



  Widget paymentType(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.dp),
      decoration: BoxDecoration(
      color: objConstantColor.white,
      borderRadius: BorderRadius.circular(10.dp),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 5,
          offset: const Offset(1, 0),
        ),
      ],

      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                objCommonWidgets.customText(
                  context,
                  'Payment Type',
                  13,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratSemiBold,
                ),
                SizedBox(height: 15.dp,),

                objCommonWidgets.customText(
                  context,
                  'Cash on Delivery',
                  18,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratSemiBold,
                ),
                SizedBox(height: 2.dp),

                objCommonWidgets.customText(
                  context,
                  'Pay when your product arrives to your home.',
                  10,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratMedium,
                ),
              ],
            ),
          ),

          Lottie.asset(
            objConstantAssest.paymentType,
            height: 120.dp,
            repeat: true,
          ),

        ],
      ),
    );
  }



  Widget priceDetail(BuildContext context, OrderSummaryScreenGlobalState notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        objCommonWidgets.customText(
            context, 'Price Details', 16, objConstantColor.navyBlue,
            objConstantFonts.montserratSemiBold),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.dp,),
            amountText(context, 'Amount', '${notifier.totalAmount}', ConstantAssests.montserratMedium, 12, 12),
            amountText(
                context, 'Discount', '${notifier.totalDiscount}', ConstantAssests.montserratMedium, 12, 12),
            amountText(context, 'Delivery Charge', '89', ConstantAssests.montserratMedium, 12, 12),
            SizedBox(height: 10.dp,),
            DottedLine(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              lineLength: double.infinity,
              lineThickness: 1.5,
              dashLength: 8.0,
              dashColor: objConstantColor.black.withAlpha(50),
              dashRadius: 0.0,
              dashGapLength: 4.0,
              dashGapColor: Colors.transparent,
              dashGapRadius: 0.0,
            ),
            SizedBox(height: 10.dp,),
            amountText(context, 'Payable Amount', '${notifier.totalPayableAmount}',
                ConstantAssests.montserratSemiBold, 18, 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                objCommonWidgets.customText(
                  context,
                  'Inc. of all taxes',
                  8,
                  objConstantColor.navyBlue,
                  ConstantAssests.montserratMedium,
                ),
              ],
            ),
            SizedBox(height: 20.dp,),
          ],
        )


      ],
    );
  }






  /// Cell Widget
  Widget cell(
      BuildContext context,
      int index,
      String productName,
      String price,
      String actualPrice,
      String gram,
      int count,
      String image,
      bool isNotLastIndex,
      ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 👈 center align with image
          children: [
            /// Image
            Container(
              width: 70.dp,
              height: 70.dp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.dp),
                border: Border.all(
                  color: objConstantColor.navyBlue,
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.dp),
                child: NetworkImageLoader(
                  imageUrl: '${ConstantURLs.baseUrl}$image',
                  placeHolder: objConstantAssest.placeHolder,
                  size: 40.dp,
                  imageSize: 70.dp,
                ),
              ),
            ),

            SizedBox(width: 12.dp),

            /// Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.dp), // 👈 add slight padding for balance
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    objCommonWidgets.customText(
                      context,
                      CodeReusability().cleanProductName(productName),
                      14,
                      objConstantColor.navyBlue,
                      objConstantFonts.montserratSemiBold,
                    ),
                    SizedBox(height: 2.dp),

                    /// Price
                    Row(
                      children: [
                        objCommonWidgets.customText(
                          context,
                          'Price:',
                          11,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratSemiBold,
                        ),
                        SizedBox(width: 5.dp,),
                        objCommonWidgets.customText(
                          context,
                          '₹$price/_',
                          11,
                          objConstantColor.green,
                          objConstantFonts.montserratSemiBold,
                        ),

                      ],
                    ),
                    SizedBox(height: 2.dp),

                    /// Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: objCommonWidgets.customText(
                            context,
                            'Quantity: $count',
                            11,
                            objConstantColor.navyBlue,
                            objConstantFonts.montserratSemiBold,
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 2.dp),

                    /// Net Weight
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              objCommonWidgets.customText(
                                context,
                                'Net Wt (per item): $gram',
                                11,
                                objConstantColor.navyBlue,
                                objConstantFonts.montserratSemiBold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        /// Divider
        if (isNotLastIndex)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.dp),
            child: Divider(
              color: objConstantColor.gray.withOpacity(0.4),
              thickness: 1.5,
              height: 1.5,
            ),
          )
        else
          SizedBox(height: 10.dp),
      ],
    );
  }



  Widget amountText(BuildContext context,String name, String value, String font, double size,  double textSize){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.dp),
      child: Row(
        children: [
          objCommonWidgets.customText(context,
            name,
            textSize,
            objConstantColor.navyBlue,
            font,
          ),
          const Spacer(),
          objCommonWidgets.customText(context,
            '₹$value/_',
            size,
            objConstantColor.navyBlue,
            font,
          )
        ],
      ),
    );
  }


}


class ShippingAddressCard extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final String address;
  final VoidCallback onEdit;

  const ShippingAddressCard({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: 5.dp),
          /// Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              objCommonWidgets.customText(context, "Shipping Address", 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
              SizedBox(width: 10.dp),
              CupertinoButton(
                onPressed: onEdit, padding: EdgeInsets.zero,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 5.dp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.dp),
                    border: BoxBorder.all(width: 0.5.dp, color: objConstantColor.orange)
                  ),
                  child: Row(
                    children: [
                      objCommonWidgets.customText(context, 'Update', 12, objConstantColor.orange, objConstantFonts.montserratBold),
                    ],
                  ),
                ),
              ),
            ],
          ),


          objCommonWidgets.customText(context, name, 12, objConstantColor.navyBlue, objConstantFonts.montserratMedium),

          objCommonWidgets.customText(context, phone, 12, objConstantColor.navyBlue, objConstantFonts.montserratMedium),

          objCommonWidgets.customText(context, email, 12, objConstantColor.navyBlue, objConstantFonts.montserratMedium),

          objCommonWidgets.customText(context, address, 12, objConstantColor.navyBlue, objConstantFonts.montserratMedium),

          SizedBox(height: 10.dp),
        ],
      ),
    );
  }

}






