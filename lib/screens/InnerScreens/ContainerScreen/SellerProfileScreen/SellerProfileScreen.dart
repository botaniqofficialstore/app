import 'package:botaniqmicrogreens/Utility/NetworkImageLoader.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/ReelsScreen/ReelsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/utilities.dart';
import '../../../../constants/Constants.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../MainScreen/MainScreen.dart';
import '../../MainScreen/MainScreenState.dart';
import '../HomeScreen/HomeScreenModel.dart';
import 'SellerProfileScreenState.dart';


class SellerProfileScreen extends ConsumerStatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  SellerProfileScreenState createState() => SellerProfileScreenState();
}

class SellerProfileScreenState extends ConsumerState<SellerProfileScreen> with TickerProviderStateMixin {

    @override
  void initState() {
    Future.microtask((){
      final notifier = ref.read(sellerProfileScreenStateProvider.notifier);
      notifier.callProductListGepAPI(context, loadMore: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellerProfileScreenStateProvider);
    final notifier = ref.read(sellerProfileScreenStateProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // optional
        statusBarIconBrightness: Brightness.dark, // ANDROID → black icons
        statusBarBrightness: Brightness.light, // iOS → black icons
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.dp, vertical: 10.dp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerView(context),
                          SizedBox(height: 15.dp),
                          objCommonWidgets.customText(
                              context, state.bio, 10.5, Colors.black,
                              objConstantFonts.montserratRegular,
                              textAlign: TextAlign.justify),
                          SizedBox(height: 5.dp),
                        ],
                      ),
                    ),
                  ),
                  // The Persistent Tab Bar (Instagram Style)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        onTap: (index) => notifier.setTabIndex(index),
                        indicatorColor: Colors.black,
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(width: 3.dp, color: Colors.black), // Thickness
                          insets: EdgeInsets.symmetric(horizontal: 30.dp), // Higher horizontal value = Shorter bar
                        ),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(icon: Icon(Icons.grid_on_sharp)),
                          Tab(icon: Icon(Icons.shopping_basket_outlined)),
                          Tab(icon: Icon(Icons.rate_review_outlined)),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _ReelsGrid(reels: state.totalReels),
                  buildItemsView(context),
                  reviewView(context, state.reviews),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget headerView(BuildContext context) {
    final state = ref.watch(sellerProfileScreenStateProvider);
    
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15.dp),
              ClipOval(
                child: SizedBox(
                  width: 80.dp,
                  height: 80.dp,
                  child: NetworkImageLoader(
                    imageUrl: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
                    placeHolder: objConstantAssest.placeHolder,
                    size: 80.dp,
                    imageSize: 80.dp,
                  ),
                ),
              ),

              SizedBox(height: 15.dp),

              objCommonWidgets.customText(
                  context, state.name, 15, Colors.black,
                  objConstantFonts.montserratSemiBold),

              SizedBox(height: 5.dp),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      color: Colors.blueAccent, size: 12.dp),
                  SizedBox(width: 2.dp),
                  objCommonWidgets.customText(context,
                      'Verified Merchant', 10, Colors.black,
                      objConstantFonts.montserratRegular),
                ],
              ),

              SizedBox(height: 10.dp),
            ],
          ),
        ),

        // Back Button Positioned relative to the stack
        Positioned(
          top: 0.dp,
          left: 0.dp,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18.dp,
            ),
          ),
        )
      ],
    );
  }

  Widget reviewView(BuildContext context, List<ProductReview> list){
    return Container(
      color: Colors.black.withAlpha(15),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => SizedBox(height: 2.dp),
        itemBuilder: (context, index) {
          final review = list[index];
          return _buildReviewCard(context, review);
        },
      ),
    );
  }

  Widget buildItemsView(BuildContext context){
    final state = ref.watch(sellerProfileScreenStateProvider);
    final notifier = ref.read(sellerProfileScreenStateProvider.notifier);

     if (state.isLoading && state.productList.isEmpty) {
       return buildProductShimmer();
     }else {
       return GridView.builder(
         padding: EdgeInsets.symmetric(horizontal: 14.dp, vertical: 10.dp),
         physics: const BouncingScrollPhysics(),
         // allow scrolling
         itemCount: state.productList.length + (state.isLoading ? 1 : 0),
         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: 2,
           mainAxisSpacing: 12,
           crossAxisSpacing: 12,
           childAspectRatio: 0.60,
         ),
         itemBuilder: (context, index) {
           if (index == state.productList.length) {
             return const Center(child: CupertinoActivityIndicator());
           }

           final product = state.productList[index];
           return _buildProductCard(product, index, notifier);
         },
       );
     }
  }

  Widget _buildReviewCard(BuildContext context, ProductReview review) {
    return Container(
      padding: EdgeInsets.only(left: 15.dp, right: 15.dp, top: 20.dp, bottom: 10.dp),
      color: Colors.white,
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
                    width: 33.dp, // Diameter (radius * 2)
                    height: 33.dp, // Diameter (radius * 2)
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Local Placeholder Image
                          Image.asset(
                            objConstantAssest.defaultProfile,
                            width: 33.dp,
                            height: 33.dp,
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
                        width: 33.dp,
                        height: 33.dp,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.dp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    objCommonWidgets.customText(context, review.userName, 11, objConstantColor.black, objConstantFonts.montserratSemiBold),
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



    Widget _buildProductCard(ProductData product, int index, SellerProfileScreenStateNotifier notifier) {
      return GestureDetector(
        onTap: () {
          savedProductDetails = ProductDetailStatus(
            productID: product.productId,
            coverImage: product.coverImage,
            inCart: product.inCart,
            isWishlisted: product.isWishlisted,
          );
          ref.read(MainScreenGlobalStateProvider.notifier).updateSelectedProduct(savedProductDetails!);
          notifier.callNavigateToDetailsScreen(context);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.dp),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8, offset: const Offset(0, 1)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- IMAGE SECTION ---
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(5.dp),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.dp),
                        child: NetworkImageLoader(
                          imageUrl: '${ConstantURLs.baseUrl}${product.image}',
                          placeHolder: objConstantAssest.placeHolder,
                          size: double.infinity,
                          imageSize: double.infinity,
                        ),
                      ),
                    ),

                    // ✅ Modern Wishlist Button (Transparent/Glass effect)
                    Positioned(
                      right: 10.dp,
                      top: 10.dp,
                      child: GestureDetector(
                        onTap: () {
                          if (product.isWishlisted == 1) {
                            notifier.callRemoveFromWishList(context, product.productId, index);
                          } else {
                            notifier.callAddToWishList(context, product.productId, index);
                          }
                        },
                        child: Icon(
                          (product.isWishlisted == 1) ? Icons.favorite : Icons.favorite_border,
                          color: (product.isWishlisted == 1) ? Colors.red : Colors.white,
                          size: 22.dp,
                        ),
                      ),
                    ),

                    // ✅ Modern Discount Tag (Zomato Style)
                    if (product.productPrice != product.productSellingPrice)
                      Positioned(
                        left: 5.dp,
                        top: 12.dp,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.dp, vertical: 2.dp),
                          decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(4.dp),
                          ),
                          child: Text(
                            "${PriceHelper.getDiscountPercentage(
                              productPrice: product.productPrice ?? 0,
                              sellingPrice: product.productSellingPrice ?? 0,
                            )} OFF",
                            style: TextStyle(color: Colors.black, fontSize: 9.dp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // --- INFO SECTION ---
              Padding(
                padding: EdgeInsets.fromLTRB(10.dp, 0, 10.dp, 10.dp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weight/Gram label (Secondary info first)
                    objCommonWidgets.customText(context,
                    "${product.gram}gm",
                    11, objConstantColor.black.withAlpha(150), objConstantFonts.montserratMedium),

                    SizedBox(height: 2.dp),

                    // Product Name
                    objCommonWidgets.customText(context,
                        CodeReusability().cleanProductName(product.productName),
                        12, Colors.black, objConstantFonts.montserratSemiBold),

                    SizedBox(height: 8.dp),

                    // Price and Add Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            objCommonWidgets.customText(context,
                                "₹${product.productSellingPrice}/_",
                                13, Colors.black, objConstantFonts.montserratSemiBold),
                            if (product.productPrice != product.productSellingPrice)
                              Text(
                                "₹${product.productPrice}",
                                style: TextStyle(
                                  fontSize: 11.dp,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),

                        // ✅ Modern "ADD" Button (Blinkit/Swiggy Style)
                        _buildAddButton(product, index, notifier),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildAddButton(ProductData product, int index, SellerProfileScreenStateNotifier notifier) {
      bool isInCart = product.inCart != 0;

      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: () {
          if (!isInCart) {
            objCommonWidgets.showAddToCartSheet(context, product, (itemCount) {
              var mainNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);
              notifier.callAddToCartAPI(context, product.productId, index, mainNotifier);
            });
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen(module: ScreenName.cart)),
            );
          }
        },
        child: isInCart ? Container(
          padding: EdgeInsets.all(8.dp),
          decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(5.dp)
          ),
          child: Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 15.dp,),
        ) : Container(
          padding: EdgeInsets.all(8.dp),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5.dp)
          ),
          child: Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 15.dp,),
        ),
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
  
}



class _EmptyGrid extends StatelessWidget {
  final String message;
  const _EmptyGrid({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

// Delegate to keep the TabBar pinned at the top while scrolling
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}


class _ReelsGrid extends StatelessWidget {
  final List<ReelsList> reels;
  const _ReelsGrid({required this.reels});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16, // Instagram Reel Aspect Ratio
        crossAxisSpacing: 1,
        mainAxisSpacing: 0,
      ),
      itemCount: reels.length,
      itemBuilder: (context, index) {
        final reel = reels[index];
        // Cloudinary trick: Change .mp4 to .jpg for instant thumbnail
        final thumbUrl = reel.videoUrl.replaceAll('.mp4', '.jpg');

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReelsScreen(),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [

              NetworkImageLoader(
                imageUrl: thumbUrl,
                placeHolder: objConstantAssest.placeHolder,
                size: 192.dp, imageSize: 192.dp,
                topCurve: 0,
                bottomCurve: 0,
              ),
              Positioned(
                bottom: 5.dp,
                right: 5.dp,
                child: Column(
                  children: [
                    Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 14.dp),
                objCommonWidgets.customText(context, reel.totalViews, 9, Colors.white, objConstantFonts.montserratSemiBold),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}