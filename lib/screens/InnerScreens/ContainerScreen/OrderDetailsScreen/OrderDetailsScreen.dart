import 'package:botaniqmicrogreens/Utility/Logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../constants/ConstantAssests.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'OrderDetailsScreenState.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int animatedStep = -1; // 👈 Controls the current animated step

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      startStepAnimation(); // 👈 Start animation after data loads
    });
  }

  /// Sequential animation of steps
  void startStepAnimation() async {
    var orderDetails = savedOrderData;
    int totalSteps = orderDetails?.currentOrderStatus ?? 0;

    for (int i = 0; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          animatedStep = i;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);
    var orderDetails = savedOrderData;
    var orderTracking = orderDetails?.orderTracking;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: objConstantColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Header
          Padding(
            padding: EdgeInsets.only(top: 5.dp,),
            child: Row(
              children: [
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Image.asset(
                        objConstantAssest.backIcon, width: 25.dp),
                    onPressed: () {
                      userScreenNotifier.callNavigation(ScreenName.orders);
                    }),
                objCommonWidgets.customText(
                  context,
                  'Track Order',
                  18,
                  objConstantColor.navyBlue,
                  ConstantAssests.montserratBold,
                ),
              ],
            ),
          ),

          /// Scroll content
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 6,
              radius: Radius.circular(10.dp),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 5.dp, horizontal: 15.dp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [


                      /// Order Details Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          objCommonWidgets.customText(
                              context, 'Order Details', 16,
                              objConstantColor.navyBlue,
                              objConstantFonts.montserratSemiBold),

                          SizedBox(height: 5.dp),

                          titleAndValueRow(
                              context,
                              'Order ID :',
                              orderDetails?.orderId ?? '',
                              objConstantColor.navyBlue,
                              objConstantColor.navyBlue,
                              11.5,
                              12.5,
                              ConstantAssests.montserratSemiBold,
                              ConstantAssests.montserratBold),

                          titleAndValueRow(
                              context,
                              'Ordered Date :',
                              CodeReusability().convertUTCToIST(
                                  orderDetails?.orderDate ?? ''),
                              objConstantColor.navyBlue,
                              objConstantColor.navyBlue,
                              11.5,
                              12.5,
                              ConstantAssests.montserratSemiBold,
                              ConstantAssests.montserratBold),

                          titleAndValueRow(
                              context,
                              'Order Status :',
                              steps[orderDetails?.currentOrderStatus ?? 0],
                              objConstantColor.navyBlue,
                              objConstantColor.green,
                              11.5,
                              12.5,
                              ConstantAssests.montserratSemiBold,
                              ConstantAssests.montserratBold),

                          titleAndValueRow(
                              context,
                              'Delivery Date :',
                              'Not Confirmed',
                              objConstantColor.navyBlue,
                              objConstantColor.navyBlue,
                              11.5,
                              12.5,
                              ConstantAssests.montserratSemiBold,
                              ConstantAssests.montserratBold),
                        ],
                      ),

                      Divider(
                          color: objConstantColor.navyBlue, thickness: 0.5.dp),
                      SizedBox(height: 10.dp),

                      objCommonWidgets.customText(
                          context, 'Track Order', 15, objConstantColor.navyBlue,
                          objConstantFonts.montserratSemiBold),

                      SizedBox(height: 10.dp),

                      /// Track Order List
                      ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: steps.length,
                        itemBuilder: (context, index) {
                          var date = '';
                          if (orderTracking != null && index <
                              orderTracking.length) {
                            date = CodeReusability()
                                .convertUTCToIST(
                                orderTracking[index].orderStatusDate ?? '');
                          }

                          return AnimatedOrderTrackStep(
                            text: steps[index],
                            date: date,
                            isCompleted: index <= animatedStep,
                            // 👈 Animated state
                            isLast: index == steps.length - 1,
                          );
                        },
                      ),

                      SizedBox(height: 10.dp),
                      Divider(
                          color: objConstantColor.navyBlue, thickness: 0.5.dp),
                      SizedBox(height: 10.dp),

                      objCommonWidgets.customText(
                          context, 'Purchase List', 16,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratSemiBold),

                      SizedBox(height: 2.dp),

                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: orderDetails?.orderDetails.length,
                        itemBuilder: (context, index) {
                          var productDetails = orderDetails
                              ?.orderDetails[index];
                          return cell(
                            context,
                            index,
                            '${productDetails?.productDetails.productName}',
                            '${productDetails?.productDetails
                                .productSellingPrice}',
                            '${productDetails?.productDetails.gram}',
                            productDetails?.productCount ?? 0,
                            '${productDetails?.productDetails.image}',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Bottom total bar
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
              padding: EdgeInsets.fromLTRB(15.dp, 10.dp, 20.dp, 10.dp),
              child: Row(
                children: [

                  if (orderDetails?.currentOrderStatus == 0)...{
                    CupertinoButton(padding: EdgeInsets.zero,
                        child: Container(
                          decoration: BoxDecoration(
                            color: objConstantColor.orange,
                            borderRadius: BorderRadius.circular(5.dp),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12.dp, horizontal: 13.dp),
                            child: objCommonWidgets.customText(
                                context, 'Cancel Order', 15,
                                objConstantColor.white,
                                objConstantFonts.montserratSemiBold),
                          ),
                        ), onPressed: () {

                      setState(() {
                        final orderDetailScreenNotifier = ref.read(OrderDetailsScreenGlobalStateProvider.notifier);
                        orderDetailScreenNotifier.callCancelOrderAPi(context, orderDetails?.orderId ?? '', userScreenNotifier);
                      });
                        }),

                    const Spacer(),
                  }else...{
                    objCommonWidgets.customText(
                      context,
                      'Total Amount',
                      17,
                      objConstantColor.navyBlue,
                      objConstantFonts.montserratBold,
                    ),
                  const Spacer(),
                  },
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      objCommonWidgets.customText(
                        context,
                        '₹${orderDetails?.orderTotalAmount}/_',
                        18,
                        objConstantColor.green,
                        objConstantFonts.montserratBold,
                      ),
                      objCommonWidgets.customText(
                        context,
                        'Inc. of all taxes',
                        10,
                        objConstantColor.navyBlue,
                        objConstantFonts.montserratMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Title and Value Row Widget
  Widget titleAndValueRow(
      BuildContext context,
      String title,
      String value,
      Color titleColor,
      Color valueColor,
      double titleSize,
      double valueSize,
      String titleFontFamily,
      String valueFontFamily) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        objCommonWidgets.customText(
          context,
          title,
          titleSize,
          titleColor,
          titleFontFamily,
        ),
        SizedBox(width: 3.dp),
        Flexible(
          child: objCommonWidgets.customText(
            context,
            value,
            valueSize,
            valueColor,
            valueFontFamily,
          ),
        ),
      ],
    );
  }

  /// Product Cell Widget
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.dp),
                border: Border.all(color: objConstantColor.navyBlue, width: 0.5),
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
                      objConstantAssest.placeHolder,
                      width: 80.dp,
                      height: 80.dp,
                      fit: BoxFit.cover,
                      color: objConstantColor.liteGray2,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CupertinoActivityIndicator(color: objConstantColor.navyBlue),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12.dp),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.dp),
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
                    Row(
                      children: [
                        objCommonWidgets.customText(
                            context, 'Price:', 12,
                            objConstantColor.navyBlue,
                            objConstantFonts.montserratSemiBold),
                        SizedBox(width: 5.dp),
                        objCommonWidgets.customText(
                            context, '₹$price/_', 12,
                            objConstantColor.green,
                            objConstantFonts.montserratSemiBold),
                      ],
                    ),
                    SizedBox(height: 2.dp),
                    objCommonWidgets.customText(
                      context,
                      'Quantity: $count',
                      12,
                      objConstantColor.navyBlue,
                      objConstantFonts.montserratSemiBold,
                    ),
                    SizedBox(height: 2.dp),
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
            ),
          ],
        ),
        SizedBox(height: 10.dp),
      ],
    );
  }
}

