
import '../../../../API/APIService.dart';
import '../../../../Constants/Constants.dart';

class LoginRepository {
  /// This Method to call login user verification API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callLoginApi(
      Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        ConstantURLs.sendOTPUrl,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }

  /// This Method to call login user verification API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callSocialLoginApi(
      Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        ConstantURLs.socialLoginUrl,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }


}
