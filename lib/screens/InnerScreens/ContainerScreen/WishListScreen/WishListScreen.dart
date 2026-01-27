import 'package:botaniqmicrogreens/CodeReusable/CodeReusability.dart';
import 'package:botaniqmicrogreens/screens/commonViews/CommonWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final wishListScreenNotifier = ref.read(WishListScreenGlobalStateProvider.notifier);
      wishListScreenNotifier.callWishListGepAPI(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userScreenNotifier =
    ref.watch(MainScreenGlobalStateProvider.notifier);
    final wishListScreenNotifier =
    ref.read(WishListScreenGlobalStateProvider.notifier);
    final wishListState = ref.watch(WishListScreenGlobalStateProvider);
    final wishListData = wishListState.wishListItems;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: objConstantColor.white,
        body: Column(
          children: [
            /// Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: objConstantColor.white,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 15.dp, top: 5.dp),
                child: Row(
                  children: [
                    CupertinoButton(
                      minimumSize: const Size(0, 0),
                      padding: EdgeInsets.zero,
                      child: Image.asset(
                        objConstantAssest.backIcon,
                        width: 20.dp,
                      ),
                      onPressed: () {
                        userScreenNotifier.callNavigation(ScreenName.home);
                      },
                    ),
                    SizedBox(width: 5.dp),
                    CommonWidget().customeText(
                      'My WishList',
                      15,
                      objConstantColor.navyBlue,
                      ConstantAssests.montserratSemiBold,
                    ),
                  ],
                ),
              ),
            ),
      
            SizedBox(height: 20.dp),
      
            /// Body (with pull to refresh)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await wishListScreenNotifier.callWishListGepAPI(context);
                },
                color: objConstantColor.navyBlue,
                backgroundColor: objConstantColor.white,
                child: wishListData.isNotEmpty
                    ? GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 0),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.60,
                  ),
                  itemCount: wishListData.length,
                  itemBuilder: (context, index) {
                    final item = wishListData[index];
                    final product = item.productDetails!;
                    return _buildProductCard(
                        item, product, index, wishListScreenNotifier);
                  },
                )
                    : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            objConstantAssest.noWish,
                            width: 65.dp,
                          ),
                          Text(
                            "Your wishlist is empty.",
                            style: TextStyle(
                              color: objConstantColor.gray,
                              fontSize: 13.dp,
                              fontFamily:
                              ConstantAssests.montserratMedium,
                            ),
                          ),
      
                          SizedBox(height: 20.dp),
      
                          CupertinoButton(padding: EdgeInsets.zero,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: objConstantColor.orange,
                                    borderRadius: BorderRadius.circular(5.dp)
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                                child: objCommonWidgets.customText(context,
                                    'Add New Products',
                                    14, objConstantColor.white,
                                    objConstantFonts.montserratBold),
                              ),
                              onPressed: (){
                                userScreenNotifier.callNavigation(ScreenName.home);
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      
            SizedBox(height: 10.dp),
          ],
        ),
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
        ref.watch(MainScreenGlobalStateProvider.notifier).callNavigation(
            ScreenName.productDetail);
      },
      child: Stack(
        children: [

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.dp),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(35), blurRadius: 15, offset: const Offset(0, 8)),
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
                                  14, objConstantColor.green, objConstantFonts.montserratSemiBold),
                              SizedBox(width: 3.dp),
                              Text(
                                "₹${product.productPrice}/_",
                                style: TextStyle(
                                  color: objConstantColor.gray,
                                  fontSize: 14.dp,
                                  fontFamily: ConstantAssests.montserratMedium,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: objConstantColor.gray,
                                  decorationThickness: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        objCommonWidgets.customText(context,
                            "${product.gram}gm",
                            12, objConstantColor.black, objConstantFonts.montserratSemiBold),

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
                                    12, objConstantColor.white, objConstantFonts.montserratSemiBold),
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