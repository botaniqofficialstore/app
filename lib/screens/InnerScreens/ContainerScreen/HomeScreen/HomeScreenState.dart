import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'HomeScreenModel.dart';
import 'HomeScreenRepository.dart';

class HomeScreenGlobalState {
  final ScreenName currentModule;
  final List<ProductData> productList;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;

  HomeScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.productList = const [],
    this.currentPage = 0,
    this.isLoading = false,
    this.hasMore = true,
  });

  HomeScreenGlobalState copyWith({
    ScreenName? currentModule,
    List<ProductData>? productList,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
  }) {
    return HomeScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      productList: productList ?? this.productList,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class HomeScreenGlobalStateNotifier extends StateNotifier<HomeScreenGlobalState> {
  HomeScreenGlobalStateNotifier() : super(HomeScreenGlobalState());

  /// This method is used to get Product List from GET API
  Future<void> callProductListGepAPI(BuildContext context, {bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    state = state.copyWith(isLoading: true);
    bool isConnected = await CodeReusability().isConnectedToNetwork();

    if (!isConnected) {
      CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      var prefs = await PreferencesManager.getInstance();
      String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

      const int limit = 10; // ✅ fixed constant limit
      int nextPage = loadMore ? state.currentPage + 1 : 1;

      String url = '${ConstantURLs.productListUrl}userId=$userID&page=$nextPage&limit=$limit';

      HomeScreenRepository().callProductListGETApi(url, (statusCode, response) async {
        final productResponse = ProductListResponse.fromJson(response);

        if (statusCode == 200) {
          Logger().log('###---> Product List API Response Page $nextPage: $response');

          final newProducts = productResponse.data;

          final hasMore = newProducts.isNotEmpty && newProducts.length >= limit;

          // ✅ If first page, replace list; else append
          state = state.copyWith(
            productList: loadMore
                ? [...state.productList, ...newProducts]
                : newProducts,
            currentPage: nextPage,
            hasMore: hasMore,
          );
        } else {
          CodeReusability().showAlert(context, productResponse.message);
        }
      });
    } catch (e) {
      Logger().log("### Error in callProductListGepAPI: $e");
    } finally {
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



}

final HomeScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    HomeScreenGlobalStateNotifier, HomeScreenGlobalState>((ref) {
  return HomeScreenGlobalStateNotifier();
});
