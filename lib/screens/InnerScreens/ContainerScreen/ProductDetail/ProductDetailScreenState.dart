// ProductDetailScreenState.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../API/CommonAPI.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Utility/Logger.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';
import '../../../commonViews/CustomToast.dart';
import '../../MainScreen/MainScreenState.dart';
import '../CartScreen/CartModel.dart';
import '../WishListScreen/WishListModel.dart';
import '../WishListScreen/WishListRepository.dart';
import 'ProductDetailModel.dart';
import 'ProductDetailsRepository.dart';



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

/// --- STATE CLASS ---
class ProductDetailScreenGlobalState {
  final ScreenName currentModule;
  final ProductData? productData;
  final int wishList;
  final int inCart;
  final int count;
  final bool isLoading; // <- loading flag for shimmer

  ProductDetailScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.productData,
    this.wishList = 0,
    this.inCart = 0,
    this.count = 1,
    this.isLoading = true, // default true so shimmer shows initially
  });

  ProductDetailScreenGlobalState copyWith({
    ScreenName? currentModule,
    ProductData? productData,
    int? wishList,
    int? inCart,
    int? count,
    bool? isLoading,
  }) {
    return ProductDetailScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      productData: productData ?? this.productData,
      wishList: wishList ?? this.wishList,
      inCart: inCart ?? this.inCart,
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// --- STATE NOTIFIER ---
class ProductDetailScreenGlobalStateNotifier
    extends StateNotifier<ProductDetailScreenGlobalState> {
  ProductDetailScreenGlobalStateNotifier()
      : super(ProductDetailScreenGlobalState());

  @override
  void dispose() {
    super.dispose();
  }

  void fetchSavedData() {
    // savedProductDetails is a global from your project (kept as-is)
    state = state.copyWith(
      wishList: savedProductDetails?.isWishlisted ?? 0,
      inCart: savedProductDetails?.inCart ?? 0,
    );
  }

  // 🔹 Increment count
  void incrementCount() {
    state = state.copyWith(count: state.count + 1);
  }

  // 🔹 Decrement count (min limit = 1)
  void decrementCount() {
    if (state.count > 1) {
      state = state.copyWith(count: state.count - 1);
    }
  }

  /// ✅ GET Product Details API
  Future<void> callProductDetailsGetAPI(BuildContext context) async {
    final isConnected = await CodeReusability().isConnectedToNetwork();

    if (!isConnected) {
      CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      return;
    }

    // show shimmer
    state = state.copyWith(isLoading: true);

    try {
      var productId = savedProductDetails?.productID ?? '';

      ProductDetailsRepository().callProductDetailsGETApi(
        '${ConstantURLs.productDetailsUrl}$productId',
            (statusCode, response) async {
          Logger().log('###---> Product Details API Response: $response');

          final detailsResponse = ProductDetailResponse.fromJson(response);

          if (statusCode == 200) {
            /// ✅ Update state with API response data and stop shimmer
            state = state.copyWith(
              productData: detailsResponse.data,
              isLoading: false,
            );
            Logger().log(
                '###---> Product details stored in state: ${detailsResponse.data.productName}');
          } else {
            state = state.copyWith(isLoading: false);
            CodeReusability().showAlert(
              context,
              detailsResponse.message.isNotEmpty
                  ? detailsResponse.message
                  : "Something went wrong",
            );
          }
        },
      );
    } catch (e) {
      Logger().log('###---> Error: $e');
      state = state.copyWith(isLoading: false);
      CodeReusability().showAlert(context, 'Something went wrong');
    }
  }

  ///This method used to call remove Product from WishList
  void callRemoveFromWishList(BuildContext context, String productID) {
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

        WishListRepository().callProductDeleteFromWishListApi(
            ConstantURLs.addRemoveWishListUrl, requestBody,
                (statusCode, responseBody) async {
              final wishListResponse = WishListRemoveResponse.fromJson(responseBody);
              if (statusCode == 200) {
                Logger().log('###---> Product Remove WishList API: $wishListResponse');
                state = state.copyWith(wishList: 0);
              } else {
                CodeReusability().showAlert(
                    context, wishListResponse.message ?? "something Went Wrong");
              }
              CommonWidgets().showLoadingBar(false, context);
            });
      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }

  ///This method used to call add Product to WishList
  void callAddToWishList(BuildContext context, String productID) {
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

        WishListRepository().callAddToWishListApi(
            ConstantURLs.addRemoveWishListUrl, requestBody,
                (statusCode, responseBody) async {
              final wishListResponse = AddToWishlistResponse.fromJson(responseBody);
              if (statusCode == 200) {
                Logger().log('###---> Product Add To WishList API: $wishListResponse');
                state = state.copyWith(wishList: 1);
              } else {
                CodeReusability().showAlert(
                    context, wishListResponse.message ?? "something Went Wrong");
              }
              CommonWidgets().showLoadingBar(false, context);
            });
      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }

  ///This method is used to add product to Cart POST API
  void callAddToCartAPI(BuildContext context, String productID,
      MainScreenGlobalStateNotifier notifier) {
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        CommonWidgets().showLoadingBar(true, context);
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

        Map<String, dynamic> requestBody = {
          'userId': userID,
          'productId': productID,
          'productCount': state.count
        };

        WishListRepository().callAddToCartApi(
            ConstantURLs.addRemoveCountUpdateCartUrl, requestBody,
                (statusCode, responseBody) async {
              final addToCartResponse = AddToCartResponse.fromJson(responseBody);
              if (statusCode == 200) {
                state = state.copyWith(inCart: 1);
                CustomToast.show(
                    context, "${state.productData?.productName} added to cart successfully!");
                notifier.callFooterCountGETAPI();
              } else {
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
}

/// --- PROVIDER ---
final productDetailScreenGlobalStateProvider =
StateNotifierProvider.autoDispose<ProductDetailScreenGlobalStateNotifier,
    ProductDetailScreenGlobalState>((ref) {
  return ProductDetailScreenGlobalStateNotifier();
});
