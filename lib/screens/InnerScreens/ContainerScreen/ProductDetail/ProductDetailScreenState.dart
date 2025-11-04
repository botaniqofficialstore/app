import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/Constants.dart';

class ProductDetailScreenGlobalState {
  final ScreenName currentModule;

  ProductDetailScreenGlobalState({
    this.currentModule = ScreenName.home,
  });

  ProductDetailScreenGlobalState copyWith({
    ScreenName? currentModule,
  }) {
    return ProductDetailScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
    );
  }
}

class ProductDetailScreenGlobalStateNotifier
    extends StateNotifier<ProductDetailScreenGlobalState> {
  ProductDetailScreenGlobalStateNotifier() : super(ProductDetailScreenGlobalState());

  @override
  void dispose() {
    super.dispose();
  }


}



final productDetailScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    ProductDetailScreenGlobalStateNotifier, ProductDetailScreenGlobalState>((ref) {
  var notifier = ProductDetailScreenGlobalStateNotifier();
  return notifier;
});

