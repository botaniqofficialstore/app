import 'package:botaniqmicrogreens/CodeReusable/CodeReusability.dart';
import 'package:botaniqmicrogreens/screens/commonViews/CommonWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../CodeReusable/utilities.dart';
import '../../../../Utility/NetworkImageLoader.dart';
import '../../../../constants/ConstantAssests.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'WishListModel.dart';
import 'WishListScreenState.dart';

class WishListScreen extends ConsumerStatefulWidget {
  const WishListScreen({super.key});

  @override
  WishListScreenState createState() => WishListScreenState();
}

class WishListScreenState extends ConsumerState<WishListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final wishListScreenNotifier = ref.read(WishListScreenGlobalStateProvider.notifier);
      wishListScreenNotifier.callWishListGepAPI(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Always dispose controllers to prevent memory leaks
    super.dispose();
  }

  Widget build(BuildContext context) {
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);
    final wishListScreenNotifier = ref.read(WishListScreenGlobalStateProvider.notifier);
    final wishListState = ref.watch(WishListScreenGlobalStateProvider);
    final wishListData = wishListState.wishListItems;

    return RefreshIndicator(
      onRefresh: () async {
        await wishListScreenNotifier.callWishListGepAPI(context);
        _scrollController.jumpTo(0);
      },
      color: objConstantColor.navyBlue,
      backgroundColor: objConstantColor.white,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          // 1. Remove Expanded.
          // 2. RefreshIndicator must wrap the scrollable area.
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                physics: wishListState.isLoading
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                child: ConstrainedBox(
                  // This forces the Column to be at least as tall as the screen
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      /// Header
                      Padding(
                        padding: EdgeInsets.only(left: 15.dp, top: 5.dp),
                        child: Row(
                          children: [
                            CupertinoButton(
                              minimumSize: const Size(0, 0),
                              padding: EdgeInsets.zero,
                              child: Image.asset(
                                objConstantAssest.backIcon,
                                width: 15.dp,
                              ),
                              onPressed: () {
                                userScreenNotifier.callNavigation(ScreenName.home);
                              },
                            ),
                            SizedBox(width: 5.dp),
                            CommonWidget().customeText(
                              'My WishList',
                              13,
                              objConstantColor.black,
                              ConstantAssests.montserratSemiBold,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10.dp),
                      infoView(),
                      SizedBox(height: 15.dp),

                      if (wishListState.isLoading) ...{
                        buildProductShimmer()
                      } else if (!wishListState.isLoading && wishListData.isNotEmpty) ...{
                        Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.60,
                              ),
                              itemCount: wishListData.length,
                              itemBuilder: (context, index) {
                                final item = wishListData[index];
                                final product = item.productDetails!;
                                return _buildProductCard(item, product, index, wishListScreenNotifier);
                              },
                            ),
                          ],
                        ),
                      } else ...{
                        SizedBox(
                          height: constraints.maxHeight * 0.7,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(objConstantAssest.noWish, width: 65.dp),
                                Text(
                                  "Your wishlist is empty.",
                                  style: TextStyle(
                                    color: objConstantColor.gray,
                                    fontSize: 13.dp,
                                    fontFamily: ConstantAssests.montserratMedium,
                                  ),
                                ),
                                SizedBox(height: 15.dp),
                                CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: objConstantColor.orange,
                                          borderRadius: BorderRadius.circular(5.dp)
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                                      child: objCommonWidgets.customText(context, 'Add New Products', 12, objConstantColor.white, objConstantFonts.montserratSemiBold),
                                    ),
                                    onPressed: () {
                                      userScreenNotifier.callNavigation(ScreenName.home);
                                    }
                                )
                              ],
                            ),
                          ),
                        )
                      },
                      // Bottom padding to ensure the bounce clears the bottom edge
                      SizedBox(height: 20.dp),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget infoView(){
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
      child: objCommonWidgets.customText(context, "Your wishlist saves the products you love for later. Review your saved items anytime and move them to your cart when you're ready to purchase.",
          9.5, Colors.black, objConstantFonts.montserratMedium,
          textAlign: TextAlign.justify),
    );
  }

  Widget buildProductShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.dp, vertical: 5.dp),
      child: GridView.builder(
        itemCount: 6, // Number of shimmer placeholders
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.dp),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 5, offset: const Offset(1, 1)),
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder
                  Container(
                    height: 120.dp,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 8.dp),
                  // Text placeholders
                  Container(
                    height: 14.dp,
                    width: 100.dp,
                    color: Colors.black,
                  ),
                  SizedBox(height: 6.dp),
                  Container(
                    height: 14.dp,
                    width: 60.dp,
                    color: Colors.black,
                  ),
                  SizedBox(height: 13.dp),
                  Container(
                    height: 25.dp,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  // ✅ Product Card Widget
  Widget _buildProductCard(WishListItem item, ProductDetailsData product, int index, WishListScreenGlobalStateNotifier notifier) {
    final GlobalKey sourceKey = GlobalKey();
    var userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return GestureDetector(
      onTap: (){
        savedProductDetails = ProductDetailStatus(productID: product.productId!,
            coverImage: product.coverImage!,
            inCart: item.inCart!,
            isWishlisted: 1);

        notifier.callNavigateToDetailsScreen(context);

      },
      child: Stack(
        children: [

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.dp),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(55), blurRadius: 5, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 5.dp, right: 5.dp, top: 5.dp),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8.dp), topRight: Radius.circular(8.dp)),
                          child: NetworkImageLoader(
                            imageUrl: '${ConstantURLs.baseUrl}${product.image}',
                            placeHolder: objConstantAssest.placeHolder,
                            size: double.infinity,
                            imageSize: double.infinity,
                          ),
                        ),
                      ),


                      // ✅ Top-right heart button
                      Positioned(
                        right: 10.dp,
                        top: 10.dp,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: CupertinoButton(
                            key: sourceKey,
                            padding: EdgeInsets.all(4.dp),
                            minSize: 25.dp,
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              objConstantAssest.wishRed,
                              width: 15.dp,
                            ),
                            onPressed: () {
                              notifier.callRemoveFromWishList(context, '${product.productId}', index);
                            },
                          ),
                        ),
                      ),


                      Positioned(bottom: 5.dp, left: 12.dp, child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(5.dp)
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 1.dp, horizontal: 5.dp),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            objCommonWidgets.customText(context, 'Verified',
                                10, Colors.white,
                                objConstantFonts.montserratSemiBold),
                            SizedBox(width: 1.dp),
                            SizedBox(
                              width: 10.dp,
                              child: Image.asset(
                                  objConstantAssest.verify,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),)
                    ],
                  ),
                ),


                Padding(padding: EdgeInsets.symmetric(horizontal: 10.dp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6.dp),

                        // ✅ Name
                        objCommonWidgets.customText(context,
                            CodeReusability().cleanProductName(product.productName),
                            12, Colors.black, objConstantFonts.montserratSemiBold),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.dp),
                          child: Row(
                            children: [
                              objCommonWidgets.customText(context,
                                  "₹${product.productSellingPrice}/_",
                                  13, Colors.black, objConstantFonts.montserratSemiBold),
                              SizedBox(width: 3.dp),
                              Text(
                                "₹${product.productPrice}/_",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.dp,
                                    decoration: TextDecoration.lineThrough,
                                    fontFamily: objConstantFonts.montserratMedium
                                ),
                              ),
                            ],
                          ),
                        ),

                        objCommonWidgets.customText(context,
                            "${product.gram}gm",
                            11, objConstantColor.black.withAlpha(150), objConstantFonts.montserratMedium),

                        SizedBox(height: 10.dp),

                        // ✅ Add to cart button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8.dp),
                              decoration: BoxDecoration(
                                color: (item.inCart == 0)
                                    ? objConstantColor.navyBlue
                                    : objConstantColor.orange,
                                borderRadius: BorderRadius.circular(5.dp),
                              ),
                              child: Center(
                                child: objCommonWidgets.customText(context,
                                    (item.inCart == 0)
                                        ? "Add to Cart"
                                        : 'View in Cart',
                                    10, objConstantColor.white, objConstantFonts.montserratSemiBold),
                              )
                          ),
                          onPressed: () {
                            notifier.viewOrAddToCart(context, userScreenNotifier, '${product.productId}', (item.inCart == 0), index);
                          },
                        ),

                        SizedBox(height: 10.dp),

                      ],
                    ))


              ],
            ),
          ),

          // ✅ Offer label
          Positioned(
              top: 5.dp,
              left: 0.dp,
              child: Container(
                color: objConstantColor.yellow,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 5.dp, top: 1.dp, bottom: 1.dp, right: 10.dp),
                  child: Text(
                    "${PriceHelper.getDiscountPercentage(
                      productPrice: product.productPrice ?? 0,
                      sellingPrice: product.productSellingPrice ?? 0,
                    )} OFF",
                    style: TextStyle(
                      color: objConstantColor.black,
                      fontSize: 10.dp,
                      fontFamily: ConstantAssests.montserratSemiBold,
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }



}