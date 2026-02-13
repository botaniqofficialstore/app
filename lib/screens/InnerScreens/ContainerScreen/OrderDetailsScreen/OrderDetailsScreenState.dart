import 'package:botaniqmicrogreens/screens/commonViews/CancelRequestPopup/CancelRequestPopup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';
import '../../../commonViews/CancelRequestSuccessPopup.dart';
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


  void openCancelRequestView(BuildContext context, String orderID, MainScreenGlobalStateNotifier notifier) async {
    final Map<String, dynamic>? result =
    await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) =>
      const CancelRequestPopup(),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );

    /// ✅ User clicked Submit
    if (result != null) {
      // Call API / show success popup
      callCancelOrderAPi(context, orderID, notifier);

    }
  }



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

          CommonWidgets().showLoadingBar(false, context);
          if (statusCode == 200 || statusCode == 201){
            CancelRequestSuccessPopup.show(context);
            notifier.callNavigation(ScreenName.orders);
          } else{
            CodeReusability().showAlert(context, cancelResponse.message ?? "something Went Wrong");
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

