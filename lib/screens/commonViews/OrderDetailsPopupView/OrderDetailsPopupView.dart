import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../Utility/NetworkImageLoader.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../InnerScreens/ContainerScreen/OrderDetailsScreen/OrderDetailsScreen.dart';
import 'OrderDetailsPopupViewState.dart';


class OrderDetailsPopupView extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;

  const OrderDetailsPopupView(this.product, {super.key});

  @override
  OrderDetailsPopupViewState createState() => OrderDetailsPopupViewState();
}

class OrderDetailsPopupViewState extends ConsumerState<OrderDetailsPopupView> {
  final ScrollController _scrollController = ScrollController();
  int animatedStep = -1;


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(orderDetailsPopupViewStateProvider.notifier);
      notifier.loadInitialData(widget.product);
      startStepAnimation();
    });
  }

  void startStepAnimation() async {
    var state = ref.watch(orderDetailsPopupViewStateProvider);

    for (int i = 0; i <= state.steps.length; i++) {
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
    var state = ref.watch(orderDetailsPopupViewStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: RefreshIndicator(
        onRefresh: () async {

        },
        color: objConstantColor.navyBlue,
        backgroundColor: objConstantColor.white,
        child: SafeArea(
          child: Column(
            children: [

              headerView(),

              Expanded(
                child: CupertinoScrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        statusView(),

                        SizedBox(height: 15.dp),

                        titleText('Order Details'),
                        orderDetailsView(),

                        SizedBox(height: 15.dp),

                        titleText('Product Details'),
                        productView(
                          state.allProducts['image'],
                          state.allProducts['name'],
                          '${state.allProducts['count']}',
                          state.allProducts['deliveryDate'],
                          state.allProducts['price'],
                          state.allProducts['rating'] ?? 0,
                          state.allProducts['returned'],
                          state.allProducts['quantity'],
                        ),

                        SizedBox(height: 15.dp),


                        if(!state.allProducts['returned'] && state.allProducts['rating'] == 0)...{
                          ratingAddView(),
                          SizedBox(height: 15.dp),
                        },


                        if(state.allProducts['returned'])...{
                          returnReasonView(),
                          SizedBox(height: 15.dp),
                        },



                        trackDetails(),
                        SizedBox(height: 15.dp),

                        if(state.enableReturnRequest)...{
                          returnRequestView(),
                          SizedBox(height: 15.dp),
                        },





                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget returnRequestView(){
    final notifier = ref.read(orderDetailsPopupViewStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText('Request for return'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 15.dp, vertical: 10.dp),
          child: objCommonWidgets.customText(
              context, 'Returns can be requested within 24 hours of delivery. Submit your request here, and we will assist you with the return process.',
              10, Colors.black, objConstantFonts.montserratMedium),
        ),
        SizedBox(height: 10.dp),
        CupertinoButton(
          padding: EdgeInsets.symmetric(horizontal: 15.dp),
            child: Container(
          padding: EdgeInsets.symmetric(vertical: 13.dp),
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(20.dp)
          ),
          child: Center(child: objCommonWidgets.customText(context,
              'Request for return', 13, Colors.white, objConstantFonts.montserratSemiBold)),
        ), onPressed: () => notifier.openReturnRequest(context))
      ],
    );
  }

  Widget returnReasonView(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText('Return Reason'),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 15.dp, vertical: 10.dp),
          child: objCommonWidgets.customText(
              context, 'The product did not meet my expectations for an organic purchase.',
              10, Colors.black, objConstantFonts.montserratMedium),
        )
      ],
    );
  }

  Widget trackDetails(){
    var state = ref.watch(orderDetailsPopupViewStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText('Tracking Details'),

        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.steps.length,
            itemBuilder: (context, index) {
              final lastIndex = (state.steps.length - 1) == index;
              var dates = [
                '20/12/2025 10:30 PM',
                '21/12/2025 9:15 AM',
                '21/12/2025 7:45 PM',
                '22/12/2025 11:30 AM',
                '24/12/2025 6:15 AM',
                '24/12/2025 3:48 PM',
                '27/12/2025 10:23 AM',
              ];


              return AnimatedOrderTrackStep(
                text: state.steps[index],
                date: dates[index],
                isCompleted: index <= animatedStep,
                isLast: index == state.steps.length - 1,
                isReturn: state.allProducts['returned'] && lastIndex,
                activeColor: (state.allProducts['returned'] && lastIndex) ? Colors.deepOrange :
                const Color(0xFF029309),

              );
            },
          ),
        )
      ],
    );
  }

  Widget ratingAddView(){
    final notifier = ref.read(orderDetailsPopupViewStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText('Rating & Review'),

        SizedBox(height: 5.dp),

        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
          child: Column(
            children: [
              objCommonWidgets.customText(
                  context, 'Please rate the product and delivery experience. '
                  'Your honest feedback helps maintain quality and service standards.', 10, objConstantColor.black,
                  objConstantFonts.montserratMedium),

              SizedBox(height: 10.dp),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.dp, horizontal: 13.dp),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20.dp)
                        ),
                        child: Center(
                          child: objCommonWidgets.customText(
                              context, 'Write a Review', 9, objConstantColor.white,
                              objConstantFonts.montserratSemiBold),
                        ),
                      ), onPressed: ()=> notifier.openRatingsAndReview(context)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget statusView(){
    var state = ref.watch(orderDetailsPopupViewStateProvider);
    final isReturned = state.allProducts['returned'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.dp),
      decoration: BoxDecoration(
          color: isReturned ? Colors.deepOrange : Colors.green,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          objCommonWidgets.customText(
            context,
            isReturned ? 'Returned' : 'Delivered',
            13,
            objConstantColor.white,
            objConstantFonts.montserratSemiBold,
          ),
          SizedBox(width: 5.dp),
          Image.asset(isReturned ? objConstantAssest.returned : objConstantAssest.delivered, width: 15.dp, color: Colors.white),

        ],
      ),
    );
  }

  Widget orderDetailsView(){
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleValueRow('OrderID :', '#OD578451552410'),
          titleValueRow('Ordered date :', '17/01/2026'),
          titleValueRow('Delivery date:', '17/01/2026')
        ],
      ),
    );
  }

  Widget titleValueRow(String title, String value){
    return Row(
      children: [
        objCommonWidgets.customText(
          context,
          title,
          11,
          Colors.black,
          objConstantFonts.montserratMedium,
        ),
        SizedBox(width: 5.dp),
        objCommonWidgets.customText(
          context,
          value,
          10.5,
          Colors.black.withAlpha(150),
          objConstantFonts.montserratMedium,
        ),
      ],
    );
  }



  Widget headerView(){
    var state = ref.watch(orderDetailsPopupViewStateProvider);

    return Container(
      padding: EdgeInsets.only(top: 5.dp, right: 10.dp, left: 10.dp, bottom: 8.dp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          CupertinoButton(padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            child: Icon(Icons.arrow_back_rounded,
                color: Colors.black,
                size: 18.dp),
            onPressed: () {
            Navigator.pop(context);
            },
          ),

          SizedBox(width: 5.dp),

          objCommonWidgets.customText(
            context,
            'Details',
            14,
            objConstantColor.black,
            objConstantFonts.montserratMedium,
          ),

          const Spacer(),

        ],
      ),
    );
  }

  Widget titleText(String title){
    return Padding(
      padding: EdgeInsets.only(left: 15.dp, bottom: 2.dp, top: 5.dp),
      child: objCommonWidgets.customText(context, title, 12, Colors.black, objConstantFonts.montserratMedium),
    );
  }


  Widget productView(
      String image,
      String name,
      String quantity,
      String date,
      String price,
      int ratings,
      bool isReturned,
      String netWeight
      ){


    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: (){

      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(5.dp),
              child: SizedBox(
                width: 90.dp,
                height: 90.dp,
                child: NetworkImageLoader(
                  imageUrl: image,
                  placeHolder: objConstantAssest.placeHolder,
                  size: 90.dp,
                  imageSize: 90.dp,
                  bottomCurve: 5,
                  topCurve: 5,
                ),
              ),
            ),

            SizedBox(width: 10.dp),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                objCommonWidgets.customText(context, name, 12, Colors.deepOrange, objConstantFonts.montserratSemiBold),
                SizedBox(height: 2.5.dp),
                objCommonWidgets.customText(context, 'Quantity: $quantity', 11, Colors.black.withAlpha(150), objConstantFonts.montserratMedium),
                SizedBox(height: 2.5.dp),
                objCommonWidgets.customText(context, netWeight, 11, Colors.black.withAlpha(150), objConstantFonts.montserratMedium),
                SizedBox(height: 2.5.dp),
                objCommonWidgets.customText(context, '₹$price/_', 13, Colors.green, objConstantFonts.montserratSemiBold),
                SizedBox(height: 2.5.dp),

                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < ratings
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 18.dp,
                    );
                  }),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }



}