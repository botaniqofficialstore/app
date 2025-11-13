// OrderScreen.dart
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
import 'OrderModel.dart';
import 'OrderScreenState.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends ConsumerState<OrderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, bool> _expandedMap = {};
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
      backgroundColor: objConstantColor.white,
      body: RefreshIndicator(
        onRefresh: () async {
          final orderScreenNotifier = ref.read(OrderScreenGlobalStateProvider.notifier);
          await orderScreenNotifier.callOrderListGepAPI(context);
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
                        child: Image.asset(
                          objConstantAssest.backIcon, width: 25.dp,),
                        onPressed: () {
                          userScreenNotifier.callNavigation(ScreenName.home);
                        }),
                    objCommonWidgets.customText(context,
                      'My Orders',
                      23,
                      objConstantColor.navyBlue,
                      ConstantAssests.montserratBold,
                    ),
                  ],
                ),
              ),
            ),

            /// Body: show shimmer if loading, else show data/empty state
            Expanded(
              child: userScreenState.isLoading
                  ? _buildShimmerPlaceholder()
                  : orderListData.isNotEmpty
                  ? Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 6,
                radius: Radius.circular(10.dp),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 5.dp),
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: orderListData.length,
                        itemBuilder: (context, index){
                          return orderListWidget(context, orderListData[index], userScreenNotifier);
                        }),
                  ),
                ),
              )
                  : Scrollbar(
                thumbVisibility: true,
                thickness: 6,
                radius: Radius.circular(10.dp),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // ✅ Important line
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7, // fill height
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(objConstantAssest.noOrder, width: 85.dp,),
                          SizedBox(height: 12.dp),
                          Text(
                            "No Orders",
                            style: TextStyle(
                              color: objConstantColor.gray,
                              fontSize: 20.dp,
                              fontFamily: ConstantAssests.montserratMedium,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget orderListWidget(BuildContext context, OrderDataList order, MainScreenGlobalStateNotifier notifier) {
    final orderScreenNotifier = ref.read(OrderScreenGlobalStateProvider.notifier);
    bool isExpanded = _expandedMap[order.orderId] ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 8.dp),
      decoration: BoxDecoration(
          color: objConstantColor.white,
          borderRadius: BorderRadius.circular(5.dp),
          border: Border.all(
            color: objConstantColor.black.withOpacity(0.8),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              spreadRadius: 1,
              offset: const Offset(3, 4),
            )
          ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.dp),
                          child: objCommonWidgets.customText(
                            context,
                            (order.currentOrderStatus == 5) ? 'Delivered' : 'Order placed' ,
                            18,
                            objConstantColor.navyBlue,
                            ConstantAssests.montserratSemiBold,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.dp),
                          child: CupertinoButton(onPressed: () {
                            setState(() {
                              savedOrderData = order;
                              orderScreenNotifier.callNavigateToTrackOrder(
                                  notifier);
                            });
                          },
                            padding: EdgeInsets.zero, child: Container(
                              decoration: BoxDecoration(
                                color: (order.currentOrderStatus == 5) ? objConstantColor.navyBlue : objConstantColor.green,
                                borderRadius: BorderRadius.circular(2.5.dp),
                                border: Border.all(
                                  color: objConstantColor.navyBlue,
                                  width: 0.6.dp,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.dp, horizontal: 8.dp),
                              child: objCommonWidgets.customText(
                                context,
                                (order.currentOrderStatus == 5) ? 'View details' : 'Track order' ,
                                11.5,
                                objConstantColor.white,
                                ConstantAssests.montserratBold,
                              ),
                            ),),
                        )
                      ],
                    ),

                    titleAndValueRow(
                        context,
                        'Ordered Date :',
                        CodeReusability().convertUTCToIST(order.orderDate),
                        objConstantColor.navyBlue,
                        objConstantColor.navyBlue,
                        12.5,
                        12.5,
                        ConstantAssests.montserratSemiBold,
                        ConstantAssests.montserratBold),
                    titleAndValueRow(
                        context,
                        'Order Status :',
                        steps[order.currentOrderStatus ?? 0],
                        objConstantColor.navyBlue,
                        objConstantColor.green,
                        12.5,
                        12.5,
                        ConstantAssests.montserratSemiBold,
                        ConstantAssests.montserratBold),
                    titleAndValueRow(
                        context,
                        'Delivery Date :',
                        '15/05/2025',
                        objConstantColor.navyBlue,
                        objConstantColor.navyBlue,
                        12.5,
                        12.5,
                        ConstantAssests.montserratSemiBold,
                        ConstantAssests.montserratBold),
                    titleAndValueRow(
                        context,
                        (order.currentOrderStatus == 5) ? 'Paid Amount :' : 'Payable Amount :',
                        '₹${order.orderTotalAmount}/_',
                        objConstantColor.navyBlue,
                        objConstantColor.green,
                        12.5,
                        15.5,
                        ConstantAssests.montserratSemiBold,
                        ConstantAssests.montserratSemiBold),

                    SizedBox(height: 10.dp,),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedMap[order.orderId] = !isExpanded;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: objConstantColor.navyBlue,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(
                                    isExpanded ? 0.dp : 5.dp),
                                bottomLeft: Radius.circular(
                                    isExpanded ? 0.dp : 5.dp)
                            )
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.dp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              objCommonWidgets.customText(
                                context,
                                'Purchase List',
                                15.5.dp,
                                objConstantColor.white,
                                ConstantAssests.montserratSemiBold,
                              ),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
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
                  ],
                ),
              ),
            ],
          ),

          (isExpanded) ?
          Divider(
            color: objConstantColor.gray.withOpacity(0.4),
            thickness: 1.5,
            height: 1.5,
          ) : const SizedBox.shrink(),

          SizedBox(height: isExpanded ? 10.dp : 0.dp,),

          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInCubic,
            child: isExpanded ?
            Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.dp),
                child: ListView.builder(
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
              ),
            )
                : const SizedBox.shrink(),
          ),
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
                      color: objConstantColor.liteGray2,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CupertinoActivityIndicator(
                        color: objConstantColor.navyBlue,
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

        SizedBox(height: 10.dp),
      ],
    );
  }

  ///This Widget is used to load Title and Value in a row
  Widget titleAndValueRow(BuildContext context, String title, String value, Color titleColor, Color valueColor, double titleSize, double valueSize, String titleFontFamily, String valueFontFamily){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.dp),
      child: Row(
        children: [
          objCommonWidgets.customText(
            context,
            title,
            titleSize,
            titleColor,
            titleFontFamily,
          ),
          SizedBox(width: 3.dp),
          objCommonWidgets.customText(
            context,
            value,
            valueSize,
            valueColor,
            valueFontFamily,
          ),
        ],
      ),
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
