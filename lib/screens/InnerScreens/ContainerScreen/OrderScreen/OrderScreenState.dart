// OrderScreenState.dart
import 'dart:async';
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
  final bool isInitialLoad; // 👈 new flag
  final List<OrderDataList> orderList;

  OrderScreenGlobalState({
    this.currentModule = ScreenName.home,
    this.currentPage = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.isInitialLoad = true, // 👈 start true so shimmer shows immediately
    this.orderList = const [],
  });

  OrderScreenGlobalState copyWith({
    ScreenName? currentModule,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    bool? isInitialLoad,
    List<OrderDataList>? orderList,
  }) {
    return OrderScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
      orderList: orderList ?? this.orderList,
    );
  }
}

class OrderScreenGlobalStateNotifier
    extends StateNotifier<OrderScreenGlobalState> {
  OrderScreenGlobalStateNotifier() : super(OrderScreenGlobalState());

  static const Duration _repoCallbackTimeout = Duration(seconds: 8);

  void callNavigateToTrackOrder(MainScreenGlobalStateNotifier notifier) {
    notifier.callNavigation(ScreenName.orderDetails);
  }

  Future<void> callOrderListGepAPI(BuildContext context, {bool loadMore = false}) async {
    // Skip if already loading or no more data
    if (state.isLoading || (!state.hasMore && loadMore)) {
      Logger().log('callOrderListGepAPI skipped: isLoading=${state.isLoading}, hasMore=${state.hasMore}, loadMore=$loadMore');
      return;
    }

    state = state.copyWith(isLoading: true, isInitialLoad: false); // 👈 mark initial load done
    Logger().log('callOrderListGepAPI started (loadMore=$loadMore)');

    bool isConnected = await CodeReusability().isConnectedToNetwork();
    if (!isConnected) {
      CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      state = state.copyWith(isLoading: false);
      return;
    }


    Timer? fallbackTimer;
    bool callbackInvoked = false;

    try {
      var prefs = await PreferencesManager.getInstance();
      String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

      int nextPage = loadMore ? state.currentPage + 1 : 1;
      String url = '${ConstantURLs.orderListUrl}userId=$userID&page=$nextPage&limit=10';

      fallbackTimer = Timer(_repoCallbackTimeout, () {
        if (!callbackInvoked) {
          Logger().log('OrderListRepository callback TIMEOUT after ${_repoCallbackTimeout.inSeconds}s');
          state = state.copyWith(isLoading: false);
        }
      });

      OrderListRepository().callOrderListGETApi(url, (statusCode, response) async {
        callbackInvoked = true;
        fallbackTimer?.cancel();

        try {
          final orderResponse = OrdersResponse.fromJson(response);
          if (statusCode == 200) {
            Logger().log('✅ Order List API Response Page $nextPage: ${orderResponse.data?.length ?? 0} items');

            List<OrderDataList> updatedList = loadMore
                ? [...state.orderList, ...orderResponse.data]
                : orderResponse.data;

            state = state.copyWith(
              orderList: updatedList,
              currentPage: nextPage,
              hasMore: orderResponse.data.isNotEmpty,
              isLoading: false,
            );
          } else {
            Logger().log('❌ Non-200 response: $statusCode, message: ${orderResponse.message}');
            CodeReusability().showAlert(context, orderResponse.message ?? "Something went wrong");
            state = state.copyWith(isLoading: false);
          }
        } catch (e, st) {
          Logger().log('⚠️ Error parsing OrderList response: $e\n$st');
          state = state.copyWith(isLoading: false);
        } finally {
        }
      });
    } catch (e, st) {
      Logger().log('Exception in callOrderListGepAPI: $e\n$st');
      state = state.copyWith(isLoading: false);
      fallbackTimer?.cancel();
    }
  }

  ///This method is used to cancel the order
  void callCancelOrderAPi(BuildContext context, String orderID, int index){
    if (!context.mounted) return;
    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        var prefs = await PreferencesManager.getInstance();
        String userID = prefs.getStringValue(PreferenceKeys.userID) ?? '';

        Map<String, dynamic> requestBody = {
          'userId': userID,
          'orderId': orderID,
        };

        OrderListRepository().callCancelOrderDELETEApi(ConstantURLs.placeOrderUrl, requestBody, (statusCode, responseBody) async {
          final cancelResponse = CancelOrderResponseModel.fromJson(responseBody);
          CodeReusability().showAlert(context, cancelResponse.message ?? "something Went Wrong");
          if (statusCode == 200 || statusCode == 201){
            if (index < 0 || index >= state.orderList.length) return;

            final updatedList = List<OrderDataList>.from(state.orderList)
              ..removeAt(index);

            state = state.copyWith(orderList: updatedList);
          }
        });
      } else {
        CodeReusability().showAlert(context, 'Please Check Your Internet Connection');
      }
    });
  }
}

final OrderScreenGlobalStateProvider =
StateNotifierProvider.autoDispose<OrderScreenGlobalStateNotifier, OrderScreenGlobalState>(
        (ref) => OrderScreenGlobalStateNotifier());
