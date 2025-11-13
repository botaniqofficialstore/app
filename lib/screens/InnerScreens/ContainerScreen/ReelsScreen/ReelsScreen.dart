import 'package:botaniqmicrogreens/Utility/Logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:video_player/video_player.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../MainScreen/MainScreenState.dart';
import 'ReelsModel.dart';
import 'ReelsScreenState.dart';
import '../../../../constants/Constants.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ReelsScreenState createState() => ReelsScreenState();
}

class ReelsScreenState extends ConsumerState<ReelsScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final Map<int, VideoPlayerController> _videoControllers = {};
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  bool _showLike = false;
  bool _heartAtCenter = false;
  bool _showReelsText = true;
  bool _isPaginating = false;
  bool _initialReelsLoaded = false; // ✅ New flag for fast-first-load
  Offset? _tapPosition;
  final Set<int> _expandedCaptions = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ReelsGlobalStateProvider.notifier).callReelsListAPI(context);
    });

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _likeAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  // ✅ Optimized video initialization (avoids duplicate loads)
  Future<void> _initializeVideo(int index, String url) async {
    if (_videoControllers.containsKey(index)) return;
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      controller.setLooping(true);
      _videoControllers[index] = controller;
      if (mounted) setState(() {});
    } catch (e) {
      Logger().log("⚠️ Video init failed at index $index: $e");
    }
  }

  // ✅ Preload first and next reel immediately after API data ready
  void _initializeFirstReels(List<ReelData> reels) async {
    if (_initialReelsLoaded || reels.isEmpty) return;
    _initialReelsLoaded = true;

    await _initializeVideo(0, reels[0].reelUrl);
    _videoControllers[0]?.play();

    // Preload next quietly
    if (reels.length > 1) {
      _initializeVideo(1, reels[1].reelUrl);
    }
  }

  // ✅ Smooth page change handler
  void _onPageChanged(int index, List<ReelData> reels) {
    Logger().log('### Page changed to $index / total ${reels.length}');

    // Pause all videos
    for (var c in _videoControllers.values) {
      c.pause();
    }

    // Play current
    if (_videoControllers[index] != null) {
      _videoControllers[index]?.play();
    } else {
      _initializeVideo(index, reels[index].reelUrl).then((_) {
        _videoControllers[index]?.play();
      });
    }

    // Preload next
    if (index + 1 < reels.length) {
      _initializeVideo(index + 1, reels[index + 1].reelUrl);
    }

    // ✅ Pagination trigger (only once per scroll)
    if (!_isPaginating &&
        index >= reels.length - 2 &&
        ref.watch(ReelsGlobalStateProvider).hasMore) {
      Logger().log('### Triggering pagination for next page...');
      _isPaginating = true;
      ref
          .read(ReelsGlobalStateProvider.notifier)
          .callReelsListAPI(context, loadMore: true)
          .then((_) {
        _isPaginating = false;
      });
    }

    setState(() {
      _showReelsText = index == 0;
    });
  }

  // ❤️ Like handling
  void _handleLikeAction(ReelData reel, int index, {required bool fromButton}) {
    final isLiked = reel.isLikedByUser;

    if (fromButton) {
      if (!isLiked) {
        _showHeartAnimation(center: true);
        ref
            .read(ReelsGlobalStateProvider.notifier)
            .callReelLikeAPI(context, reel.reelId, true, index);
      } else {
        ref
            .read(ReelsGlobalStateProvider.notifier)
            .callReelLikeAPI(context, reel.reelId, false, index);
      }
      return;
    }

    if (!isLiked) {
      _showHeartAnimation(center: false);
      ref
          .read(ReelsGlobalStateProvider.notifier)
          .callReelLikeAPI(context, reel.reelId, true, index);
    } else {
      _showHeartAnimation(center: false);
    }
  }

  void _showHeartAnimation({required bool center}) {
    setState(() {
      _showLike = true;
      _heartAtCenter = center;
      if (center) _tapPosition = null;
    });

    _likeAnimationController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _showLike = false;
            _heartAtCenter = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ReelsGlobalStateProvider);
    final reels = state.reelsList;

    // ✅ Initialize first and next reels after API load
    if (reels.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFirstReels(reels);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: state.isLoading && reels.isEmpty
          ? Center(child: CircularProgressIndicator(color: objConstantColor.navyBlue))
          : PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: reels.length,
        onPageChanged: (i) {
          if (i < reels.length) _onPageChanged(i, reels);
        },
        itemBuilder: (context, index) {
          final reel = reels[index];
          final controller = _videoControllers[index];

          if (controller == null || !controller.value.isInitialized) {
            return Center(
              child: CircularProgressIndicator(color: objConstantColor.navyBlue),
            );
          }

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTapDown: (details) {
              _tapPosition = details.localPosition;
            },
            onDoubleTap: () {
              _handleLikeAction(reel, index, fromButton: false);
            },
            child: Stack(
              children: [
                // 🎥 Video player
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),

                // ❤️ Heart animation
                if (_showLike)
                  (_heartAtCenter
                      ? Positioned.fill(
                    child: Center(
                      child: ScaleTransition(
                        scale: _likeAnimation,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                                colors: [Colors.red, Colors.orange],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                          child: Icon(
                            Icons.favorite,
                            size: 80.dp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                      : (_tapPosition != null
                      ? Positioned(
                    left: _tapPosition!.dx - 40,
                    top: _tapPosition!.dy - 40,
                    child: ScaleTransition(
                      scale: _likeAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            const LinearGradient(
                              colors: [Colors.red, Colors.orange],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                        child: Icon(
                          Icons.favorite,
                          size: 80.dp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                      : Positioned.fill(
                    child: Center(
                      child: ScaleTransition(
                        scale: _likeAnimation,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                                colors: [Colors.red, Colors.orange],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                          child: Icon(
                            Icons.favorite,
                            size: 80.dp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ))),

                // 🔹 Reels header
                Positioned(
                  top: 10.dp,
                  left: _showReelsText ? 15.dp : 0.dp,
                  child: Row(
                    children: [
                      if (!_showReelsText)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            objConstantAssest.backIcon,
                            color: objConstantColor.white,
                            width: 25.dp,
                          ),
                          onPressed: () {
                            ref
                                .watch(MainScreenGlobalStateProvider.notifier)
                                .callNavigation(ScreenName.home);
                          },
                        ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        top: _showReelsText ? 15.dp : -50.dp,
                        left: 15.dp,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _showReelsText ? 1 : 0,
                          child: Text(
                            'Reels',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 35.dp,
                              fontFamily:
                              objConstantFonts.montserratSemiBold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 👉 Right side buttons (like/share)
                Positioned(
                  right: 10,
                  bottom: 85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Image.asset(
                          reel.isLikedByUser
                              ? objConstantAssest.likedIcon
                              : objConstantAssest.disLikedIcon,
                          width: 25.dp,
                        ),
                        onPressed: () {
                          _handleLikeAction(reel, index, fromButton: true);
                        },
                      ),
                      customeText(
                        '${reel.totalLikes}',
                        13,
                        objConstantColor.white,
                        objConstantFonts.montserratSemiBold,
                      ),
                      SizedBox(height: 15.dp),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Image.asset(
                          objConstantAssest.shareIcon,
                          width: 25.dp,
                        ),
                        onPressed: () {
                          ref
                              .read(ReelsGlobalStateProvider.notifier)
                              .shareReel(context, reel);
                        },
                      ),
                    ],
                  ),
                ),

                // 👤 Profile & caption
                Positioned(
                  left: 15,
                  bottom: 25,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            objConstantAssest.logo,
                            width: 37.dp,
                            height: 37.dp,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.dp),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              customeText(
                                'BotaniQ',
                                14,
                                objConstantColor.white,
                                objConstantFonts.montserratSemiBold,
                              ),
                              SizedBox(width: 2.dp),
                              Image.asset(
                                objConstantAssest.verifiedIcon,
                                width: 15.dp,
                                height: 15.dp,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_expandedCaptions.contains(index)) {
                                  _expandedCaptions.remove(index);
                                } else {
                                  _expandedCaptions.add(index);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 65.w,
                              constraints: const BoxConstraints(
                                minHeight: 0,
                                maxHeight: double.infinity,
                              ),
                              child: AnimatedSize(
                                duration:
                                const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: Text(
                                  reel.caption,
                                  softWrap: true,
                                  overflow:
                                  _expandedCaptions.contains(index)
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                  maxLines:
                                  _expandedCaptions.contains(index)
                                      ? null
                                      : 1,
                                  style: TextStyle(
                                    color: objConstantColor.white,
                                    fontSize: 12.dp,
                                    fontFamily: objConstantFonts
                                        .montserratMedium,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget customeText(String text, int size, Color color, String font) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: size.dp,
        fontFamily: font,
      ),
    );
  }
}
