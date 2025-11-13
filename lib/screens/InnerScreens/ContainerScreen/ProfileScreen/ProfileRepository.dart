
import 'package:botaniqmicrogreens/Constants/Constants.dart';

import '../../../../API/APIService.dart';

class ProfileRepository{
  /// This Method to call Logout POST API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callLogoutApi(Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        ConstantURLs.logoutUrl,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }
}