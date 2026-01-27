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

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: objConstantColor.white,
        body: RefreshIndicator( onRefresh: () async {
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
                  child: Container(
                    child: _ordersSection(context, orderListData, userScreenState,
                        userScreenNotifier),
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
              Image.asset(objConstantAssest.noOrder, width: 65.dp),
              SizedBox(height: 1.dp),
              Text("No Orders" ,
                style: TextStyle(
                  color: objConstantColor.gray,
                  fontSize: 15.dp,
                  fontFamily: ConstantAssests.montserratSemiBold,
                ),
              ),

              SizedBox(height: 10.dp),

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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 5.dp),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: orderList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              if (index != 0)
                SizedBox(height: 20.dp,),
              orderListWidget(
                  context,
                  orderList[index],
                  userScreenNotifier,
                index
              ),
              SizedBox(height: 25.dp),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.dp),
                child: const Divider(
                  color: Colors.black12,
                  thickness: 1.5,
                  height: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget orderListWidget(BuildContext context, OrderDataList order, MainScreenGlobalStateNotifier notifier, int index) {
    final orderScreenNotifier = ref.read(
        OrderScreenGlobalStateProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.dp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 5.dp,),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          Container(
            padding: EdgeInsets.only(top: 15.dp, left: 15.dp, right: 15.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                objCommonWidgets.customText(context,
                    'Order Details', 15,
                    objConstantColor.navyBlue,
                    objConstantFonts.montserratSemiBold),

                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: order.orderDetails.length,
                  itemBuilder: (context, index) {
                    var productDetails = order.orderDetails[index];

                    return cell(
                      context,
                      index,
                      '${productDetails.productDetails.productName}',
                      '${productDetails.productDetails.productSellingPrice}',
                      '${productDetails.productDetails.gram}',
                      productDetails.productCount,
                      '${productDetails.productDetails.image}',
                    );
                  },
                ),

              ],

            ),
          ),


          Container(
            decoration: BoxDecoration(
                color: const Color(0xFF373737),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.dp),
                    bottomRight: Radius.circular(20.dp),
                    topLeft: Radius.circular(25.dp),
                    topRight: Radius.circular(25.dp)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ]
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.dp),
            child: Column(
              children: [
                SizedBox(height: 5.dp),


                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical: 10.dp, horizontal: 5.dp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          objCommonWidgets.customText(
                              context, 'Payment Type', 12,
                              objConstantColor.white,
                              objConstantFonts.montserratBold),
                          objCommonWidgets.customText(
                              context, 'Cash on delivery', 15,
                              objConstantColor.white,
                              objConstantFonts.montserratSemiBold),
                        ],
                      ),

                      objCommonWidgets.customText(
                          context, '₹${order.orderTotalAmount}/_', 18,
                          objConstantColor.white,
                          objConstantFonts.montserratBold),
                    ],
                  ),
                ),


                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.dp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: objConstantColor.white.withAlpha(15),
                            borderRadius: BorderRadius.circular(10.dp),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15.dp, horizontal: 10.dp),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: objConstantColor.white.withAlpha(20),
                                  borderRadius: BorderRadius.circular(35.dp),
                                ),
                                padding: EdgeInsets.all(10.dp),
                                child: Icon(Icons.delivery_dining_sharp,
                                    size: 15.dp, color: Colors.white),
                              ),
                              SizedBox(width: 8.dp),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  objCommonWidgets.customText(
                                    context, 'Delivery on', 10,
                                    objConstantColor.white.withAlpha(200),
                                    objConstantFonts.montserratSemiBold,
                                  ),
                                  objCommonWidgets.customText(
                                    context, 'Dec 6', 13,
                                    objConstantColor.white,
                                    objConstantFonts.montserratBold,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 10.dp), // space between both boxes

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: objConstantColor.white.withAlpha(15),
                            borderRadius: BorderRadius.circular(10.dp),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15.dp, horizontal: 10.dp),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: objConstantColor.white.withAlpha(20),
                                  borderRadius: BorderRadius.circular(35.dp),
                                ),
                                padding: EdgeInsets.all(10.dp),
                                child: Image.asset(
                                  objConstantAssest.orderSelectedIcon,
                                  width: 15.dp,
                                  color: Colors.white,),
                              ),
                              SizedBox(width: 8.dp),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    objCommonWidgets.customText(
                                      context, 'Order Status', 10,
                                      objConstantColor.white.withAlpha(200),
                                      objConstantFonts.montserratSemiBold,
                                    ),

                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: objCommonWidgets.customText(
                                        context,
                                        steps[order.currentOrderStatus ?? 0],
                                        13,
                                        objConstantColor.white,
                                        objConstantFonts.montserratBold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                SizedBox(height: 15.dp),

                CupertinoButton(onPressed: () {
                  setState(() {
                    savedOrderData = order;
                    orderScreenNotifier.callNavigateToTrackOrder(
                        notifier);
                  });
                },
                  padding: EdgeInsets.zero, child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: objConstantColor.white,
                      borderRadius: BorderRadius.circular(35.dp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 13.dp, horizontal: 18.dp),
                      child: Center(
                        child: objCommonWidgets.customText(
                            context, 'Track Order', 15,
                            const Color(0xFF01B502),
                            objConstantFonts.montserratSemiBold),
                      ),
                    ),
                  ),),

                SizedBox(height: 10.dp,),
              ],
            ),
          )

        ],
      ),
    );
  }

  /// Cell Widget
  Widget cell(
      BuildContext context,
      int index,
      String productName,
      String price,
      String gram,
      int count,
      String image,
      ) {
    return Column(
      children: [
        Row(
          children: [
            /// Image
            Container(
              width: 70.dp,
              height: 70.dp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.dp),
                border: Border.all(
                  color: objConstantColor.black,
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.dp),
                child: NetworkImageLoader(
                  imageUrl: '${ConstantURLs.baseUrl}$image',
                  placeHolder: objConstantAssest.placeHolder,
                  size: 50.dp,
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
                      12,
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
                          12,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratSemiBold,
                        ),
                        SizedBox(width: 5.dp,),
                        objCommonWidgets.customText(
                          context,
                          '₹$price/_',
                          12,
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
                            12,
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
                                12,
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

        SizedBox(height: 10.dp),
      ],
    );
  }


  /// Shimmer placeholder for order list
  Widget _buildShimmerPlaceholder() {
    // create multiple skeleton cards
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.dp, horizontal: 8.dp),
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
