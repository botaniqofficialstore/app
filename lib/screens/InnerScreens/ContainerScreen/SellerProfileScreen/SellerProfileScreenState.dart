import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Constants/Constants.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../commonViews/CustomToast.dart';
import '../../MainScreen/MainScreenState.dart';
import '../CartScreen/CartModel.dart';
import '../HomeScreen/HomeScreenModel.dart';
import '../HomeScreen/HomeScreenRepository.dart';
import '../ProductDetail/ProductDetailScreen.dart';
import '../WishListScreen/WishListModel.dart';
import '../WishListScreen/WishListRepository.dart';

class SellerProfileScreenState {
  final String sellerID;
  final String name;
  final String bio;
  final int selectedTabIndex;
  final List<ReelsList> totalReels;
  final List<ProductReview> reviews;

  final List<ProductData> productList;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;

  SellerProfileScreenState({
    required this.sellerID,
    this.name = "Nourish Organics",
    this.bio = "Nourish Organics offers a premium selection of 100% organic products sourced responsibly from certified farms. Our mission is to provide clean, chemical-free, and naturally nourishing products that support a healthier lifestyle and a sustainable future.",
    this.selectedTabIndex = 0,
    required this.totalReels,
    this.reviews = const [],

    this.productList = const [],
    this.currentPage = 0,
    this.isLoading = false,
    this.hasMore = true,
  });

