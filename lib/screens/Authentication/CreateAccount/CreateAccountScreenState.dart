import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:botaniqmicrogreens/screens/Authentication/CreateAccount/CreateAccountRepository.dart';
import 'package:botaniqmicrogreens/screens/Authentication/LoginScreen/LoginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../CodeReusable/CommonWidgets.dart';
import '../../../Utility/PreferencesManager.dart';
import '../CreatePassword/CreatePassword.dart';
import 'CreateAccountModel.dart';

class CreateAccountScreenGlobalState {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController mobileNumberController;

  CreateAccountScreenGlobalState({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.mobileNumberController,
  });

  CreateAccountScreenGlobalState copyWith({
    TextEditingController? firstNameController,
    TextEditingController? lastNameController,
    TextEditingController? emailController,
    TextEditingController? mobileNumberController,
  }) {
    return CreateAccountScreenGlobalState(
      firstNameController: firstNameController ?? this.firstNameController,
      lastNameController: firstNameController ?? this.lastNameController,
      emailController: firstNameController ?? this.lastNameController,
      mobileNumberController: firstNameController ?? this.lastNameController,
    );
  }
}

class CreateAccountScreenStateNotifier
    extends StateNotifier<CreateAccountScreenGlobalState> {
  CreateAccountScreenStateNotifier() : super(CreateAccountScreenGlobalState(
    firstNameController: TextEditingController(),
    lastNameController: TextEditingController(),
    emailController: TextEditingController(),
    mobileNumberController: TextEditingController(),
  ));

  @override
  void dispose() {
    super.dispose();
  }



  ///This Method used to check login field validation and call API
  void checkTextFieldValidation(BuildContext context) {
    if (!context.mounted) return;
    CodeReusability.hideKeyboard(context);

    if (CodeReusability.isEmptyOrWhitespace(state.firstNameController.text)) {
      CodeReusability().showAlert(context, 'Please enter your first name');
    } else if (CodeReusability.isEmptyOrWhitespace(state.lastNameController.text)) {
      CodeReusability().showAlert(context, 'Please enter your last name');
    } else if (CodeReusability.isEmptyOrWhitespace(state.emailController.text)) {
      CodeReusability().showAlert(context, 'Please enter your Email address');
    } else if (!CodeReusability.isValidEmail(state.emailController.text)){
      CodeReusability().showAlert(context, 'Please Enter a valid Email');
    } else if (CodeReusability.isEmptyOrWhitespace(state.mobileNumberController.text)) {
      CodeReusability().showAlert(context, 'Please enter your mobile number');
    } else if (!CodeReusability.isValidMobileNumber(state.mobileNumberController.text)){
      CodeReusability().showAlert(context, 'Please Enter a valid mobile number');
    }  else {
      callCreateAccountAPI(context);
    }
  }

  ///This method used to call Create Account POST API
  void callCreateAccountAPI(BuildContext context) {
    if (!context.mounted) return;

    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        Map<String, dynamic> requestBody = {
          'firstName': state.firstNameController.text,
          'lastName': state.lastNameController.text,
          'email': state.emailController.text,
          'mobileNumber': state.mobileNumberController.text,
        };

        CommonWidgets().showLoadingBar(true, context); //  Loading bar is Enabled Here
        CreateAccountRepository().callCreateAccountApi(requestBody, (statusCode, responseBody) {
          CreateAccountResponse response = CreateAccountResponse.fromJson(responseBody);


          if (statusCode == 200 || statusCode == 201) {
              CommonWidgets().showLoadingBar(false, context); //  Loading bar is disabled Here
              callNavigation(context);
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

  ///This method is used to navigate to Create New Password Screen
  void callNavigation(BuildContext context){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const LoginScreen()),//const ForgotPasswordScreen()),
    );
  }


}



final CreateAccountScreenStateProvider = StateNotifierProvider.autoDispose<
    CreateAccountScreenStateNotifier, CreateAccountScreenGlobalState>((ref) {
  var notifier = CreateAccountScreenStateNotifier();
  return notifier;
});

