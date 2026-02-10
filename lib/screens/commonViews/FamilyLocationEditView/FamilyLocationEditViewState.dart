import 'package:botaniqmicrogreens/Utility/Logger.dart';
import 'package:botaniqmicrogreens/screens/commonViews/CommonMapScreen/CommonMapScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamilyLocationEditViewState {
  final TextEditingController firstNameController;
  final TextEditingController mobileNumberController;
  final String location;
  final bool isAdd;

  FamilyLocationEditViewState({
    required this.firstNameController,
    required this.mobileNumberController,
    required this.location,
    this.isAdd = false
  });

  FamilyLocationEditViewState copyWith({
    TextEditingController? firstNameController,
    TextEditingController? mobileNumberController,
    String? location,
    bool? isAdd
  }) {
    return FamilyLocationEditViewState(
      firstNameController: firstNameController ?? this.firstNameController,
      mobileNumberController: mobileNumberController ?? this.mobileNumberController,
        isAdd: isAdd ?? this.isAdd,
      location: location ?? this.location
    );
  }
}


class FamilyLocationEditViewStateNotifier
    extends StateNotifier<FamilyLocationEditViewState> {

  FamilyLocationEditViewStateNotifier()
      : super(FamilyLocationEditViewState(
    firstNameController: TextEditingController(),
    mobileNumberController: TextEditingController(),
    location: ''
  ));



  void loadData(String name, String mobile, String address){
    state = state.copyWith(
        firstNameController: TextEditingController(text: name),
        mobileNumberController: TextEditingController(text: mobile),
        location: address,
        isAdd: name.isEmpty
    );
  }

  void onChanged() {
    state = state.copyWith();
  }

  Future<void> callMapScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const CommonMapScreen(),
      ),
    );

    if (result != null) {
      final location = result['location'];
      final address = result['address'];

      state = state.copyWith(location: address);
    }
  }

  bool allowSave(){
    final mobile = state.mobileNumberController.text.trim();

    return (state.firstNameController.text.trim().isNotEmpty &&
        mobile.length > 9 &&
    state.location.isNotEmpty);
  }




}

final familyLocationEditViewStateProvider =
StateNotifierProvider.autoDispose<FamilyLocationEditViewStateNotifier, FamilyLocationEditViewState>((ref) {
  return FamilyLocationEditViewStateNotifier();
});


