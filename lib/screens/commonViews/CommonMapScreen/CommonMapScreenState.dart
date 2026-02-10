import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Constants/Constants.dart';

class CommonMapScreenState {
  final ScreenName currentModule;

  CommonMapScreenState({
    this.currentModule = ScreenName.home,
  });

  CommonMapScreenState copyWith({
    ScreenName? currentModule,
  }) {
    return CommonMapScreenState(
      currentModule: currentModule ?? this.currentModule,
    );
  }
}

class CommonMapScreenStateNotifier extends StateNotifier<CommonMapScreenState> {
  CommonMapScreenStateNotifier() : super(CommonMapScreenState());

  @override
  void dispose() {
    super.dispose();
  }

}


final commonMapScreenStateProvider = StateNotifierProvider.autoDispose<
    CommonMapScreenStateNotifier, CommonMapScreenState>((ref) {
  var notifier = CommonMapScreenStateNotifier();
  return notifier;
});