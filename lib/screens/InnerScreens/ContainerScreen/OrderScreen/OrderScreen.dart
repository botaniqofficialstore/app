// OrderScreen.dart
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
import 'OrderModel.dart';
import 'OrderScreenState.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends ConsumerState<OrderScreen> with SingleTickerProviderStateMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        Future.microtask(() {
          final orderScreenNotifier = ref.read(OrderScreenGlobalStateProvider.notifier);
          orderScreenNotifier.callOrderListGepAPI(context);
        });
      }
    });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userScreenState = ref.watch(OrderScreenGlobalStateProvider);
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);
    var orderListData = userScreenState.orderList;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.black,
          backgroundColor: Colors.white,
          onRefresh: () async {
          final orderScreenNotifier = ref.read(OrderScreenGlobalStateProvider.notifier);
          await orderScreenNotifier.callOrderListGepAPI(context);
          },
          child: Column(
            children: [
              /// Header - unchanged
              Padding(
                padding: EdgeInsets.only(top: 5.dp, left: 10.dp, bottom: 5.dp),
                child: Row(
                  children: [
                    CupertinoButton(
                      minimumSize: const Size(0, 0),
                        padding: EdgeInsets.zero,
                        child: Image.asset(
                          objConstantAssest.backIcon, width: 20.dp,),
                        onPressed: () {
                          userScreenNotifier.callNavigation(ScreenName.home);
                        }),
                    SizedBox(width: 5.dp),
                    objCommonWidgets.customText(
                      context, 'My Orders', 15,
                      objConstantColor.navyBlue,
                      ConstantAssests.montserratSemiBold,
                    ),
                  ],
                ),
              ),
            
              SizedBox(height: 5.dp),
            
              /// 🔹 Tabs
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _ordersSection(context, orderListData, userScreenState,
                          userScreenNotifier),
                    ],
                  ),
                ),
              ),
            
              SizedBox(height: 10.dp),
            
            ],
          ),
        ),
      ),
    
    );
  }


  Widget _ordersSection(BuildContext context, List orderList,
      OrderScreenGlobalState userScreenState,
      MainScreenGlobalStateNotifier userScreenNotifier) {

    if (userScreenState.isLoading) {
      return _buildShimmerPlaceholder();
    }

    if (orderList.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(objConstantAssest.noOrder, width: 50.dp),
              SizedBox(height: 1.dp),
              Text("No active orders" ,
                style: TextStyle(
                  color: Colors.black.withAlpha(150),
                  fontSize: 12.dp,
                  fontFamily: ConstantAssests.montserratMedium,
                ),
              ),

              SizedBox(height: 7.dp),

              CupertinoButton(padding: EdgeInsets.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      color: objConstantColor.orange,
                      borderRadius: BorderRadius.circular(5.dp)
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                    child: objCommonWidgets.customText(context,
                        'Shop Now',
                        12, objConstantColor.white,
                        objConstantFonts.montserratSemiBold),
                  ),
                  onPressed: (){
                    userScreenNotifier.callNavigation(ScreenName.home);
                  })
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.dp),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: orderList.length,
        separatorBuilder: (context, index) => SizedBox(height: 10.dp),
        itemBuilder: (context, index) {
          return Column(
            children: [
              orderListWidget(
                  context,
                  orderList[index],
                  userScreenNotifier,
                index
              ),
            ],
          );
        },
      ),
    );
  }


  Widget orderListWidget(BuildContext context, OrderDataList order, MainScreenGlobalStateNotifier notifier, int index) {
    final orderScreenNotifier = ref.read(OrderScreenGlobalStateProvider.notifier);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: () {
        setState(() {
          savedOrderData = order;
          orderScreenNotifier.callNavigateToTrackOrder(notifier);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.dp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order Header: Status & Arrow
            Padding(
              padding: EdgeInsets.all(12.dp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      objCommonWidgets.customText(
                        context,
                        steps[order.currentOrderStatus ?? 0],
                        13,
                        Colors.green,
                        objConstantFonts.montserratSemiBold,
                      ),
                      SizedBox(height: 2.dp),
                      objCommonWidgets.customText(
                        context,
                        "Order #${order.orderId}",
                        10,
                        Colors.black.withAlpha(150),
                        objConstantFonts.montserratRegular,
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios_outlined, size: 14.dp, color: Colors.grey),
                ],
              ),
            ),

            Divider(height: 0.dp, thickness: 0.5),

            // 2. Product List
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.dp, horizontal: 12.dp),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: order.orderDetails.length,
                itemBuilder: (context, idx) {
                  var productDetails = order.orderDetails[idx];
                  return cell(
                    context,
                    idx,
                    productDetails.productDetails.productName,
                    '${productDetails.productDetails.productSellingPrice}',
                    '${productDetails.productDetails.gram}',
                    productDetails.productCount,
                    productDetails.productDetails.image,
                  );
                },
              ),
            ),

            Divider(height: 0.dp, thickness: 0.5),

            // 3. Order Footer: Expected Delivery Date
            Padding(
              padding: EdgeInsets.all(12.dp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  objCommonWidgets.customText(
                    context,
                    "Expected Delivery :",
                    13,
                    Colors.black,
                    objConstantFonts.montserratMedium,
                  ),
                  

                  
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 10.dp),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(200),
                      borderRadius: BorderRadius.circular(20.dp)
                    ),
                    child: Row(
                      children: [

                        Icon(Icons.calendar_month_sharp, color: Colors.white, size: 15.dp),
                        SizedBox(width: 5.dp),
                        objCommonWidgets.customText(
                          context,
                          'Feb 25 2026',
                          12,
                          Colors.white,
                          objConstantFonts.montserratSemiBold,
                        ),
                      ],
                    ),
                  )



                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget cell(
      BuildContext context,
      int index,
      String productName,
      String price,
      String gram,
      int count,
      String image,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            ClipRRect(
              borderRadius: BorderRadius.circular(5.dp),
              child: SizedBox(
                width: 80.dp,
                height: 80.dp,
                child: NetworkImageLoader(
                  imageUrl: '${ConstantURLs.baseUrl}$image',
                  placeHolder: objConstantAssest.placeHolder,
                  size: 80.dp,
                  imageSize: 80.dp,
                  bottomCurve: 5,
                  topCurve: 5,
                ),
              ),
            ),

            SizedBox(width: 10.dp),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 1.dp),

                  objCommonWidgets.customText(
                    context,
                    CodeReusability().cleanProductName(productName),
                    13,
                    Colors.deepOrange,
                    objConstantFonts.montserratSemiBold,
                  ),

                  SizedBox(height: 1.dp),

                  /// Quantity
                  objCommonWidgets.customText(
                    context,
                    'item: $count',
                    11,
                    Colors.black,
                    objConstantFonts.montserratMedium,
                  ),
                  SizedBox(height: 1.dp),

                  objCommonWidgets.customText(
                    context,
                    '$gram gm',
                    11,
                    Colors.black,
                    objConstantFonts.montserratMedium,
                  ),

                  SizedBox(height: 1.dp),
                  objCommonWidgets.customText(
                    context,
                    'Ordered on: 17/02/2026',
                    11,
                    Colors.black,
                    objConstantFonts.montserratMedium,
                  ),
                  SizedBox(height: 1.dp),
                  Row(
                    children: [
                      objCommonWidgets.customText(context, 'Amount to be paid : ', 11, Colors.black, objConstantFonts.montserratMedium),
                      objCommonWidgets.customText(context, '₹$price/_', 12, Colors.green, objConstantFonts.montserratSemiBold),
                    ],
                  )

                ],
              ),
            ),
          ],
        );
  }


  /// Shimmer placeholder for order list
  Widget _buildShimmerPlaceholder() {
    // create multiple skeleton cards
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.dp),
        child: Column(
          children: List.generate(4, (index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.dp),
              decoration: BoxDecoration(
                color: objConstantColor.white,
                borderRadius: BorderRadius.circular(5.dp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Padding(
                  padding: EdgeInsets.all(12.dp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // header row skeleton
                      Row(
                        children: [
                          Container(width: 120.dp, height: 18.dp, color: Colors.white),
                          Spacer(),
                          Container(width: 90.dp, height: 30.dp, color: Colors.white),
                        ],
                      ),
                      SizedBox(height: 10.dp),
                      // small lines
                      Container(width: double.infinity, height: 12.dp, color: Colors.white),
                      SizedBox(height: 6.dp),
                      Container(width: double.infinity, height: 12.dp, color: Colors.white),
                      SizedBox(height: 6.dp),
                      Container(width: 140.dp, height: 12.dp, color: Colors.white),
                      SizedBox(height: 12.dp),
                      // purchase list header skeleton
                      Container(width: 150.dp, height: 18.dp, color: Colors.white),
                      SizedBox(height: 10.dp),
                      // product item skeleton
                      Row(
                        children: [
                          Container(width: 80.dp, height: 80.dp, color: Colors.white),
                          SizedBox(width: 12.dp),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: double.infinity, height: 16.dp, color: Colors.white),
                                SizedBox(height: 8.dp),
                                Container(width: 120.dp, height: 14.dp, color: Colors.white),
                                SizedBox(height: 6.dp),
                                Container(width: 100.dp, height: 14.dp, color: Colors.white),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10.dp),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
