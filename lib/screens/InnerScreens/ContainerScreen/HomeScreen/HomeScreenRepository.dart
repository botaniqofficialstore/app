
import '../../../../API/APIService.dart';

class HomeScreenRepository{
  /// This Method used to call Product List GET API
  ///
  /// [completer] - This param used to return the API Completion handler
  void callProductListGETApi(String url, ApiCompletionHandler completer) async {
    await APIService().callCommonGETApi(url, completer);
  }
}