class AnimatedOrderTrackStep extends StatefulWidget {
  final String text;
  final String date;
  final bool isCompleted;
  final bool isLast;
  final Duration animationDuration;
  final Color activeColor;
  final Color inactiveColor;
  final TextStyle? textStyle;

  const AnimatedOrderTrackStep({
    super.key,
    required this.text,
    required this.date,
    this.isCompleted = false,
    this.isLast = false,
    this.animationDuration = const Duration(milliseconds: 800),
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.textStyle,
  });

  @override
  State<AnimatedOrderTrackStep> createState() => _AnimatedOrderTrackStepState();
}

class _AnimatedOrderTrackStepState extends State<AnimatedOrderTrackStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleScale;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _lineFill;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _circleScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(_controller);

    _lineFill = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isCompleted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedOrderTrackStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !_controller.isCompleted) {
      _controller.forward();
    } else if (!widget.isCompleted && _controller.isCompleted) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Circle + Line)
        Column(
          children: [
            // Circle animation
            ScaleTransition(
              scale: _circleScale,
              child: AnimatedBuilder(
                animation: _colorAnimation,
                builder: (context, child) => Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    shape: BoxShape.circle,
                  ),
                  child: widget.isCompleted
                      ? Icon(Icons.check, size: 10.dp, color: Colors.white)
                      : null,
                ),
              ),
            ),

            // Line animation (Gray + Green overlay)
            if (!widget.isLast)
              SizedBox(
                height: 25,
                width: 2,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Base gray line (always visible)
                    Container(
                      color: widget.inactiveColor.withOpacity(0.4),
                    ),
                    // Animated green line (fills gradually)
                    AnimatedBuilder(
                      animation: _lineFill,
                      builder: (context, child) => Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 25 * _lineFill.value,
                          width: 2,
                          color: widget.activeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        SizedBox(width: 8.dp),

        // Right text column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: widget.animationDuration,
                style: widget.textStyle ??
                    TextStyle(
                      fontSize: 11.5.dp,
                      fontFamily: objConstantFonts.montserratSemiBold,
                      color: widget.isCompleted
                          ? widget.activeColor
                          : objConstantColor.gray,
                    ),
                child: Text(widget.text),
              ),
              objCommonWidgets.customText(
                context,
                widget.date,
                10,
                objConstantColor.gray,
                objConstantFonts.montserratMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

