
import '../../../../API/APIService.dart';

class OrderListRepository {
  /// This Method used to call Order List GET API
  Future<void> callOrderListGETApi(String url, ApiCompletionHandler completer) async {
    await APIService().callCommonGETApi(url, completer);
  }

  /// This Method used to call Order List GET API
  Future<void> callCancelOrderDELETEApi(String url, Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonDELETEApi(url, requestBody, completer);
  }
}