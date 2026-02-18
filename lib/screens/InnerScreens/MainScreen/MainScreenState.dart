import 'package:botaniqmicrogreens/screens/Authentication/CreateAccount/CreateAccountScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/CartScreen/CartScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/EditProfileScreen/EditProfileScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/FamilyLocationScreen/FamilyLocationScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/HomeScreen/HomeScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/InformationScreen/InformationScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/LocationScreen/LocationScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/OrderDetailsScreen/OrderDetailsScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/OrderHistoryScreen/OrderHistoryScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/OrderSummaryScreen/OrderSummaryScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/ProductDetail/ProductDetailScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/ProfileScreen/ProfileScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/WishListScreen/WishListScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:botaniqmicrogreens/API/CommonAPI.dart';
import 'package:botaniqmicrogreens/CodeReusable/CodeReusability.dart';
import 'package:botaniqmicrogreens/constants/Constants.dart';
import '../../../API/APIService.dart';
import '../../../API/CommonModel.dart';
import '../../../Utility/Logger.dart';
import '../../../Utility/PreferencesManager.dart';
import '../ContainerScreen/OrderScreen/OrderScreen.dart';
import '../ContainerScreen/ReelsScreen/ReelsScreen.dart';

class MainScreenGlobalState {
  final ScreenName currentModule;
  final int cartCount;
  final int wishlistCount;
  final int totalCount;

  final ProductDetailStatus? selectedProduct; // 👈 ADD THIS

  MainScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.cartCount = 0,
    this.wishlistCount = 0,
    this.totalCount = 0,
    this.selectedProduct, // 👈 ADD THIS
  });

  MainScreenGlobalState copyWith({
    ScreenName? currentModule,
    int? cartCount,
    int? wishlistCount,
    int? totalCount,
    ProductDetailStatus? selectedProduct, // 👈 ADD THIS
  }) {
    return MainScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      cartCount: cartCount ?? this.cartCount,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      totalCount: totalCount ?? this.totalCount,
      selectedProduct: selectedProduct ?? this.selectedProduct, // 👈 ADD THIS
    );
  }
}


