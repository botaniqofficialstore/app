import 'package:botaniqmicrogreens/Constants/Constants.dart';

import '../../API/APIService.dart';

class PushNotificationRepository{
  /// This Method to call Device Register API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callDeviceRegisterApi(Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        ConstantURLs.deviceRegisterUrl,
        requestBody,
        isAccessTokenNeeded: true,
        completer);
  }
  /// This Method to call Device Register API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callDeviceUnRegisterApi(Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        ConstantURLs.deviceUnregisterUrl,
        requestBody,
        isAccessTokenNeeded: true,
        completer);
  }
}