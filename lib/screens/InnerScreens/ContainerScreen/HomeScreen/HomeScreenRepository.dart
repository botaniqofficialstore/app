import '../../../../API/APIService.dart';

class HomeScreenRepository {
  /// Product List GET API
  void callProductListGETApi(String url, ApiCompletionHandler completer) async {
    await APIService().callCommonGETApi(url, completer);
  }
}
