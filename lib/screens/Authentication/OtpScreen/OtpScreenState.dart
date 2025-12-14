import 'dart:async';
import 'package:botaniqmicrogreens/screens/Authentication/OtpScreen/OtpRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../API/CommonAPI.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../CodeReusable/CommonWidgets.dart';
import '../../../Utility/PreferencesManager.dart';
import '../../InnerScreens/MainScreen/MainScreen.dart';
import '../LoginScreen/LoginModel.dart';

class OtpScreenGlobalState {
  final List<TextEditingController> controllers;
  final List<String> otpValues;
  final List<FocusNode> focusNodes;
  final String user;

  OtpScreenGlobalState({
    required this.controllers,
    required this.otpValues,
    required this.focusNodes,
    required this.user
  });

  OtpScreenGlobalState copyWith({
    List<TextEditingController>? controllers,
    List<String>? otpValues,
    List<FocusNode>? focusNodes,
    String? user
  }) {
    return OtpScreenGlobalState(
      controllers: controllers ?? this.controllers,
      otpValues: otpValues ?? this.otpValues,
      focusNodes: focusNodes ?? this.focusNodes,
      user: user ?? this.user
    );
  }
}

class OtpScreenGlobalStateNotifier
    extends StateNotifier<OtpScreenGlobalState> {
  OtpScreenGlobalStateNotifier() : super(OtpScreenGlobalState(controllers: List.generate(6, (_) => TextEditingController()), otpValues: List.generate(6, (_) => ""), focusNodes: List.generate(6, (_) => FocusNode()), user: ''));

  @override
  void dispose() {
    super.dispose();
  }


  //MARK: - METHODS
  ///This method used to dispose values
  void clearValues() {
    for (final controller in state.controllers) {
      controller.dispose();
    }
    for (final focusNode in state.focusNodes) {
      focusNode.dispose();
    }
  }

  ///This method is used to format from the timer value
  ///
  /// [seconds] - This param used to pass the seconds value
  String formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  ///This method used to clear OTP Fields
  void clearOtpFields() {
    for (var controller in state.controllers) {
      controller.clear();
    }
    state.otpValues.fillRange(0, state.otpValues.length, "");
  }

  ///This Method used to Auto-fill OTP fields
  void updateFieldsWithAutoFill(String otp) {
    for (int i = 0; i < otp.length; i++) {
      if (i < 6) {
        state.controllers[i].text = "*";
        state.otpValues[i] = otp[i];
      }
    }
  }

  void updateUserData(String user){
    state = state.copyWith(user: user);
  }

  void listenOtpAutoFill(BuildContext context,String otp) {
    clearOtpFields();
    updateFieldsWithAutoFill(otp);

    // Automatically verify when full OTP is received
    if (otp.length == 6) {
      callOTPVerifyAPI(context, otp); // store globalContext from init
    }
  }


  ///This method is used to for empty validation
    void checkEmptyValidation(BuildContext context) {
      if (!context.mounted) return;
      CodeReusability.hideKeyboard(context);

      // Check if any OTP field is empty
      bool anyEmpty = state.otpValues.any((value) => value.trim().isEmpty);

      if (anyEmpty) {
        CodeReusability().showAlert(context, 'Please enter the OTP');
      } else {
        // OTP is fully entered, proceed with verification
        String otp = state.otpValues.join();
        callOTPVerifyAPI(context, otp);
      }
    }


  ///This method used to call Login with password API
  void callOTPVerifyAPI(BuildContext context, String otp) {
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        Map<String, dynamic> requestBody = {
          'emailOrMobile': state.user,
          'otp': otp,
          'deviceId': 'device-12345',
          'appVersion': '1.0.0'
        };

        CommonWidgets().showLoadingBar(true, context); //  Loading bar is Enabled Here
        OtpRepository().callVerifyOtpApi(requestBody, (statusCode, responseBody) {
          LoginResponse response = LoginResponse.fromJson(responseBody);

          if (statusCode == 200) {
            PreferencesManager.getInstance().then((prefs) {
              prefs.setStringValue(PreferenceKeys.userID,
                  response.userId ?? '');
              prefs.setStringValue(PreferenceKeys.refreshToken,
                  response.refreshToken ?? '');
              prefs.setStringValue(PreferenceKeys.accessToken,
                  response.accessToken ?? '');
              prefs.setStringValue(PreferenceKeys.loginActivityId,
                  response.loginActivityId ?? '');
              prefs.setBooleanValue(PreferenceKeys.isUserLogged, true);

              CommonWidgets().showLoadingBar(false, context); //  Loading bar is disabled Here
              CommonAPI().callUserProfileAPI();
              CommonAPI().callDeviceRegisterAPI();

              //Call Navigation
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );

            });
          } else {
            CommonWidgets().showLoadingBar(false, context);
            CodeReusability().showAlert(
                context, response.message ?? "something Went Wrong");
          }
        });
      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }

  ///This Method is used to call Resend OTP API
  Future<bool> callReSendOtpAPI(BuildContext context) async {
    if (!context.mounted) return false;

    bool isConnected = await CodeReusability().isConnectedToNetwork();
    if (!isConnected) {
      CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      return false;
    }

    Map<String, dynamic> requestBody = {
      'emailOrMobile': state.user,
    };

    CommonWidgets().showLoadingBar(true, context); // Loading bar enabled

    try {
      final completer = Completer<bool>();

      OtpRepository().callReSendOTPApi(requestBody, (statusCode, responseBody) {
        CommonWidgets().showLoadingBar(false, context); // Hide loading bar

        LoginResponse response = LoginResponse.fromJson(responseBody);

        if (statusCode == 200) {
          completer.complete(true);
        } else {
          CodeReusability().showAlert(context, response.message ?? "Something went wrong");
          completer.complete(false);
        }
      });

      return await completer.future;
    } catch (e) {
      CommonWidgets().showLoadingBar(false, context);
      CodeReusability().showAlert(context, 'An unexpected error occurred: $e');
      return false;
    }
  }




}



final otpScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    OtpScreenGlobalStateNotifier, OtpScreenGlobalState>((ref) {
  var notifier = OtpScreenGlobalStateNotifier();
  return notifier;
});

