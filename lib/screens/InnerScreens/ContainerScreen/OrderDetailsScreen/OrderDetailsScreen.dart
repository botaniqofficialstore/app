import 'package:botaniqmicrogreens/screens/commonViews/ProductRatingScreen.dart';
import 'package:botaniqmicrogreens/screens/commonViews/ReviewSuccessPopup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../Utility/NetworkImageLoader.dart';
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

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: objConstantColor.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Header
            Padding(
              padding: EdgeInsets.only(left: 10.dp, top: 5.dp,),
              child: Row(
                children: [
                  CupertinoButton(
                      minimumSize: const Size(0, 0),
                      padding: EdgeInsets.zero,
                      child: Image.asset(
                          objConstantAssest.backIcon, width: 20.dp),
                      onPressed: () {
                        userScreenNotifier.callNavigation(ScreenName.orders);
                      }),
                  SizedBox(width: 5.dp),
                  objCommonWidgets.customText(
                    context,
                    'Order Details',
                    15,
                    objConstantColor.navyBlue,
                    ConstantAssests.montserratSemiBold,
                  ),
                ],
              ),
            ),

            SizedBox(height: 5.dp),

            /// Scroll content
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 6,
                radius: Radius.circular(10.dp),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 5.dp, horizontal: 15.dp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        orderDetailsWidget(context),


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

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.dp),
                          child: Divider(color: Colors.black, thickness: 0.5.dp),
                        ),


                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// ⭐ Title
                            objCommonWidgets.customText(
                                context, 'Add Your Rating & Review', 15, objConstantColor.black,
                                objConstantFonts.montserratSemiBold),

                            SizedBox(height: 5.dp),

                            /// 📄 Description
                            objCommonWidgets.customText(
                                context, 'Please rate the product and delivery experience. '
                                'Your honest feedback helps maintain quality and service standards.', 10, objConstantColor.black,
                                objConstantFonts.montserratMedium),

                            SizedBox(height: 10.dp),

                            /// 🚀 Action Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(20.dp)
                                      ),
                                  child: Center(
                                    child: objCommonWidgets.customText(
                                        context, 'Write a Review', 10, objConstantColor.white,
                                        objConstantFonts.montserratSemiBold),
                                  ),
                                ), onPressed: ()=> openRatingsAndReview(context)),
                              ],
                            )
                          ],
                        ),



                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.dp),
                          child: Divider(color: Colors.black, thickness: 0.5.dp),
                        ),

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
                            var productDetails = orderDetails?.orderDetails[index];
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
      ),
    );
  }

  Widget orderDetailsWidget(BuildContext context) {
    var orderDetails = savedOrderData;

    // Define status-specific colors for a premium feel
    Color statusColor = Colors.green;
    Color statusBgColor = Colors.green.withAlpha(20);

    return Container(

      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.dp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  objCommonWidgets.customText(
                      context, 'Order Summary', 15, objConstantColor.navyBlue,
                      objConstantFonts.montserratSemiBold),
                ],
              ),
              // Premium Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 4.dp),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20.dp),
                ),
                child: objCommonWidgets.customText(
                    context,
                    steps[orderDetails?.currentOrderStatus ?? 0].toUpperCase(),
                    10,
                    statusColor,
                    objConstantFonts.montserratBold),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.dp),
            child: Divider(color: Colors.black, thickness: 0.5.dp),
          ),

          // Data Grid
          _modernInfoRow(
            context,
            'Order ID',
            '#${orderDetails?.orderId ?? 'N/A'}',
            Icons.tag_rounded,
          ),

          SizedBox(height: 16.dp),

          _modernInfoRow(
            context,
            'Placed On',
            CodeReusability().convertUTCToIST(orderDetails?.orderDate ?? ''),
            Icons.calendar_today_rounded,
          ),

          SizedBox(height: 16.dp),

          _modernInfoRow(
            context,
            'Delivery Estimation',
            'Not Confirmed',
            Icons.local_shipping_outlined,
            valueColor: Colors.orange.shade700,
          ),

          SizedBox(height: 10.dp),

          // Optional: Progress Tracker Placeholder
          // (Great for "Pro" UIs to show a visual timeline)
          _buildMiniProgressTracker(orderDetails?.currentOrderStatus ?? 0),

          SizedBox(height: 10.dp),
        ],
      ),
    );
  }

  /// Helper for modern info rows with icons
  Widget _modernInfoRow(
      BuildContext context,
      String label,
      String value,
      IconData icon, {
        Color? valueColor,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Icon
        Container(
          padding: EdgeInsets.all(8.dp),
          decoration: BoxDecoration(
            color: objConstantColor.navyBlue.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14.dp,
            color: objConstantColor.navyBlue,
          ),
        ),

        SizedBox(width: 12.dp),

        /// Text Section (Expandable for multi-line)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              objCommonWidgets.customText(
                context,
                label,
                11,
                Colors.grey.shade600,
                objConstantFonts.montserratMedium,
              ),
              SizedBox(height: 2.dp),

              /// ✅ Multi-line Value Text
              objCommonWidgets.customText(
                context,
                value,
                10,
                valueColor ?? objConstantColor.navyBlue,
                objConstantFonts.montserratSemiBold,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildMiniProgressTracker(int statusIndex) {
    return Container(
      padding: EdgeInsets.all(12.dp),
      decoration: BoxDecoration(
          color: Colors.deepOrange.shade50,
          borderRadius: BorderRadius.circular(12.dp),
          border: Border.all(color: Colors.deepOrange.shade200)
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16.dp, color: Colors.deepOrange),
          SizedBox(width: 5.dp),
          Flexible(
            child: objCommonWidgets.customText(
                context, "Your order is currently being processed. You will receive an update once it's shipped.", 8,
                Colors.deepOrange,
                objConstantFonts.montserratMedium),
          ),

        ],
      ),
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
              width: 80.dp,
              height: 80.dp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.dp),
                border: Border.all(color: objConstantColor.navyBlue, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.dp),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.dp),
                  child: NetworkImageLoader(
                    imageUrl: '${ConstantURLs.baseUrl}$image',
                    placeHolder: objConstantAssest.placeHolder,
                    size: 60.dp,
                    imageSize: 80.dp,
                  ),
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
                      15,
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


  void openRatingsAndReview(BuildContext context) async {
    final Map<String, dynamic>? result =
    await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Benefits',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) =>
      const ProductRatingScreen(),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );

    /// ✅ User clicked Submit
    if (result != null) {
      final int rating = result['rating'];
      final String review = result['review'];

      debugPrint("User submitted review");
      debugPrint("Rating: $rating");
      debugPrint("Review: $review");

      // Call API / show success popup
      ReviewSuccessPopup.show(context);
    }
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
  final bool isReturn;

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
    this.isReturn = false
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
                  width: 13.dp,
                  height: 13.dp,
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    shape: BoxShape.circle,
                  ),
                  child: widget.isCompleted
                      ? Icon(Icons.check, size: 8.dp, color: Colors.white)
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
                      fontSize: 10.5.dp,
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
                8.5,
                Colors.black.withAlpha(150),
                objConstantFonts.montserratMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

}

