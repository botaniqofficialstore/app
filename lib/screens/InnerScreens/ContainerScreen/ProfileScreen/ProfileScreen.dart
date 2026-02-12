import 'package:botaniqmicrogreens/screens/commonViews/DeleteAccountPopup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
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
                    14,
                    objConstantColor.navyBlue,
                    objConstantFonts.montserratMedium,
                  ),

                  const Spacer(),


                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

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
                        'Customer Support',
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
                          'Customer support is available to assist you with order issues, refunds, delivery concerns, and account queries. Please reach out with accurate details so we can resolve your request quickly and efficiently.',
                          10,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratMedium
                      ),
                    ),
                    SizedBox(height: 2.dp),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        screenNotifier.openCustomerSupportEmail();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 15.dp, vertical: 13.dp),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.headset_mic_rounded, size: 16.dp, color: const Color(0xFF0345DC)),
                            SizedBox(width: 5.dp),
                            objCommonWidgets.customText(
                                context,
                                'Customer Support', 11.5,
                                const Color(0xFF0345DC),
                                objConstantFonts.montserratMedium
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right, size: 18.dp, color: const Color(0xFF0345DC))
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30.dp),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.dp),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: (){
                          LogoutPopup.showLogoutPopup(
                            context: context,
                            onConfirm: () {
                              screenNotifier.callLogoutAPI(context);
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 14.dp),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20.dp),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(15),
                                blurRadius: 5,
                                offset: const Offset(2, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Image.asset(objConstantAssest.logout,color: Colors.white, width: 16.dp,),
                              SizedBox(width: 5.dp),
                              objCommonWidgets.customText(
                                  context,
                                  'Logout',
                                  15,
                                  Colors.white,
                                  objConstantFonts.montserratSemiBold
                              ),
                            ],
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
        commonBtn('Order History', (){
          mainScreenNotifier.callNavigation(ScreenName.orderHistory);
        }),
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
        commonBtn('Delete Account', (){
          DeleteAccountPopup.showDeleteAccountPopup(
            context: context,
            onConfirm: () {

            },
          );
        }),
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



}
