import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../Utility/Logger.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import 'ReelsRepository.dart';
import 'ReelsModel.dart';

class ReelsScreenState {
  final List<ReelData> reelsList;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;

  ReelsScreenState({
    this.reelsList = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
  });

  ReelsScreenState copyWith({
    List<ReelData>? reelsList,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
  }) {
    return ReelsScreenState(
      reelsList: reelsList ?? this.reelsList,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ReelsGlobalStateNotifier extends StateNotifier<ReelsScreenState> {
  ReelsGlobalStateNotifier() : super(ReelsScreenState());

  Future<void> shareReel(BuildContext context, ReelData reel) async {
    try {
      final text = '''
Check out this amazing reel from BotaniQ Microgreens!

"${reel.caption}"

Watch now: ${reel.reelUrl}
''';

      await Share.share(
        text,
        subject: 'BotaniQ Microgreens Reels',
      );
    } catch (e) {
      Logger().log('Error sharing reel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to share this reel right now.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// ✅ FIXED PAGINATION & UI UPDATE
  Future<void> callReelsListAPI(BuildContext context, {bool loadMore = false}) async {
    if (state.isLoading) return;
    if (loadMore && !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    bool connected = await CodeReusability().isConnectedToNetwork();
    if (!connected) {
      CodeReusability().showAlert(context, "Please check your internet connection");
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final prefs = await PreferencesManager.getInstance();
      String userId = prefs.getStringValue(PreferenceKeys.userID) ?? '';

      final int nextPage = loadMore ? state.currentPage + 1 : 1;
      Map<String, dynamic> body = {
        "userId": userId,
        "page": nextPage,
        "limit": 10,
      };

      // ✅ Keep loading true until callback completes
      await ReelsRepository().callReelsListGETApi(body, (statusCode, responseBody) async {
        if (statusCode == 200) {
          final response = ReelsResponse.fromJson(responseBody);
          final newList = response.reels;
          final hasMore = newList.length >= response.limit;

          // 🧠 Prevent over-fetching
          final allLoaded = (state.reelsList.length + newList.length) >= response.totalReels;

          // ✅ Properly merge new items for loadMore
          final updatedList = loadMore ? [...state.reelsList, ...newList] : newList;

          state = state.copyWith(
            reelsList: updatedList,
            currentPage: nextPage,
            hasMore: !allLoaded && hasMore,
            isLoading: false, // ✅ set after successful update
          );

          Logger().log("### Reels Loaded: ${state.reelsList.length}/${response.totalReels}");
        } else {
          state = state.copyWith(isLoading: false);
          CodeReusability().showAlert(context, "Something went wrong!");
        }
      });
    } catch (e) {
      Logger().log("### Error in callReelsListAPI: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  /// Like / Dislike reel
  Future<void> callReelLikeAPI(BuildContext context, String reelId,
      bool isLiked, int index) async {
    bool connected = await CodeReusability().isConnectedToNetwork();
    if (!connected) return;

    final prefs = await PreferencesManager.getInstance();
    String userId = prefs.getStringValue(PreferenceKeys.userID) ?? '';

    Map<String, dynamic> body = {
      "reelId": reelId,
      "userId": userId,
      "isLiked": isLiked,
    };

    ReelsRepository().callReelsLikeDisLikeApi(
        body, (statusCode, responseBody) async {
      if (statusCode == 200) {
        final res = LikeReelResponse.fromJson(responseBody);
        Logger().log("### Like Response: ${res.message}");

        final updatedList = [...state.reelsList];
        if (index >= 0 && index < updatedList.length) {
          final oldReel = updatedList[index];
          final updatedReel = ReelData(
            reelId: oldReel.reelId,
            reelUrl: oldReel.reelUrl,
            caption: oldReel.caption,
            totalLikes: isLiked
                ? oldReel.totalLikes + 1
                : (oldReel.totalLikes > 0 ? oldReel.totalLikes - 1 : 0),
            isLikedByUser: isLiked,
          );

          updatedList[index] = updatedReel;
          state = state.copyWith(reelsList: updatedList);
        }
      }
    });
  }
}

final ReelsGlobalStateProvider =
StateNotifierProvider.autoDispose<ReelsGlobalStateNotifier, ReelsScreenState>(
        (ref) => ReelsGlobalStateNotifier());
