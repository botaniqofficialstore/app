// CartScreen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../CodeReusable/CodeReusability.dart';
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
      backgroundColor: objConstantColor.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await cartScreenNotifier.callCartListGepAPI(context);
        },
        color: objConstantColor.navyBlue,
        backgroundColor: objConstantColor.white,
        child: Column(
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
                      userScreenNotifier.callNavigation(ScreenName.home);
                    }),
                    customeText(
                      'My Cart',
                      23,
                      objConstantColor.navyBlue,
                      ConstantAssests.montserratBold,
                    ),
                  ],
                ),
              ),
            ),

            /// Scroll content (shimmer while loading, else real content)
            Expanded(
              child: userScreenState.isLoading
                  ? _buildShimmerPlaceholder() // show shimmer while loading
                  : Scrollbar(
                thumbVisibility: true,
                thickness: 6,
                radius: Radius.circular(10.dp),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // ✅ Important line
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 18.dp),
                    child: Builder(
                      builder: (context) {
                        if (cartItems.isEmpty) {
                          // ✅ Still allow pull to refresh even when empty
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7, // fill height
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(objConstantAssest.emptyCartIcon, width: 70.dp),
                                  SizedBox(height: 10.dp),
                                  Text(
                                    "Your cart is empty.",
                                    style: TextStyle(
                                      color: objConstantColor.gray,
                                      fontSize: 17.dp,
                                      fontFamily: ConstantAssests.montserratMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // ✅ Normal cart content
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.dp),
                            customeText(
                              'Order Summary',
                              20,
                              objConstantColor.navyBlue,
                              ConstantAssests.montserratSemiBold,
                            ),
                            SizedBox(height: 5.dp),

                            /// Cart List
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartItems.length,
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
                                    details.productId
                                );
                              },
                            ),

                            SizedBox(height: 10.dp),
                            amountText('Amount', '${userScreenState.totalAmount}', ConstantAssests.montserratMedium),
                            amountText('Discount', '${userScreenState.totalDiscount}', ConstantAssests.montserratMedium),
                            amountText('Delivery Charge', '89', ConstantAssests.montserratMedium),
                            SizedBox(height: 5.dp),
                            amountText(
                              'Payable Amount',
                              '${userScreenState.totalPayableAmount}',
                              ConstantAssests.montserratSemiBold,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            /// Checkout (only when not loading and cart is not empty)
            if (!userScreenState.isLoading && cartItems.isNotEmpty)
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
                          customeText(
                            '₹${userScreenState.totalPayableAmount}/_',
                            20,
                            objConstantColor.navyBlue,
                            ConstantAssests.montserratBold,
                          ),
                          customeText(
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
                          onPressed: () {
                            cartScreenNotifier.callNavigateToSummary(userScreenNotifier);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.dp, horizontal: 20.dp),
                            decoration: BoxDecoration(
                              color: objConstantColor.green,
                              borderRadius: BorderRadius.circular(4.dp),
                              border: Border.all(
                                color: objConstantColor.navyBlue,
                                width: 1.5,
                              ),
                            ),
                            child:  Shimmer.fromColors(
                              baseColor: objConstantColor.white,
                              highlightColor: objConstantColor.black,
                              child: customeText(
                                'Checkout',
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
      ),
    );
  }


  /// Cell Widget
  Widget cell(int index, String productName, String price, String actualPrice,
      String gram, int count, String image, CartScreenGlobalStateNotifier notifier, String productID) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.dp),
                border: Border.all(
                  color: objConstantColor.navyBlue,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.dp),
                child: Image.network(
                  '${ConstantURLs.baseUrl}$image',
                  width: 120.dp,
                  height: 120.dp,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      objConstantAssest.placeHolder, // fallback image from assets
                      width: 130.dp,
                      height: 130.dp,
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

            SizedBox(width: 10.dp),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customeText(CodeReusability().cleanProductName(productName),
                    17,
                    objConstantColor.navyBlue,
                    objConstantFonts.montserratSemiBold,
                  ),
                  SizedBox(height: 2.dp),

                  /// Price & Offer
                  Row(
                    children: [
                      customeText(
                        '₹$price/_',
                        14,
                        objConstantColor.green,
                        objConstantFonts.montserratSemiBold,
                      ),
                      SizedBox(width: 8.dp),
                      Text(
                        "₹$actualPrice/_",
                        style: TextStyle(
                          color: objConstantColor.gray,
                          fontSize: 14.dp,
                          fontFamily: ConstantAssests.montserratMedium,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: objConstantColor.gray,
                          decorationThickness: 1,
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 2.dp),
                  customeText(
                    gram,
                    14,
                    objConstantColor.navyBlue,
                    objConstantFonts.montserratSemiBold,
                  ),

                  SizedBox(height: 5.dp),

                  /// Delete Button
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        var mainNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);
                        notifier.callRemoveFromCart(context, productID, index, mainNotifier); // Remove Product
                      });
                    },
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: Image.asset(
                      objConstantAssest.deleteIcon,
                      width: 18.dp,
                      height: 18.dp,
                    ),
                  ),

                  SizedBox(height: 10.dp),

                  /// Quantity Counter
                  QuantityCounter(
                    count: count,
                    onChanged: (newCount) {
                      setState(() {
                        notifier.callUpdateCountAPI(context, productID, index, newCount); //Add Product Count
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        /// Divider
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.dp),
          child: Divider(
            color: objConstantColor.gray.withOpacity(0.4),
            thickness: 1.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }


  Widget amountText(String name, String value, String font){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.dp),
      child: Row(
        children: [
          customeText(
            name,
            15,
            objConstantColor.navyBlue,
            font,
          ),
          const Spacer(),
          customeText(
            '₹${value}/_',
            15,
            objConstantColor.navyBlue,
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


  /// Shimmer placeholder while cart loads
  Widget _buildShimmerPlaceholder() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.dp, horizontal: 18.dp),
        child: Column(
          children: [
            // title skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 140.dp,
                  height: 26.dp,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 12.dp),

            // multiple item skeletons
            Column(
              children: List.generate(3, (i) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12.dp),
                  padding: EdgeInsets.all(10.dp),
                  decoration: BoxDecoration(
                    color: objConstantColor.white,
                    borderRadius: BorderRadius.circular(6.dp),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 100.dp, height: 100.dp, color: Colors.white),
                        SizedBox(width: 12.dp),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(width: double.infinity, height: 16.dp, color: Colors.white),
                              SizedBox(height: 8.dp),
                              Container(width: 120.dp, height: 14.dp, color: Colors.white),
                              SizedBox(height: 8.dp),
                              Container(width: 80.dp, height: 14.dp, color: Colors.white),
                              SizedBox(height: 10.dp),
                              Row(
                                children: [
                                  Container(width: 90.dp, height: 36.dp, color: Colors.white),
                                  SizedBox(width: 10.dp),
                                  Container(width: 70.dp, height: 36.dp, color: Colors.white),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 8.dp),

            // totals skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                children: [
                  Container(width: double.infinity, height: 14.dp, color: Colors.white),
                  SizedBox(height: 8.dp),
                  Container(width: double.infinity, height: 14.dp, color: Colors.white),
                  SizedBox(height: 8.dp),
                  Container(width: double.infinity, height: 14.dp, color: Colors.white),
                  SizedBox(height: 12.dp),
                  Container(width: 180.dp, height: 18.dp, color: Colors.white),
                ],
              ),
            ),

            SizedBox(height: 18.dp),

            // checkout button skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: double.infinity,
                height: 54.dp,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.dp),
                ),
              ),
            ),

            SizedBox(height: 18.dp),
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
      padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 4.dp),
      decoration: BoxDecoration(
        border: Border.all(color: objConstantColor.navyBlue, width: 1), // border color
        borderRadius: BorderRadius.circular(5.dp), // curved corners
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          SizedBox(width: 5.dp,),
          /// Minus button
          CupertinoButton(
            onPressed: () {
              if (count > 1) {
                onChanged(count - 1);
              }
            },
            padding: EdgeInsets.zero,
            minSize: 0, // removes default CupertinoButton size
            child: Image.asset(
              (count > 1) ? objConstantAssest.minusIcon : objConstantAssest.minusDisableIcon,
              width: 13.dp,
              height: 15.dp,
            ),
          ),

          SizedBox(width: 15.dp,),

          /// Count in center
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.dp),
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 16.dp,
                fontFamily: objConstantFonts.montserratMedium,
                color: objConstantColor.navyBlue,
              ),
            ),
          ),

          SizedBox(width: 15.dp,),

          /// Plus button
          CupertinoButton(
            onPressed: () {
              onChanged(count + 1);
            },
            padding: EdgeInsets.zero,
            minSize: 0,
            child: Image.asset(
              objConstantAssest.addIcon,
              width: 13.dp,
              height: 15.dp,
            ),
          ),

          SizedBox(width: 5.dp,),
        ],
      ),
    );
  }
}
