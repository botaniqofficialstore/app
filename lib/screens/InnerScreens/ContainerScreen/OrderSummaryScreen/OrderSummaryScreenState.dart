import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';
import '../../../commonViews/FamilyLocationEditView/FamilyLocationEditView.dart';
import '../../../commonViews/NotificationService.dart';
import '../../../commonViews/OrderPlacedSuccessPopup.dart';
import '../../MainScreen/MainScreenState.dart';
import '../CartScreen/CartModel.dart';
import '../FamilyLocationScreen/FamilyLocationScreenState.dart';
import '../OrderDetailsScreen/OrderRepository.dart';
import 'OrderModel.dart';

class OrderSummaryScreenGlobalState {
  final ScreenName currentModule;
  final List<CartItem> cartItems;
  final String userName;
  final String mobileNumber;
  final String email;
  final String address;
  final List<FamilyMemberLocation> familyMembers;
  final String selectedMember;
  final int pageIndex;
  final List<PaymentTypes> paymentTypes;
  final bool isCod;
  final bool isOnlinePay;
  final bool isPriceViewExpanded;

  OrderSummaryScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.cartItems = const [],
    this.userName = '',
    this.mobileNumber = '',
    this.email = '',
    this.address = '',
    this.familyMembers = const [],
    this.selectedMember = '',
    this.pageIndex = 0,
    this.paymentTypes = const [],
    this.isCod = false,
    this.isOnlinePay = false,
    this.isPriceViewExpanded = false
  });

  OrderSummaryScreenGlobalState copyWith({
    ScreenName? currentModule,
    List<CartItem>? cartItems,
    String? userName,
    String? mobileNumber,
    String? email,
    String? address,
    List<FamilyMemberLocation>? familyMembers,
    String? selectedMember,
    int? pageIndex,
    List<PaymentTypes>? paymentTypes,
    bool? isCod,
    bool? isOnlinePay,
    bool? isPriceViewExpanded
  }) {
    return OrderSummaryScreenGlobalState(
        currentModule: currentModule ?? this.currentModule,
        cartItems: cartItems ?? this.cartItems,
        userName: userName ?? this.userName,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        email: email ?? this.email,
        address: address ?? this.address,
      familyMembers: familyMembers ?? this.familyMembers,
        selectedMember: selectedMember ?? this.selectedMember,
      pageIndex: pageIndex ?? this.pageIndex,
      paymentTypes: paymentTypes ?? this.paymentTypes,
      isCod: isCod ?? this.isCod,
      isOnlinePay: isOnlinePay ?? this.isOnlinePay,
      isPriceViewExpanded: isPriceViewExpanded ?? this.isPriceViewExpanded,
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
  OrderSummaryScreenGlobalStateNotifier() : super(OrderSummaryScreenGlobalState(
    familyMembers: const [
      FamilyMemberLocation(
        name: 'Ragesh Pillai',
        mobileNumber: '9447012345',
        address: 'Skyline Ivy, Panampilly Nagar, Kochi, Kerala, 678451',
      ),
      FamilyMemberLocation(
        name: 'Anjali Menon',
        mobileNumber: '7012345678',
        address: 'TC 15/12, Kowdiar, Thiruvananthapuram, Kerala, 678450',
      ),
    ],
    selectedMember: '',
    pageIndex: 0,
      paymentTypes: [
        PaymentTypes(
          name: 'Gpay',
          icon: objConstantAssest.gPay,
          description: 'Pay securely with Google Pay • Save up to ₹50 on your first order',
          isSelected: false
        ),
        PaymentTypes(
          name: 'PhonePe',
          icon: objConstantAssest.phonePe,
          description: 'Fast UPI payments • Get cashback up to ₹75 on eligible orders',
          isSelected: false
        ),
        PaymentTypes(
          name: 'Paytm',
          icon: objConstantAssest.payTm,
          description: 'Quick & trusted payments • Save up to ₹100 with Paytm offers',
          isSelected: false
        ),
      ],

      isCod: false,
      isOnlinePay: false,
      isPriceViewExpanded: false
  ));


  void updateIsCod(bool isCod) {
    state = state.copyWith(isCod: isCod, isOnlinePay: !isCod);
  }

  void updateIsOnlinePay(bool isOnlinePay) {
    state = state.copyWith(isOnlinePay: isOnlinePay, isCod: !isOnlinePay);
  }

  void updateSelectedDelivery(String contact){
    state = state.copyWith(selectedMember: contact);
  }

  void updatePriceView(bool isExpand){
    state = state.copyWith(isPriceViewExpanded: isExpand);
  }

  void updatePageIndex(int step){
    state = state.copyWith(pageIndex: step);
  }

  void callAddMemberView(BuildContext context, String name, String phone, String address) async {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => FamilyLocationScreen(name: name, phone: phone, address: address),
      ),
    );
  }

  void selectPaymentByIndex(int index) {
    final updatedList = state.paymentTypes.asMap().entries.map((entry) {
      int i = entry.key;
      PaymentTypes item = entry.value;

      return item.copyWith(
        isSelected: i == index,
      );
    }).toList();

    state = state.copyWith(paymentTypes: updatedList);
  }

  void clearAllPaymentSelection() {
    final updatedList = state.paymentTypes.map((item) {
      return item.copyWith(isSelected: false);
    }).toList();

    state = state.copyWith(paymentTypes: updatedList);
  }



  ///This method is used to update Cart List & User Info
  Future<void> updateCartListAndUserInfo() async {
    final manager = await PreferencesManager.getInstance();
    final userFirstName = manager.getStringValue(PreferenceKeys.userFirstName);
    final userLastName = manager.getStringValue(PreferenceKeys.userLastName);
    final userEmailID = manager.getStringValue(PreferenceKeys.userEmailID);
    final userMobileNumber = manager.getStringValue(PreferenceKeys.userMobileNumber);
    final userAddress = exactAddress;

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



final orderSummaryScreenStateProvider = StateNotifierProvider.autoDispose<
    OrderSummaryScreenGlobalStateNotifier, OrderSummaryScreenGlobalState>((ref) {
  var notifier = OrderSummaryScreenGlobalStateNotifier();
  return notifier;
});


class PaymentTypes {
  final String name;
  final String icon;
  final String description;
  final bool isSelected;

  PaymentTypes({
    required this.name,
    required this.icon,
    required this.description,
    this.isSelected = false,
  });

  PaymentTypes copyWith({
    String? name,
    String? icon,
    String? description,
    bool? isSelected,
  }) {
    return PaymentTypes(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

