
import '../../../../API/APIService.dart';

class CartRepository {
  /// This Method to call Cart List GET API
  ///
  /// [completer] - This param used to return the API Completion handler
  void callCartListApi(String url, ApiCompletionHandler completer) async {
    await APIService().callCommonGETApi(
        url,
        isAccessTokenNeeded: false,
        completer);
  }

  /// This Method to call Product Count Update API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callProductCountUpdateApi(String url,
      Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPUTApi(
        url,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }

  /// This Method to call Product Delete From Cart API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callProductDeleteFromCartApi(String url,
      Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonDELETEApi(
        url,
        requestBody,
        completer);
  }
}
