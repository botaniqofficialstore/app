// CartScreen.dart
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../Utility/NetworkImageLoader.dart';
import '../../../../constants/ConstantAssests.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'CartScreenState.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends ConsumerState<CartScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final cartScreenNotifier = ref.read(cartScreenGlobalStateProvider.notifier);
      cartScreenNotifier.callCartListGepAPI(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var userScreenState = ref.watch(cartScreenGlobalStateProvider);
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);
    final cartScreenNotifier = ref.read(cartScreenGlobalStateProvider.notifier);
    final cartItems = userScreenState.cartItems;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F4F4),
      body: RefreshIndicator(
        onRefresh: () async {
          await cartScreenNotifier.callCartListGepAPI(context);
        },
        color: objConstantColor.navyBlue,
        backgroundColor: objConstantColor.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Header
              Padding(
                padding: EdgeInsets.only(left: 10.dp, top: 5.dp, bottom: 5.dp),
                child: Row(
                  children: [
                    CupertinoButton(
                        minimumSize: const Size(0, 0),
                        padding: EdgeInsets.zero,
                        child: Image.asset(objConstantAssest.backIcon, width: 20.dp,), onPressed: (){
                      userScreenNotifier.callNavigation(ScreenName.home);
                    }),
                    SizedBox(width: 5.dp),
                    customeText(
                      'My Cart',
                      15,
                      objConstantColor.navyBlue,
                      ConstantAssests.montserratSemiBold,
                    ),
                  ],
                ),
              ),

              /// Scroll content (shimmer while loading, else real content)
              Expanded(
                child: userScreenState.isLoading
                    ?  cartShimmerLoader() : Scrollbar(
                  thickness: 6,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Builder(
                      builder: (context) {
                        if (cartItems.isEmpty) {

                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7, // fill height
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(objConstantAssest.emptyCartIcon, width: 65.dp),
                                  SizedBox(height: 1.dp),
                                  Text(
                                    "Your cart is empty.",
                                    style: TextStyle(
                                      color: objConstantColor.gray,
                                      fontSize: 13.dp,
                                      fontFamily: ConstantAssests.montserratSemiBold,
                                    ),
                                  ),

                                  SizedBox(height: 20.dp),

                                  CupertinoButton(padding: EdgeInsets.zero,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: objConstantColor.orange,
                                            borderRadius: BorderRadius.circular(5.dp)
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                                        child: objCommonWidgets.customText(context,
                                            'Shop Now',
                                            14, objConstantColor.white,
                                            objConstantFonts.montserratBold),
                                      ),
                                      onPressed: (){
                                        userScreenNotifier.callNavigation(ScreenName.home);
                                      })
                                ],
                              ),
                            ),
                          );
                        }

                        // ✅ Normal cart content
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// Cart List
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartItems.length,
                              separatorBuilder: (context, index) => Divider(color: Colors.black, height: 0.5.dp, thickness: 0.2,),
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                final details = item.productDetails!;

                                return cell(
                                    index,
                                    details.productName,
                                    details.productSellingPrice.toString(),
                                    details.productPrice.toString(),
                                    '${details.gram} gm',
                                    item.productCount,
                                    details.image,
                                    cartScreenNotifier,
                                    details.productId,
                                );
                              },
                            ),

                            SizedBox(height: 20.dp),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.dp),
                              child: Column(
                                children: [
                                  amountText(context, 'Amount', '${userScreenState.totalAmount}', ConstantAssests.montserratMedium, 12, 12),
                                  amountText(context, 'Discount', '${userScreenState.totalDiscount}', ConstantAssests.montserratMedium, 12, 12),
                                  amountText(context, 'Delivery Charge', (userScreenState.isDeliveryAddress) ? '89' : ' __', ConstantAssests.montserratMedium, 12 , 12),
                                  SizedBox(height: 10.dp),
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
                                  SizedBox(height: 10.dp),
                                  amountText(context, 'Payable Amount', (userScreenState.isDeliveryAddress) ? '${userScreenState.totalPayableAmount}' : ' __', ConstantAssests.montserratSemiBold, 13, 13,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              /// Checkout (only when not loading and cart is not empty)

              if (!userScreenState.isLoading && cartItems.isNotEmpty)
               if (userScreenState.isProfileCompleted) ...{
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: objConstantColor.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12, blurRadius: 5, spreadRadius: 1),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.dp, 10.dp, 20.dp, 10.dp),
                    child: Row(
                      children: [

                        Column(
                          children: [
                            customeText(
                              '₹${userScreenState.totalPayableAmount}/_',
                              20,
                              objConstantColor.black,
                              ConstantAssests.montserratSemiBold,
                            ),
                            customeText(
                              'Inc. of all taxes',
                              8,
                              objConstantColor.black,
                              ConstantAssests.montserratMedium,
                            )
                          ],
                        ),

                        const Spacer(),

                        CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              cartScreenNotifier.callNavigateToSummary(userScreenNotifier);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.dp, horizontal: 15.dp),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(5.dp),
                              ),
                              child: customeText(
                                'Checkout',
                                13,
                                objConstantColor.white,
                                ConstantAssests.montserratSemiBold,
                              ),
                            )
                        ),


                      ],
                    ),
                  ),
                ),
              }else...{
                 showUpdateProfileView(context)
              }

            ],
          ),
        ),
      ),
    );
  }

  Widget showUpdateProfileView(BuildContext context){
    var userScreenState = ref.watch(cartScreenGlobalStateProvider);
    final cartScreenNotifier = ref.read(cartScreenGlobalStateProvider.notifier);
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: objConstantColor.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.dp, 10.dp, 20.dp, 10.dp),
        child: Row(
          children: [

            Expanded(
              child: customeText(
                userScreenState.profileIncompleteMessage,
                12,
                objConstantColor.navyBlue,
                ConstantAssests.montserratSemiBold,

              ),
            ),

            SizedBox(width: 10.dp,),

            CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  cartScreenNotifier.calNavigationToEditProfile(userScreenNotifier);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 10.dp, horizontal: 22.dp),
                  decoration: BoxDecoration(
                    color: objConstantColor.orange,
                    borderRadius: BorderRadius.circular(4.dp),

                  ),
                  child: customeText(
                    'Update',
                    18,
                    objConstantColor.white,
                    ConstantAssests.montserratBold,
                  ),
                )
            ),


          ],
        ),
      ),
    );
  }



  Widget cell(
      int index,
      String productName,
      String price,
      String actualPrice,
      String gram,
      int count,
      String image,
      CartScreenGlobalStateNotifier notifier,
      String productID) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15.dp, horizontal: 15.dp),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 1. Product Details (Left Side)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    objCommonWidgets.customText(context,
                        CodeReusability().cleanProductName(productName),
                        13, Colors.black, objConstantFonts.montserratSemiBold
                    ),
                    SizedBox(height: 2.dp),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.dp, vertical: 2.dp),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(4.dp),
                          ),
                          child: Row(
                            children: [
                              objCommonWidgets.customText(context,
                                  "4.2",
                                  9, Colors.white, objConstantFonts.montserratMedium
                              ),
                              SizedBox(width: 2.dp),
                              Icon(Icons.star, color: Colors.white, size: 8.dp),
                            ],
                          ),
                        ),
                        SizedBox(width: 6.dp),
                        objCommonWidgets.customText(context,
                            "(120+ ratings)",
                            10, Colors.black, objConstantFonts.montserratMedium
                        ),
                      ],
                    ),
                    SizedBox(height: 6.dp),
                    objCommonWidgets.customText(context,
                        gram,
                        11, Colors.black.withAlpha(180),
                        objConstantFonts.montserratMedium
                    ),

                    /// Price Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        objCommonWidgets.customText(context,
                            '₹$price',
                            16, Colors.black, objConstantFonts.montserratSemiBold
                        ),
                        SizedBox(width: 5.dp),
                        Text(
                          "₹$actualPrice",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.dp,
                            decoration: TextDecoration.lineThrough,
                            fontFamily: objConstantFonts.montserratMedium
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 5.dp),

                    CupertinoButton(
                      onPressed: () {
                        var mainNotifier = ref.read(MainScreenGlobalStateProvider.notifier);
                        notifier.callRemoveFromCart(context, productID, index, mainNotifier);
                      },
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 8.dp),
                        decoration: BoxDecoration(
                          color: Color(0xFFE32B2B),
                          borderRadius: BorderRadius.circular(5.dp)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_forever_sharp, color: Colors.white, size: 13.dp,),
                            SizedBox(width: 1.5.dp),
                            objCommonWidgets.customText(context, 'Remove item', 10, Colors.white, objConstantFonts.montserratSemiBold)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 15.dp),

              /// 2. Image & Quantity Toggle (Right Side)
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      /// Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5.dp),
                        child: SizedBox(
                          width: 85.dp,
                          height: 85.dp,
                          child: NetworkImageLoader(
                            imageUrl: '${ConstantURLs.baseUrl}$image',
                            placeHolder: objConstantAssest.placeHolder,
                            size: 85.dp,
                            imageSize: 85.dp,
                            bottomCurve: 5,
                            topCurve: 5,
                          ),
                        ),
                      ),


                    ],
                  ),
                  SizedBox(height: 10.dp),
                  QuantityCounter(
                    count: count,
                    onChanged: (newCount) {
                      notifier.callUpdateCountAPI(context, productID, index, newCount);
                    },
                  )
                ],
              ),
            ],
          ),
        ],
      ),
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
            Colors.black,
            font,
          ),
          const Spacer(),
          objCommonWidgets.customText(context,
            '₹$value/_',
            size,
            Colors.black,
            font,
          )
        ],
      ),
    );
  }



  Widget customeText(String text, int size, Color color, String font){
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: size.dp,
        fontFamily: font,
      ),
    );
  }


  Widget cartShimmerLoader() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          /// Shimmer List (Shows 3 items by default)
          ListView.separated(
            shrinkWrap: true,
            itemCount: 3,
            separatorBuilder: (context, index) => Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) => shimmerCell(),
          ),

          SizedBox(height: 30.dp),

          /// Shimmer Billing Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.dp),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: List.generate(4, (index) => Padding(
                  padding: EdgeInsets.only(bottom: 15.dp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 100.dp, height: 12.dp, color: Colors.white),
                      Container(width: 50.dp, height: 12.dp, color: Colors.white),
                    ],
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget shimmerCell() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15.dp, horizontal: 15.dp),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Left side: Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name line
                  Container(width: 140.dp, height: 14.dp, color: Colors.white),
                  SizedBox(height: 8.dp),
                  // Rating line
                  Container(width: 60.dp, height: 10.dp, color: Colors.white),
                  SizedBox(height: 8.dp),
                  // Gram/Weight line
                  Container(width: 40.dp, height: 10.dp, color: Colors.white),
                  SizedBox(height: 12.dp),
                  // Price line
                  Container(width: 80.dp, height: 16.dp, color: Colors.white),
                ],
              ),
            ),

            SizedBox(width: 15.dp),

            /// Right side: Image & Counter
            Column(
              children: [
                Container(
                  width: 85.dp,
                  height: 85.dp,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.dp),
                  ),
                ),
                SizedBox(height: 10.dp),
                Container(
                  width: 70.dp,
                  height: 30.dp,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.dp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



}



class QuantityCounter extends StatelessWidget {
  final int count;
  final Function(int) onChanged;

  const QuantityCounter({
    super.key,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.dp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBtn(
            icon: count > 1 ? Icons.remove : Icons.delete_outline,
            onTap: () {
              if (count > 1) onChanged(count - 1);
            },
            color: count > 1 ? objConstantColor.navyBlue : Colors.red,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.dp),
            child: objCommonWidgets.customText(context, "$count", 14, Colors.black, objConstantFonts.montserratSemiBold)
          ),
          _buildBtn(
            icon: Icons.add,
            onTap: () => onChanged(count + 1),
            color: objConstantColor.navyBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildBtn({required IconData icon, required VoidCallback onTap, required Color color}) {
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      minSize: 32.dp,
      child: Icon(icon, size: 16.dp, color: color),
    );
  }
}
