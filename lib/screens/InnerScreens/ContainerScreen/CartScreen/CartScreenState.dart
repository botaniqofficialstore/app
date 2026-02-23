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
  final bool isProfileCompleted;
  final String profileIncompleteMessage;
  final bool isDeliveryAddress;

  CartScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.cartItems = const [],
    this.isLoading = true,
    this.isProfileCompleted = true,
    this.profileIncompleteMessage = '',
    this.isDeliveryAddress = false,
  });

  CartScreenGlobalState copyWith({
    ScreenName? currentModule,
    List<CartItem>? cartItems,
    bool? isLoading,
    bool? isProfileCompleted,
    String? profileIncompleteMessage,
    bool? isDeliveryAddress,
  }) {
    return CartScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      profileIncompleteMessage: profileIncompleteMessage ?? this.profileIncompleteMessage,
      isDeliveryAddress: isDeliveryAddress ?? this.isDeliveryAddress,
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

  void calNavigationToEditProfile(MainScreenGlobalStateNotifier notifier){
    notifier.callNavigation(ScreenName.editProfile);
  }

  void updateCheckoutStatus(PreferencesManager prefs){
    String mobile = prefs.getStringValue(PreferenceKeys.userMobileNumber) ?? '';
    String address = prefs.getStringValue(PreferenceKeys.userAddress) ?? '';


    String message = '';
    bool deliveryAddress = true;
    if (mobile.isEmpty && address.isEmpty){
      message = 'Please update your mobile number and delivery location to continue shopping';
      deliveryAddress = false;
    } else if (mobile.isEmpty && address.isNotEmpty){
      message = 'Please update your mobile number to continue shopping';
    } else if (mobile.isNotEmpty && address.isEmpty){
      message = 'Please update your delivery location to continue shopping';
      deliveryAddress = false;
    }

    state = state.copyWith(
        profileIncompleteMessage: message,
        isProfileCompleted: message.isEmpty,
      isDeliveryAddress: deliveryAddress
    );
  Logger().log('### message: $message, isProfileCompleted: ${state.isProfileCompleted}');

  }

  /// 🧩 Get Cart List (with shimmer stop logic)
  Future<void> callCartListGepAPI(BuildContext context) async {
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        // ✅ Start shimmer
        state = state.copyWith(isLoading: true);

        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';
        updateCheckoutStatus(prefs);

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
  /// 🗑️ Optimized Remove (Background Processing)
  void callRemoveFromCart(BuildContext context, String productID, int index,
      MainScreenGlobalStateNotifier notifier, {int retryCount = 0}) {

    final oldItems = [...state.cartItems];
    final itemToRemove = oldItems[index];

    // 1. Remove from UI immediately
    final updatedList = List<CartItem>.from(state.cartItems);
    updatedList.removeAt(index);
    state = state.copyWith(cartItems: updatedList);

    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

        CartRepository().callProductDeleteFromCartApi(
            ConstantURLs.cartListUrl,
            {'userId': userID, 'productId': productID},
                (statusCode, responseBody) async {
              if (statusCode == 200) {
                notifier.callFooterCountGETAPI(); // Update badge count
              } else {
                // 2. Retry Logic
                if (retryCount < 2) {
                  callRemoveFromCart(context, productID, index, notifier, retryCount: retryCount + 1);
                } else {
                  // Revert UI on permanent failure
                  state = state.copyWith(cartItems: oldItems);
                  CodeReusability().showAlert(context, "Could not remove item. Please try again.");
                }
              }
            }
        );
      } else {
        state = state.copyWith(cartItems: oldItems);
        CodeReusability().showAlert(context, 'No Internet Connection');
      }
    });
  }

  /// 🔄 Update Count
  /// 🔄 Optimized Update Count (Optimistic UI)
  void callUpdateCountAPI(
      BuildContext context, String productID, int index, int count, {int retryCount = 0}) {

    // 1. Store the old count in case we need to revert on failure
    final oldItems = [...state.cartItems];
    final oldCount = oldItems[index].productCount;

    // 2. Update UI Immediately (Optimistic Update)
    final updatedList = List<CartItem>.from(state.cartItems);
    updatedList[index] = updatedList[index].copyWith(productCount: count);
    state = state.copyWith(cartItems: updatedList);

    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        // No showLoadingBar here! We let it run in the background.
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

        Map<String, dynamic> requestBody = {
          'userId': userID,
          'productId': productID,
          'productCount': count,
        };

        CartRepository().callProductCountUpdateApi(
            ConstantURLs.cartListUrl,
            requestBody,
                (statusCode, responseBody) async {
              if (statusCode != 200) {
                // 3. Handle Failure: Retry logic
                if (retryCount < 2) {
                  Logger().log('### API Failed, retrying... Attempt: ${retryCount + 1}');
                  callUpdateCountAPI(context, productID, index, count, retryCount: retryCount + 1);
                } else {
                  // Revert to old state if all retries fail
                  state = state.copyWith(cartItems: oldItems);
                  CodeReusability().showAlert(context, 'Failed to update quantity. Please try again.');
                }
              }
            }
        );
      } else {
        // Revert immediately if no internet
        state = state.copyWith(cartItems: oldItems);
        CodeReusability().showAlert(context, 'No Internet Connection');
      }
    });
  }
}

final cartScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    CartScreenGlobalStateNotifier, CartScreenGlobalState>((ref) {
  var notifier = CartScreenGlobalStateNotifier();
  return notifier;
});