  SellerProfileScreenState copyWith({
    int? selectedTabIndex,
    List<ReelsList>? totalReels,
    List<ProductReview>? reviews,

    List<ProductData>? productList,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
  }) {
    return SellerProfileScreenState(
      sellerID: sellerID,
      name: name,
      bio: bio,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      totalReels: totalReels ?? this.totalReels,
      reviews: reviews ?? this.reviews,
      productList: productList ?? this.productList,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class SellerProfileScreenStateNotifier
    extends StateNotifier<SellerProfileScreenState> {
  SellerProfileScreenStateNotifier() : super(SellerProfileScreenState(
      sellerID: '', totalReels: getReelsList(),
      reviews: getProductReviewList(),
  ));

  static List<ReelsList> getReelsList() {
    return [
      ReelsList(
          brandLogo: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
          brandName: 'Nourish Organics',
          totalViews: '106',
          videoDescription: 'See hwo we harvest #Microgreens',
          productID: '78412254',
          videoUrl: 'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138705/SnapInsta.to_AQNNFZPoa4YLTl7YB-S1one5dPHJL7Q-wcEVUwou_yQsiEQuUFcd844X8M2d46p1_eRdj5NBQ1ZZJoPityhT_7zp34XBT-JhohFVFO0_qg1ibq.mp4'
      ),
      ReelsList(
          brandLogo: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
          brandName: 'Nourish Organics',
          totalViews: '1.5k',
          videoDescription: 'Fresh & Organic',
          productID: '78412254',
          videoUrl: 'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138720/SnapInsta.to_AQOts8468lXOl27PrNJoK9VtNUvn-YVjowfVqJB6kfo1zFOGRqkU6ZUoFHufRpNkN2yNV8f4gaHu0-50iVane1jCO-wCX-zYlhwrNq0_yvbkyd.mp4'
      ),
      ReelsList(
          brandLogo: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
          brandName: 'Nourish Organics',
          totalViews: '458k',
          videoDescription: 'See how easy is it #Microgreens',
          productID: '78412254',
          videoUrl: 'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138739/SnapInsta.to_AQOk0IcWRqTl3u_vSeoqrHhbOhFDG_WpWHNoATsWYJmT0eSgMMIBzo1UuQwBZuLRm5FDM4HWWPLkDNOFwTyH6AVBD8cdPEF7MXa6N3c_eeuhe1.mp4'
      ),
      ReelsList(
          brandLogo: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
          brandName: 'Nourish Organics',
          totalViews: '2.6k',
          videoDescription: 'Introducing new varieties of microgreens, #Microgreens, #BotaniQ',
          productID: '78412254',
          videoUrl: 'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138747/SnapInsta.to_AQPpZtQ7bKg2koYcilH1vUqdqu5SwE7yvrylBWK8QzvIbmCiLG567CIxzNVOEULRje8Kj6Bus4YQbEj7QQVrWSM5ACi6pcjIQS3mAFo_xukvql.mp4'
      ),
      ReelsList(
          brandLogo: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
          brandName: 'Nourish Organics',
          totalViews: '152k',
          videoDescription: 'Eat organic food everyday... #HomeFarming, #Microgreens, #BotaniQ',
          productID: '78412254',
          videoUrl: 'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138771/SnapInsta.to_AQPoGLAnqAl2aiYcWV_24tGgowtylD81l-utzuMmDIslGla8v3pCXJLmN3BnC_UuEXMTKbA1P-HZ-jlF8Qr3_F_Ga08syvLGZn7C0jI_isfnyr.mp4'
      ),
      ReelsList(
          brandLogo: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
          brandName: 'Nourish Organics',
          totalViews: '12.4k',
          videoDescription: 'Green to your home',
          productID: '78412254',
          videoUrl: 'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138792/SnapInsta.to_AQPyfoGS1yuPyVbgftcFiEHrg2aFc7cshSiKFe7EGn5CSKQLof-bMsm6z6nz8S3I6_zpCImPmcz17fkTSzC2xu0MtSz55Cc2sLkHE80_ounszk.mp4'
      ),
      ReelsList(
          brandLogo: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
          brandName: 'Nourish Organics',
          totalViews: '45k',
          videoDescription: 'Grow Microgreens at you home!',
          productID: '78412254',
          videoUrl: 'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138796/SnapInsta.to_AQPS9ds3-4d7WKpasvRKYAHJObMfSH_JHyDeW6Wc-34qzL93DNU1wfHMlRRpLfzby1xJJQAkC4NYxpvM85aOhiuPnBTbkftYD-lQVl4_vmt7cu.mp4'
      ),
      ReelsList(
          brandLogo: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
          brandName: 'Nourish Organics',
          totalViews: '546.2k',
          videoDescription: 'Fresh Microgreens Harvesting',
          productID: '78412254',
          videoUrl: 'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138814/SnapInsta.to_AQMEqax1BBYme00g3Oilz6OfR0yauZcg-De76JVzGfzhmzXRoZzpvhqWGy9K_E3xI97wW83cKGrBgwSdEvCET5J5mIXr1BG9hE_Xh2o_ijsj79.mp4'
      ),
    ];
  }



  static List<ProductReview> getProductReviewList() {
    return [
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
  }

  void setTabIndex(int index) => state = state.copyWith(selectedTabIndex: index);

  /// This method is used to get Product List from GET API
  Future<void> callProductListGepAPI(
      BuildContext context, {
        bool loadMore = false,
      }) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    state = state.copyWith(isLoading: true);

    bool isConnected = await CodeReusability().isConnectedToNetwork();
    if (!isConnected) {
      state = state.copyWith(isLoading: false);
      CodeReusability()
          .showAlert(context, 'Please Check Your Internet Connection');
      return;
    }

    try {
      var prefs = await PreferencesManager.getInstance();
      String userID =
          prefs.getStringValue(PreferenceKeys.userID) ?? '';

      const int limit = 10;
      int nextPage = loadMore ? state.currentPage + 1 : 1;

      String url =
          '${ConstantURLs.productListUrl}userId=$userID&page=$nextPage&limit=$limit';

      HomeScreenRepository().callProductListGETApi(
        url,
            (statusCode, response) async {
          final productResponse =
          ProductListResponse.fromJson(response);
          if (statusCode == 200) {
            final newProducts = productResponse.data;
            final hasMore = newProducts.length >= limit;

            state = state.copyWith(
              productList: loadMore
                  ? [...state.productList, ...newProducts]
                  : newProducts,
              currentPage: nextPage,
              hasMore: hasMore,
              isLoading: false,
            );
          } else {
            state = state.copyWith(isLoading: false);
            CodeReusability()
                .showAlert(context, productResponse.message);
          }
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }




  ///This method used to call remove Product from WishList
  void callRemoveFromWishList(BuildContext context, String productID, int index){
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        CommonWidgets().showLoadingBar(true, context);
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

        Map<String, dynamic> requestBody = {
          'userId': userID,
          'productId': productID,
        };

        WishListRepository().callProductDeleteFromWishListApi(ConstantURLs.addRemoveWishListUrl, requestBody, (statusCode, responseBody) async {
          final wishListResponse = WishListRemoveResponse.fromJson(responseBody);
          if (statusCode == 200) {
            updateWishlistStatus(index, 0);
          } else {
            CodeReusability().showAlert(context, wishListResponse.message ?? "something Went Wrong");
          }
          CommonWidgets().showLoadingBar(false, context);
        });
      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }


  ///This method used to call remove Product from WishList
  void callAddToWishList(BuildContext context, String productID, int index){
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        CommonWidgets().showLoadingBar(true, context);
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

        Map<String, dynamic> requestBody = {
          'userId': userID,
          'productId': productID,
        };

        WishListRepository().callAddToWishListApi(ConstantURLs.addRemoveWishListUrl, requestBody, (statusCode, responseBody) async {
          final wishListResponse = AddToWishlistResponse.fromJson(responseBody);
          if (statusCode == 200) {
            updateWishlistStatus(index, 1);
          } else {
            CodeReusability().showAlert(context, wishListResponse.message ?? "something Went Wrong");
          }
          CommonWidgets().showLoadingBar(false, context);
        });
      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }

  ///This method is used to add product to Cart POST API
  void callAddToCartAPI(BuildContext context, String productID, int index, MainScreenGlobalStateNotifier notifier) {
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        CommonWidgets().showLoadingBar(true, context);
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

        Map<String, dynamic> requestBody = {
          'userId': userID,
          'productId': productID,
        };

        WishListRepository().callAddToCartApi(
            ConstantURLs.addRemoveCountUpdateCartUrl, requestBody, (statusCode,
            responseBody) async {
          final addToCartResponse = AddToCartResponse.fromJson(responseBody);
          if (statusCode == 200) {
            updateCartListStatus(context, index, 1);
            notifier.callFooterCountGETAPI();
          }

          else {
            CodeReusability().showAlert(
                context, addToCartResponse.message ?? "something Went Wrong");
          }
          CommonWidgets().showLoadingBar(false, context);
        });
      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }


  ///This method is used to update the WishList Status
  void updateWishlistStatus(int index, int newStatus) {
    // Make a mutable copy of the list
    final updatedList = [...state.productList];

    if (index >= 0 && index < updatedList.length) {
      final product = updatedList[index];

      // Create a new ProductData with updated isWishlisted value
      final updatedProduct = ProductData(
        id: product.id,
        productId: product.productId,
        productName: product.productName,
        productPrice: product.productPrice,
        productSellingPrice: product.productSellingPrice,
        gram: product.gram,
        image: product.image,
        coverImage: product.coverImage,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        v: product.v,
        isWishlisted: newStatus,
        inCart: product.inCart,
      );

      // Replace the item at the same index
      updatedList[index] = updatedProduct;

      // Update the state
      state = state.copyWith(productList: updatedList);


    }
  }

  ///This method is used to update the WishList Status
  void updateCartListStatus(BuildContext context, int index, int newStatus) {
    // Make a mutable copy of the list
    final updatedList = [...state.productList];

    if (index >= 0 && index < updatedList.length) {
      final product = updatedList[index];

      // Create a new ProductData with updated isWishlisted value
      final updatedProduct = ProductData(
        id: product.id,
        productId: product.productId,
        productName: product.productName,
        productPrice: product.productPrice,
        productSellingPrice: product.productSellingPrice,
        gram: product.gram,
        image: product.image,
        coverImage: product.coverImage,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        v: product.v,
        isWishlisted: product.isWishlisted,
        inCart: newStatus,
      );

      // Replace the item at the same index
      updatedList[index] = updatedProduct;

      // Update the state
      state = state.copyWith(productList: updatedList);

      // Show toast
      if (newStatus == 1){
        CustomToast.show(context, "${product.productName} added to cart successfully!");
      }
    }
  }

  void callNavigateToDetailsScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) =>  const ProductDetailScreen(),
      ),
    );
  }

}

final sellerProfileScreenStateProvider = StateNotifierProvider.autoDispose<
    SellerProfileScreenStateNotifier, SellerProfileScreenState>((ref) {
  var notifier = SellerProfileScreenStateNotifier();
  return notifier;
});



class ReelsList {
  final String brandLogo;
  final String brandName;
  final String totalViews;
  final String videoDescription;
  final String productID;
  final String videoUrl;

  ReelsList({
    required this.brandLogo,
    required this.brandName,
    required this.totalViews,
    required this.videoDescription,
    required this.productID,
    required this.videoUrl,
  });
}


class ProductReview {
  final String userName;
  final String userImage;
  final double rating;
  final String date;
  final String comment;

  ProductReview({
    required this.userName,
    required this.userImage,
    required this.rating,
    required this.date,
    required this.comment,
  });
}