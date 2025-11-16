import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../CodeReusable/CodeReusability.dart';
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
  bool _isExpanded = false;

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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: objConstantColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: objConstantColor.white,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 8, spreadRadius: 1),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 2.dp, top: 5.dp, bottom: 5.dp),
              child: Row(
                children: [
                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Image.asset(objConstantAssest.backIcon, width: 25.dp,), onPressed: (){
                    userScreenNotifier.callNavigation(ScreenName.cart);
                  }),
                  objCommonWidgets.customText(context,
                    'Order Summary',
                    20,
                    objConstantColor.navyBlue,
                    ConstantAssests.montserratBold,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5.dp),

          /// Purchase Details with toggle button
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [




                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 12.dp, vertical: 8.dp), // adds spacing around
                        decoration: BoxDecoration(
                          color: objConstantColor.white,
                          borderRadius: BorderRadius.circular(5.dp),
                            border: Border.all(
                              color: objConstantColor.gray.withOpacity(0.8),
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.09),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: const Offset(0, 3),
                              )
                            ]
                        ),
                        child:

                        Column(
                          children: [


                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child:
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.dp),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(width: 2.dp,),
                                  objCommonWidgets.customText(
                                    context,
                                    'Purchase Details',
                                    18,
                                    objConstantColor.navyBlue,
                                    ConstantAssests.montserratSemiBold,
                                  ),
                                  const Spacer(),
                                  AnimatedRotation(
                                      turns: _isExpanded ? 0.5 : 0, // rotate arrow
                                      duration: const Duration(milliseconds: 300),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 35.dp,
                                        color: objConstantColor.navyBlue,
                                      ),
                                    ),

                                ],
                              ),
                            ),
                            ),



                            (_isExpanded) ?
                            /// Divider
                            Divider(
                              color: objConstantColor.gray.withOpacity(0.4),
                              thickness: 1.5,
                              height: 1.5,
                            ) : const SizedBox.shrink(),

                            SizedBox(height: _isExpanded ? 10.dp : 0.dp,),

                            AnimatedSize(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInCubic,
                              child: _isExpanded ?

                              /// Cart List
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.dp),
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = cartItems[index];
                                    final details = item.productDetails!;
                                    bool isNotLast = index != cartItems.length - 1;

                                    return cell(context,
                                      index,
                                        details.productName,
                                        details.productSellingPrice.toString(),
                                        details.productPrice.toString(),
                                        details.gram.toString(),
                                        item.productCount,
                                        details.image, isNotLast
                                    );
                                  },
                                ),
                              )
                                  : const SizedBox.shrink(),
                            ),

                          ],
                        )
                      ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.dp, vertical: 10.dp),
                      child: paymentType(context),
                    ),

                    SizedBox(height: 5.dp,),

                    ShippingAddressCard(
                        name: userScreenState.userName,
                        phone: "+91 ${userScreenState.mobileNumber}",
                        email: userScreenState.email,
                        address: userScreenState.address,
                        onEdit: () {
                          userScreenNotifier.callNavigation(ScreenName.editProfile);
                        }
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.dp, vertical: 10.dp),
                      child: priceDetail(context, userScreenState),
                    ),


                    SizedBox(height: 5.dp,),

              ],
                ),
              ),
            ),
          ),



          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: objConstantColor.white,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 8, spreadRadius: 1),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.dp, 20.dp, 20.dp, 20.dp),
              child: Row(
                children: [

                  Column(
                    children: [
                      objCommonWidgets.customText(context,
                        '₹${'${userScreenState.totalPayableAmount}'}/_',
                        20,
                        objConstantColor.navyBlue,
                        ConstantAssests.montserratBold,
                      ),
                      objCommonWidgets.customText(context,
                        'Inc. of all taxes',
                        10,
                        objConstantColor.navyBlue,
                        ConstantAssests.montserratMedium,
                      )
                    ],
                  ),

                  const Spacer(),

                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        orderSummaryScreenNotifier.callPlaceOrderAPI(context, userScreenNotifier);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.dp, horizontal: 20.dp),
                        decoration: BoxDecoration(
                          color: objConstantColor.green,
                          borderRadius: BorderRadius.circular(4.dp),
                          border: Border.all(
                            color: objConstantColor.navyBlue,
                            width: 1,
                          ),
                        ),
                        child:  Shimmer.fromColors(
                          baseColor: objConstantColor.white,
                          highlightColor: objConstantColor.black,
                          child: objCommonWidgets.customText(context,
                            'Place Order',
                            20,
                            objConstantColor.white,
                            ConstantAssests.montserratBold,
                          ),
                        ),
                      )
                  ),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget paymentType(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.dp),
      decoration: BoxDecoration(
        color: objConstantColor.white,
        borderRadius: BorderRadius.circular(12.dp), // rectangular with light rounding
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          )
        ],
        border: Border.all(color: objConstantColor.navyBlue.withOpacity(0.2)),
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
                  'Cash on Delivery',
                  20,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratSemiBold,
                ),
                SizedBox(height: 6.dp),
                objCommonWidgets.customText(
                  context,
                  'Pay when your fresh microgreens arrive 🌱',
                  13,
                  Colors.grey.shade600,
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
            context, 'Price Details', 18, objConstantColor.navyBlue,
            objConstantFonts.montserratSemiBold),

        SizedBox(height: 2.dp,),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.dp),
            color: objConstantColor.gray.withOpacity(0.15),
            border: Border.all(
              color: objConstantColor.gray.withOpacity(0.8),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5.dp,),
                amountText(
                    context, 'Amount', '${notifier.totalAmount}', ConstantAssests.montserratMedium, 15, 15),
                amountText(
                    context, 'Discount', '${notifier.totalDiscount}', ConstantAssests.montserratMedium, 15, 15),
                amountText(context, 'Delivery Charge', '89', ConstantAssests.montserratMedium, 15, 15),
                SizedBox(height: 5.dp,),
                DottedLine(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  lineLength: double.infinity,
                  lineThickness: 2.0,
                  dashLength: 8.0,
                  dashColor: objConstantColor.gray.withOpacity(0.4),
                  dashRadius: 0.0,
                  dashGapLength: 4.0,
                  dashGapColor: Colors.transparent,
                  dashGapRadius: 0.0,
                ),
                SizedBox(height: 5.dp,),
                amountText(context, 'Payable Amount', '${notifier.totalPayableAmount}',
                    ConstantAssests.montserratSemiBold, 18, 18),
                SizedBox(height: 15.dp,),
              ],
            ),
          ),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.dp),
                border: Border.all(
                  color: objConstantColor.navyBlue,
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.dp),
                child: Image.network(
                  '${ConstantURLs.baseUrl}$image',
                  width: 80.dp,
                  height: 80.dp,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      objConstantAssest.placeHolder, // fallback image from assets
                      width: 80.dp,
                      height: 80.dp,
                      fit: BoxFit.cover,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CupertinoActivityIndicator(
                        color: objConstantColor.gray,
                      ),
                    );
                  },
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
                      17,
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
                          14,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratSemiBold,
                        ),
                        SizedBox(width: 5.dp,),
                        objCommonWidgets.customText(
                          context,
                          '₹$price/_',
                          14,
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
                            14,
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
                                14,
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
            '₹${value}/_',
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 10.dp),
      padding: EdgeInsets.all(10.dp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.dp),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              objCommonWidgets.customText(context, "Shipping Address", 18, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),

              CupertinoButton(
                borderRadius: BorderRadius.circular(8.dp),
                onPressed: onEdit, padding: EdgeInsets.zero,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 6.dp),
                  decoration: BoxDecoration(
                    color: objConstantColor.litegray,
                    borderRadius: BorderRadius.circular(5.dp),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16.dp, color: objConstantColor.navyBlue),
                      SizedBox(width: 4.dp),
                      Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 15.dp,
                          fontWeight: FontWeight.w600,
                          color: objConstantColor.navyBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.dp),
          Divider(height: 1, color: Colors.grey.shade300),
          SizedBox(height: 12.dp),

          /// Details
          Row(
            children: [
              Icon(Icons.person, size: 20.dp, color: objConstantColor.navyBlue),
              SizedBox(width: 10.dp),
              objCommonWidgets.customText(context, name, 14, objConstantColor.navyBlue, objConstantFonts.montserratMedium),
            ],
          ),
          SizedBox(height: 5.dp),

          Row(
            children: [
              Icon(Icons.phone, size: 20.dp, color: objConstantColor.navyBlue),
              SizedBox(width: 10.dp),
              objCommonWidgets.customText(context, phone, 14, objConstantColor.navyBlue, objConstantFonts.montserratMedium),
            ],
          ),
          SizedBox(height: 5.dp),

          Row(
            children: [
              Icon(Icons.email, size: 20.dp, color: objConstantColor.navyBlue),
              SizedBox(width: 10.dp),
              Expanded(
                child: objCommonWidgets.customText(context, email, 14, objConstantColor.navyBlue, objConstantFonts.montserratMedium),
              ),
            ],
          ),
          SizedBox(height: 5.dp),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 20.dp, color: objConstantColor.navyBlue),
              SizedBox(width: 10.dp),
              Expanded(
                child: objCommonWidgets.customText(context, address, 14, objConstantColor.navyBlue, objConstantFonts.montserratMedium),
              ),
            ],
          ),

          SizedBox(height: 10.dp),

        ],
      ),
    );
  }
}







