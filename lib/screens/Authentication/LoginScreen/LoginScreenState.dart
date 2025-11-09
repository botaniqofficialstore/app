import 'package:botaniqmicrogreens/screens/Authentication/OtpScreen/OtpScreen.dart';
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

  LoginScreenGlobalState({
    required this.emailMobileController,
  });

  LoginScreenGlobalState copyWith({
    TextEditingController? emailMobileController,
  }) {
    return LoginScreenGlobalState(
      emailMobileController: emailMobileController ?? this.emailMobileController,

    );
  }
}

class LoginScreenGlobalStateNotifier
    extends StateNotifier<LoginScreenGlobalState> {
  LoginScreenGlobalStateNotifier() : super(LoginScreenGlobalState(emailMobileController: TextEditingController(),));

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
    } else if (!CodeReusability.isValidMailOrMobile(state.emailMobileController.text)){
      CodeReusability().showAlert(context, 'Please Enter Valid Email or Mobile Number');
    } else {
      callSendOtpAPI(context);
    }
  }

  ///This method used to call Login with OTP API
  void callSendOtpAPI(BuildContext context) {
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        Map<String, dynamic> requestBody = {
          'emailOrMobile': state.emailMobileController.text.trim(),
        };

          CommonWidgets().showLoadingBar(true, context); //  Loading bar is Enabled Here
          LoginRepository().callLoginApi(requestBody, (statusCode, responseBody) {
            LoginResponse response = LoginResponse.fromJson(responseBody);

            if (statusCode == 200) {
              CommonWidgets().showLoadingBar(false, context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => OtpScreen(loginWith: state.emailMobileController.text.trim(), isEmail: CodeReusability().isEmail(state.emailMobileController.text.trim()),)),
              );

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

