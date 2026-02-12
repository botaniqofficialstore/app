import 'package:botaniqmicrogreens/screens/commonViews/OrderDetailsPopupView/OrderDetailsPopupView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../commonViews/ProductRatingScreen.dart';
import '../../../commonViews/ReviewSuccessPopup.dart';

class OrderHistoryScreenState {
  final List<Map<String, dynamic>> allProducts;

  OrderHistoryScreenState({
    required this.allProducts,
  });

  OrderHistoryScreenState copyWith({
    List<Map<String, dynamic>>? allProducts,
  }) {
    return OrderHistoryScreenState(
      allProducts: allProducts ?? this.allProducts,
    );
  }
}

class OrderHistoryScreenStateNotifier
    extends StateNotifier<OrderHistoryScreenState> {
  OrderHistoryScreenStateNotifier() : super(OrderHistoryScreenState(
      allProducts: _getSampleData(),
  ));

  static List<Map<String, dynamic>> _getSampleData() {
    return [
      {
        'id': 1,
        'count': 1,
        'name': 'Radish Pink Microgreen',
        'price': '189',
        'quantity': '250 gm',
        'returned': false,
        'image': 'https://botaniqofficialstore.github.io/botaniqofficialstore/assets/microgreens/radhishPink_Micro.png',
        'deliveryDate' : '10/01/2026 10:35 AM',
        'rating' : 4
      },
      {
        'id': 2,
        'count': 2,
        'name': 'Beetroot Microgreens',
        'price': '219',
        'quantity': '100 gm',
        'returned': false, 
        'image': 'https://botaniqofficialstore.github.io/botaniqofficialstore/assets/microgreens/betroot_Micro.png',
        'deliveryDate' : '10/12/2025 10:35 AM',
        'rating' : 0
      },
      {
        'id': 3,
        'count': 1,
        'name': 'Body Lotion',
        'price': '589',
        'quantity': '80 ml',
        'returned': true, // Under Verification
        'image': 'https://drive.google.com/uc?export=view&id=1bGeGt3KwsA9qxgye6_xyTlumIXJ9dB6w',
        'deliveryDate' : '10/01/2026 10:35 AM',
        'rating' : 4
      },
      {
        'id': 4,
        'count': 1,
        'name': 'Saffron',
        'price': '349',
        'quantity': '50 gm',
        'returned': false, 
        'image': 'https://drive.google.com/uc?export=view&id=1a-gMZQnJ8Wb-vIHWuN096fihPYlFfb8M',
        'deliveryDate' : '10/01/2026 10:35 AM',
        'rating' : 3
      },
      {
        'id': 5,
        'count': 1,
        'name': 'Ayurvedic Oil',
        'price': '499',
        'quantity': '250 ml',
        'returned': false, // Under Verification
        'image': 'https://drive.google.com/uc?export=view&id=1xMbrdOw0U2fQgd5lg-Vjc8qYLCMCBRfx',
        'deliveryDate' : '10/01/2026 10:35 AM',
        'rating' : 0
      },
      {
        'id': 6,
        'count': 1,
        'name': 'Beard Oil',
        'price': '750',
        'quantity': '100 ml',
        'returned': false, 
        'image': 'https://drive.google.com/uc?export=view&id=1RrgnKP-jwliXtrX8wT9QZQkYRvKgwt-e',
        'deliveryDate' : '10/01/2026 10:35 AM',
        'rating' : 0
      },
      {
        'id': 7,
        'count': 1,
        'name': 'Face Cream',
        'price': '349',
        'quantity': '100 gm',
        'returned': true, 
        'image': 'https://drive.google.com/uc?export=view&id=11DFsZtITk6NZKAnHGM8hDL8iO-LQ4n5Y',
        'deliveryDate' : '10/01/2026 10:35 AM',
        'rating' : 0
      },
      {
        'id': 8,
        'count': 1,
        'name': 'Ayurvedic Hair Oil',
        'price': '689',
        'quantity': '200 ml',
        'returned': false, // Under Verification
        'image': 'https://drive.google.com/uc?export=view&id=1yRv8IO_7AOrpmiVI37YzF88bpDPlV1Pd',
        'deliveryDate' : '10/01/2026 10:35 AM',
        'rating' : 4
      },
      {
        'id': 10,
        'count': 2,
        'name': 'Kerala Spices',
        'price': '199',
        'quantity': '100 gm',
        'returned': false, 
        'image': 'https://drive.google.com/uc?export=view&id=18sWwbn5yEI5yk2b1F9lYjd3HoH1kVgwx',
        'deliveryDate' : '10/01/2026 10:35 AM',
        'rating' : 4
      },
    ];
  }

  void callDetailsScreenNavigation(BuildContext context, Map<String, dynamic> product){
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => OrderDetailsPopupView(product),
      ),
    );
  }


  void openRatingsAndReview(BuildContext context) async {
    final Map<String, dynamic>? result =
    await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Benefits',
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

}


final orderHistoryScreenStateProvider = StateNotifierProvider.autoDispose<
    OrderHistoryScreenStateNotifier, OrderHistoryScreenState>((ref) {
  var notifier = OrderHistoryScreenStateNotifier();
  return notifier;
});