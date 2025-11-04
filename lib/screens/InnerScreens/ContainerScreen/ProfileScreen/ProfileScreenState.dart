import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';

class ProfileScreenGlobalState {
  final ScreenName currentModule;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String address;
  final int wishListCount;

  ProfileScreenGlobalState({
    this.currentModule = ScreenName.home,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.address,
    required this.wishListCount,
  });

  ProfileScreenGlobalState copyWith({
    ScreenName? currentModule,
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNumber,
    String? address,
    int? wishListCount
  }) {
    return ProfileScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      wishListCount: wishListCount ?? this.wishListCount,
    );
  }
}

class ProfileScreenGlobalStateNotifier
    extends StateNotifier<ProfileScreenGlobalState> {
  ProfileScreenGlobalStateNotifier() : super(ProfileScreenGlobalState(
      firstName: '',
      lastName: '',
      email: '',
      mobileNumber: '',
      address: '',
      wishListCount: 0
  ));

  @override
  void dispose() {
    super.dispose();
  }

  ///This method is used to get the user profile details from local
  Future<void> updateUserDetails() async {
    final manager = await PreferencesManager.getInstance();
    final userFirstName = manager.getStringValue(PreferenceKeys.userFirstName);
    final userLastName = manager.getStringValue(PreferenceKeys.userLastName);
    final userEmailID = manager.getStringValue(PreferenceKeys.userEmailID);
    final userMobileNumber = manager.getStringValue(PreferenceKeys.userMobileNumber);
    final userAddress = manager.getStringValue(PreferenceKeys.userAddress);

    state = state.copyWith(firstName: userFirstName, lastName: userLastName, email: userEmailID, mobileNumber: userMobileNumber, address: userAddress);
  }

}



final ProfileScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    ProfileScreenGlobalStateNotifier, ProfileScreenGlobalState>((ref) {
  var notifier = ProfileScreenGlobalStateNotifier();
  return notifier;
});

