import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Utility/Logger.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';
import '../../../commonViews/NotificationService.dart';
import '../../../commonViews/OrderPlacedSuccessPopup.dart';
import '../../MainScreen/MainScreenState.dart';
import '../CartScreen/CartModel.dart';
import '../OrderDetailsScreen/OrderRepository.dart';
import 'OrderModel.dart';

class OrderSummaryScreenGlobalState {
  final ScreenName currentModule;
  final List<CartItem> cartItems;
  final String userName;
  final String mobileNumber;
  final String email;
  final String address;

  OrderSummaryScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.cartItems = const [],
    this.userName = '',
    this.mobileNumber = '',
    this.email = '',
    this.address = ''
  });

  OrderSummaryScreenGlobalState copyWith({
    ScreenName? currentModule,
    List<CartItem>? cartItems,
    String? userName,
    String? mobileNumber,
    String? email,
    String? address
  }) {
    return OrderSummaryScreenGlobalState(
        currentModule: currentModule ?? this.currentModule,
        cartItems: cartItems ?? this.cartItems,
        userName: userName ?? this.userName,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        email: email ?? this.email,
        address: address ?? this.address
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

class OrderSummaryScreenGlobalStateNotifier
    extends StateNotifier<OrderSummaryScreenGlobalState> {
  OrderSummaryScreenGlobalStateNotifier() : super(OrderSummaryScreenGlobalState());

  @override
  void dispose() {
    super.dispose();
  }

  ///This method is used to update Cart List & User Info
  Future<void> updateCartListAndUserInfo() async {
    final manager = await PreferencesManager.getInstance();
    final userFirstName = manager.getStringValue(PreferenceKeys.userFirstName);
    final userLastName = manager.getStringValue(PreferenceKeys.userLastName);
    final userEmailID = manager.getStringValue(PreferenceKeys.userEmailID);
    final userMobileNumber = manager.getStringValue(PreferenceKeys.userMobileNumber);
    final userAddress = manager.getStringValue(PreferenceKeys.userAddress);

    state = state.copyWith(
        cartItems: savedCartItems,
        userName: '$userFirstName $userLastName',
      email: userEmailID,
      mobileNumber: userMobileNumber,
      address: userAddress
    );
  }

  //MARK:- Common Views
  ///
  ///This method used to call Order success popup
  //////
  void callOrderSuccessPopup(BuildContext context) {
    if (!context.mounted) return;
    OrderPlacedSuccessPopup.showOrderConfirmationPopup(
        context, onDonePressed: () {
      Navigator.pop(context);
    });
  }

  ///This method is used to call Place Order API
  void callPlaceOrderAPI(BuildContext context, MainScreenGlobalStateNotifier notifier) {
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        CommonWidgets().showLoadingBar(true, context);
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';



        // ✅ Build dynamic products array from cartItems
        List<Map<String, dynamic>> products = state.cartItems.map((item) {
          return {
            "productId": item.productId,
            "productCount": item.productCount,
          };
        }).toList();

        // ✅ Final request body
        Map<String, dynamic> requestBody = {
          "userId": userID,
          "products": products,
        };

        OrderRepository().callPlaceOrderApi(ConstantURLs.placeOrderUrl, requestBody, (statusCode, responseBody) async {
          final orderResponse = OrderResponse.fromJson(responseBody);


          if (statusCode == 200 || statusCode == 201) {

            callOrderSuccessPopup(context);

            // ✅ Trigger local notification
            await NotificationService.showNotification(
              title: "Order Placed Successfully 🎉",
              body: "Your fresh microgreens will be delivered soon 🌱",
            );
            notifier.callNavigation(ScreenName.orders);

          } else {
            CodeReusability().showAlert(context, orderResponse.message ?? "something Went Wrong");
          }

          CommonWidgets().showLoadingBar(false, context);

        });


      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }



}



final OrderSummaryScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    OrderSummaryScreenGlobalStateNotifier, OrderSummaryScreenGlobalState>((ref) {
  var notifier = OrderSummaryScreenGlobalStateNotifier();
  return notifier;
});

