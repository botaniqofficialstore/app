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
import '../LoginScreen/LoginScreen.dart';
import 'CreateAccountScreenState.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  CreateAccountScreenState createState() => CreateAccountScreenState();
}

class CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(createAccountInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(createAccountInterceptor);
    super.dispose();
  }


  //MARK: - METHODS
  /// Return true to prevent default behavior (app exit)
  /// Return false to allow default behavior
  bool createAccountInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (kDebugMode) {
      print("Back button intercepted!");
    }
    PreferencesManager.getInstance().then((prefs) {
      if (prefs.getBooleanValue(PreferenceKeys.isDialogOpened) == true) {
        return true;
      } else if (prefs.getBooleanValue(PreferenceKeys.isLoadingBarStarted) ==
          true) {
        return false;
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
        body: SafeArea(
          bottom: false,
          child:SingleChildScrollView(
              child: createAccountView(context)
          ),
        ),
      ),
    );
  }


  Widget createAccountView(BuildContext context) {
    final screenState = ref.watch(CreateAccountScreenStateProvider);
    final screenNotifier = ref.read(CreateAccountScreenStateProvider.notifier);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [


          Stack(
            children: [
              Image.asset(
                objConstantAssest.addImage8,
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
            ],
          ),

          Padding(
            padding: EdgeInsets.only(top: 15.dp),
            child: objCommonWidgets.customText(
              context,
              'Create Account',
              30,
              objConstantColor.navyBlue,
              objConstantFonts.montserratBold,
            ),
          ),




          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.dp, vertical: 15.dp), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              objCommonWidgets.customText(context, 'First Name', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
              CommonTextField(
                controller: screenState.firstNameController,
                placeholder: "Enter First Name",
                textSize: 15,
                fontFamily: objConstantFonts.montserratMedium,
                textColor: objConstantColor.navyBlue,
                isNumber: false, // alphabetic
                onChanged: (value) {

                },
              ),
              SizedBox(height: 10.dp,),


              objCommonWidgets.customText(context, 'Last Name', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
              CommonTextField(
                controller: screenState.lastNameController,
                placeholder: "Enter Last Name",
                textSize: 15,
                fontFamily: objConstantFonts.montserratMedium,
                textColor: objConstantColor.navyBlue,
                isNumber: false, // alphabetic
                onChanged: (value) {

                },
              ),
              SizedBox(height: 10.dp,),


              objCommonWidgets.customText(context, 'Email Address', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
              CommonTextField(
                controller: screenState.emailController,
                placeholder: "Enter Email Address",
                textSize: 15,
                fontFamily: objConstantFonts.montserratMedium,
                textColor: objConstantColor.navyBlue,
                isNumber: false, // alphabetic
                onChanged: (value) {

                },
              ),
              SizedBox(height: 10.dp,),


              objCommonWidgets.customText(context, 'Mobile Number', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10.dp),
                      child: objCommonWidgets.customText(context,
                          '+91', 15,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratSemiBold
                      ),
                    ),
                  ),

                  SizedBox(width: 10.dp,),

                  Expanded(
                    child: CommonTextField(
                      controller: screenState.mobileNumberController,
                      placeholder: "Enter Mobile Number",
                      textSize: 15,
                      fontFamily: objConstantFonts.montserratMedium,
                      textColor: objConstantColor.navyBlue,
                      isNumber: true, // alphabetic
                      onChanged: (value) {

                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.dp,),


              Padding(
                padding: EdgeInsets.only(top: 10.dp, bottom: 20.dp),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: 15.dp),
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.dp),
                    onPressed: () {
                      screenNotifier.checkTextFieldValidation(context);

                    },
                    child: objCommonWidgets.customText(
                      context,
                      'Create Account',
                      18,
                      objConstantColor.white,
                      objConstantFonts.montserratSemiBold,
                    ),
                  ),
                ),
              )

            ],
          ),)


        ]
    );
  }


}
