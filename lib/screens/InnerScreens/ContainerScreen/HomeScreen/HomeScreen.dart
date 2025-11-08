import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:botaniqmicrogreens/constants/ConstantAssests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../API/CommonAPI.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/utilities.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'HomeScreenModel.dart';
import 'HomeScreenState.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ✅ GlobalKey for wishlist button (target)
  final GlobalKey wishButtonKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        Future.microtask(() {
          CommonAPI().callUserProfileAPI();
          ref.watch(MainScreenGlobalStateProvider.notifier).callFooterCountGETAPI();
          final cartScreenNotifier = ref.read(
              HomeScreenGlobalStateProvider.notifier);
          cartScreenNotifier.callProductListGepAPI(context);
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    var homeScreenState = ref.watch(HomeScreenGlobalStateProvider);
    var homeScreenNotifier = ref.watch(HomeScreenGlobalStateProvider.notifier);
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: objConstantColor.white,
      body: RefreshIndicator(
        onRefresh: () async {
      await homeScreenNotifier.callProductListGepAPI(context);
    },
    color: objConstantColor.navyBlue,
    backgroundColor: objConstantColor.white,
    child:  Column(
        children: [
          // ✅ Search Field
          CommonSearchField(
            controller: TextEditingController(),
            hintText: 'Search',
            onChanged: (value) {
              debugPrint("Searching: $value");
            },
          ),

          // ✅ Header Row (fixed at top)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.dp),
            child: Row(
              children: [
                SizedBox(width: 5.dp,),
                Text(
                  "Microgreens",
                  style: TextStyle(
                    color: objConstantColor.navyBlue,
                    fontSize: 28.dp,
                    fontFamily: ConstantAssests.montserratBold,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  key: wishButtonKey,
                  padding: EdgeInsets.zero,
                  child: Image.asset(
                    objConstantAssest.wish2,
                    width: 27.dp,
                  ),
                  onPressed: () {
                    userScreenNotifier.callNavigation(ScreenName.wishList);
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 5.dp,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.dp),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.dp,),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.dp),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 2.5,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Row(
                children: [

                  /// Animated Location Icon
                  Lottie.asset(
                    objConstantAssest.locationIcon,
                    width: 35.dp,
                    repeat: true,
                  ),

                  /// Address Text
                  Expanded(
                    child: objCommonWidgets.customText(context,
                        'Chendrathil House Vadakkathara, Chittur, Palakkad, Kerala',
                        13, objConstantColor.navyBlue,
                        objConstantFonts.montserratMedium),
                  ),
                  CupertinoButton(
                    borderRadius: BorderRadius.circular(8.dp),
<<<<<<< HEAD
                    onPressed: () {
                      userScreenNotifier.callNavigation(ScreenName.map);
                    }, padding: EdgeInsets.zero,
=======
                    onPressed: () {}, padding: EdgeInsets.zero,
>>>>>>> dfdff9d8cd23a9cdbbd4a1bc6a20349b46a4ff7a
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.dp, vertical: 6.dp),
                      child: Image.asset(
                        objConstantAssest.editImage, width: 20.dp,),
                    ),
                  ),

                  SizedBox(width: 5.dp,)
                ],
              ),
            ),
          ),

          SizedBox(height: 20.dp,),


          // ✅ Scrollable Grid only
      Expanded(
        child:  Consumer(
            builder: (context, ref, _) {

              if (homeScreenState.isLoading && homeScreenState.productList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: buildProductShimmer(),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent &&
                      !homeScreenState.isLoading &&
                      homeScreenState.hasMore) {
                    homeScreenNotifier.callProductListGepAPI(context, loadMore: true);
                  }
                  return false;
                },
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.60,
                  ),
                  itemCount: homeScreenState.productList.length + (homeScreenState.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == homeScreenState.productList.length) {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                    final product = homeScreenState.productList[index];
                    return _buildProductCard(product, index, homeScreenNotifier);
                  },
                ),
              );
            },
        )
      ),

          SizedBox(height: 10.dp,)
        ],
      ),
      )
    );
  }


  // ✅ Product Card Widget
  Widget _buildProductCard(ProductData product, int index, HomeScreenGlobalStateNotifier notifier, ) {
    final GlobalKey sourceKey = GlobalKey(); // 👈 unique key per product heart

    return GestureDetector(
      onTap: () {
        savedProductDetails = ProductDetailStatus(productID: product.productId, coverImage: product.coverImage, inCart: product.inCart, isWishlisted: product.isWishlisted);
<<<<<<< HEAD
          ref.watch(MainScreenGlobalStateProvider.notifier).callNavigation(ScreenName.productDetail);
=======
          ref.watch(MainScreenGlobalStateProvider.notifier).callNavigation(
              ScreenName.productDetail);
>>>>>>> dfdff9d8cd23a9cdbbd4a1bc6a20349b46a4ff7a

      },
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: objConstantColor.navyBlue.withOpacity(0.2)),
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
                            width: 120.dp,
                            height: 120.dp,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                objConstantAssest.placeHolder, // fallback image from assets
                                width: 130.dp,
                                height: 130.dp,
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
                              key: sourceKey,
                              padding: EdgeInsets.all(4.dp),
                              minSize: 28.dp,
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                (product.isWishlisted == 1 )
                                    ? objConstantAssest.wishRed
                                    : objConstantAssest.wishUnCheckWhite,
                                width: 15.dp,
                              ),
                              onPressed: () {


                                setState(() {

                                  if (product.isWishlisted == 1 ){
                                    notifier.callRemoveFromWishList(context, product.productId, index);
                                  } else {
                                    notifier.callAddToWishList(context, product.productId, index);
                                    _animateToWishlist(context, wishButtonKey, sourceKey);
                                  }

                                });
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
                    color: objConstantColor.navyBlue,
                    borderRadius: BorderRadius.circular(5.dp),
                    child: Text(
                      (product.inCart == 0)
                          ? "Add to Cart"
                          : 'View in Cart',
                      style: TextStyle(
                        color: objConstantColor.white,
                        fontSize: 13.dp,
                        fontFamily: ConstantAssests.montserratSemiBold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (product.inCart == 0){
                          var mainNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);
                          notifier.callAddToCartAPI(context, product.productId, index, mainNotifier);
                        }else{
                          ref.watch(MainScreenGlobalStateProvider.notifier).callNavigation(
                              ScreenName.cart);
                        }
                      });
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

  Widget buildProductShimmer() {
    return GridView.builder(
      itemCount: 6, // Number of shimmer placeholders
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),
                // Text placeholders
                Container(
                  height: 14,
                  width: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 6),
                Container(
                  height: 14,
                  width: 60,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }






  // ✅ Animation Method
  void _animateToWishlist(BuildContext context, GlobalKey targetKey,
      GlobalKey sourceKey) {
    final overlay = Overlay.of(context);

    final sourceBox = sourceKey.currentContext!.findRenderObject() as RenderBox;
    final targetBox = targetKey.currentContext!.findRenderObject() as RenderBox;

    final sourcePosition = sourceBox.localToGlobal(Offset.zero);
    final targetPosition = targetBox.localToGlobal(Offset.zero);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _FlyingHeart(
          start: sourcePosition,
          end: targetPosition,
          onComplete: () => overlayEntry.remove(),
        );
      },
    );

    overlay.insert(overlayEntry);
  }
}

