import 'package:botaniqmicrogreens/CodeReusable/CodeReusability.dart';
import 'package:botaniqmicrogreens/Utility/Logger.dart';
import 'package:botaniqmicrogreens/screens/commonViews/CommonWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../CodeReusable/utilities.dart';
import '../../../../constants/ConstantAssests.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../../commonViews/CustomToast.dart';
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
    var userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);
    Logger().log('----------------> ${item.inCart}');

    return GestureDetector(
      onTap: (){
        savedProductDetails = ProductDetailStatus(productID: product.productId!,
            coverImage: product.coverImage!,
            inCart: item.inCart!,
            isWishlisted: 1);
        ref.watch(MainScreenGlobalStateProvider.notifier).callNavigation(
            ScreenName.productDetail);
      },
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: objConstantColor.navyBlue.withOpacity(0.2)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(5, 4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Fixed height image
                SizedBox(
                  height: 130.dp,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.dp),
                    child: Stack(
                      children: [
                        // ✅ Background Image
                        Positioned.fill(
                          child: Image.network(
                            '${ConstantURLs.baseUrl}${product.image}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                objConstantAssest.placeHolder, // fallback image from assets
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
                        ),

                        // ✅ Top-right heart button
                        Positioned(
                          top: 6.dp,
                          right: 6.dp,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.all(4.dp),
                              minSize: 28.dp,
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // ✅ Name
                Text(CodeReusability().cleanProductName(product.productName),
                  style: TextStyle(
                    color: objConstantColor.black,
                    fontSize: 15.dp,
                    fontFamily: ConstantAssests.montserratSemiBold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.dp),
                  child: Row(
                    children: [
                      Text(
                        "₹${product.productSellingPrice}/_",
                        style: TextStyle(
                          color: objConstantColor.green,
                          fontSize: 14.dp,
                          fontFamily: ConstantAssests.montserratSemiBold,
                        ),
                      ),
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

                Text(
                  "${product.gram}gm",
                  style: TextStyle(
                    color: objConstantColor.navyBlue,
                    fontSize: 14.dp,
                    fontFamily: ConstantAssests.montserratSemiBold,
                  ),
                ),

                const Spacer(),

                // ✅ Add to cart button
                SizedBox(
                  height: 35.dp,
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: (item.inCart == 0) ? objConstantColor.navyBlue : objConstantColor.orange,
                    borderRadius: BorderRadius.circular(5.dp),
                    child: Text( (item.inCart == 0) ? "Add to Cart" : 'View in Cart',
                      style: TextStyle(
                        color: objConstantColor.white,
                        fontSize: 13.dp,
                        fontFamily: ConstantAssests.montserratSemiBold,
                      ),
                    ),
                    onPressed: () {
                      notifier.viewOrAddToCart(context, userScreenNotifier, '${product.productId}', (item.inCart == 0), index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ Offer label
        Positioned(
            top: 9.dp,
            left: 1.dp,
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
                    fontSize: 12.dp,
                    fontFamily: ConstantAssests.montserratSemiBold,
                  ),
                ),
              ),
            ))
      ]),
    );
  }



}