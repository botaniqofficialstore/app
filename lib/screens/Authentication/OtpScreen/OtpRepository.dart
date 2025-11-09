
import '../../../API/APIService.dart';
import '../../../Constants/Constants.dart';

class OtpRepository{

  /// This Method to call login user verification API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callVerifyOtpApi(
      Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        ConstantURLs.verifyOTPUrl,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }

  /// This Method to call Resend OTP API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callReSendOTPApi(
      Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        ConstantURLs.reSendOTPUrl,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }
}