class MainScreenGlobalStateNotifier
    extends StateNotifier<MainScreenGlobalState> {
  MainScreenGlobalStateNotifier() : super(MainScreenGlobalState());

  @override
  void dispose() {
    super.dispose();
  }

  ///MARK: - METHODS
  ///This method used to clear state
  void clearStates() {
    state = MainScreenGlobalState();
  }

  ///This method used to handle footer selection
  void setFooterSelection(int index) {
    ScreenName selectedModule;
    if (index == 1) {
      selectedModule = ScreenName.orders;
    } else if (index == 2) {
      selectedModule = ScreenName.reels;
    } else if (index == 3) {
      selectedModule = ScreenName.cart;
    } else if (index == 4) {
      selectedModule = ScreenName.profile;
    } else if (index == 5) {
      selectedModule = ScreenName.wishList;
    } else {
      selectedModule = ScreenName.home;
    }
    state = state.copyWith(currentModule: selectedModule);
  }

  /// This Method to used to change screenName
  void callNavigation(ScreenName selectedScreen) {
    state = state.copyWith(currentModule: selectedScreen);
  }

  /// This method used to get widget container
  Widget getChildContainer() {
    if (state.currentModule == ScreenName.orders) {
      return const OrderScreen();
    } else if (state.currentModule == ScreenName.reels) {
      return const ReelsScreen();
    } else if (state.currentModule == ScreenName.cart) {
      return const CartScreen();
    } else if (state.currentModule == ScreenName.profile) {
      return const ProfileScreen();
    } else if (state.currentModule == ScreenName.wishList) {
      return const WishListScreen();
    } else if (state.currentModule == ScreenName.productDetail) {
      return ProductDetailScreen();
    } else if (state.currentModule == ScreenName.orderSummary) {
      return const OrderSummaryScreen();
    } else if (state.currentModule == ScreenName.editProfile) {
      return const EditProfileScreen();
    } else if (state.currentModule == ScreenName.createAccount) {
      return const CreateAccountScreen();
    } else if (state.currentModule == ScreenName.orderDetails) {
      return const OrderDetailsScreen();
    } else if (state.currentModule == ScreenName.map) {
      return const LocationScreen();
    } else if (state.currentModule == ScreenName.information){
      return const InformationScreen();
    } else if (state.currentModule == ScreenName.familyAndFriends){
      return const FamilyLocationScreen();
    } else if (state.currentModule == ScreenName.orderHistory){
      return const OrderHistoryScreen();
    } else {
      return const HomeScreen();
    }
  }

  ///This method used to handle back navigation
  Future<void> callBackNavigation(
      BuildContext context, ScreenName module) async {
    if (!context.mounted) return;
    ScreenName onScreen = state.currentModule;

    if (module == ScreenName.cart ||
        module == ScreenName.reels ||
        module == ScreenName.orders ||
        module == ScreenName.profile ||
        module == ScreenName.productDetail) {
      onScreen = ScreenName.home;
    } else if (module == ScreenName.editProfile ||
        module == ScreenName.information ||
    module == ScreenName.familyAndFriends ||
    module == ScreenName.orderHistory) {
      onScreen = ScreenName.profile;
    } else if (module == ScreenName.orderSummary) {
      onScreen = ScreenName.cart;
    } else if (module == ScreenName.orderDetails) {
      onScreen = ScreenName.orders;
    } else if (module == ScreenName.map){
      if (userFrom == ScreenName.editProfile){
        onScreen = ScreenName.editProfile;
      } else if (userFrom == ScreenName.orderSummary){
        onScreen = ScreenName.orderSummary;
      } else if (userFrom == ScreenName.profile){
        onScreen = ScreenName.profile;
      } else {
        onScreen = ScreenName.home;
      }
    } else if (module == ScreenName.wishList){
      if (userFrom == ScreenName.home){
        onScreen = ScreenName.home;
      } else {
        onScreen = ScreenName.profile;
      }
    }

    state = state.copyWith(currentModule: onScreen);
  }


  void callBackNavigationFromLocationScreen(){
    if (userFrom == ScreenName.home){
      callNavigation(ScreenName.home);
    } else if (userFrom == ScreenName.productDetail) {
      callNavigation(ScreenName.productDetail);
    } else if (userFrom == ScreenName.profile) {
      callNavigation(ScreenName.profile);
    } else{
      callNavigation(ScreenName.editProfile);
    }
  }

  ///This method is used to update product details screen UI
  void updateSelectedProduct(ProductDetailStatus product) {
    state = state.copyWith(selectedProduct: product);
  }

  ///This method is used to GET Api for refresh token api response as success
  void backgroundRefreshForAPI(data) {
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        CommonAPI().callUserProfileAPI();
        callFooterCountGETAPI();
      }
    });
  }


  SystemUiOverlayStyle getStatusBarStyleFromColor(ScreenName currentModule) {

    if (currentModule == ScreenName.home ||
    currentModule == ScreenName.wishList ||
    currentModule == ScreenName.productDetail ||
        currentModule == ScreenName.map ||
        currentModule == ScreenName.orders ||
        currentModule == ScreenName.orderDetails ||
        currentModule == ScreenName.cart ||
        currentModule == ScreenName.orderSummary ||
        currentModule == ScreenName.profile ||
        currentModule == ScreenName.privacyPolicy ||
        currentModule == ScreenName.editProfile ||
        currentModule == ScreenName.orderHistory ||
        currentModule == ScreenName.familyAndFriends ||
        currentModule == ScreenName.information){

      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      );
    } else {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      );
    }


  }



  Future <void> callFooterCountGETAPI() async {
    var prefs = await PreferencesManager.getInstance();
    String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';
    await APIService().callCommonGETApi('${ConstantURLs.countUrl}$userID', isAccessTokenNeeded: false,
            (statusCode, response) async {
          if (statusCode == 200) {
            Logger().log('###---> Footer count API Response: $response');
            final userResponse = CountResponse.fromJson(response);
            state = state.copyWith(wishlistCount: userResponse.wishlistCount, cartCount: userResponse.cartCount);
          } else {
            Logger().log('###---> Response: $response');
          }
        });
  }


}

final MainScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    MainScreenGlobalStateNotifier, MainScreenGlobalState>((ref) {
  var notifier = MainScreenGlobalStateNotifier();
  return notifier;
});
