import 'package:botaniqmicrogreens/screens/InnerScreens/MainScreen/MainScreenState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Utility/Logger.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';
import 'CartModel.dart';
import 'CartRepository.dart';

class CartScreenGlobalState {
  final ScreenName currentModule;
  final List<CartItem> cartItems;

  CartScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.cartItems = const [],
  });

  CartScreenGlobalState copyWith({
    ScreenName? currentModule,
    List<CartItem>? cartItems,
  }) {
    return CartScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      cartItems: cartItems ?? this.cartItems,
    );
  }

  /// Calculate payable amount (sum of each product's selling price × count)
  int get totalPayableAmount {
    return cartItems.fold(0, (sum, item) {
      final price = item.productDetails?.productSellingPrice ?? 0;
      return sum + (price * item.productCount);
    });
  }

  /// Calculate payable amount (sum of each product's selling price × count)
  int get totalAmount {
    return cartItems.fold(0, (sum, item) {
      final price = item.productDetails?.productPrice ?? 0;
      return sum + (price * item.productCount);
    });
  }

  /// Total discount = totalAmount - totalPayableAmount
  int get totalDiscount {
    return totalAmount - totalPayableAmount;
  }
}


class CartScreenGlobalStateNotifier
    extends StateNotifier<CartScreenGlobalState> {
  CartScreenGlobalStateNotifier() : super(CartScreenGlobalState());

  @override
  void dispose() {
    super.dispose();
  }

  void callNavigateToSummary(MainScreenGlobalStateNotifier notifier){
    savedCartItems = state.cartItems;
    notifier.callNavigation(ScreenName.orderSummary);
  }


  ///This method is used to get cart list using GET API
  Future<void> callCartListGepAPI(BuildContext context) async {
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        CommonWidgets().showLoadingBar(true, context);
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';
        CartRepository().callCartListApi(
            '${ConstantURLs.cartListUrl}userId=$userID&page=1&limit=100', (
            statusCode, response) async {
          final cartResponse = CartResponse.fromJson(response);
          if (statusCode == 200) {
            Logger().log('###---> Cart List API Response: $response');
            state = state.copyWith(cartItems: cartResponse.data);
          } else {
            Logger().log('###---> Response: $response');
            CodeReusability().showAlert(
                context, cartResponse.message ?? "something Went Wrong");
          }
          CommonWidgets().showLoadingBar(false, context);
        });
      } else {
        CodeReusability().showAlert(
            context, 'Please Check Your Internet Connection');
      }
    });
  }

  ///This method used to call remove oriduct from cart API
  void callRemoveFromCart(BuildContext context, String productID, int index, MainScreenGlobalStateNotifier notifier){
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

        CartRepository().callProductDeleteFromCartApi(ConstantURLs.cartListUrl, requestBody, (statusCode, responseBody) async {
          CartRemoveResponse response = CartRemoveResponse.fromJson(responseBody);
          if (statusCode == 200) {

            Logger().log('###---> Cart Remove API Response: $response');
            // ✅ Remove the item locally using the index
            final updatedList = List<CartItem>.from(state.cartItems);
            updatedList.removeAt(index);
            notifier.callFooterCountGETAPI();

            // ✅ Update the state to refresh UI
            state = state.copyWith(cartItems: updatedList);

          } else {
            Logger().log('###---> Response: $response');
          }
          CommonWidgets().showLoadingBar(false, context);
        });
      } else {
        CodeReusability().showAlert(
            context, 'Please Check Your Internet Connection');
      }
    });
  }


  ///This method used to call Update Count PUT API
  void callUpdateCountAPI(BuildContext context, String productID, int index, int count) {
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        CommonWidgets().showLoadingBar(true, context);
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

        Map<String, dynamic> requestBody = {
          'userId': userID,
          'productId': productID,
          'productCount': count,
        };

        CartRepository().callProductCountUpdateApi(ConstantURLs.cartListUrl, requestBody, (statusCode, responseBody) async {
          CartUpdateResponse response = CartUpdateResponse.fromJson(responseBody);
          if (statusCode == 200) {
            Logger().log('###---> Cart Count Updated API Response: $response');

            // ✅ Update the local list immutably
            final updatedList = List<CartItem>.from(state.cartItems);
            final updatedItem = updatedList[index].copyWith(productCount: count);
            updatedList[index] = updatedItem;

            // ✅ Update the state (this will rebuild UI)
            state = state.copyWith(cartItems: updatedList);

          } else {
            Logger().log('###---> Response: $response');
          }
          CommonWidgets().showLoadingBar(false, context);
        });
      } else {
        CodeReusability().showAlert(
            context, 'Please Check Your Internet Connection');
      }
    });

  }


}



final cartScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    CartScreenGlobalStateNotifier, CartScreenGlobalState>((ref) {
  var notifier = CartScreenGlobalStateNotifier();
  return notifier;
});

