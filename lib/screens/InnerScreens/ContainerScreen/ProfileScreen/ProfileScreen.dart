import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../Authentication/LoginScreen/LoginScreen.dart';
import '../../../commonViews/LogoutPopup.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'ProfileScreenState.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends ConsumerState<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final profilrScreenNotifier = ref.read(ProfileScreenGlobalStateProvider.notifier);
      profilrScreenNotifier.updateUserDetails();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.withAlpha(30),

      body: profileView(context),
    );
  }


  ///Profile Screen
Widget profileView(BuildContext context) {
  final screenState = ref.watch(ProfileScreenGlobalStateProvider);
  final screenNotifier = ref.read(ProfileScreenGlobalStateProvider.notifier);
  final mainScreenNotifier = ref.read(MainScreenGlobalStateProvider.notifier);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Container(
        padding: EdgeInsets.symmetric(vertical: 8.dp, horizontal: 5.dp),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2.dp, offset: const Offset(0, 1))],
        ),
        child: Stack(
          children: [
            CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                child: Padding(
                  padding: EdgeInsets.only(top: 5.dp),
                  child: Image.asset(
                    objConstantAssest.backIcon,
                    height: 20.dp,
                    color: objConstantColor.navyBlue,
                  ),
                ),
                onPressed: () {
                  mainScreenNotifier.callNavigation(ScreenName.home);
                }),


            Align(
              alignment: Alignment.center,
              child: objCommonWidgets.customText(
                context,
                'Account',
                18,
                objConstantColor.navyBlue,
                objConstantFonts.montserratSemiBold,
              ),
            ),


          ],
        )
      ),

      Expanded(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [

              SizedBox(height: 10.dp),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2.dp, offset: const Offset(0, 1))],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 5.dp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.dp),
                      objCommonWidgets.customText(context, 'Personal Details', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
                      SizedBox(height: 7.dp),

                      optionCard(context, 'My Profile', Icons.person_3_outlined, Colors.blueAccent,(){
                        mainScreenNotifier.callNavigation(ScreenName.editProfile);
                      }),
                      optionCard(context, 'Delivery Location', Icons.location_on_outlined, Colors.blueAccent,(){
                        userFrom = ScreenName.profile;
                        mainScreenNotifier.callNavigation(ScreenName.map);
                      }),

                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.dp),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2.dp, offset: const Offset(0, 1))],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 5.dp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.dp),
                      objCommonWidgets.customText(context, 'Shopping Details', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
                      SizedBox(height: 7.dp),

                      optionCard(context, 'My Orders', Icons.shopping_bag_outlined, Colors.blueAccent,(){
                        mainScreenNotifier.callNavigation(ScreenName.orders);
                      }),
                      optionCard(context, 'Wish List', Icons.favorite_border_outlined, Colors.blueAccent,(){
                        mainScreenNotifier.callNavigation(ScreenName.wishList);
                      }),
                      optionCard(context, 'Cart List', Icons.shopping_cart_outlined, Colors.blueAccent,(){
                        mainScreenNotifier.callNavigation(ScreenName.cart);
                      }),

                    ],
                  ),
                ),
              ),


              SizedBox(height: 10.dp),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2.dp, offset: const Offset(0, 1))],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 5.dp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.dp),
                      objCommonWidgets.customText(context, 'Legal & Information', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
                      SizedBox(height: 7.dp),


                      optionCard(context, 'Privacy Policy', Icons.privacy_tip_outlined, Colors.blueAccent,(){
                        selectedLegalInformation = ScreenName.privacyPolicy;
                        mainScreenNotifier.callNavigation(ScreenName.information);
                      }),
                      optionCard(context, 'Terms & Conditions', Icons.description_outlined, Colors.blueAccent,(){
                        selectedLegalInformation = ScreenName.termsAndCondition;
                        mainScreenNotifier.callNavigation(ScreenName.information);
                      }),
                      optionCard(context, 'Refund Policy', Icons.currency_rupee, Colors.blueAccent,(){
                        selectedLegalInformation = ScreenName.refundPolicy;
                        mainScreenNotifier.callNavigation(ScreenName.information);
                      }),
                      optionCard(context, 'Shipping Policy', Icons.local_shipping_outlined, Colors.blueAccent,(){
                        selectedLegalInformation = ScreenName.shippingPolicy;
                        mainScreenNotifier.callNavigation(ScreenName.information);
                      }),
                      optionCard(context, 'About Us', Icons.info_outline_rounded, Colors.blueAccent,(){
                        selectedLegalInformation = ScreenName.aboutUS;
                        mainScreenNotifier.callNavigation(ScreenName.information);
                      }),

                    ],
                  ),
                ),
              ),


              SizedBox(height: 10.dp),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2.dp, offset: const Offset(0, 1))],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 5.dp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.dp),
                      objCommonWidgets.customText(context, 'Support', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
                      SizedBox(height: 7.dp),

                      optionCard(context, 'Customer Care', Icons.headset_mic, Colors.blueAccent,(){
                        screenNotifier.openCustomerSupportEmail();
                      }),


                    ],
                  ),
                ),
              ),


              SizedBox(height: 10.dp),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2.dp, offset: const Offset(0, 1))],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 5.dp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      optionCard(context, 'Log Out', Icons.power_settings_new_outlined, Colors.red,(){
                        PreferencesManager.getInstance().then((pref) {
                          pref.setBooleanValue(PreferenceKeys.isDialogOpened, true);
                          LogoutPopup.showLogoutPopup(
                            context: context,
                            onConfirm: () {
                              pref.setBooleanValue(PreferenceKeys.isDialogOpened, false);
                              screenNotifier.callLogoutAPI(context);
                            },
                          );
                        });
                      }, isLogout: true),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.dp),

            ],
          ),
        ),
      )









    ],
  );
}


  Widget optionCard(
      BuildContext context,
      String title,
      IconData image,
      Color colour,
      VoidCallback onClick, {
        bool isLogout = false,
      }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 0),
      onPressed: onClick,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.dp),
        child: Row(
          mainAxisAlignment:
          isLogout ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(image, color: colour, size: 17.9.dp),
            SizedBox(width: 5.dp),
            objCommonWidgets.customText(
              context,
              title,
              14.50,
              colour,
              objConstantFonts.montserratMedium,
            ),

            if (!isLogout) ...[
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: colour,
                size: 17.9.dp,
              ),
            ],
          ],
        ),
      ),
    );
  }


}
