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
        onTap: () {
      CodeReusability.hideKeyboard(context);
    },
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: loginView(context),
      ),
    )
    );
  }


  Widget loginView(BuildContext context) {
    final loginState = ref.watch(loginScreenProvider);
    final loginNotifier = ref.read(loginScreenProvider.notifier);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: objConstantColor.navyBlue,
            padding: EdgeInsets.symmetric(vertical: 40.dp),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Image.asset(
                  objConstantAssest.loginLogo,
                  width: 150.dp,
                  height: 90.dp,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.dp,),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 16.dp), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              objCommonWidgets.customText(
                  context, 'Email/Mobile Number', 15, objConstantColor.navyBlue,
                  objConstantFonts.montserratSemiBold),
              CommonTextField(
                controller: loginState.emailMobileController,
                placeholder: "Enter your email or mobile number",
                textSize: 15,
                fontFamily: objConstantFonts.montserratMedium,
                textColor: objConstantColor.navyBlue,
                isNumber: false,
                // alphabetic
                onChanged: (value) {
                },
              ),

              SizedBox(height: 15.dp,),

              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(vertical: 15.dp),
                  color: objConstantColor.orange,
                  borderRadius: BorderRadius.circular(12.dp),
                  onPressed: () {
                    setState(() {
                      loginNotifier.checkLoginFieldValidation(context);
                    });
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


              SizedBox(height: 20.dp,),

              objCommonWidgets.orWidget(context),

              SizedBox(height: 20.dp,),

              Row(
                children: [

                  const Spacer(),

                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50.dp),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 1,
                              spreadRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child:
                        Padding(
                          padding: EdgeInsets.all(12.dp),
                          child: Image.asset(
                            objConstantAssest.google, width: 16.dp,),
                        ),
                      ), onPressed: () async {
                    final user = await GoogleSignInService.signInWithGoogle();
                    if (user != null) {
                      if (kDebugMode) {
                        print('object------> ${user.email}');
                        print('object------> ${user.displayName}');
                      }
                    }
                  }),

                  SizedBox(width: 50.dp,),

                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50.dp),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 1,
                              spreadRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child:
                        Padding(
                          padding: EdgeInsets.all(10.dp),
                          child: Image.asset(
                            objConstantAssest.facebook, width: 18.dp,),
                        ),
                      ), onPressed: () async {
                    final user = await FacebookSignInService
                        .signInWithFacebook();
                    if (user != null) {
                      if (kDebugMode) {
                        print('object------> ${user['name']}');
                        print('object------> ${user['email']}');
                      }
                    }
                  }),
                  const Spacer(),
                ],
              ),

              SizedBox(height: 15.dp,),

              Row(
                children: [
                  const Spacer(),
                  objCommonWidgets.customText(
                      context, 'New User?', 12, Colors.grey.shade600,
                      objConstantFonts.montserratMedium),
                  SizedBox(width: 5.dp,),
                  CupertinoButton(padding: EdgeInsets.zero,
                      child: objCommonWidgets.customText(
                          context, 'Create Account', 13,
                          objConstantColor.orange,
                          objConstantFonts.montserratSemiBold),
                      onPressed: () {

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateAccountScreen()),
                        );

                      }),
                  const Spacer(),
                ],
              )


            ],
          ),)


        ]
    );
  }


}
