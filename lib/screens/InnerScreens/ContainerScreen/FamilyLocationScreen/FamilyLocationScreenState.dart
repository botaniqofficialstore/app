import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../commonViews/FamilyLocationEditView/FamilyLocationEditView.dart';

class FamilyLocationScreenState {
  final bool isLoading;
  final List<FamilyMemberLocation> familyMembers;

  FamilyLocationScreenState({
    this.isLoading = false,
    this.familyMembers = const [],
  });

  FamilyLocationScreenState copyWith({
    bool? isLoading,
    List<FamilyMemberLocation>? familyMembers,
  }) {
    return FamilyLocationScreenState(
      isLoading: isLoading ?? this.isLoading,
      familyMembers: familyMembers ?? this.familyMembers,
    );
  }
}


class FamilyLocationScreenStateNotifier
    extends StateNotifier<FamilyLocationScreenState> {

  FamilyLocationScreenStateNotifier()
      : super(
    FamilyLocationScreenState(
      familyMembers: const [
        FamilyMemberLocation(
          name: 'Ragesh Pillai',
          mobileNumber: '9447012345',
          address: 'Skyline Ivy, Panampilly Nagar, Kochi, Kerala, 678451',
        ),
        FamilyMemberLocation(
          name: 'Anjali Menon',
          mobileNumber: '7012345678',
          address: 'TC 15/12, Kowdiar, Thiruvananthapuram, Kerala, 678450',
        ),
        FamilyMemberLocation(
          name: 'Devika Nambiar',
          mobileNumber: '8547112233',
          address: 'Sobha City, Puzhakkal, Thrissur, Kerala, 648751',
        ),
      ],
    ),
  );


  void callAddMemberView(BuildContext context, String name, String phone, String address) async {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => FamilyLocationScreen(name: name, phone: phone, address: address),
      ),
    );
  }



}

final familyLocationScreenStateProvider =
StateNotifierProvider.autoDispose<FamilyLocationScreenStateNotifier, FamilyLocationScreenState>((ref) {
  return FamilyLocationScreenStateNotifier();
});

class FamilyMemberLocation {
  final String name;
  final String mobileNumber;
  final String address;
  final bool? isSelected;

  const FamilyMemberLocation({
    required this.name,
    required this.mobileNumber,
    required this.address,
    this.isSelected = false
  });
}
