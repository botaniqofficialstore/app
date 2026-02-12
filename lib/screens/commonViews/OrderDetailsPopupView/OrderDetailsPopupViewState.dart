import 'package:botaniqmicrogreens/screens/commonViews/ReturnRequestPopup/ReturnRequestPopup.dart';

import '../../../constants/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ProductRatingScreen.dart';
import '../ReturnRequestSuccessPopup.dart';
import '../ReviewSuccessPopup.dart';

class OrderDetailsPopupViewState {
  final Map<String, dynamic> allProducts;
  final List<String> steps;
  final bool enableReturnRequest;

  OrderDetailsPopupViewState({
    required this.allProducts,
    required this.steps,
    required this.enableReturnRequest,
  });

  OrderDetailsPopupViewState copyWith({
    Map<String, dynamic>? allProducts,
    List<String>? steps,
    bool? enableReturnRequest
  }) {
    return OrderDetailsPopupViewState(
      allProducts: allProducts ?? this.allProducts,
      steps: steps ?? this.steps,
        enableReturnRequest: enableReturnRequest ?? this.enableReturnRequest
    );
  }
}

class OrderDetailsPopupViewStateNotifier
    extends StateNotifier<OrderDetailsPopupViewState> {
  OrderDetailsPopupViewStateNotifier() : super(OrderDetailsPopupViewState(
    allProducts: {},
    steps: [],
      enableReturnRequest: false
  ));

  void loadInitialData(Map<String, dynamic> allProducts){
    final trackSteps = allProducts['returned'] ? returnSteps : steps;
    final isReturned = allProducts['returned'];

    state = state.copyWith(allProducts: allProducts, steps: trackSteps, enableReturnRequest: !isReturned);
  }


  void openRatingsAndReview(BuildContext context) async {
    final Map<String, dynamic>? result =
    await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) =>
      const ProductRatingScreen(),
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
      final int rating = result['rating'];
      final String review = result['review'];

      // Call API / show success popup
      ReviewSuccessPopup.show(context);
    }
  }

  void openReturnRequest(BuildContext context) async {
    final Map<String, dynamic>? result =
    await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) =>
      const ReturnRequestPopup(),
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
      Navigator.pop(context);
      ReturnRequestSuccessPopup.show(context);

    }
  }

}


final orderDetailsPopupViewStateProvider = StateNotifierProvider.autoDispose<
    OrderDetailsPopupViewStateNotifier, OrderDetailsPopupViewState>((ref) {
  var notifier = OrderDetailsPopupViewStateNotifier();
  return notifier;
});