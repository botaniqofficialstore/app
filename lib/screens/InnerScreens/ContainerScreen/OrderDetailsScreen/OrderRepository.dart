import '../../../../API/APIService.dart';

class OrderRepository{

  /// This Method to call place Order POST API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callPlaceOrderApi(String url,
      Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        url,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }


}