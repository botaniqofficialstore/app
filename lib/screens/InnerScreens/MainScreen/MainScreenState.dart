
import 'package:botaniqmicrogreens/screens/Authentication/CreateAccount/CreateAccountScreen.dart';
import 'package:botaniqmicrogreens/screens/Authentication/ForgotPasswordScreen/ForgotPasswordScreen.dart';
import 'package:botaniqmicrogreens/screens/Authentication/LoginScreen/LoginScreen.dart';
import 'package:botaniqmicrogreens/screens/Authentication/OtpScreen/OtpScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/CartScreen/CartScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/EditProfileScreen/EditProfileScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/HomeScreen/HomeScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/OrderDetailsScreen/OrderDetailsScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/OrderSummaryScreen/OrderSummaryScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/ProductDetail/ProductDetailScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/ProfileScreen/ProfileScreen.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/WishListScreen/WishListScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../API/CommonAPI.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../constants/Constants.dart';
import '../../commonViews/LocationPickerScreen.dart';
import '../ContainerScreen/OrderScreen/OrderScreen.dart';
import '../ContainerScreen/ReelsScreen/ReelsScreen.dart';


class MainScreenGlobalState {
  final ScreenName currentModule;

  MainScreenGlobalState({
    this.currentModule = ScreenName.home,
  });

  MainScreenGlobalState copyWith({
    ScreenName? currentModule,
  }) {
    return MainScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
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
  ///
  /// [index] - This param used to pass the selected index
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
  ///
  /// [selectedScreen] - This param used to pass the selected ScreenName
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
      return const ProfileScreen(); //const LocationPickerScreen();//
    } else if (state.currentModule == ScreenName.wishList) {
      return const WishListScreen();
    } else if (state.currentModule == ScreenName.productDetail) {
      return  ProductDetailScreen();
    } else if (state.currentModule == ScreenName.orderSummary) {
      return  const OrderSummaryScreen();
    } else if (state.currentModule == ScreenName.editProfile) {
      return const EditProfileScreen();
    } else if (state.currentModule == ScreenName.login){
      return const LoginScreen();
    } else if (state.currentModule == ScreenName.otp){
      return const OtpScreen();
    } else if (state.currentModule == ScreenName.forgotPassword){
      return const ForgotPasswordScreen();
    } else if (state.currentModule == ScreenName.createAccount){
      return const CreateAccountScreen();
    } else if (state.currentModule == ScreenName.orderDetails){
      return const OrderDetailsScreen();
    } else {
      return const HomeScreen();
    }
  }

  ///This method used to handle back navigation
  ///
  /// [module] - This param used to pass the current module
  Future<void> callBackNavigation(BuildContext context, ScreenName module) async {
    if (!context.mounted) return;
    ScreenName onScreen = state.currentModule;

    if (module == ScreenName.cart ||
        module == ScreenName.reels ||
        module == ScreenName.orders ||
        module == ScreenName.profile ||
        module == ScreenName.productDetail ||
        module == ScreenName.wishList ||
        module == ScreenName.login) {
      onScreen = ScreenName.home;
    } else if (module == ScreenName.editProfile){
      onScreen = ScreenName.profile;
    } else if (module == ScreenName.orderSummary){
      onScreen = ScreenName.cart;
    }

    state = state.copyWith(currentModule: onScreen);
  }



  ///This method is used to GET Api for refresh token api response as success
  void backgroundRefreshForAPI(data) {
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        CommonAPI().callUserProfileAPI();
      }
    });
  }



}



final MainScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    MainScreenGlobalStateNotifier, MainScreenGlobalState>((ref) {
  var notifier = MainScreenGlobalStateNotifier();
  return notifier;
});

