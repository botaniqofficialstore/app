
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
        ConstantURLs.manualLoginUrl,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }


}
