import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:botaniqmicrogreens/constants/ConstantAssests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../API/CommonAPI.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/utilities.dart';
import '../../../../Utility/AnimatedCarouselSlider.dart';
import '../../../../Utility/NetworkImageLoader.dart';
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
  final ScrollController categoryScrollController = ScrollController();
  final ScrollController _scrollController = ScrollController();


  final List<Map<String, String>> productCategories = [
    {"title": "All", "image": objConstantAssest.allIcon},
    {"title": "Fresh", "image": objConstantAssest.freshIcon},
    {"title": "Spices & Herbs", "image": objConstantAssest.spicesIcon},
    {"title": "Oils & Staples", "image": objConstantAssest.oilsStaplesIcon},
    {"title": "Health & Wellness", "image": objConstantAssest.healthWellnessIcon},
    {"title": "Care", "image": objConstantAssest.personalCareIcon},
    {"title": "Snack", "image": objConstantAssest.snacksIcon},
  ];


  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !ref.read(HomeScreenGlobalStateProvider).isLoading &&
          ref.read(HomeScreenGlobalStateProvider).hasMore) {
        ref
            .read(HomeScreenGlobalStateProvider.notifier)
            .callProductListGepAPI(context, loadMore: true);
      }
    });

    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        Future.microtask(() {
          CommonAPI().callUserProfileAPI();
          ref
              .read(MainScreenGlobalStateProvider.notifier)
              .callFooterCountGETAPI();
          ref
              .read(HomeScreenGlobalStateProvider.notifier)
              .callProductListGepAPI(context);
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final homeScreenState = ref.watch(HomeScreenGlobalStateProvider);
    final homeScreenNotifier =
    ref.watch(HomeScreenGlobalStateProvider.notifier);
    final userScreenNotifier =
    ref.watch(MainScreenGlobalStateProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          await homeScreenNotifier.callProductListGepAPI(context);
        },
        color: objConstantColor.navyBlue,
        backgroundColor: objConstantColor.white,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [

              /// 🔥 HEADER
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.dp),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFA600),
                      Color(0xFFFF6A00),
                      Color(0xFFFF3D00),
                      Color(0xFFFF3D00),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.dp),
                    bottomRight: Radius.circular(30.dp),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              objCommonWidgets.customText(
                                context,
                                'Good to see you again',
                                15,
                                objConstantColor.white,
                                objConstantFonts.montserratBold,
                              ),
                              objCommonWidgets.customText(
                                context,
                                'Let’s find something natural today.',
                                8,
                                objConstantColor.white,
                                objConstantFonts.montserratSemiBold,
                              ),
                            ],
                          ),

                          CupertinoButton(
                            key: wishButtonKey,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            child: Image.asset(
                              objConstantAssest.wishlist,
                              width: 25.dp,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              userFrom = ScreenName.home;
                              userScreenNotifier.callNavigation(ScreenName.wishList);
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 10.dp),

                      /// Location
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          objCommonWidgets.customText(
                            context,
                            'Delivery Location',
                            12,
                            Colors.white,
                            objConstantFonts.montserratBold,
                          ),
                          GestureDetector(
                            onTap: () {
                              userFrom = ScreenName.home;
                              userScreenNotifier
                                  .callNavigation(ScreenName.map);
                            },
                            child: exactAddress.isNotEmpty
                                ? Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.white, size: 15.dp),
                                SizedBox(
                                  width: 120.dp,
                                  child: Text(
                                    exactAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5.dp,
                                      fontFamily: objConstantFonts
                                          .montserratSemiBold,
                                    ),
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white, size: 20.dp),
                              ],
                            )
                                : Padding(
                                  padding: EdgeInsets.only(top: 5.dp),
                                  child: Container(
                                                              padding: EdgeInsets.symmetric(
                                    vertical: 6.dp, horizontal: 7.dp),
                                                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(10.dp),
                                                              ),
                                                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.my_location_outlined,
                                        color: objConstantColor.orange,
                                        size: 15.dp),
                                    SizedBox(width: 4.dp),
                                    objCommonWidgets.customText(
                                      context,
                                      'Update Location',
                                      10,
                                      objConstantColor.orange,
                                      objConstantFonts.montserratBold,
                                    ),
                                  ],
                                                              ),
                                                            ),
                                ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.dp),

                      /// Search
                      CommonSearchField(
                        controller: TextEditingController(),
                        hintText: 'Search',
                        onChanged: (value) {},
                      ),

                      SizedBox(height: 10.dp),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 5.dp),

               Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15.dp),

                    /// Categories title
                    Padding(
                      padding: EdgeInsets.only(left: 15.dp),
                      child: objCommonWidgets.customText(
                        context,
                        'Categories',
                        13,
                        objConstantColor.navyBlue,
                        objConstantFonts.montserratSemiBold,
                      ),
                    ),

                    /// Categories list
                    Padding(
                      padding: EdgeInsets.only(left: 15.dp, top: 5.dp),
                      child: SizedBox(
                        height: 45.dp,
                        child: ListView.separated(
                          padding: EdgeInsets.only(right: 10.dp),
                          controller: categoryScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: productCategories.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: 10.dp),
                          itemBuilder: (context, index) {
                            final isSelected =
                                homeScreenState.selectedIndex == index;

                            return CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                homeScreenNotifier.updateSelectedIndex(index);
                                categoryScrollController.animateTo(
                                  index * 60,
                                  duration:
                                  const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                              child: Container(
                                width: 40.dp,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? objConstantColor.yellow
                                      : objConstantColor.navyBlue,
                                  borderRadius:
                                  BorderRadius.circular(8.dp),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      productCategories[index]['image']!,
                                      width: 20.dp,
                                      height: 20.dp,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    SizedBox(height: 2.dp),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 5.dp),
                                      child: Text(
                                        productCategories[index]['title']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10.dp,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.white,
                                          fontFamily: objConstantFonts
                                              .montserratMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 20.dp),

                    /// Banner
                    SizedBox(
                      height: 150.dp,
                      child: AnimatedCarouselSlider(
                        imageList: [
                          objConstantAssest.add2,
                          objConstantAssest.add3,
                          objConstantAssest.add1,
                          objConstantAssest.add4,
                          objConstantAssest.add5,
                        ],
                        fallbackImage:
                        "assets/images/placeholder.png",
                      ),
                    ),

                    SizedBox(height: 20.dp),

                    Padding(
                      padding: EdgeInsets.only(left: 15.dp),
                      child: objCommonWidgets.customText(
                        context,
                        'Products',
                        13,
                        objConstantColor.navyBlue,
                        objConstantFonts.montserratSemiBold,
                      ),
                    ),

                    /// Product Grid
                    if (homeScreenState.isLoading && homeScreenState.productList.isEmpty)...{
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.dp, vertical: 5.dp),
                        child: buildProductShimmer(),
                      )
                    } else...{
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.dp),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          primary: false,
                          shrinkWrap: true,
                          physics:
                          const NeverScrollableScrollPhysics(),
                          itemCount:
                          homeScreenState.productList.length +
                              (homeScreenState.isLoading ? 1 : 0),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.60,
                          ),
                          itemBuilder: (context, index) {
                            if (index ==
                                homeScreenState.productList.length) {
                              return const Center(
                                child: CupertinoActivityIndicator(),
                              );
                            }
                            final product =
                            homeScreenState.productList[index];
                            return _buildProductCard(
                                product, index, homeScreenNotifier);
                          },
                        ),
                      ),
                    },

                    SizedBox(height: 10.dp),
                  ],
                ),

            ],
          ),
        ),
      ),
    );
  }



  // ✅ Product Card Widget
  Widget _buildProductCard(ProductData product, int index, HomeScreenGlobalStateNotifier notifier, ) {
    final GlobalKey sourceKey = GlobalKey();

    return GestureDetector(
      onTap: () {
        savedProductDetails = ProductDetailStatus(productID: product.productId,
            coverImage: product.coverImage,
            inCart: product.inCart,
            isWishlisted: product.isWishlisted);

        ref.read(MainScreenGlobalStateProvider.notifier)
            .updateSelectedProduct(savedProductDetails!);

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
                              (product.isWishlisted == 1)
                                  ? objConstantAssest.wishRed
                                  : objConstantAssest.wishUnCheckWhite,
                              width: 15.dp,
                            ),
                            onPressed: () {
                              setState(() {
                                if (product.isWishlisted == 1) {
                                  notifier.callRemoveFromWishList(
                                      context, product.productId, index);
                                } else {
                                  notifier.callAddToWishList(
                                      context, product.productId, index);
                                  _animateToWishlist(
                                      context, wishButtonKey, sourceKey);
                                }
                              });
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

                      SizedBox(height: 5.dp),

                      // ✅ Add to cart button
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 8.dp),
                          decoration: BoxDecoration(
                            color: (product.inCart == 0)
                                ? objConstantColor.navyBlue
                                : objConstantColor.orange,
                            borderRadius: BorderRadius.circular(5.dp),
                          ),
                          child: Center(
                            child: objCommonWidgets.customText(context,
                                (product.inCart == 0)
                                    ? "Add to Cart"
                                    : 'View in Cart',
                                10, objConstantColor.white, objConstantFonts.montserratSemiBold),
                          )
                        ),
                        onPressed: () {
                          setState(() {
                            if (product.inCart == 0) {
                              var mainNotifier = ref.watch(
                                  MainScreenGlobalStateProvider.notifier);
                              notifier.callAddToCartAPI(
                                  context, product.productId, index, mainNotifier);
                            } else {
                              ref.watch(MainScreenGlobalStateProvider.notifier)
                                  .callNavigation(
                                  ScreenName.cart);
                            }
                          });
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

  Widget buildProductShimmer() {
    return GridView.builder(
      itemCount: 6, // Number of shimmer placeholders
      padding: EdgeInsets.zero,
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
    return Container(
      height: 40.dp,
      padding: EdgeInsets.symmetric(horizontal: 5.dp, vertical: 3.dp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.dp), // rounded corners
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
                animationDuration: const Duration(milliseconds: 1220),
                hintTexts: const [
                  ' Micro greens',
                  'Hair Oil',
                  'Body Lotion',
                  'White Radish Micro greens',
                  'Ayurvedic Products',
                  'Saffron',
                  'Protein Rich',
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
    );
  }
}



