import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../CodeReusable/FacebookSignInService.dart';
import '../../../../CodeReusable/GoogleSignInService.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../Utility/PreferencesManager.dart';
import '../../commonViews/CommonWidgets.dart';
import '../CreateAccount/CreateAccountScreen.dart';
import 'LoginScreenState.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(loginInterceptor);
  }


  @override
  void dispose() {
    BackButtonInterceptor.remove(loginInterceptor);
    super.dispose();
  }


  //MARK: - METHODS
  /// Return true to prevent default behavior (app exit)
  /// Return false to allow default behavior
  bool loginInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
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
        return false;
      }
    });
    return true;
  }


  //MARK: - Widget
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => CodeReusability.hideKeyboard(context),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: objConstantColor.navyBlue,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight, // important
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(),
                        // LOGO
                        Padding(
                          padding: EdgeInsets.only(top: 35.dp),
                          child: Center(
                            child: Image.asset(
                              objConstantAssest.loginLogo,
                              width: 150.dp,
                              height: 90.dp,
                            ),
                          ),
                        ),

                        const Spacer(),
                        const Spacer(),
                        const Spacer(),
                        // White Bottom Section
                        loginBottomContainer(context),

                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget loginBottomContainer(BuildContext context) {
    final loginState = ref.watch(loginScreenProvider);
    final loginNotifier = ref.read(loginScreenProvider.notifier);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35.dp),
          topRight: Radius.circular(35.dp),
        ),
      ),
      padding: EdgeInsets.fromLTRB(25.dp, 20.dp, 25.dp, MediaQuery.of(context).viewInsets.bottom + 5.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.dp),
            child: Center(
              child: objCommonWidgets.customText(
                context,
                'Login',
                30,
                objConstantColor.navyBlue,
                objConstantFonts.montserratBold,
              ),
            ),
          ),

          SizedBox(height: 15.dp),

          objCommonWidgets.customText(
            context,
            'Email/Mobile Number',
            15,
            objConstantColor.navyBlue,
            objConstantFonts.montserratSemiBold,
          ),

          SizedBox(height: 5.dp),

          CommonTextField(
            controller: loginState.emailMobileController,
            placeholder: "Enter your email or mobile number",
            textSize: 15,
            fontFamily: objConstantFonts.montserratMedium,
            textColor: objConstantColor.navyBlue,
            isNumber: false,
            onChanged: (value) {},
          ),

          SizedBox(height: 18.dp),

          // OTP Button
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 15.dp),
              color: objConstantColor.orange,
              borderRadius: BorderRadius.circular(12.dp),
              onPressed: () {
                loginNotifier.checkLoginFieldValidation(context);
              },
              child: objCommonWidgets.customText(
                context,
                'GET OTP',
                18,
                objConstantColor.white,
                objConstantFonts.montserratSemiBold,
              ),
            ),
          ),

          SizedBox(height: 25.dp),

          objCommonWidgets.orWidget(context),

          SizedBox(height: 20.dp),

          // Social buttons
          Row(
            children: [
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: socialIcon(objConstantAssest.google, 16.dp),
                onPressed: () async {
                  final user = await GoogleSignInService.signInWithGoogle();
                  if (user != null){
                    var result = CodeReusability().splitFullName('${user.displayName}');
                    loginNotifier.callSocialSignInAPI(context, user.email, 'google', '${result["firstName"]}', '${result["lastName"]}');
                  }
                },
              ),
              SizedBox(width: 50.dp),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: socialIcon(objConstantAssest.facebook, 18.dp),
                onPressed: () async {
                  final user = await FacebookSignInService.signInWithFacebook();
                  var result = CodeReusability().splitFullName('${user?.displayName}');
                  if (user != null){
                    loginNotifier.callSocialSignInAPI(context, '${user.email}', 'facebook', '${result["firstName"]}', '${result["lastName"]}');
                  }
                },
              ),
              const Spacer(),
            ],
          ),

          SizedBox(height: 25.dp),

          // Create account
          Row(
            children: [
              const Spacer(),
              objCommonWidgets.customText(
                  context,
                  'New User?',
                  12,
                  Colors.grey.shade600,
                  objConstantFonts.montserratMedium),
              SizedBox(width: 5.dp),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: objCommonWidgets.customText(
                    context,
                    'Create Account',
                    13,
                    objConstantColor.orange,
                    objConstantFonts.montserratSemiBold),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom)


        ],
      ),
    );
  }

  Widget socialIcon(String asset, double size) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.dp),
        border: Border.all(color: Colors.grey.shade400, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 1,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.dp),
        child: Image.asset(asset, width: size),
      ),
    );
  }



}
