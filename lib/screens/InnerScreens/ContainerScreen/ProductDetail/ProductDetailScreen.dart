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
import '../../../../Utility/NetworkImageLoader.dart';
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
                    context, 'Microgreens', 12,
                    Colors.black.withAlpha(130), objConstantFonts.montserratMedium,
                  ),

                  SizedBox(height: 5.dp),

                  Row(
                    children: [
                      objCommonWidgets.customText(
                        context,
                        CodeReusability().cleanProductName(
                            detailsScreenState.productData?.productName),
                        20,
                        Colors.black,
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

                  SizedBox(height: 15.dp),

                  customSectionTitle(context, "About"),
                  objCommonWidgets.customText(context,
                      '${detailsScreenState.productData?.description}',
                      10, Colors.black,
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
                    SizedBox(height: 5.dp),
                    customSectionTitle(context, "Add to cart"),
                    SizedBox(height: 5.dp),
                    addCart(context),
                  } else
                    ...{
                      SizedBox(height: 15.dp),
                      buyNow(context)
                    },

                  SizedBox(height: 20.dp),
                  customSectionTitle(context, "Nutritional Benefits"),
                  SizedBox(height: 5.dp),
                  productDetails(context),


                  SizedBox(height: 20.dp),
                  customSectionTitle(context, "Seller Details"),
                  SizedBox(height: 5.dp),
                  sellerDetails(context),

                  SizedBox(height: 20.dp),
                  customSectionTitle(context, "Ratings & Reviews"),
                  SizedBox(height: 5.dp),
                  ratingAndReviewDetails(context),


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

                ],
              ),
            ),
          ),

          /// 🔰 3. SIMILAR PRODUCT GRID
          similarProduct(context, homeScreenState, homeScreenNotifier),


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
        color: Colors.black.withAlpha(10),
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
                        12, Colors.black,
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
        color: Colors.black.withAlpha(10),
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
                        12, Colors.black,
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
      objConstantColor.black, objConstantFonts.montserratSemiBold,
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
            height: 240.dp, // 👈 required fixed height
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
                  width: 145.dp, // 👈 card width
                  margin: EdgeInsets.only(right: 12.dp, bottom: 10.dp),
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
                            12, objConstantColor.black.withAlpha(150), objConstantFonts.montserratMedium),

                        SizedBox(height: 10.dp),

                        // ✅ Add to cart button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8.dp),
                              decoration: BoxDecoration(
                                color: (product.inCart == 0)
                                    ? Colors.black
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
                    Colors.black,
                    objConstantFonts.montserratSemiBold),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
                child: objCommonWidgets.customText(
                    context,
                    'Benefit',
                    15,
                    Colors.black,
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
                      Colors.black, objConstantFonts.montserratSemiBold),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
                  child: objCommonWidgets.customText(context, n.benefit, 11,
                      Colors.black, objConstantFonts.montserratMedium),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget sellerDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            Container(
              width: 35.dp, // slightly bigger than avatar
              height: 35.dp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black, // 🔥 black border
                  width: 1.2,          // stroke thickness
                ),
              ),
              child: CircleAvatar(
                radius: 18.dp,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: Image.network(
                    'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
                    width: 36.dp,
                    height: 36.dp,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            objConstantAssest.placeHolder,
                            width: 30.dp,
                            height: 30.dp,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: 10.dp,
                            height: 10.dp,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ],
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        objConstantAssest.profileIcon,
                        width: 30.dp,
                        height: 30.dp,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(width: 8.dp),

            Column(
              children: [
                objCommonWidgets.customText(
                    context, 'Nourish Organics', 12, Colors.black,
                    objConstantFonts.montserratSemiBold),
                Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        color: Colors.blueAccent, size: 12.dp),
                    SizedBox(width: 2.dp),
                    objCommonWidgets.customText(context,
                        'Verified Merchant', 10, Colors.black,
                        objConstantFonts.montserratRegular),
                  ],
                ),
              ],
            )
          ],
        ),

        SizedBox(height: 10.dp),

        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'About: ',
                style: TextStyle(
                  fontSize: 12.dp,
                  color: Colors.black,
                  fontFamily: objConstantFonts.montserratSemiBold,
                ),
              ),
              TextSpan(
                text: "Nourish Organics offers a premium selection of 100% organic products sourced responsibly from certified farms. Our mission is to provide clean, chemical-free, and naturally nourishing products that support a healthier lifestyle and a sustainable future.",
                style: TextStyle(
                  fontSize: 11.dp,
                  color: Colors.black87,
                  fontFamily: objConstantFonts.montserratMedium,
                ),
              ),

            ],
          ),
        )


      ],
    );
  }


  Widget ratingAndReviewDetails(BuildContext context) {
    const rating = 4.2;
    ProductReview(
    userName: "Maria Garcia",
    userImage: "https://i.pravatar.cc/150?u=2",
    rating: 4.5,
    date: "1 week ago",
    comment: "Fast delivery and great packaging. The flavor is very intense and earthy. Will definitely order again.",
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 20.dp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                objCommonWidgets.customText(
                  context,
                  rating.toString(),
                  35,
                  objConstantColor.black,
                  objConstantFonts.montserratSemiBold,
                ),
                objCommonWidgets.customText(
                  context,
                  "1.2k Reviews",
                  11,
                  Colors.black,
                  objConstantFonts.montserratMedium,
                ),
              ],
            ),
            const Spacer(),

            _buildStars(rating, Colors.amber),
            SizedBox(width: 20.dp),

          ],
        ),

        SizedBox(height: 20.dp),

        _buildReviewCard(ProductReview(
          userName: "Alex Johnson",
          userImage: "https://i.pravatar.cc/150?u=1",
          rating: 5.0,
          date: "2 days ago",
          comment: "The quality of these microgreens is exceptional! Extremely fresh and arrived in perfect condition. Highly recommended for garnish.",
        ),),

        SizedBox(height: 10.dp),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoButton(padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                child: Container(
                    padding: EdgeInsets.only(bottom: 0.3.dp),
                    // 👈 space between text & underline
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: objConstantColor.black,
                          width: 1.dp, // underline thickness
                        ),
                      ),
                    ),
                    child: objCommonWidgets.customText(
                      context, "View all reviews's", 11,
                      objConstantColor.black, objConstantFonts
                        .montserratMedium,
                    )
                ), onPressed: ()=> showReviewsBottomSheet(context)),
          ],
        )

      ],
    );
  }



  Widget _buildStars(double rating, Color color) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
          color: color,
          size: 25.dp,
        );
      }),
    );
  }


  Widget _buildReviewCard(ProductReview review) {
    return Container(
      padding: EdgeInsets.all(10.dp),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.dp),
          border: Border.all(color: Colors.black.withAlpha(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 2,
              offset: const Offset(0, 2),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 18.dp,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: Image.network(
                    review.userImage,
                    width: 36.dp, // Diameter (radius * 2)
                    height: 36.dp, // Diameter (radius * 2)
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Local Placeholder Image
                          Image.asset(
                            objConstantAssest.placeHolder,
                            width: 36.dp,
                            height: 36.dp,
                            fit: BoxFit.cover,
                          ),
                          // 2. Small White Circular Progress Bar
                          SizedBox(
                            width: 12.dp, // Scaled down for the small avatar
                            height: 12.dp,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ],
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        objConstantAssest.profileIcon,
                        width: 36.dp,
                        height: 36.dp,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.dp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    objCommonWidgets.customText(context, review.userName, 13, objConstantColor.black, objConstantFonts.montserratSemiBold),
                    objCommonWidgets.customText(context, review.date, 10, Colors.grey, objConstantFonts.montserratMedium),
                  ],
                ),
              ),
              // Stars for individual rating
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 14.dp,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 12.dp),
          // Review Text
          objCommonWidgets.customText(
              context,
              review.comment,
              10,
              Colors.black.withOpacity(0.75),
              objConstantFonts.montserratMedium
          ),
        ],
      ),
    );
  }



  void showReviewsBottomSheet(BuildContext context) {
    final List<ProductReview> reviews = [
      ProductReview(
        userName: "Alex Johnson",
        userImage: "https://i.pravatar.cc/150?u=1",
        rating: 5.0,
        date: "2 days ago",
        comment: "The quality of these microgreens is exceptional! Extremely fresh and arrived in perfect condition. Highly recommended for garnish.",
      ),
      ProductReview(
        userName: "Maria Garcia",
        userImage: "https://i.pravatar.cc/150?u=2",
        rating: 4.5,
        date: "1 week ago",
        comment: "Fast delivery and great packaging. The flavor is very intense and earthy. Will definitely order again.",
      ),
      ProductReview(
        userName: "James Wilson",
        userImage: "https://i.pravatar.cc/150?u=3",
        rating: 4.0,
        date: "2 weeks ago",
        comment: "Very good quality, though I wish the portion size was slightly larger for the price point.",
      ),
      ProductReview(
        userName: "Sarah Miller",
        userImage: "https://i.pravatar.cc/150?u=4",
        rating: 5.0,
        date: "1 month ago",
        comment: "Absolutely love these! They stayed fresh in my fridge for over a week. Perfect for my morning smoothies.",
      ),
      ProductReview(
        userName: "David Chen",
        userImage: "https://i.pravatar.cc/150?u=5",
        rating: 4.8,
        date: "1 month ago",
        comment: "Incredible vibrant color. Used these for a dinner party and everyone asked where I got them. A bit pricey but worth it for the premium feel.",
      ),
      ProductReview(
        userName: "Emily Watson",
        userImage: "https://i.pravatar.cc/150?u=6",
        rating: 3.5,
        date: "2 months ago",
        comment: "The product itself is 5 stars, but the delivery took two days longer than promised. The greens were still cold, so no harm done.",
      ),
      ProductReview(
        userName: "Michael Ross",
        userImage: "https://i.pravatar.cc/150?u=7",
        rating: 5.0,
        date: "2 months ago",
        comment: "Consistency is key for my restaurant, and Botaniq delivers every single time. Best microgreens in the city, hands down.",
      ),
      ProductReview(
        userName: "Jessica Alba",
        userImage: "https://i.pravatar.cc/150?u=8",
        rating: 4.2,
        date: "3 months ago",
        comment: "Great crunch and peppery taste. I appreciate the eco-friendly packaging they used.",
      ),
      ProductReview(
        userName: "Robert Fox",
        userImage: "https://i.pravatar.cc/150?u=9",
        rating: 5.0,
        date: "3 months ago",
        comment: "Super healthy addition to my diet. I love how these are grown locally.",
      ),
      ProductReview(
        userName: "Linda Thorne",
        userImage: "https://i.pravatar.cc/150?u=10",
        rating: 2.0,
        date: "4 months ago",
        comment: "I received the wrong variety of Amaranthus. Customer support was helpful in fixing it, but it was still a bit frustrating.",
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.25,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(35.dp),
                ),
              ),
              child: Column(
                children: [
                  /// 🔹 Drag Handle (FIXED)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.dp),
                    child: Container(
                      width: 40.dp,
                      height: 4.dp,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10.dp),
                      ),
                    ),
                  ),

                  /// 🔹 Title (FIXED)
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16.dp, vertical: 6.dp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        customSectionTitle(context, "Ratings & Reviews"),

                        CupertinoButton(
                          minimumSize: Size.zero,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          padding: EdgeInsets.zero,
                          child: Container(
                            padding: EdgeInsets.all(6.dp),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withAlpha(30),),
                            child: Icon(Icons.close_rounded,
                                size: 18.dp,
                                color: Colors.black),
                          ),)
                      ],
                    ),
                  ),

                  /// 🔹 Divider (optional but nice)
                  Divider(height: 1, color: Colors.grey.shade200),

                  /// 🔹 Scrollable Reviews
                  Expanded(
                    child: SafeArea(
                      child: ListView.separated(
                        controller: scrollController, // ✅ REQUIRED
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.dp, vertical: 12.dp),
                        itemCount: reviews.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: 12.dp),
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                      
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration:
                            Duration(milliseconds: 350 + (index * 120)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildReviewCard(review),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
