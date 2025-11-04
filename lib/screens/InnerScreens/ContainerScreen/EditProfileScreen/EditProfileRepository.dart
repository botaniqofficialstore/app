
import '../../../../API/APIService.dart';

class EditProfileRepository {
  /// This Method to call Create user API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callEditProfileApi(String url,
      Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPUTApi(
        url,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }
}
