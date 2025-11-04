import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/Constants.dart';

class ReelsScreenGlobalState {
  final ScreenName currentModule;

  ReelsScreenGlobalState({
    this.currentModule = ScreenName.home,
  });

  ReelsScreenGlobalState copyWith({
    ScreenName? currentModule,
  }) {
    return ReelsScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
    );
  }
}

class ReelsScreenGlobalStateNotifier
    extends StateNotifier<ReelsScreenGlobalState> {
  ReelsScreenGlobalStateNotifier() : super(ReelsScreenGlobalState());

  @override
  void dispose() {
    super.dispose();
  }


}



final ReelsScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    ReelsScreenGlobalStateNotifier, ReelsScreenGlobalState>((ref) {
  var notifier = ReelsScreenGlobalStateNotifier();
  return notifier;
});