// ✅ Flying Heart Widget
class _FlyingHeart extends StatefulWidget {
  final Offset start;
  final Offset end;
  final VoidCallback onComplete;

  const _FlyingHeart({
    required this.start,
    required this.end,
    required this.onComplete,
  });

  @override
  State<_FlyingHeart> createState() => _FlyingHeartState();
}

class _FlyingHeartState extends State<_FlyingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

    _position = Tween<Offset>(
      begin: widget.start,
      end: widget.end,
    ).animate(curve);

    _controller.forward().whenComplete(widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      builder: (context, child) {
        return Positioned(
          top: _position.value.dy,
          left: _position.value.dx,
          child: child!,
        );
      },
      child: Icon(Icons.favorite, color: Colors.red, size: 28),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}




class CommonSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;

  const CommonSearchField({
    super.key,
    required this.controller,
    this.hintText = "search",
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 17.dp, right: 17.dp, top: 15.dp, bottom: 5.dp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.dp, vertical: 3.dp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.dp), // rounded corners
          border: Border.all(
            color: objConstantColor.navyBlue, // ✅ border color
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            // ✅ Custom image instead of icon
            const SizedBox(width: 10),
            Image.asset(
              objConstantAssest.searchIcon, // change with your image path
              width: 18.dp,
              height: 18.dp,
            ),
            const SizedBox(width: 10),
            // ✅ Expanded TextField
            Expanded(
              child: AnimatedTextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.text,
                animationType: Animationtype.slide,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z ]")),
                ],
                style: TextStyle(
                  color: objConstantColor.navyBlue,
                  fontSize: 20.dp,
                  fontFamily: ConstantAssests.montserratRegular,
                ),
                onChanged: onChanged,
                hintTexts: const [
                  'Beetroot Microgreens',
                  'Sunflower Microgreens',
                  'Red Radish Microgreens',
                  'White Radish Microgreens',
                  'Pakchoi Microgreens',
                  'Amaranthus Microgreens',
                  'Green Mustard Microgreens',
                ],
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),

              )
            ),
          ],
        ),
      ),
    );
  }
}




class LocationSetupButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const LocationSetupButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.dp, horizontal: 16.dp),
        padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 14.dp),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.dp),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.location_solid,
              color: Colors.green.shade700,
              size: 18.dp,
            ),
            SizedBox(width: 8.dp),
            Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15.dp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
