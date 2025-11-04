
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:botaniqmicrogreens/screens/Authentication/ForgotPasswordScreen/ForgotPasswordScreenState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../Utility/PreferencesManager.dart';
import '../../InnerScreens/MainScreen/MainScreenState.dart';
import '../../commonViews/CommonWidgets.dart';
import '../LoginScreen/LoginScreen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(screenInterceptor);
  }


  @override
  void dispose() {
    BackButtonInterceptor.remove(screenInterceptor);
    super.dispose();
  }



  //MARK: - METHODS
  /// Return true to prevent default behavior (app exit)
  /// Return false to allow default behavior
  bool screenInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (kDebugMode) {
      print("Back button intercepted!");
    }
    PreferencesManager.getInstance().then((prefs) {
      if (prefs.getBooleanValue(PreferenceKeys.isDialogOpened) == true) {
        return false;
      } else if ((prefs.getBooleanValue(PreferenceKeys.isLoadingBarStarted) ==
          true)) {
        return true;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginScreen()),
        );
      }
    });
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CodeReusability.hideKeyboard(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: forGotView(context)
        ),
      ),
    );
  }


  Widget forGotView(BuildContext context) {
    final screenState = ref.watch(ForgotPasswordScreenStateProvider);
    final screenNotifier = ref.read(ForgotPasswordScreenStateProvider.notifier);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Stack(
            children: [
              Image.asset(
                objConstantAssest.forgotPassword,
                fit: BoxFit.cover, // adjust image scaling
              ),

              Positioned(top: 10.dp,
                  left: 5.dp,child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Image.asset(
                      objConstantAssest.backIcon,
                      color: objConstantColor.white,
                      height: 30.dp,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                  )),

              Positioned(bottom: 10.dp, left: 10.dp,child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  objCommonWidgets.customText(
                    context,
                    'Forgot',
                    30,
                    objConstantColor.white,
                    objConstantFonts.montserratBold,
                  ),
                  objCommonWidgets.customText(
                    context,
                    'Password',
                    30,
                    objConstantColor.white,
                    objConstantFonts.montserratBold,
                  )
                ],
              ))
            ],
          ),


          SizedBox(height: 20.dp,),


          /// Center Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                objCommonWidgets.customText(
                  context,
                  'Email or Mobile Number',
                  15,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratSemiBold,
                ),
                SizedBox(height: 5.dp),
                CommonTextField(
                  controller: screenState.emailMobileController,
                  placeholder: "Enter Your Email or Mobile Number",
                  textSize: 15,
                  fontFamily: objConstantFonts.montserratMedium,
                  textColor: objConstantColor.navyBlue,
                  isNumber: false,
                  onChanged: (value) {},
                ),
                SizedBox(height: 25.dp),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: 15.dp),
                    color: objConstantColor.navyBlue,
                    borderRadius: BorderRadius.circular(12.dp),
                    onPressed: () {
                      screenNotifier.checkTextFieldValidation(context);
                    },
                    child: objCommonWidgets.customText(
                      context,
                      'Send OTP',
                      18,
                      objConstantColor.white,
                      objConstantFonts.montserratSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),


          /// Bottom "Create Account"
          Row(
            children: [
              const Spacer(),
              objCommonWidgets.customText(
                context,
                'New User?',
                12,
                Colors.grey.shade600,
                objConstantFonts.montserratMedium,
              ),
              SizedBox(width: 5.dp),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: objCommonWidgets.customText(
                  context,
                  'Create Account',
                  13,
                  objConstantColor.orange,
                  objConstantFonts.montserratSemiBold,
                ),
                onPressed: () {
                  ref.watch(MainScreenGlobalStateProvider.notifier)
                      .callNavigation(ScreenName.createAccount);
                },
              ),
              const Spacer(),
            ],
          ),

          SizedBox(height: 15.dp),
        ],
      ),
    );
  }



}
