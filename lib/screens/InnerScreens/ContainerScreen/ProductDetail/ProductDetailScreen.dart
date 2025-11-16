// ProductDetailScreen.dart
import 'package:botaniqmicrogreens/constants/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../MainScreen/MainScreenState.dart';
import 'ProductDetailScreenState.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final cartScreenNotifier =
      ref.read(productDetailScreenGlobalStateProvider.notifier);
      cartScreenNotifier.fetchSavedData();
      cartScreenNotifier.callProductDetailsGetAPI(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0, // scroll offset (0 = top)
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    var detailsScreenState = ref.watch(productDetailScreenGlobalStateProvider);
    var detailsScreenNotifier =
    ref.watch(productDetailScreenGlobalStateProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: objConstantColor.white,
      body: detailsScreenState.isLoading
          ? _buildShimmerPlaceholder()
          : Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 5.dp,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Background Image
                        Image.network(
                          '${ConstantURLs.baseUrl}${savedProductDetails?.coverImage}',
                          width: double.infinity,
                          height: 180.dp,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              objConstantAssest.placeHolder,
                              // fallback image from assets
                              width: double.infinity,
                              height: 180.dp,
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

                        // Text positioned above bottom
                        Positioned(
                          left: 10.dp,
                          bottom: 10.dp, // 👈 distance from bottom
                          child: objCommonWidgets.customText(
                            context,
                            CodeReusability().cleanProductName(
                                detailsScreenState.productData?.productName),
                            30,
                            objConstantColor.white,
                            objConstantFonts.montserratBold,
                          ),
                        ),

                        Positioned(
                          top: 10.dp,
                          right: 15.dp,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.all(4.dp),
                              minSize: 35.dp,
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                (detailsScreenState.wishList == 0)
                                    ? objConstantAssest.wishUnCheckWhite
                                    : objConstantAssest.wishRed,
                                width: 20.dp,
                              ),
                              onPressed: () {
                                if (detailsScreenState.wishList == 0) {
                                  detailsScreenNotifier.callAddToWishList(
                                      context,
                                      '${detailsScreenState.productData?.productId}');
                                } else {
                                  detailsScreenNotifier.callRemoveFromWishList(
                                      context,
                                      '${detailsScreenState.productData?.productId}');
                                }
                              },
                            ),
                          ),
                        ),

                        Positioned(
                          top: 10.dp,
                          left: 15.dp,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.all(4.dp),
                              minSize: 35.dp,
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                objConstantAssest.backIcon,
                                color: objConstantColor.white,
                                width: 25.dp,
                              ),
                              onPressed: () {
                                ref
                                    .watch(MainScreenGlobalStateProvider.notifier)
                                    .callNavigation(ScreenName.home);
                              },
                            ),
                          ),
                        )
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.all(14.dp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5.dp),
                          objCommonWidgets.customText(
                              context,
                              '${detailsScreenState.productData?.description}',
                              14.5,
                              objConstantColor.navyBlue,
                              objConstantFonts.montserratMedium,
                              textAlign: TextAlign.justify),

                          SizedBox(height: 20.dp),

                          /// Nutrients section
                          objCommonWidgets.customText(
                            context,
                            'Nutritional Benefits',
                            18,
                            objConstantColor.navyBlue,
                            objConstantFonts.montserratSemiBold,
                          ),

                          SizedBox(height: 10.dp),

                          /// Nutrient cards inside wrap
                          Wrap(
                            spacing: 12,
                            runSpacing: 14,
                            children: [
                              // if nutrients list is empty show fallback else list of nutrient cards
                              if ((detailsScreenState.productData?.nutrients ??
                                  [])
                                  .isNotEmpty)
                                for (var n in detailsScreenState
                                    .productData!.nutrients)
                                  Container(
                                    width: 150.dp,
                                    padding: EdgeInsets.all(14.dp),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(18.dp),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                          Colors.grey.withOpacity(0.5),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                          offset: const Offset(3, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        /// Circle icon background
                                        Container(
                                          padding: EdgeInsets.all(8.dp),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: objConstantColor.navyBlue
                                                .withOpacity(0.08),
                                          ),
                                          child: Text(
                                            _getVitaminIcon(n.vitamin),
                                            style:
                                            TextStyle(fontSize: 20.dp),
                                          ),
                                        ),
                                        SizedBox(height: 10.dp),

                                        /// Vitamin name
                                        Text(
                                          n.vitamin,
                                          style: TextStyle(
                                            fontSize: 15.dp,
                                            fontWeight: FontWeight.w600,
                                            color: objConstantColor.navyBlue,
                                          ),
                                        ),
                                        SizedBox(height: 6.dp),

                                        /// Benefit text
                                        Text(
                                          n.benefit,
                                          style: TextStyle(
                                            fontSize: 13.dp,
                                            height: 1.3,
                                            color:
                                            Colors.black.withOpacity(0.7),
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  )
                              else
                                Padding(
                                  padding: EdgeInsets.only(top: 10.dp),
                                  child: objCommonWidgets.customText(
                                    context,
                                    'No nutrients information available.',
                                    14,
                                    objConstantColor.gray,
                                    objConstantFonts.montserratMedium,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (detailsScreenState.inCart == 1)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ref
                              .watch(MainScreenGlobalStateProvider.notifier)
                              .callNavigation(ScreenName.cart);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.dp, vertical: 15.dp),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.dp, vertical: 15.dp),
                            decoration: BoxDecoration(
                              color: objConstantColor.navyBlue,
                              borderRadius: BorderRadius.circular(4.dp),
                            ),
                            alignment: Alignment.center,
                            child: objCommonWidgets.customText(
                              context,
                              'View in Cart',
                              15,
                              objConstantColor.white,
                              objConstantFonts.montserratSemiBold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (detailsScreenState.inCart == 0)
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
                  padding: EdgeInsets.fromLTRB(20.dp, 15.dp, 20.dp, 10.dp),
                  child: Row(
                    children: [
                      /// Count Handler
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.dp, vertical: 7.dp),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: objConstantColor.navyBlue, width: 1),
                            borderRadius: BorderRadius.circular(5.dp),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              CupertinoButton(
                                onPressed: () {
                                  detailsScreenNotifier.decrementCount();
                                },
                                padding: EdgeInsets.zero,
                                minSize: 0,
                                child: Image.asset(
                                  objConstantAssest.minusIcon,
                                  width: 13.dp,
                                  height: 15.dp,
                                ),
                              ),

                              Text(
                                '${detailsScreenState.count}',
                                style: TextStyle(
                                  fontSize: 20.dp,
                                  fontFamily: objConstantFonts.montserratMedium,
                                  color: objConstantColor.navyBlue,
                                ),
                              ),

                              CupertinoButton(
                                onPressed: () {
                                  detailsScreenNotifier.incrementCount();
                                },
                                padding: EdgeInsets.zero,
                                minSize: 0,
                                child: Image.asset(
                                  objConstantAssest.addIcon,
                                  width: 13.dp,
                                  height: 15.dp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 12.dp), // 👈 gap between the two

                      /// Add to Cart Button
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            var mainNotifier =
                            ref.watch(MainScreenGlobalStateProvider.notifier);
                            detailsScreenNotifier.callAddToCartAPI(
                                context,
                                '${detailsScreenState.productData?.productId}',
                                mainNotifier);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.dp, vertical: 12.dp),
                            decoration: BoxDecoration(
                              color: objConstantColor.navyBlue,
                              borderRadius: BorderRadius.circular(4.dp),
                            ),
                            alignment: Alignment.center,
                            child: objCommonWidgets.customText(
                              context,
                              'Add to Cart',
                              15,
                              objConstantColor.white,
                              objConstantFonts.montserratSemiBold,
                            ),
                          ),
                        ),
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

  /// Helper method for nutrient icons
  String _getVitaminIcon(String vitamin) {
    final key = vitamin.trim().toLowerCase(); // normalize input

    switch (key) {
      case "vitamin a":
        return "👁";
      case "vitamin c":
        return "🍊";
      case "vitamin k":
        return "🦴";
      case "folate":
        return "🧬";
      case "calcium & magnesium":
        return "🥛";
      case "iron":
        return "❤️";
      case "protein":
        return "💪";
      default:
        return "🌱";
    }
  }

  /// Shimmer placeholder while data loads
  Widget _buildShimmerPlaceholder() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top image shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: double.infinity,
              height: 180.dp,
              color: Colors.white,
            ),
          ),

          Padding(
            padding: EdgeInsets.all(14.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.dp),
                // Title shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 200.dp,
                    height: 25.dp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.dp),

                // Description shimmer lines
                for (int i = 0; i < 3; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.dp),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: double.infinity,
                        height: 12.dp,
                        color: Colors.white,
                      ),
                    ),
                  ),

                SizedBox(height: 20.dp),

                // Nutritional header shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 150.dp,
                    height: 20.dp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 15.dp),

                // Nutrient cards shimmer
                Wrap(
                  spacing: 12,
                  runSpacing: 14,
                  children: List.generate(
                    4,
                        (index) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 150.dp,
                        height: 90.dp,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.dp),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.dp),

          // Bottom Add to cart area shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.dp),
            child: Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 48.dp,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.dp),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.dp),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 48.dp,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.dp),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.dp),
        ],
      ),
    );
  }
}
