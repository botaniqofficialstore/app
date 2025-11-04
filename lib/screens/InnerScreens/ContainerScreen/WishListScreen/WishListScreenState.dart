import 'package:botaniqmicrogreens/screens/InnerScreens/MainScreen/MainScreenState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Utility/Logger.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';
import '../../../commonViews/CustomToast.dart';
import '../CartScreen/CartModel.dart';
import 'WishListModel.dart';
import 'WishListRepository.dart';


class WishListScreenGlobalState {
  final ScreenName currentModule;
  final List<WishListItem> wishListItems;

  WishListScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.wishListItems = const [],
  });

  WishListScreenGlobalState copyWith({
    ScreenName? currentModule,
    List<WishListItem>? wishListItems,
  }) {
    return WishListScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      wishListItems: wishListItems ?? this.wishListItems,
    );
  }
}


class WishListScreenGlobalStateNotifier
    extends StateNotifier<WishListScreenGlobalState> {
  WishListScreenGlobalStateNotifier() : super(WishListScreenGlobalState());

  @override
  void dispose() {
    super.dispose();
  }

  ///This method is used to validate Add to Cart and View in Cart
  void viewOrAddToCart(BuildContext context, MainScreenGlobalStateNotifier notifier, String productID, bool addToCart, int index){
    if (addToCart){
      callAddToCartAPI(context, productID, index);
    } else {
      notifier.callNavigation(ScreenName.cart);
    }
  }

  ///This method is used to get Wish list using GET API
  Future<void> callWishListGepAPI(BuildContext context) async {
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        CommonWidgets().showLoadingBar(true, context);
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';
        WishListRepository().callWishListApi(
            '${ConstantURLs.getWishListUrl}userId=$userID&page=1&limit=100',
                (statusCode, response) async {
                  final wishListResponse = WishListResponse.fromJson(response);
              if (statusCode == 200) {
                Logger().log('###---> Wish List API Response: $response');

                // ✅ Update the UI state with fetched data
                state = state.copyWith(wishListItems: wishListResponse.data ?? []);
              } else {
                Logger().log('###---> Response: $response');
                CodeReusability().showAlert(context, wishListResponse.message ?? "something Went Wrong");
              }

              CommonWidgets().showLoadingBar(false, context);
            });
      } else {
        CodeReusability().showAlert(
            context, 'Please Check Your Internet Connection');
      }
    });
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
            // ✅ Remove item locally
            final updatedList = List<WishListItem>.from(state.wishListItems);
            updatedList.removeAt(index);

            // ✅ Update state to refresh UI
            state = state.copyWith(wishListItems: updatedList);
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
  void callAddToCartAPI(BuildContext context, String productID, int index) {
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

        WishListRepository().callAddToCartApi(ConstantURLs.addRemoveCountUpdateCartUrl, requestBody, (statusCode, responseBody) async {
          final addToCartResponse = AddToCartResponse.fromJson(responseBody);
          if (statusCode == 200) {
            // ✅ Update local UI immediately
            final updatedList = List<WishListItem>.from(state.wishListItems);

            if (index >= 0 && index < updatedList.length) {
              final currentItem = updatedList[index];

              final updatedItem = WishListItem(
                userId: currentItem.userId,
                productId: currentItem.productId,
                addedAt: currentItem.addedAt,
                inCart: 1, // ✅ update here
                productDetails: currentItem.productDetails,
              );
              updatedList[index] = updatedItem;
              CustomToast.show(context, "${currentItem.productDetails!.productName} added to cart successfully!");

              // ✅ Refresh state to update UI
              state = state.copyWith(wishListItems: updatedList);
            }

          } else {
            CodeReusability().showAlert(context, addToCartResponse.message ?? "something Went Wrong");
          }
          CommonWidgets().showLoadingBar(false, context);
        });


      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }



}



final WishListScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    WishListScreenGlobalStateNotifier, WishListScreenGlobalState>((ref) {
  var notifier = WishListScreenGlobalStateNotifier();
  return notifier;
});

