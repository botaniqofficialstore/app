import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Utility/Logger.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'OrderModel.dart';
import 'OrderRepository.dart';

class OrderScreenGlobalState {
  final ScreenName currentModule;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final List<OrderDataList> orderList;

  OrderScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.currentPage = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.orderList = const [],
  });

  OrderScreenGlobalState copyWith({
    ScreenName? currentModule,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    List<OrderDataList>? orderList,
  }) {
    return OrderScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      orderList: orderList ?? this.orderList,
    );
  }
}


class OrderScreenGlobalStateNotifier
    extends StateNotifier<OrderScreenGlobalState> {
  OrderScreenGlobalStateNotifier() : super(OrderScreenGlobalState());

  @override
  void dispose() {
    super.dispose();
  }

  void callNavigateToTrackOrder(MainScreenGlobalStateNotifier notifier){
    notifier.callNavigation(ScreenName.orderDetails);
  }


  /// This method is used to get Product List from GET API
  Future<void> callOrderListGepAPI(BuildContext context, {bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    state = state.copyWith(isLoading: true);
    bool isConnected = await CodeReusability().isConnectedToNetwork();

    if (!isConnected) {
      CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      state = state.copyWith(isLoading: false);
      return;
    }

    if (!loadMore) CommonWidgets().showLoadingBar(true, context);

    try {
      var prefs = await PreferencesManager.getInstance();
      String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

      int nextPage = loadMore ? state.currentPage + 1 : 1;
      String url = '${ConstantURLs.orderListUrl}userId=$userID&page=$nextPage&limit=10';

      await OrderListRepository().callOrderListGETApi(url, (statusCode, response) async {
        final orderResponse = OrdersResponse.fromJson(response);

        if (statusCode == 200) {
          Logger().log('###---> Order List API Response Page $nextPage: $response');
          Logger().log('###---> orderResponse data length: ${orderResponse.data?.length ?? 0}');

          List<OrderDataList> updatedList = loadMore
              ? [...state.orderList, ...orderResponse.data]
              : orderResponse.data;

          state = state.copyWith(
            orderList: updatedList,
            currentPage: nextPage,
            hasMore: orderResponse.data.isNotEmpty,
          );
        } else {
          CodeReusability().showAlert(context, orderResponse.message);
        }
      });


    } catch (e) {
      Logger().log("### Error in callOrderListGepAPI: $e");
    } finally {
      state = state.copyWith(isLoading: false);
      if (!loadMore) CommonWidgets().showLoadingBar(false, context);
    }
  }



}



final OrderScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    OrderScreenGlobalStateNotifier, OrderScreenGlobalState>((ref) {
  var notifier = OrderScreenGlobalStateNotifier();
  return notifier;
});

