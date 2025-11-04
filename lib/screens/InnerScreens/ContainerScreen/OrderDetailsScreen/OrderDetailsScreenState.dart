import 'package:botaniqmicrogreens/Utility/Logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import '../OrderScreen/OrderModel.dart';
import '../OrderScreen/OrderRepository.dart';

class OrderDetailsScreenGlobalState {
  final ScreenName currentModule;

  OrderDetailsScreenGlobalState({
    this.currentModule = ScreenName.home,
  });

  OrderDetailsScreenGlobalState copyWith({
    ScreenName? currentModule,
  }) {
    return OrderDetailsScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
    );
  }
}

class OrderDetailsScreenGlobalStateNotifier
    extends StateNotifier<OrderDetailsScreenGlobalState> {
  OrderDetailsScreenGlobalStateNotifier() : super(OrderDetailsScreenGlobalState());


  void callCancelOrderAPi(BuildContext context, String orderID, MainScreenGlobalStateNotifier notifier){
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        CommonWidgets().showLoadingBar(true, context);
        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

        Map<String, dynamic> requestBody = {
          'userId': userID,
          'orderId': orderID,
        };

        OrderListRepository().callCancelOrderDELETEApi(ConstantURLs.placeOrderUrl, requestBody, (statusCode, responseBody) async {
          final cancelResponse = CancelOrderResponseModel.fromJson(responseBody);
          CodeReusability().showAlert(context, cancelResponse.message ?? "something Went Wrong");
          CommonWidgets().showLoadingBar(false, context);
          if (statusCode == 200 || statusCode == 201){
            notifier.callNavigation(ScreenName.orders);
          }
        });
      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }


}



final OrderDetailsScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    OrderDetailsScreenGlobalStateNotifier, OrderDetailsScreenGlobalState>((ref) {
  var notifier = OrderDetailsScreenGlobalStateNotifier();
  return notifier;
});

