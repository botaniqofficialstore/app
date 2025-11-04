
import '../../../../API/APIService.dart';
class ProductDetailsRepository{
  /// This Method used to call Product Detail GET API
  ///
  /// [completer] - This param used to return the API Completion handler
  void callProductDetailsGETApi(String url, ApiCompletionHandler completer) async {
    await APIService().callCommonGETApi(url, completer);
  }
}