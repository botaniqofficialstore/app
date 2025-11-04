import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/Constants.dart';

class OtpScreenGlobalState {
  final List<TextEditingController> controllers;
  final List<String> otpValues;
  final List<FocusNode> focusNodes;

  OtpScreenGlobalState({
    required this.controllers,
    required this.otpValues,
    required this.focusNodes,
  });

  OtpScreenGlobalState copyWith({
    List<TextEditingController>? controllers,
    List<String>? otpValues,
    List<FocusNode>? focusNodes,
  }) {
    return OtpScreenGlobalState(
      controllers: controllers ?? this.controllers,
      otpValues: otpValues ?? this.otpValues,
      focusNodes: focusNodes ?? this.focusNodes,
    );
  }
}

class OtpScreenGlobalStateNotifier
    extends StateNotifier<OtpScreenGlobalState> {
  OtpScreenGlobalStateNotifier() : super(OtpScreenGlobalState(controllers: List.generate(4, (_) => TextEditingController()), otpValues: List.generate(4, (_) => ""), focusNodes: List.generate(4, (_) => FocusNode())));

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
      if (i < 4) {
        state.controllers[i].text = "*";
        state.otpValues[i] = otp[i];
      }
    }
  }


}



final otpScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    OtpScreenGlobalStateNotifier, OtpScreenGlobalState>((ref) {
  var notifier = OtpScreenGlobalStateNotifier();
  return notifier;
});

