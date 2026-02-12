import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReturnRequestPopupState {
  final TextEditingController dobController;
  final TextEditingController reasonController;
  final List<String> returnReason;
  final bool isOther;
  final String? reason;
  final bool isSubmit;

  ReturnRequestPopupState({
    required this.dobController,
    required this.reasonController,
    required this.returnReason,
    required this.isOther,
    this.reason,
    required this.isSubmit,
  });

  ReturnRequestPopupState copyWith({
    TextEditingController? dobController,
    TextEditingController? reasonController,
    List<String>? returnReason,
    bool? isOther,
    String? reason,
    bool? isSubmit,
  }) {
    return ReturnRequestPopupState(
      dobController: dobController ?? this.dobController,
      reasonController: reasonController ?? this.reasonController,
      returnReason: returnReason ?? this.returnReason,
      isOther: isOther ?? this.isOther,
      reason: reason ?? this.reason,
      isSubmit: isSubmit ?? this.isSubmit,
    );
  }
}

class ReturnRequestPopupStateNotifier
    extends StateNotifier<ReturnRequestPopupState> {
  ReturnRequestPopupStateNotifier() : super(ReturnRequestPopupState(
    dobController: TextEditingController(),
      reasonController: TextEditingController(),
    returnReason: [
      'Damaged or leaked product',
      'Wrong or missing item',
      'Quality issue',
      'Expired or near expiry',
      'Allergic reaction',
      'Ordered by mistake',
      'Other'
    ],
      isOther: false,
      isSubmit: false
  ));


  void updateReason(String type) {
    final disableOther = type != 'Other';
    state = state.copyWith(reason: type, isSubmit: disableOther, isOther: !disableOther, reasonController: TextEditingController(text: ''));
  }

  void onChanged() {
    state = state.copyWith(isSubmit: state.reasonController.text.trim().isNotEmpty);
  }

  void callSubmit(BuildContext context){
    Navigator.pop(context, {
      'submit': true,
    });
  }


}


final returnRequestPopupStateProvider = StateNotifierProvider.autoDispose<
    ReturnRequestPopupStateNotifier, ReturnRequestPopupState>((ref) {
  var notifier = ReturnRequestPopupStateNotifier();
  return notifier;
});