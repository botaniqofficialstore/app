import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../Utility/PreferencesManager.dart';
import '../../../constants/Constants.dart';
import 'package:botaniqmicrogreens/screens/InnerScreens/MainScreen/MainScreenState.dart';


class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //Fetch count data when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(MainScreenGlobalStateProvider.notifier).backgroundRefreshForAPI(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userScreenState = ref.watch(MainScreenGlobalStateProvider);
    var userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: userScreenNotifier.getStatusBarStyleFromColor(userScreenState.currentModule),
      child: PopScope(
        canPop: false, // 🔥 We fully control back navigation
        onPopInvokedWithResult: (didPop, dynamic) {
          if (didPop) return;
          _handleBack(context);
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: objConstantColor.white,

              body: Center(
                child: userScreenNotifier.getChildContainer(),
              ),

              // UPDATED: Footer shows live cart & wishlist count
              bottomNavigationBar: ((userScreenState.currentModule != ScreenName.reels))

                  ? UserFooterView(
                currentModule: userScreenState.currentModule,
                cartCount: userScreenState.cartCount,
                wishlistCount: userScreenState.wishlistCount,
                selectedFooterIndex: (index) {
                  userScreenNotifier.setFooterSelection(index);
                },
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }


  /// 🔥 SAFE BACK HANDLER
  Future<void> _handleBack(BuildContext context) async {
    if (!context.mounted) return;

    var state = ref.watch(MainScreenGlobalStateProvider);
    var userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    PreferencesManager.getInstance().then((prefs) {
      if (prefs.getBooleanValue(PreferenceKeys.isDialogOpened) == true) {
        return false;
      }
      if (_scaffoldKey.currentState?.isDrawerOpen ?? false == true) {
        _scaffoldKey.currentState?.closeDrawer();
        return false;
      } else if (prefs.getBooleanValue(PreferenceKeys.isLoadingBarStarted) ==
          true) {
        return false;
      } else {
        userScreenNotifier.callBackNavigation(context, state.currentModule);
      }
    });
    return;
  }

}

class UserFooterView extends ConsumerStatefulWidget {
  final ScreenName currentModule;
  final int cartCount;
  final int wishlistCount;
  final Function(int) selectedFooterIndex;

  const UserFooterView({
    required this.currentModule,
    required this.selectedFooterIndex,
    this.cartCount = 0,
    this.wishlistCount = 0,
    super.key,
  });

  @override
  UserFooterViewState createState() => UserFooterViewState();
}

class UserFooterViewState extends ConsumerState<UserFooterView> {
  final List<String> inactiveIcons = [
    objConstantAssest.homeIcon,
    objConstantAssest.orderIcon,
    objConstantAssest.reelsIcon,
    objConstantAssest.cartIcon,
    objConstantAssest.profileIcon,
  ];

  final List<String> activeIcons = [
    objConstantAssest.homeSelectedIcon,
    objConstantAssest.orderSelectedIcon,
    objConstantAssest.reelsSelectedIcon,
    objConstantAssest.cartSelectedIcon,
    objConstantAssest.profileSelectedIcon,
  ];

  final List<String> modules = [
    'Home',
    'Orders',
    'Reels',
    'Cart',
    'Account',
  ];

  int get currentIndex {
    if (widget.currentModule == ScreenName.home) return 0;
    if (widget.currentModule == ScreenName.orders) return 1;
    if (widget.currentModule == ScreenName.reels) return 2;
    if (widget.currentModule == ScreenName.cart) return 3;
    if (widget.currentModule == ScreenName.profile ||
        widget.currentModule == ScreenName.editProfile) {
      return 4;
    }
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 20.dp;
    double tabWidth = screenWidth / inactiveIcons.length;
    double indicatorWidth = 22.5.dp;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.dp),
        decoration: BoxDecoration(
          color: objConstantColor.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 1,
              offset: const Offset(0, -2), // push shadow upward
            ),
          ],
        ),

        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.currentModule == ScreenName.home ||
                widget.currentModule == ScreenName.orders ||
                widget.currentModule == ScreenName.reels ||
                widget.currentModule == ScreenName.cart ||
                widget.currentModule == ScreenName.profile)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: 6.dp,
                left: currentIndex * tabWidth + (tabWidth - indicatorWidth) / 2,
                child: Container(
                  height: 4.dp,
                  width: indicatorWidth,
                  decoration: BoxDecoration(
                    color: objConstantColor.black,
                    borderRadius: BorderRadius.circular(20.dp),
                  ),
                ),
              ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.dp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(inactiveIcons.length, (index) {
                    final isSelected = currentIndex == index;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [

                        CupertinoButton(
                          onPressed: () => widget.selectedFooterIndex(index),
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              SizedBox(height: 5.dp),
                              Image.asset(
                                isSelected ? activeIcons[index] : inactiveIcons[index],
                                height: 20.dp,
                                width: 20.dp,
                                color: Colors.black,
                              ),
                              SizedBox(height: 2.5.dp),
                              objCommonWidgets.customText(
                                  context,
                                  modules[index],
                                  10,
                                  objConstantColor.navyBlue,
                                  objConstantFonts.montserratSemiBold
                              ),
                              SizedBox(height: 2.5.dp),
                            ],
                          ),
                        ),

                        //Badge for Cart
                        if (index == 3 && widget.cartCount > 0)
                          Positioned(
                            right: 1.dp,
                            top: 2.dp,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0.8.dp, horizontal: 5.dp),
                              decoration: BoxDecoration(
                                color: objConstantColor.redd,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${widget.cartCount}',
                                style: TextStyle(
                                  fontSize: 10.dp,
                                  color: Colors.white,
                                  fontFamily: objConstantFonts.montserratBold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
                SizedBox(height: 5.dp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
