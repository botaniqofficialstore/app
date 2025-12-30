import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';
import '../../../Authentication/LoginScreen/LoginScreen.dart';
import 'ProfileModel.dart';
import 'ProfileRepository.dart';

class ProfileScreenGlobalState {
  final ScreenName currentModule;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String address;
  final int wishListCount;
  final bool isSms;
  final bool isWhatsAPP;
  final bool isPushNotification;

  ProfileScreenGlobalState({
    this.currentModule = ScreenName.home,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.address,
    required this.wishListCount,
    required this.isSms,
    required this.isWhatsAPP,
    required this.isPushNotification
  });

  ProfileScreenGlobalState copyWith({
    ScreenName? currentModule,
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNumber,
    String? address,
    int? wishListCount,
    bool? isSms,
    bool? isWhatsAPP,
    bool? isPushNotification
  }) {
    return ProfileScreenGlobalState(
        currentModule: currentModule ?? this.currentModule,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        address: address ?? this.address,
        wishListCount: wishListCount ?? this.wishListCount,
        isSms: isSms ?? this.isSms,
        isWhatsAPP: isWhatsAPP ?? this.isWhatsAPP,
        isPushNotification: isPushNotification ?? this.isPushNotification
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
      wishListCount: 0,
      isSms: true,
      isWhatsAPP: true,
      isPushNotification: true
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
    final userAddress = exactAddress;

    state = state.copyWith(firstName: userFirstName, lastName: userLastName, email: userEmailID, mobileNumber: userMobileNumber, address: userAddress);
  }

  void updateSms(bool status){
    state = state.copyWith(isSms: status);
  }

  void updateWhatsApp(bool status){
    state = state.copyWith(isWhatsAPP: status);
  }

  void updatePushNotification(bool status){
    state = state.copyWith(isPushNotification: status);
  }


  //This method is used to call user logout API
  void callLogoutAPI(BuildContext context){
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        CommonWidgets().showLoadingBar(true, context);
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';
        String loginID = prefs.getStringValue(PreferenceKeys.loginActivityId) ?? '';
        String fcmToken = prefs.getStringValue(PreferenceKeys.fcmToken) ?? '';

        Map<String, dynamic> requestBody = {
          'userId': userID,
          'loginActivityId': loginID,
          'fcmToken': fcmToken,
        };

        ProfileRepository().callLogoutApi(requestBody, (statusCode, responseBody) async {
          final logoutResponse = LogoutResponse.fromJson(responseBody);
          CodeReusability().showAlert(context, logoutResponse.message ?? "something Went Wrong");
          CommonWidgets().showLoadingBar(false, context);

          if (statusCode == 200 || statusCode == 201){
            // 🔹 Clear user session
            prefs.removePref();
            CodeReusability().clearLocalVariables();

            prefs.setBooleanValue(PreferenceKeys.isUserLogged, false);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }else{
            CodeReusability().showAlert(context, logoutResponse.message ?? "something Went Wrong");
          }

        });
      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }



  //This method is used to connect gmail
  Future<void> openCustomerSupportEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'botaniqofficialstore@gmail.com',
      queryParameters: {
        'subject': 'BotaniQ Customer Support',
        'body':
        'Hello BotaniQ Team,\n\nPlease describe your issue here.\nOrder ID (if any):',
      },
    );

    await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );
  }


}



final ProfileScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    ProfileScreenGlobalStateNotifier, ProfileScreenGlobalState>((ref) {
  var notifier = ProfileScreenGlobalStateNotifier();
  return notifier;
});

