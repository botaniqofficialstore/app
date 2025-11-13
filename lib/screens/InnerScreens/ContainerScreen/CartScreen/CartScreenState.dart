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
  final bool isLoading; // ✅ Added shimmer control flag

  CartScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.cartItems = const [],
    this.isLoading = true,
  });

  CartScreenGlobalState copyWith({
    ScreenName? currentModule,
    List<CartItem>? cartItems,
    bool? isLoading,
  }) {
    return CartScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Calculate payable amount (sum of each product's selling price × count)
  int get totalPayableAmount {
    return cartItems.fold(0, (sum, item) {
      final price = item.productDetails?.productSellingPrice ?? 0;
      return sum + (price * item.productCount);
    });
  }

  int get totalAmount {
    return cartItems.fold(0, (sum, item) {
      final price = item.productDetails?.productPrice ?? 0;
      return sum + (price * item.productCount);
    });
  }

  int get totalDiscount {
    return totalAmount - totalPayableAmount;
  }
}

class CartScreenGlobalStateNotifier extends StateNotifier<CartScreenGlobalState> {
  CartScreenGlobalStateNotifier() : super(CartScreenGlobalState());

  @override
  void dispose() {
    super.dispose();
  }

  void callNavigateToSummary(MainScreenGlobalStateNotifier notifier) {
    savedCartItems = state.cartItems;
    notifier.callNavigation(ScreenName.orderSummary);
  }

  /// 🧩 Get Cart List (with shimmer stop logic)
  Future<void> callCartListGepAPI(BuildContext context) async {
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        // ✅ Start shimmer
        state = state.copyWith(isLoading: true);

        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

        CartRepository().callCartListApi(
          '${ConstantURLs.cartListUrl}userId=$userID&page=1&limit=100',
              (statusCode, response) async {
            try {
              final cartResponse = CartResponse.fromJson(response);
              Logger().log('###---> Cart List API Response: $response');

              if (statusCode == 200) {
                // ✅ Even if list is empty, shimmer must stop
                state = state.copyWith(
                  cartItems: cartResponse.data,
                  isLoading: false,
                );
              } else {
                CodeReusability().showAlert(
                    context, cartResponse.message ?? "Something went wrong");
                state = state.copyWith(isLoading: false);
              }
            } catch (e) {
              Logger().log('###---> Exception: $e');
              state = state.copyWith(isLoading: false);
            }
          },
        );
      } else {
        CodeReusability()
            .showAlert(context, 'Please Check Your Internet Connection');
        state = state.copyWith(isLoading: false); // ✅ Stop shimmer on error
      }
    });
  }

  /// 🗑️ Remove Product from Cart
  void callRemoveFromCart(BuildContext context, String productID, int index,
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
        };

        CartRepository().callProductDeleteFromCartApi(
            ConstantURLs.cartListUrl, requestBody,
                (statusCode, responseBody) async {
              CartRemoveResponse response =
              CartRemoveResponse.fromJson(responseBody);
              if (statusCode == 200) {
                final updatedList = List<CartItem>.from(state.cartItems);
                updatedList.removeAt(index);
                notifier.callFooterCountGETAPI();

                state = state.copyWith(cartItems: updatedList);
              } else {
                Logger().log('###---> Response: $response');
              }
              CommonWidgets().showLoadingBar(false, context);
            });
      } else {
        CodeReusability()
            .showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }

  /// 🔄 Update Count
  void callUpdateCountAPI(
      BuildContext context, String productID, int index, int count) {
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

        CartRepository().callProductCountUpdateApi(
            ConstantURLs.cartListUrl, requestBody,
                (statusCode, responseBody) async {
              CartUpdateResponse response =
              CartUpdateResponse.fromJson(responseBody);
              if (statusCode == 200) {
                final updatedList = List<CartItem>.from(state.cartItems);
                final updatedItem =
                updatedList[index].copyWith(productCount: count);
                updatedList[index] = updatedItem;

                state = state.copyWith(cartItems: updatedList);
              }
              CommonWidgets().showLoadingBar(false, context);
            });
      } else {
        CodeReusability()
            .showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }
}

final cartScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    CartScreenGlobalStateNotifier, CartScreenGlobalState>((ref) {
  var notifier = CartScreenGlobalStateNotifier();
  return notifier;
});
