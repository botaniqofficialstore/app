import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/Constants.dart';


class InformationScreenGlobalState {
  final ScreenName currentModule;
  final String currentPage;

  InformationScreenGlobalState({
    this.currentModule = ScreenName.home,
    required this.currentPage
  });

  InformationScreenGlobalState copyWith({
    ScreenName? currentModule,
    String? currentPage
  }) {
    return InformationScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      currentPage: currentPage ?? this.currentPage
    );
  }
}

class InformationScreenGlobalStateNotifier
    extends StateNotifier<InformationScreenGlobalState> {
  InformationScreenGlobalStateNotifier() : super(InformationScreenGlobalState(currentPage: ''

  ));

  @override
  void dispose() {
    super.dispose();
  }

  ///This method is used to get the user profile details from local
  Future<void> updatePageDetails() async {
    state = state.copyWith(currentPage: getPolicyTitle(selectedLegalInformation!));
  }

  String getPolicyTitle(ScreenName screen) {
    switch (screen) {
      case ScreenName.privacyPolicy:
        return 'Privacy Policy';

      case ScreenName.termsAndCondition:
        return 'Terms & Conditions';

      case ScreenName.refundPolicy:
        return 'Refund Policy';

      case ScreenName.shippingPolicy:
        return 'Shipping Policy';

      case ScreenName.aboutUS:
        return 'About Us';

      default:
        return '';
    }
  }




}



final InformationScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    InformationScreenGlobalStateNotifier, InformationScreenGlobalState>((ref) {
  var notifier = InformationScreenGlobalStateNotifier();
  return notifier;
});

