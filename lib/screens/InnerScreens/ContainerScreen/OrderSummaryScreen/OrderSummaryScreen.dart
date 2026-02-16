import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:lottie/lottie.dart';
import '../../../../Utility/SimpleCheckoutStepper.dart';
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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final summaryScreenNotifier = ref.read(orderSummaryScreenStateProvider.notifier);
      summaryScreenNotifier.updateCartListAndUserInfo();
    });
  }

  void callBackNavigation(BuildContext context){
    var state = ref.watch(orderSummaryScreenStateProvider);
    final notifier = ref.watch(orderSummaryScreenStateProvider.notifier);
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    if (state.pageIndex > 0){
      _pageController.previousPage(
        duration: 300.ms,
        curve: Curves.easeInOut,
      );
      notifier.updatePageIndex(state.pageIndex - 1);
    } else {
      userScreenNotifier.callNavigation(ScreenName.cart);
    }

  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(orderSummaryScreenStateProvider);


    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic) {
        if (didPop) return;
        if (!context.mounted) return;
        callBackNavigation(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          child: Column(
            children: [

              Padding(
                padding: EdgeInsets.only(left: 10.dp, bottom: 5.dp, top: 5.dp),
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    /// Back button (left aligned)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        minimumSize: const Size(0, 0),
                        padding: EdgeInsets.zero,
                        onPressed: () => callBackNavigation(context),
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
                      15,
                      Colors.black,
                      ConstantAssests.montserratSemiBold,
                    ),
                  ],
                ),
              ),

              Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 20.dp),
                  child: SimpleCheckoutStepper(currentStep: state.pageIndex)),



              /// Scrollable content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  pageSnapping: false,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [

                    /// Payment
                    /*Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.dp),
                      child: paymentType(context),
                    ),
                    SizedBox(height: 15.dp),*/


                    /// Shipping Address Card
                    shippingAddressView(),

                    paymentView(),




                    /// Price Details



                    /*Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.dp),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          orderSummaryScreenNotifier.callPlaceOrderAPI(context,
                              userScreenNotifier);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 14.dp,
                              horizontal: 20.dp),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25.dp),
                          ),
                          child: Center(
                            child: objCommonWidgets.customText(
                              context,
                              'Place Order',
                              13,
                              Colors.white,
                              ConstantAssests.montserratSemiBold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.dp)*/

                  ],
                ),
              ),

            ],
          ),
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



  Widget priceDetail(
      BuildContext context) {
    var state = ref.watch(orderSummaryScreenStateProvider);
    final notifier = ref.watch(orderSummaryScreenStateProvider.notifier);

    return GestureDetector(
      onTap: () => notifier.updatePriceView(!state.isPriceViewExpanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15.dp, horizontal: 10.dp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.dp),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      objCommonWidgets.customText(
                        context,
                        'Payable Amount',
                        14,
                        Colors.black,
                        ConstantAssests.montserratSemiBold,
                      ),
                      objCommonWidgets.customText(
                        context,
                        'Inc. of all taxes',
                        9,
                        Colors.black.withAlpha(180),
                        ConstantAssests.montserratMedium,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      objCommonWidgets.customText(
                        context,
                        '₹${state.totalPayableAmount}.0/_',
                        16,
                        Colors.black,
                        ConstantAssests.montserratSemiBold,
                      ),

                      objCommonWidgets.customText(
                        context,
                        !state.isPriceViewExpanded ? 'View Details' : 'Hide details',
                        10,
                        Colors.deepOrange,
                        ConstantAssests.montserratMedium,
                      ),
                    ],
                  ),
                ],
              ),

              if (state.isPriceViewExpanded) ...[
                SizedBox(height: 10.dp),

                DottedLine(
                  direction: Axis.horizontal,
                  lineLength: double.infinity,
                  lineThickness: 1.2,
                  dashLength: 6,
                  dashGapLength: 4,
                  dashColor: Colors.grey.shade400,
                ),

                SizedBox(height: 15.dp),

                amountText(
                    context,
                    'Amount',
                    '${state.totalAmount}',
                    ConstantAssests.montserratMedium,
                    12,
                    12),

                amountText(
                    context,
                    'Discount',
                    '${state.totalDiscount}',
                    ConstantAssests.montserratMedium,
                    12,
                    12),

                amountText(
                    context,
                    'Delivery Charge',
                    '89',
                    ConstantAssests.montserratMedium,
                    12,
                    12),

              ],
            ],
          ),
        ),
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


  Widget listViewCell({
    required BuildContext context,
    required String name,
    required String number,
    required String location,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onEdit,
  }) {
    return Stack(
      children: [
        CupertinoButton(
          onPressed: onTap,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.dp),
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Radio Button logic
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? Colors.orange : Colors.grey.shade400,
                  size: 18.dp,
                ),

                SizedBox(width: 8.dp),

                /// 🔹 Contact Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 1.dp),
                      objCommonWidgets.customText(
                        context,
                        name,
                        11,
                        Colors.black,
                        objConstantFonts.montserratSemiBold,
                      ),
                      SizedBox(height: 5.dp),
                      objCommonWidgets.customText(context, "+91 $number", 11, Colors.black.withAlpha(180), objConstantFonts.montserratMedium),
                      objCommonWidgets.customText(context, location, 11, Colors.black.withAlpha(180), objConstantFonts.montserratMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(top: 8.dp, right: 8.dp,
          child: CupertinoButton(
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            child: Image.asset(objConstantAssest.editImage, color: Colors.black, width: 15.dp,),
          ),)
      ],
    );
  }


  Widget shippingAddressView() {
    var state = ref.watch(orderSummaryScreenStateProvider);
    final notifier = ref.watch(orderSummaryScreenStateProvider.notifier);
    final userScreenNotifier = ref.watch(
        MainScreenGlobalStateProvider.notifier);
    final isDefaultAddress = state.selectedMember
        .trim()
        .isEmpty;

    return RawScrollbar(
      thumbColor: objConstantColor.black.withAlpha(45),
      thickness: 4,
      thumbVisibility: false,
      interactive: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.dp),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.dp),
                  child: objCommonWidgets.customText(
                      context, "Shipping Address", 12, Colors.black,
                      objConstantFonts.montserratSemiBold),
                ),
                SizedBox(height: 5.dp),

                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15.dp),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.dp),
                        child: objCommonWidgets.customText(
                            context,
                            "Select a delivery address for this order. "
                                "You can choose your saved address or send it to a friend or family member.",
                            10,
                            objConstantColor.navyBlue,
                            objConstantFonts.montserratMedium
                        ),
                      ),
                      SizedBox(height: 15.dp),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.dp),
                        child: Stack(
                          children: [
                            CupertinoButton(
                              onPressed: () => notifier.updateSelectedDelivery(''),
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.dp, horizontal: 8.dp),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isDefaultAddress ? Colors.green : Colors
                                        .grey.shade200,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.dp),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      blurRadius: 2,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      isDefaultAddress
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: isDefaultAddress
                                          ? Colors.green
                                          : Colors.grey.shade400,
                                      size: 18.dp,
                                    ),
                                    SizedBox(width: 5.dp),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 1.dp),
                                        objCommonWidgets.customText(
                                            context, state.userName.capitalize(),
                                            12, Colors.black,
                                            objConstantFonts.montserratSemiBold),
                                        SizedBox(height: 5.dp),
                                        objCommonWidgets.customText(
                                            context, "+91 ${state.mobileNumber}",
                                            11, Colors.black.withAlpha(180),
                                            objConstantFonts.montserratMedium),
                                        objCommonWidgets.customText(
                                            context, state.email, 11,
                                            Colors.black.withAlpha(180),
                                            objConstantFonts.montserratMedium),
                                        objCommonWidgets.customText(
                                            context, state.address, 11,
                                            Colors.black.withAlpha(180),
                                            objConstantFonts.montserratMedium),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Positioned(top: 8.dp, right: 8.dp,
                              child: CupertinoButton(
                                onPressed: () => userScreenNotifier.callNavigation(
                                    ScreenName.editProfile),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                child: Image.asset(
                                  objConstantAssest.editImage, color: Colors.black,
                                  width: 15.dp,),
                              ),)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.dp),


                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15.dp),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.dp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            objCommonWidgets.customText(
                                context, 'Looking for friends or family?',
                                10, Colors.black,
                                objConstantFonts.montserratMedium),
                            CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                child: objCommonWidgets.customText(
                                    context, 'Add a member?', 10, Colors.blueAccent,
                                    objConstantFonts.montserratSemiBold),
                                onPressed: () =>
                                    notifier.callAddMemberView(context, '', '', '')
                            )
                          ],
                        ),
                      ),


                      SizedBox(height: 10.dp),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.dp),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.familyMembers.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 12.dp),
                          itemBuilder: (context, index) {
                            final member = state.familyMembers[index];

                            // Assuming your state has a 'selectedMemberId' or similar
                            bool isSelected = state.selectedMember == member.name;

                            return listViewCell(
                                context: context,
                                name: member.name,
                                number: member.mobileNumber,
                                location: member.address,
                                isSelected: isSelected,
                                onTap: () {
                                  notifier.updateSelectedDelivery(member.name);
                                },
                                onEdit: () {
                                  notifier.callAddMemberView(
                                      context, member.name, member.mobileNumber,
                                      member.address);
                                }
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),


              ],
            ),

            SizedBox(height: 15.dp),

            CupertinoButton(
                padding: EdgeInsets.symmetric(
                    horizontal: 15.dp, vertical: 5.dp),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 13.dp),
                  decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(20.dp)
                  ),
                  child: Center(
                    child: objCommonWidgets.customText(
                        context, 'Confirm ', 13, Colors.white,
                        objConstantFonts.montserratSemiBold),
                  ),
                ), onPressed: () async {
              await _pageController.nextPage(
                duration: 300.ms,
                curve: Curves.easeInOut,
              );

              notifier.updatePageIndex(1);
            }),


            SizedBox(height: 15.dp),

          ],
        ),
      ),
    );
  }

  Widget paymentView(){
    var state = ref.watch(orderSummaryScreenStateProvider);
    final notifier = ref.watch(orderSummaryScreenStateProvider.notifier);
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return RawScrollbar(
      thumbColor: objConstantColor.black.withAlpha(45),
      thickness: 4,
      thumbVisibility: false,
      interactive: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15.dp),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.dp),
              child: priceDetail(context),
            ),

            SizedBox(height: 20.dp),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.dp),
              child: objCommonWidgets.customText(
                  context, "Choose Payment Type", 12, Colors.black,
                  objConstantFonts.montserratSemiBold),
            ),
            SizedBox(height: 15.dp),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.dp),
              child: objCommonWidgets.customText(
                  context, "Pay on Delivery", 12, Colors.black,
                  objConstantFonts.montserratSemiBold),
            ),
            SizedBox(height: 5.dp),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.dp),
              child: InkWell(
                onTap: () {
                  notifier.updateIsCod(!state.isCod);
                  notifier.clearAllPaymentSelection();
                },
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.dp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 2,
                          offset: const Offset(1, 0),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.dp),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Lottie.asset(
                              objConstantAssest.paymentType,
                              height: 70.dp,
                              repeat: true,
                            ),
                            SizedBox(width: 5.dp),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                objCommonWidgets.customText(
                                    context, "Pay on Delivery (Cash/UPI)", 12, Colors.black,
                                    objConstantFonts.montserratSemiBold),
                                objCommonWidgets.customText(
                                    context, "Pay cash or ask for QR code", 10, Colors.black.withAlpha(150),
                                    objConstantFonts.montserratMedium)
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              state.isCod
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: state.isCod
                                  ? Colors.green
                                  : Colors.grey.shade400,
                              size: 20.dp,
                            ),
                            SizedBox(width: 15.dp),
                          ],
                        ),

                        if (state.isCod)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.dp),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                notifier.callPlaceOrderAPI(context,
                                    userScreenNotifier);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 12.dp,
                                    horizontal: 20.dp),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(25.dp),
                                ),
                                child: Center(
                                  child: objCommonWidgets.customText(
                                    context,
                                    'Place Order',
                                    13,
                                    Colors.white,
                                    ConstantAssests.montserratSemiBold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.dp),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.dp),
              child: Row(
                children: [
                  Image.asset(objConstantAssest.bhmUPI, width: 50.dp),
                  SizedBox(width: 5.dp),
                  objCommonWidgets.customText(
                      context, "Pay by any UPI app", 12, Colors.black,
                      objConstantFonts.montserratSemiBold)
                ],
              ),
            ),

            SizedBox(height: 5.dp),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.paymentTypes.length,
              separatorBuilder: (context, index) => SizedBox(height: 10.dp),
              itemBuilder: (context, index) {
                final type = state.paymentTypes[index];
                return paymentCell(type.name, type.icon, type.description, type.isSelected, (){
                  notifier.updateIsOnlinePay(true);
                  notifier.selectPaymentByIndex(index);
                }, (){
                  notifier.callPlaceOrderAPI(context, userScreenNotifier);
                });
              },
            ),
            SizedBox(height: 10.dp),

          ],
        ),
      ),
    );
  }


  Widget paymentCell(String title, String icon, String description, bool selected, VoidCallback onSelect, VoidCallback doPayment){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.dp),
      child: InkWell(
        onTap: selected ? null : onSelect,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.dp),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 2,
                  offset: const Offset(1, 0),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 15.dp, horizontal: 15.dp),
            child: Column(
              children: [

                Row(
                  children: [

                    Image.asset(icon, width: 30.dp,),

                    SizedBox(width: 10.dp),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          objCommonWidgets.customText(
                              context, title, 13, Colors.black,
                              objConstantFonts.montserratSemiBold),
                          objCommonWidgets.customText(
                              context, description, 10, Colors.green,
                              objConstantFonts.montserratMedium)
                        ],
                      ),
                    ),
                    SizedBox(width: 5.dp),

                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected
                          ? Colors.green
                          : Colors.grey.shade400,
                      size: 20.dp,
                    ),

                  ],
                ),

                if (selected)
                Padding(
                  padding: EdgeInsets.only(left: 15.dp, right: 15.dp, top: 15.dp),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: doPayment,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12.dp,
                          horizontal: 20.dp),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(25.dp),
                      ),
                      child: Center(
                        child: objCommonWidgets.customText(
                          context,
                          'Pay via $title',
                          13,
                          Colors.white,
                          ConstantAssests.montserratSemiBold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}








extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return "";
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}