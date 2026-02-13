import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CancelRequestPopupState {
  final TextEditingController dobController;
  final TextEditingController reasonController;
  final List<String> returnReason;
  final bool isOther;
  final String? reason;
  final bool isSubmit;

  CancelRequestPopupState({
    required this.dobController,
    required this.reasonController,
    required this.returnReason,
    required this.isOther,
    this.reason,
    required this.isSubmit,
  });

  CancelRequestPopupState copyWith({
    TextEditingController? dobController,
    TextEditingController? reasonController,
    List<String>? returnReason,
    bool? isOther,
    String? reason,
    bool? isSubmit,
  }) {
    return CancelRequestPopupState(
      dobController: dobController ?? this.dobController,
      reasonController: reasonController ?? this.reasonController,
      returnReason: returnReason ?? this.returnReason,
      isOther: isOther ?? this.isOther,
      reason: reason ?? this.reason,
      isSubmit: isSubmit ?? this.isSubmit,
    );
  }
}

class CancelRequestPopupStateNotifier
    extends StateNotifier<CancelRequestPopupState> {
  CancelRequestPopupStateNotifier() : super(CancelRequestPopupState(
      dobController: TextEditingController(),
      reasonController: TextEditingController(),
      returnReason: [
        'Ordered by mistake',
        'Found a better price elsewhere',
        'Delivery time is too long',
        'Want to change delivery address',
        'Payment issue',
        'Duplicate order placed',
        'No longer needed',
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


final cancelRequestPopupStateProvider = StateNotifierProvider.autoDispose<
    CancelRequestPopupStateNotifier, CancelRequestPopupState>((ref) {
  var notifier = CancelRequestPopupStateNotifier();
  return notifier;
});