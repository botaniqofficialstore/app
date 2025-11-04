import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/Constants.dart';
import '../../../CodeReusable/CodeReusability.dart';

class ForgotPasswordScreenGlobalState {
  final TextEditingController emailMobileController;

  ForgotPasswordScreenGlobalState({
    required this.emailMobileController,
  });

  ForgotPasswordScreenGlobalState copyWith({
    TextEditingController? emailMobileController,
  }) {
    return ForgotPasswordScreenGlobalState(
      emailMobileController: emailMobileController ?? this.emailMobileController,
    );
  }
}

class ForgotPasswordScreenStateNotifier
    extends StateNotifier<ForgotPasswordScreenGlobalState> {
  ForgotPasswordScreenStateNotifier() : super(ForgotPasswordScreenGlobalState(emailMobileController: TextEditingController()));

  @override
  void dispose() {
    super.dispose();
  }


  ///This Method used to check login field validation and call API
  void checkTextFieldValidation(BuildContext context) {
    if (!context.mounted) return;
    CodeReusability.hideKeyboard(context);

    if (CodeReusability.isEmptyOrWhitespace(state.emailMobileController.text)) {
      CodeReusability().showAlert(context, 'Please Enter Email or Mobile Number');
    } else if (!CodeReusability.isValidMailOrMobile(state.emailMobileController.text)){
      CodeReusability().showAlert(context, 'Please Enter Valid Email or Mobile Number');
    } else {
      //API
    }
  }


}



final ForgotPasswordScreenStateProvider = StateNotifierProvider.autoDispose<
    ForgotPasswordScreenStateNotifier, ForgotPasswordScreenGlobalState>((ref) {
  var notifier = ForgotPasswordScreenStateNotifier();
  return notifier;
});

