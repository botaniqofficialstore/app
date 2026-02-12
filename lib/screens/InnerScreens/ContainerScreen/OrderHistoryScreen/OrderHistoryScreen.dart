import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../Utility/NetworkImageLoader.dart';
import '../../../../constants/Constants.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../MainScreen/MainScreenState.dart';
import 'OrderHistoryScreenState.dart';


class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  OrderHistoryScreenState createState() => OrderHistoryScreenState();
}

class OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(orderHistoryScreenStateProvider.notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(orderHistoryScreenStateProvider);
    final notifier = ref.read(orderHistoryScreenStateProvider.notifier);

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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.dp),
                      child: Column(
                        children: [

                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 8.dp),
                            itemCount: state.allProducts.length,
                            itemBuilder: (context, index) {
                              final product = state.allProducts[index];
                              return productView(
                                product['image'],
                                product['name'],
                                '${product['count']}',
                                product['deliveryDate'],
                                product['price'],
                                product['rating'] ?? 0,
                                product['returned'],
                                  (){
                                    notifier.callDetailsScreenNavigation(context, product);
                                  }
                              );
                            },
                          ),

                          SizedBox(height: 10.dp)

                        ],
                      ),
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

  Widget headerView(){
    final mainScreenNotifier = ref.read(MainScreenGlobalStateProvider.notifier);

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
              mainScreenNotifier.callNavigation(ScreenName.profile);
            },
          ),

          SizedBox(width: 5.dp),

          objCommonWidgets.customText(
            context,
            'Order History',
            14,
            objConstantColor.navyBlue,
            objConstantFonts.montserratMedium,
          ),

          const Spacer(),

        ],
      ),
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
      VoidCallback onTap
      ){

    final notifier = ref.read(orderHistoryScreenStateProvider.notifier);
    final isAddRating = ratings == 0;
    final statusText = isReturned ? "Returned on" : "Delivered on";

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Stack(
        children: [

          Container(
            padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.dp),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(5.dp),
                  child: SizedBox(
                    width: 80.dp,
                    height: 80.dp,
                    child: NetworkImageLoader(
                      imageUrl: image,
                      placeHolder: objConstantAssest.placeHolder,
                      size: 80.dp,
                      imageSize: 80.dp,
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
                    objCommonWidgets.customText(context, 'item count: $quantity', 10, Colors.black, objConstantFonts.montserratMedium),
                    objCommonWidgets.customText(context, '$statusText : $date', 10, Colors.black, objConstantFonts.montserratMedium),
                    SizedBox(height: 2.5.dp),
                    objCommonWidgets.customText(context, '₹$price/_', 13, Colors.green, objConstantFonts.montserratSemiBold),
                    SizedBox(height: 2.5.dp),
                    if (isAddRating)...{
                      SizedBox(height: 2.5.dp),
                      CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 10.dp),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20.dp)
                            ),
                            child: Center(
                              child: objCommonWidgets.customText(
                                  context, 'Write a Review', 9, objConstantColor.white,
                                  objConstantFonts.montserratSemiBold),
                            ),
                          ), onPressed: ()=> notifier.openRatingsAndReview(context))

                    }else...{
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

                    },
                    SizedBox(height: 2.5.dp),
                  ],
                )
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            right: 0.dp,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 4.dp),
              decoration: BoxDecoration(
                  color: isReturned ? Colors.deepOrange : Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.dp),
                    bottomRight: Radius.circular(8.dp)
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
              ),
              child: objCommonWidgets.customText(context, isReturned ? "Returned" : "Delivered", 10, Colors.white, objConstantFonts.montserratSemiBold),
            ),
          ),
        ],
      ),
    );
  }



Widget shimmerView(){
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(height: 8.dp),
      itemCount: 15,
      itemBuilder: (context, index) {

        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.dp),
                ),
                child: Row(
                  children: [
                    // Image Bone
                    Container(
                      width: 80.dp,
                      height: 80.dp,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.dp),
                      ),
                    ),

                    SizedBox(width: 10.dp),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Bone
                          Container(width: 120.dp, height: 12.dp, color: Colors.white),
                          SizedBox(height: 6.dp),
                          // Quantity Bone
                          Container(width: 80.dp, height: 10.dp, color: Colors.white),
                          SizedBox(height: 6.dp),
                          // Date Bone
                          Container(width: 100.dp, height: 10.dp, color: Colors.white),
                          SizedBox(height: 8.dp),
                          // Price Bone
                          Container(width: 60.dp, height: 13.dp, color: Colors.white),
                          SizedBox(height: 8.dp),
                          // Rating/Button Bone
                          Container(
                            width: 90.dp,
                            height: 25.dp,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.dp),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // Status Badge Bone
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 70.dp,
                  height: 20.dp,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.dp),
                      topRight: Radius.circular(8.dp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
}

}