

import 'dart:io';

import 'package:botaniqmicrogreens/CodeReusable/CodeReusability.dart';
import 'package:botaniqmicrogreens/Utility/PushNotificationService/PushNotificationRepository.dart';
import 'package:notification_center/notification_center.dart';
import '../Utility/Logger.dart';
import '../Utility/PreferencesManager.dart';
import '../Utility/PushNotificationService/NotificationResponseModel.dart';
import '../constants/Constants.dart';
import '../screens/InnerScreens/ContainerScreen/ProfileScreen/ProfileModel.dart';
import 'APIService.dart';

class CommonAPI {

  ///This method is used to call Refresh token API
  Future<void> callRefreshTokenAPI() async {
    var prefs = await PreferencesManager.getInstance();
    var redreshToken = prefs.getStringValue(PreferenceKeys.refreshToken);
    String url = ConstantURLs.refreshTokenUrl;

    await APIService().callCommonGETApi(url, isAccessTokenNeeded: true,
            (statusCode, response) async {
          if (statusCode == 200) {
            Logger().log('###---> Refresh Token API Response: $response');

            prefs.setStringValue(
                PreferenceKeys.accessToken, response['accessToken']);
            NotificationCenter()
                .notify(
                NotificationCenterId.refreshTokenAPIResponse, data: null);
          } else {
            Logger().log('###---> Response: $response');
          }
        });
  }


  ///This method is used to call User Profile API
  Future<void> callUserProfileAPI() async {
    var prefs = await PreferencesManager.getInstance();
    String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';
    await APIService().callCommonGETApi(
        '${ConstantURLs.customerProfileUrl}$userID', isAccessTokenNeeded: false,
            (statusCode, response) async {
          if (statusCode == 200) {
            Logger().log('###---> Refresh Profile API Response: $response');
            final userResponse = UserProfileResponse.fromJson(response);

            Logger().log(
                '###-------------> userAddress: ${userResponse.data.address}');
            prefs.setStringValue(
                PreferenceKeys.userFirstName, userResponse.data.firstName);
            prefs.setStringValue(
                PreferenceKeys.userLastName, userResponse.data.lastName);
            prefs.setStringValue(
                PreferenceKeys.userEmailID, userResponse.data.email);
            prefs.setStringValue(PreferenceKeys.userMobileNumber,
                userResponse.data.mobileNumber);
            prefs.setStringValue(
                PreferenceKeys.userAddress, userResponse.data.address);

            exactAddress = await CodeReusability().getAddressFromPosition(
                userResponse.data.address);
            Logger().log('###---> Address: $exactAddress');

            NotificationCenter().notify(NotificationCenterId.updateUserProfile, data: null);
          } else {
            Logger().log('###---> Response: $response');
          }
        });
  }

  ///This method is used to call User Profile API
  Future<void> callDeviceRegisterAPI() async {
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';
        String fcmToken = prefs.getStringValue(PreferenceKeys.fcmToken) ?? '';
        final deviceType = Platform.isAndroid ? 'android' : 'ios';

        Map<String, dynamic> requestBody = {
          'userId': userID,
          'deviceType': deviceType,
          'fcmToken': fcmToken,
        };

        PushNotificationRepository().callDeviceRegisterApi(requestBody, (statusCode, responseBody) async {
          DeviceRegisterResponse response = DeviceRegisterResponse.fromJson(responseBody);
          Logger().log('### Device Register API Response ---> $response');
              if (statusCode == 200) {

              }else{

              }

          });
        }
    });
  }


}