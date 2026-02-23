import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellerProfileScreenState {
  final String sellerID;
  final String name;
  final String bio;
  final int selectedTabIndex;

  SellerProfileScreenState({
    required this.sellerID,
    this.name = "Nourish Organics",
    this.bio = "Nourish Organics offers a premium selection of 100% organic products sourced responsibly from certified farms. Our mission is to provide clean, chemical-free, and naturally nourishing products that support a healthier lifestyle and a sustainable future.",
    this.selectedTabIndex = 0,
  });

  SellerProfileScreenState copyWith({int? selectedTabIndex}) {
    return SellerProfileScreenState(
      sellerID: sellerID,
      name: name,
      bio: bio,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}

class SellerProfileScreenStateNotifier
    extends StateNotifier<SellerProfileScreenState> {
  SellerProfileScreenStateNotifier() : super(SellerProfileScreenState(
      sellerID: '',
  ));

  void setTabIndex(int index) => state = state.copyWith(selectedTabIndex: index);

}

final sellerProfileScreenStateProvider = StateNotifierProvider.autoDispose<
    SellerProfileScreenStateNotifier, SellerProfileScreenState>((ref) {
  var notifier = SellerProfileScreenStateNotifier();
  return notifier;
});