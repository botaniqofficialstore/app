import 'package:botaniqmicrogreens/screens/InnerScreens/MainScreen/MainScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../API/CommonAPI.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../CodeReusable/CommonWidgets.dart';
import '../../../Utility/PreferencesManager.dart';
import 'LoginModel.dart';
import 'LoginRepository.dart';


class LoginScreenGlobalState {
  final TextEditingController emailMobileController;
  final TextEditingController passwordController;

  LoginScreenGlobalState({
    required this.emailMobileController,
    required this.passwordController,
  });

  LoginScreenGlobalState copyWith({
    TextEditingController? emailMobileController,
    TextEditingController? passwordController,
  }) {
    return LoginScreenGlobalState(
      emailMobileController: emailMobileController ?? this.emailMobileController,
      passwordController: passwordController ?? this.passwordController,

    );
  }
}

class LoginScreenGlobalStateNotifier
    extends StateNotifier<LoginScreenGlobalState> {
  LoginScreenGlobalStateNotifier() : super(LoginScreenGlobalState(emailMobileController: TextEditingController(),
      passwordController: TextEditingController()));

  @override
  void dispose() {
    super.dispose();
  }

  ///This Method used to check login field validation and call API
  void checkLoginFieldValidation(BuildContext context) {
    if (!context.mounted) return;
    CodeReusability.hideKeyboard(context);

    if (CodeReusability.isEmptyOrWhitespace(state.emailMobileController.text)) {
      CodeReusability().showAlert(context, 'Please Enter Email or Mobile Number');
    } else if (CodeReusability.isEmptyOrWhitespace(state.passwordController.text)) {
      CodeReusability().showAlert(context, 'Please Enter Your Password');
    } else if (!CodeReusability.isValidMailOrMobile(state.emailMobileController.text)){
      CodeReusability().showAlert(context, 'Please Enter Valid Email or Mobile Number');
    } else {
      callPasswordLoginAPI(context);
    }
  }

  ///This method used to call Login with password API
  void callPasswordLoginAPI(BuildContext context) {
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        Map<String, dynamic> requestBody = {
          'emailOrMobile': state.emailMobileController.text.toLowerCase().trim(),
          'password': state.passwordController.text.trim(),
          'deviceId': "DEVICE-12345",
          'appVersion': "1.2.0"
        };

          CommonWidgets().showLoadingBar(true, context); //  Loading bar is Enabled Here
          LoginRepository().callLoginApi(requestBody, (statusCode, responseBody) {
            LoginResponse response = LoginResponse.fromJson(responseBody);

            if (statusCode == 200) {
              PreferencesManager.getInstance().then((prefs) {
                prefs.setStringValue(PreferenceKeys.userID,
                    response.userID ?? '');
                prefs.setStringValue(PreferenceKeys.refreshToken,
                    response.refreshToken ?? '');
                prefs.setStringValue(PreferenceKeys.accessToken,
                    response.accessToken ?? '');
                prefs.setStringValue(PreferenceKeys.loginActivityId,
                    response.loginActivityId ?? '');
                prefs.setBooleanValue(PreferenceKeys.isUserLogged, true);

                CommonWidgets().showLoadingBar(false, context); //  Loading bar is disabled Here
                CommonAPI().callUserProfileAPI();

                //Call Navigation
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainScreen()),
                );


              });
            } else {
              CommonWidgets().showLoadingBar(false, context);
              CodeReusability().showAlert(context, response.message ?? "something Went Wrong");
            }
          });


      } else {
        CodeReusability().showAlert(
            context, 'Please Check Your Internet Connection');
      }
    });
  }


}



final loginScreenProvider = StateNotifierProvider.autoDispose<
    LoginScreenGlobalStateNotifier, LoginScreenGlobalState>((ref) {
  var notifier = LoginScreenGlobalStateNotifier();
  return notifier;
});

