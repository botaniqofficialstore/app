
import '../../../../API/APIService.dart';

class WishListRepository {
  /// This Method to call Wish List GET API
  ///
  /// [completer] - This param used to return the API Completion handler
  void callWishListApi(String url, ApiCompletionHandler completer) async {
    await APIService().callCommonGETApi(
        url,
        isAccessTokenNeeded: false,
        completer);
  }

  /// This Method to call Product Delete From WIsh LIst API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callProductDeleteFromWishListApi(String url,
      Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonDELETEApi(
        url,
        requestBody,
        completer);
  }

  /// This Method to call Add To Cart API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callAddToCartApi(String url, Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        url,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }

  /// This Method to call Add To Cart API
  ///
  /// [requestBody] - This param used to pass the API request body
  /// [completer] - This param used to return the API Completion handler
  void callAddToWishListApi(String url, Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(
        url,
        requestBody,
        isAccessTokenNeeded: false,
        completer);
  }
}
