import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../Utility/PreferencesManager.dart';
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
      final profileScreenNotifier = ref.read(ProfileScreenGlobalStateProvider.notifier);
      profileScreenNotifier.updateUserDetails();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: profileView(context),
    );
  }


  ///Profile Screen
  Widget profileView(BuildContext context) {
    final screenNotifier =
    ref.read(ProfileScreenGlobalStateProvider.notifier);
    final mainScreenNotifier =
    ref.read(MainScreenGlobalStateProvider.notifier);
    var userScreenState = ref.watch(ProfileScreenGlobalStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 5.dp, right: 10.dp, left: 10.dp, bottom: 8.dp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [


                  CupertinoButton(padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.black,
                        size: 18.dp),
                    onPressed: () {
                      mainScreenNotifier.callNavigation(ScreenName.home);
                    },
                  ),

                  SizedBox(width: 5.dp),

                  objCommonWidgets.customText(
                    context,
                    'Account',
                    15,
                    objConstantColor.navyBlue,
                    objConstantFonts.montserratSemiBold,
                  ),

                  const Spacer(),

                  CupertinoButton(
                      minimumSize: const Size(0, 0),
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          objCommonWidgets.customText(
                            context,
                            'Logout',
                            12.5,
                            Colors.red,
                            objConstantFonts.montserratSemiBold,
                          ),
                          SizedBox(width: 2.5.dp),
                          Icon(Icons.power_settings_new_outlined, color: Colors.red, size: 19.9.dp),
                        ],
                      ),
                      onPressed: (){
                        PreferencesManager.getInstance().then((pref) {
                          pref.setBooleanValue(
                              PreferenceKeys.isDialogOpened, true);
                          LogoutPopup.showLogoutPopup(
                            context: context,
                            onConfirm: () {
                              pref.setBooleanValue(
                                  PreferenceKeys.isDialogOpened, false);
                              screenNotifier.callLogoutAPI(context);
                            },
                          );
                        });
                      }),

                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    /// PROFILE + LOCATION
                   /* Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.dp),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15.dp, horizontal: 10.dp),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.dp),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _bigCard(
                                    icon: Icons.person,
                                    title: 'Profile',
                                    subtitle: 'View & edit details',
                                    onTap: () {
                                      mainScreenNotifier.callNavigation(ScreenName.editProfile);
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.dp),
                                Expanded(
                                  child: _bigCard(
                                    icon: Icons.location_on,
                                    title: 'Location',
                                    subtitle: 'Delivery address',
                                    onTap: () {
                                      userFrom = ScreenName.profile;
                                      mainScreenNotifier.callNavigation(ScreenName.map);
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.dp),

                            /// SUPPORT
                            _supportCard(
                              context,
                              onTap: () {
                                screenNotifier.openCustomerSupportEmail();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),*/

                    SizedBox(height: 10.dp),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.dp),
                      child: objCommonWidgets.customText(
                        context,
                        'Personal & Quick actions',
                        10,
                        objConstantColor.navyBlue,
                        objConstantFonts.montserratMedium,
                      ),
                    ),
                    SizedBox(height: 5.dp),

                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                      child: objCommonWidgets.customText(
                          context,
                          'Access and control everything related to your account, orders, and shopping preferences.',
                          10,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratMedium
                      ),
                    ),

                    SizedBox(height: 10.dp),

                    optionsView(),

                    SizedBox(height: 30.dp),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.dp),
                      child: objCommonWidgets.customText(
                        context,
                        'RECOMMENDATION & REMINDERS',
                        10,
                        objConstantColor.navyBlue,
                        objConstantFonts.montserratMedium,
                      ),
                    ),
                    SizedBox(height: 5.dp),

                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                      child: objCommonWidgets.customText(
                          context,
                          'Keep this on to receive offer recommendations & timely reminders based on your interests',
                          10,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratMedium
                      ),
                    ),

                    SizedBox(height: 10.dp),

                    switchButton(context, 'SMS', userScreenState.isSms, (newValue) {
                      screenNotifier.updateSms(newValue);
                    },),

                    SizedBox(height: 2.dp),

                    switchButton(context, 'WhatsApp', userScreenState.isWhatsAPP, (newValue) {
                      screenNotifier.updateWhatsApp(newValue);
                    },),

                    SizedBox(height: 2.dp),

                    switchButton(context, 'Push Notification', userScreenState.isPushNotification, (newValue) {
                      screenNotifier.updatePushNotification(newValue);
                    },),


                    SizedBox(height: 30.dp),

                    /// LEGAL
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.dp),
                      child: objCommonWidgets.customText(
                        context,
                        'Legal & Information',
                        10,
                        objConstantColor.navyBlue,
                        objConstantFonts.montserratMedium,
                      ),
                    ),

                    SizedBox(height: 5.dp),

                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                      child: objCommonWidgets.customText(
                          context,
                          'Find detailed information about our service standards and your consumer protections. We’ve made our terms easy to read so you can shop with complete peace of mind.',
                          10,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratMedium
                      ),
                    ),

                    SizedBox(height: 10.dp),

                    Column(
                      children: [
                        _chipCard(context, 'Privacy Policy',
                            ScreenName.privacyPolicy, Icons.privacy_tip_sharp),
                        _chipCard(context, 'Terms & Conditions',
                            ScreenName.termsAndCondition, Icons.description_sharp),
                        _chipCard(context, 'Refund Policy',
                            ScreenName.refundPolicy, Icons.currency_rupee),
                        _chipCard(context, 'Shipping Policy',
                            ScreenName.shippingPolicy, Icons.local_shipping),
                        _chipCard(context, 'About Us',
                            ScreenName.aboutUS, Icons.info),
                      ],
                    ),


                    SizedBox(height: 30.dp),

                    /// LEGAL
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.dp),
                      child: objCommonWidgets.customText(
                        context,
                        'DELETE ACCOUNT',
                        10,
                        objConstantColor.navyBlue,
                        objConstantFonts.montserratMedium,
                      ),
                    ),

                    SizedBox(height: 5.dp),

                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                      child: objCommonWidgets.customText(
                          context,
                          'Closing your account will delete your profile and personal data permanently. You will no longer be able to access your purchase history or loyalty points.',
                          10,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratMedium
                      ),
                    ),

                    SizedBox(height: 20.dp),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.dp),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: (){},
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 14.dp),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20.dp),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(45),
                                blurRadius: 10,
                                offset: const Offset(2, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: objCommonWidgets.customText(
                                context,
                                'DELETE ACCOUNT',
                                15,
                                Colors.white,
                                objConstantFonts.montserratSemiBold),
                          ),
                        ), ),
                    ),

                    SizedBox(height: 20.dp),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget optionsView(){
    final mainScreenNotifier = ref.read(MainScreenGlobalStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonBtn('Profile', (){
          mainScreenNotifier.callNavigation(ScreenName.editProfile);
        }),
        SizedBox(height: 2.dp),
        commonBtn('Delivery Location', (){
          userFrom = ScreenName.profile;
          mainScreenNotifier.callNavigation(ScreenName.map);
        }),
        SizedBox(height: 2.dp),
        commonBtn('Order History', (){}),
        SizedBox(height: 2.dp),
        commonBtn('My Wishlist', (){
          userFrom = ScreenName.profile;
          mainScreenNotifier.callNavigation(ScreenName.wishList);
        }),
        SizedBox(height: 2.dp),
        commonBtn('Buy for friends & Family', (){
          mainScreenNotifier.callNavigation(ScreenName.familyAndFriends);
        }),
        SizedBox(height: 2.dp),
        commonBtn('Delete Account', (){}),
      ],
    );
  }

  Widget commonBtn(String title, VoidCallback onClick){
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: CupertinoButton(
          padding: EdgeInsets.symmetric(vertical: 13.dp, horizontal: 15.dp),
          minimumSize: Size.zero,
          onPressed: onClick,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              objCommonWidgets.customText(context, title, 11.5, Colors.black, objConstantFonts.montserratMedium),
              Icon(Icons.chevron_right, size: 18.dp, color: Colors.black,)
            ],
          )),
    );
  }

  Widget switchButton(BuildContext context, String title, bool status, ValueChanged<bool> action) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 15.dp),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Using Expanded ensures the text doesn't push the switch off-screen
          Expanded(
            child: objCommonWidgets.customText(
              context,
              title,
              11.5,
              Colors.black,
              objConstantFonts.montserratMedium,
            ),
          ),
          // Shrink the switch here
          Transform.scale(
            scale: 0.75, // Scaled down to 75% of original size
            alignment: Alignment.centerRight,
            child: CupertinoSwitch(
              value: status,
              activeColor: CupertinoColors.activeGreen,
              trackColor: CupertinoColors.systemGrey5,
              onChanged: action,
            ),
          ),
        ],
      ),
    );
  }




  Widget _bigCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.dp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.dp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40.dp,
              width: 40.dp,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F6),
                borderRadius: BorderRadius.circular(10.5.dp),
              ),
              child: Icon(icon, size: 20.dp, color: objConstantColor.orange),
            ),
            SizedBox(height: 14.dp),
            objCommonWidgets.customText(context, title, 13, Colors.black, objConstantFonts.montserratMedium),
            SizedBox(height: 2.dp),
            objCommonWidgets.customText(context, subtitle, 10.5, Colors.grey.shade600, objConstantFonts.montserratMedium),

          ],
        ),
      ),
    );
  }



  Widget _chipCard(
      BuildContext context,
      String title,
      ScreenName screenName,
      IconData icon
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.dp),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          selectedLegalInformation = screenName;
          ref
              .read(MainScreenGlobalStateProvider.notifier)
              .callNavigation(ScreenName.information);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 15.dp, vertical: 13.dp),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16.dp, color: Colors.black),
              SizedBox(width: 5.dp),
              objCommonWidgets.customText(
                  context,
                  title, 11.5,
                  Colors.black,
                  objConstantFonts.montserratMedium
              ),
              const Spacer(),
              Icon(Icons.chevron_right, size: 18.dp, color: Colors.black,)
            ],
          ),
        ),
      ),
    );
  }


  Widget _supportCard(
      BuildContext context, {
        required VoidCallback onTap,
      }) {
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 22.dp, horizontal: 15.dp),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [

              Color(0xFF0345DC),
              Color(0xFF3264D3),
              Color(0xFF5A8DF6),

            ],
            stops: [0.0, 0.55, 1.0],
          ),
          borderRadius: BorderRadius.circular(20.dp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(1, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.headset_mic, color: Colors.white, size: 30.dp),
            SizedBox(width: 5.dp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                objCommonWidgets.customText(context,
                    'Customer Support',
                    15, Colors.white, objConstantFonts.montserratSemiBold),
                objCommonWidgets.customText(context,
                    'Need any help?',
                    10, Colors.white, objConstantFonts.montserratMedium),
              ],
            ),
            const Spacer(),
            Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 20.dp),
          ],
        ),
      ),
    );
  }




}
