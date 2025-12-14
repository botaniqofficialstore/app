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
import '../../../../Utility/AnimatedCarouselSlider.dart';
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
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        Future.microtask(() {
          CommonAPI().callUserProfileAPI();
          ref.watch(MainScreenGlobalStateProvider.notifier).callFooterCountGETAPI();
          final homeScreenNotifier = ref.read(
              HomeScreenGlobalStateProvider.notifier);
          homeScreenNotifier.callProductListGepAPI(context);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 20.dp,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            objCommonWidgets.customText(context, 'Good to see you again',
                                18, objConstantColor.white, objConstantFonts.montserratBold),

                            objCommonWidgets.customText(context, 'Let’s find something natural today.',
                                10, objConstantColor.white, objConstantFonts.montserratSemiBold),
                          ],
                        ),

                        CupertinoButton(
                          key: wishButtonKey,
                          padding: EdgeInsets.zero,
                          child: Image.asset(
                            objConstantAssest.wishlist,
                            width: 28.dp,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            userScreenNotifier.callNavigation(ScreenName.wishList);
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 15.dp),

                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            objCommonWidgets.customText(context,
                                'Delivery Location', 13, Colors.white,
                                objConstantFonts.montserratBold),
                            GestureDetector(
                              onTap: (){
                                userFrom = ScreenName.home;
                                userScreenNotifier.callNavigation(ScreenName.map);
                              },
                              child: (exactAddress.isNotEmpty) ? Row(
                                children: [
                                  Icon(Icons.location_on,color: Colors.white, size: 18.dp,),
                                  SizedBox(
                                    width: 120.dp,
                                    child: Text(exactAddress, style: TextStyle(color: Colors.white,
                                    fontFamily: objConstantFonts.montserratSemiBold,
                                    fontSize: 10.5.dp,
                                    ),maxLines: 1,
                                      overflow: TextOverflow.ellipsis,),
                                  ),
                                  Icon(Icons.keyboard_arrow_down_rounded,color: Colors.white, size: 20.dp,),
                                ],
                              ) :
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.dp)
                                ),
                                padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 7.dp),
                                child: Row(
                                  children: [
                                    Icon(Icons.my_location_outlined,color: objConstantColor.orange, size: 15.dp,),
                                    SizedBox(width: 2.dp,),
                                    objCommonWidgets.customText(context,
                                        'Update Location', 10, objConstantColor.orange,
                                        objConstantFonts.montserratBold),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),



                      ],
                    ),

                    SizedBox(height: 15.dp),

                    // ✅ Header Row (fixed at top)
                    CommonSearchField(
                      controller: TextEditingController(),
                      hintText: 'Search',
                      onChanged: (value) {
                        debugPrint("Searching: $value");
                      },
                    ),

                    SizedBox(height: 15.dp,),



                  ],
                ),
              ),


              SizedBox(height: 15.dp,),

              Padding(
                padding: EdgeInsets.only(left: 15.dp),
                child: objCommonWidgets.customText(context,
                    'Categories', 15, objConstantColor.navyBlue,
                    objConstantFonts.montserratSemiBold),
              ),

              Padding(
                padding: EdgeInsets.only(left: 15.dp, right: 5.dp, top: 5.dp),
                child: SizedBox(
                  height: 50.dp,
                  child: ListView.separated(
                    controller: categoryScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: productCategories.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.dp),
                    itemBuilder: (context, index) {
                      bool isSelected = homeScreenState.selectedIndex == index;

                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          homeScreenNotifier.updateSelectedIndex(index);

                          categoryScrollController.animateTo(
                            index * 60.0,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Container(
                          width: 45.dp,
                          height: 50.dp,
                          padding: EdgeInsets.symmetric(horizontal: 5.dp,),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? objConstantColor.yellow
                                : objConstantColor.navyBlue,
                            borderRadius: BorderRadius.circular(8.dp),
                            border: Border.all(
                              color: isSelected
                                  ? objConstantColor.navyBlue
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 23.dp,
                                height: 23.dp,
                                child: Image.asset(
                                  productCategories[index]['image']!,
                                  fit: BoxFit.fill,
                                  color: isSelected ? Colors.black : Colors
                                      .white,
                                ),
                              ),
                              SizedBox(height: 2.5.dp),
                              Text(
                                productCategories[index]['title']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.dp,
                                  color: isSelected ? Colors.black : Colors
                                      .white,
                                  fontFamily: objConstantFonts.montserratMedium,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),


              SizedBox(height: 15.dp,),

              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                        !homeScreenState.isLoading &&
                        homeScreenState.hasMore)
                    {
                      homeScreenNotifier.callProductListGepAPI(
                        context,
                        loadMore: true,
                      );
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    slivers: [

                      /// 🔥 Banner Carousel
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 180.dp,
                              child: AnimatedCarouselSlider(
                                imageList: [
                                  objConstantAssest.add2,
                                  objConstantAssest.add3,
                                  objConstantAssest.add1,
                                  objConstantAssest.add4,
                                  objConstantAssest.add5,
                                ],
                                fallbackImage: "assets/images/placeholder.png",
                              ),
                            ),
                            SizedBox(height: 20.dp),
                          ],
                        ),
                      ),

                      /// 🔥 Product Grid With Sliver
                      Consumer(builder: (context, ref, _) {
                        if (homeScreenState.isLoading &&
                            homeScreenState.productList.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(16.dp),
                              child: buildProductShimmer(),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.60,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                if (index == homeScreenState.productList.length) {
                                  return const Center(
                                    child: CupertinoActivityIndicator(),
                                  );
                                }

                                final product =
                                homeScreenState.productList[index];
                                return _buildProductCard(
                                    product, index, homeScreenNotifier);
                              },
                              childCount: homeScreenState.productList.length +
                                  (homeScreenState.isLoading ? 1 : 0),
                            ),
                          ),
                        );
                      }),



                    ],
                  ),
                ),
              ),









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
        savedProductDetails = ProductDetailStatus(productID: product.productId,
            coverImage: product.coverImage,
            inCart: product.inCart,
            isWishlisted: product.isWishlisted);

        ref.read(MainScreenGlobalStateProvider.notifier)
            .updateSelectedProduct(savedProductDetails!);

        ref.watch(MainScreenGlobalStateProvider.notifier).callNavigation(
            ScreenName.productDetail);
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
                                objConstantAssest.placeHolder,
                                // fallback image from assets
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
                          right: 6.dp,
                          top: 6.dp,
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

                        Positioned(bottom: 5.dp, left: 5.dp, child: Container(
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
                    color: (product.inCart == 0)
                        ? objConstantColor.navyBlue
                        : objConstantColor.orange,
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
                ),
              ],
            ),
          ),
        ),

        // ✅ Offer label
        Positioned(
            top: 8.dp,
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
    );
  }
}



