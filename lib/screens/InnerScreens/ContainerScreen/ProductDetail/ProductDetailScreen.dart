// ProductDetailScreen.dart
import 'dart:async';
import 'package:botaniqmicrogreens/Utility/Logger.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:botaniqmicrogreens/constants/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/utilities.dart';
import '../../../../Utility/DeliveryUtils.dart';
import '../../../../Utility/TimerUtils.dart';
import '../../../../constants/ConstantAssests.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../MainScreen/MainScreenState.dart';
import '../HomeScreen/HomeScreenModel.dart';
import '../HomeScreen/HomeScreenState.dart';
import 'ProductDetailScreenState.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  int currentIndex = 0;
  late CarouselController innerCarouselController;

  final List<String> sample = [
  'https://app-1q5g.onrender.com/uploads/1761632706172.png',
  'https://app-1q5g.onrender.com/uploads/1761994235917.png',
  'https://app-1q5g.onrender.com/uploads/1761994615276.png',
  'https://app-1q5g.onrender.com/uploads/1761994304973.png',
  'https://app-1q5g.onrender.com/uploads/1761994675928.png'
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {}); // rebuilds widget every second
    });
    Future.microtask(() {
      final cartScreenNotifier =
      ref.read(productDetailScreenGlobalStateProvider.notifier);
      cartScreenNotifier.fetchSavedData();
      cartScreenNotifier.callProductDetailsGetAPI(context);
      final homeScreenNotifier = ref.read(
          HomeScreenGlobalStateProvider.notifier);
      homeScreenNotifier.callProductListGepAPI(context);
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
    var homeScreenState = ref.watch(HomeScreenGlobalStateProvider);
    var homeScreenNotifier = ref.watch(HomeScreenGlobalStateProvider.notifier);
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: objConstantColor.white,
      body: detailsScreenState.isLoading
          ? buildProductDetailShimmer(context)
          : CustomScrollView(
        slivers: [

          /// 🔰 1. CAROUSEL + TOP PART
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                carousalSlider(context),

                Positioned(
                  bottom: -18.dp,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40.dp,
                    decoration: BoxDecoration(
                      color: objConstantColor.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.dp),
                        topRight: Radius.circular(25.dp),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 50.dp,
                        height: 5.dp,
                        decoration: BoxDecoration(
                            color: Colors.black.withAlpha(50),
                            borderRadius: BorderRadius.circular(20.dp)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔰 2. BODY CONTENT SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.dp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.dp),

                  objCommonWidgets.customText(
                    context, 'Microgreens', 14,
                    objConstantColor.gray, objConstantFonts.montserratSemiBold,
                  ),

                  SizedBox(height: 5.dp),

                  Row(
                    children: [
                      objCommonWidgets.customText(
                        context,
                        CodeReusability().cleanProductName(
                            detailsScreenState.productData?.productName),
                        22,
                        objConstantColor.navyBlue,
                        objConstantFonts.montserratBold,
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(width: 1.5.dp, color: Colors
                              .green),
                        ),
                        padding: EdgeInsets.all(2.8.dp),
                        child: Container(
                          width: 8.dp,
                          height: 8.dp,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 20.dp),

                  customSectionTitle(context, "About"),
                  objCommonWidgets.customText(context,
                      '${detailsScreenState.productData?.description}',
                      12, objConstantColor.navyBlue,
                      objConstantFonts.montserratMedium,
                      textAlign: TextAlign.justify),

                  SizedBox(height: 20.dp),

                  customSectionTitle(context, "Delivery Details"),
                  SizedBox(height: 5.dp),
                  expectedDelivery(context),
                  SizedBox(height: 2.5.dp),
                  homeAddress(context),

                  SizedBox(height: 20.dp),

                  customSectionTitle(context, "Price Details"),
                  SizedBox(height: 5.dp),
                  priceDetails(context),

                  SizedBox(height: 15.dp),



                  if (detailsScreenState.inCart == 0) ...{
                    SizedBox(height: 20.dp),
                    customSectionTitle(context, "Add to cart"),
                    SizedBox(height: 5.dp),
                    addCart(context),
                  } else
                    ...{
                      SizedBox(height: 15.dp),
                      buyNow(context)
                    },

                  SizedBox(height: 30.dp),

                  customSectionTitle(context, "Nutritional Benefits"),
                  SizedBox(height: 5.dp),
                  productDetails(context),


                  SizedBox(height: 20.dp),
                  Row(
                    children: [
                      customSectionTitle(context, "Similar Products"),
                      const Spacer(),
                      CupertinoButton(
                          padding: EdgeInsets.zero, child: Container(
                          padding: EdgeInsets.only(bottom: 0.5.dp),
                          // 👈 space between text & underline
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: objConstantColor.orange,
                                width: 2.dp, // underline thickness
                              ),
                            ),
                          ),
                          child: objCommonWidgets.customText(
                            context, 'See All', 11,
                            objConstantColor.orange, objConstantFonts
                              .montserratSemiBold,
                          )
                      ),
                          onPressed: () {})

                    ],
                  ),
                  SizedBox(height: 5.dp),

                ],
              ),
            ),
          ),

          /// 🔰 3. SIMILAR PRODUCT GRID
          similarProduct(context, homeScreenState, homeScreenNotifier),

          SliverToBoxAdapter(
            child: SizedBox(height: 15.dp),
          )
        ],
      ),
    );
  }



  Widget carousalSlider(BuildContext context){
    var detailsScreenState = ref.watch(productDetailScreenGlobalStateProvider);
    var detailsScreenNotifier = ref.watch(productDetailScreenGlobalStateProvider.notifier);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider.builder(
          itemCount: sample.length,
          itemBuilder: (context, index, realIndex) {
            String imagePath = sample[index];

            return Image.network(
              imagePath,
              width: double.infinity,
              height: 250.dp,
              fit: BoxFit.fill,
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
            );
          },
          options: CarouselOptions(
            height: 320.dp,
            autoPlay: false,
            enlargeCenterPage: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() => currentIndex = index);
            },
          ),
        ),

        // 🔥 Indicator placed inside the image
        Positioned(
          bottom: 45.dp,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(sample.length, (index) {
              bool isActive = currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 45.dp : 8.dp,
                height: 8.dp,
                decoration: BoxDecoration(
                  color: isActive
                      ? objConstantColor.white
                      : objConstantColor.gray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.dp),
                ),
              );
            }),
          ),
        ),

        Positioned(
          top: 0.dp,
          right: 15.dp,
          child: SafeArea(
            child: Row(
              children: [
            
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
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
            
                SizedBox(width: 10.dp),
            
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.all(4.dp),
                    minSize: 35.dp,
                    borderRadius: BorderRadius.circular(30),
                    child: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
            
                    },
                  ),
                ),
            
            
              ],
            ),
          ),
        ),

        Positioned(
          top: 0.dp,
          left: 15.dp,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(30),
              ),
              child: CupertinoButton(
                padding: EdgeInsets.all(4.dp),
                minSize: 35.dp,
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  objConstantAssest.backIcon,
                  color: Colors.white,
                  width: 25.dp,
                ),
                onPressed: () {
                  ref
                      .watch(MainScreenGlobalStateProvider.notifier)
                      .callNavigation(ScreenName.home);
                },
              ),
            ),
          ),
        )

      ],
    );
  }


  Widget priceDetails(BuildContext context){
    var detailsScreenState = ref.watch(productDetailScreenGlobalStateProvider);
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5.dp),
                topLeft: Radius.circular(5.dp),
              ),
            ),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.dp),
            child: Center(
              child: objCommonWidgets.customText(
                context, '₹${detailsScreenState.productData?.productSellingPrice}/_',
                17,
                Colors.white,
                objConstantFonts.montserratSemiBold,
              ),
            ),
          ),
        ),
        SizedBox(width: 2.5.dp),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(5.dp),
                topRight: Radius.circular(5.dp),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 10.dp),
            child: Center(
              child: Text(
                "₹${detailsScreenState.productData?.productPrice}/_",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17.dp,
                  fontFamily: objConstantFonts.montserratSemiBold,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.black,
                  decorationThickness: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget homeAddress(BuildContext context){
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 15.dp, right: 15.dp, bottom: 10.dp, top: 5.dp),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(15),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.dp),
          bottomRight: Radius.circular(10.dp),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(objConstantAssest.home, width: 20.dp,),
              SizedBox(width: 10.dp),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    objCommonWidgets.customText(context, 'Delivery Address',
                        12, objConstantColor.navyBlue,
                        objConstantFonts.montserratSemiBold),

                    (exactAddress.isNotEmpty) ? objCommonWidgets.customText(context, exactAddress,
                        11, objConstantColor.orange,
                        objConstantFonts.montserratSemiBold) :

                    GestureDetector(
                      onTap: (){
                        userFrom = ScreenName.productDetail;
                        userScreenNotifier.callNavigation(ScreenName.map);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.dp)
                        ),
                        padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 7.dp),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.my_location_outlined,color: objConstantColor.orange, size: 15.dp,),
                            SizedBox(width: 2.dp,),
                            objCommonWidgets.customText(context,
                                'Update Location', 10, objConstantColor.orange,
                                objConstantFonts.montserratBold),

                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget expectedDelivery(BuildContext context){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 15.dp, right: 15.dp, bottom: 5.dp, top: 10.dp),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(15),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.dp),
          topRight: Radius.circular(10.dp),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(

            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(objConstantAssest.deliveryVan, width: 20.dp,),
              SizedBox(width: 10.dp),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    objCommonWidgets.customText(context, DeliveryUtils.getExpectedDeliveryDate(5),
                        12, objConstantColor.navyBlue,
                        objConstantFonts.montserratSemiBold),
                    objCommonWidgets.customText(context, 'Order in ${TimerUtils.getRemainingTimeToMidnight()}',
                        11, objConstantColor.orange,
                        objConstantFonts.montserratSemiBold),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }


  Widget customSectionTitle(BuildContext context, String title) {
    return objCommonWidgets.customText(
      context, title, 16,
      objConstantColor.navyBlue, objConstantFonts.montserratSemiBold,
    );
  }

  Widget similarProduct(BuildContext context, HomeScreenGlobalState homeScreenState, HomeScreenGlobalStateNotifier homeScreenNotifier) {
    return Consumer(builder: (context, ref, _) {
      return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              !homeScreenState.isLoading &&
              homeScreenState.hasMore) {
            homeScreenNotifier.callProductListGepAPI(
              context,
              loadMore: true,
            );
          }
          return false;
        },
        child: SliverToBoxAdapter(
          child: SizedBox(
            height: 270.dp, // 👈 required fixed height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: homeScreenState.productList.length +
                  (homeScreenState.isLoading ? 1 : 0),
              padding: EdgeInsets.symmetric(horizontal: 15.dp),
              itemBuilder: (context, index) {
                if (index == homeScreenState.productList.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CupertinoActivityIndicator(),
                  );
                }

                final product = homeScreenState.productList[index];

                return Container(
                  width: 165.dp, // 👈 card width
                  margin: EdgeInsets.only(right: 12.dp),
                  child: _buildProductCard(product, index, homeScreenNotifier),
                );
              },
            ),
          ),
        ),
      );
    });
  }



  // ✅ Product Card Widget
  Widget _buildProductCard(ProductData product, int index, HomeScreenGlobalStateNotifier notifier, ) {
    final GlobalKey sourceKey = GlobalKey();

    return GestureDetector(
      onTap: () {
        setState(() {
          savedProductDetails = ProductDetailStatus(productID: product.productId,
              coverImage: product.coverImage,
              inCart: product.inCart,
              isWishlisted: product.isWishlisted);
        });

        ref.read(MainScreenGlobalStateProvider.notifier)
            .updateSelectedProduct(savedProductDetails!);

        ref.watch(MainScreenGlobalStateProvider.notifier).callNavigation(
            ScreenName.productDetail);
        Logger().log('### ----> Clicked $savedProductDetails');

        final productDetailsScreenNotifier = ref.read(productDetailScreenGlobalStateProvider.notifier);
        productDetailsScreenNotifier.fetchSavedData();
        productDetailsScreenNotifier.callProductDetailsGetAPI(context);
        final homeScreenNotifier = ref.read(
            HomeScreenGlobalStateProvider.notifier);
        homeScreenNotifier.callProductListGepAPI(context);

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
                                (product.isWishlisted == 1)
                                    ? objConstantAssest.wishRed
                                    : objConstantAssest.wishUnCheckWhite,
                                width: 15.dp,
                              ),
                              onPressed: () {
                                if (product.isWishlisted == 1) {
                                  notifier.callRemoveFromWishList(
                                      context, product.productId, index);
                                } else {
                                  notifier.callAddToWishList(
                                      context, product.productId, index);
                                }
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

  Widget buildProductDetailShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 Top Image Carousel
            Container(
              height: 300.dp,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Stack(
                children: [
                  // Back button
                  Positioned(
                    top: 40.dp,
                    left: 20.dp,
                    child: Container(
                      width: 38.dp,
                      height: 38.dp,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Wishlist button
                  Positioned(
                    top: 40.dp,
                    right: 20.dp,
                    child: Container(
                      width: 38.dp,
                      height: 38.dp,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Dot indicator
                  Positioned(
                    bottom: 10.dp,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                            (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.dp),
                          width: 10.dp,
                          height: 4.dp,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10.dp),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 16.dp),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.dp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📌 Category shimmer
                  Container(
                    width: 120.dp,
                    height: 16.dp,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.dp),
                    ),
                  ),
                  SizedBox(height: 8.dp),

                  // 📌 Title + Verified
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 22.dp,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4.dp),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.dp),
                      Container(
                        width: 18.dp,
                        height: 18.dp,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.dp),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.dp),

                  // 📌 About heading
                  Container(
                    width: 80.dp,
                    height: 18.dp,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.dp),
                    ),
                  ),
                  SizedBox(height: 12.dp),

                  // 📌 Paragraph shimmer
                  ...List.generate(
                    6,
                        (index) => Padding(
                      padding: EdgeInsets.only(bottom: 8.dp),
                      child: Container(
                        height: 12.dp,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.dp),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.dp),

                  // 📌 Price Details heading
                  Container(
                    width: 120.dp,
                    height: 18.dp,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.dp),
                    ),
                  ),
                  SizedBox(height: 16.dp),

                  // 📌 Price buttons (Green + Yellow)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45.dp,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6.dp),
                              bottomLeft: Radius.circular(6.dp),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 45.dp,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(6.dp),
                              bottomRight: Radius.circular(6.dp),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.dp),
          ],
        ),
      ),
    );
  }



  Widget productDetails(BuildContext context) {
    var detailsScreenState = ref.watch(productDetailScreenGlobalStateProvider);
    var nutrients = detailsScreenState.productData?.nutrients ?? [];

    return nutrients.isEmpty
        ? Padding(
      padding: EdgeInsets.only(top: 25.dp),
      child: objCommonWidgets.customText(
        context,
        'No nutrients information available.',
        14,
        objConstantColor.gray,
        objConstantFonts.montserratMedium,
      ),
    )
        : Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.dp), // 👈 Rounded corners
        border: Border.all(color: Colors.black.withAlpha(50), width: 0.6),
      ),
      clipBehavior: Clip.hardEdge, // 👈 Needed to clip internal child corners
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(3),
        },
        children: [
          /// Header Row
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade200),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
                child: objCommonWidgets.customText(
                    context,
                    'Vitamin',
                    15,
                    objConstantColor.navyBlue,
                    objConstantFonts.montserratSemiBold),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
                child: objCommonWidgets.customText(
                    context,
                    'Benefit',
                    15,
                    objConstantColor.navyBlue,
                    objConstantFonts.montserratSemiBold),
              ),
            ],
          ),

          /// Dynamic rows
          for (var n in nutrients)
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
                  child: objCommonWidgets.customText(context, n.vitamin, 12,
                      objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
                  child: objCommonWidgets.customText(context, n.benefit, 11,
                      objConstantColor.navyBlue, objConstantFonts.montserratMedium),
                ),
              ],
            ),
        ],
      ),
    );
  }




  Widget buyNow(BuildContext context){

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        ref
            .watch(MainScreenGlobalStateProvider.notifier)
            .callNavigation(ScreenName.cart);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.dp),
        decoration: BoxDecoration(
          color: objConstantColor.orange,
          borderRadius: BorderRadius.circular(25.dp),
        ),
        alignment: Alignment.center,
        child: objCommonWidgets.customText(
          context,
          'Buy Now',
          16,
          objConstantColor.white,
          objConstantFonts.montserratBold,
        ),
      ),
    );
  }

  Widget addCart(BuildContext context){
    var detailsScreenState = ref.watch(productDetailScreenGlobalStateProvider);
    var detailsScreenNotifier = ref.watch(productDetailScreenGlobalStateProvider.notifier);

    return
      Row(
        children: [
          /// Count Handler
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 20.dp, vertical: 7.dp),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(15),
                borderRadius: BorderRadius.circular(20.dp),
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
                      color: Colors.black,
                    ),
                  ),

                  Text(
                    '${detailsScreenState.count}',
                    style: TextStyle(
                      fontSize: 20.dp,
                      fontFamily: objConstantFonts.montserratSemiBold,
                      color: objConstantColor.orange,
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
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 5.dp),

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
                  color: objConstantColor.orange,
                  borderRadius: BorderRadius.circular(20.dp),
                ),
                alignment: Alignment.center,
                child: objCommonWidgets.customText(
                  context,
                  'ADD',
                  15,
                  objConstantColor.white,
                  objConstantFonts.montserratBold,
                ),
              ),
            ),
          ),
        ],
      );
  }


}
