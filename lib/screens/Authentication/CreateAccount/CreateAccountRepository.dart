
import '../../../../API/APIService.dart';
import '../../../../Constants/Constants.dart';

class CreateAccountRepository {
  /// This Method to call Create user API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callCreateAccountApi(
      Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        ConstantURLs.createUser,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }
}
