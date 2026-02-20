import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../Utility/NetworkImageLoader.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'ReelsModel.dart';
import 'ReelsScreenState.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ReelsScreenState createState() => ReelsScreenState();
}

class ReelsScreenState extends ConsumerState<ReelsScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final Map<int, VideoPlayerController> _controllers = {};
  int _focusedIndex = 0;
  bool _isSpeedUp = false;

  late AnimationController _heartController;
  late Animation<double> _heartAnimation;
  bool _isHeartVisible = false;
  Offset _heartPosition = Offset.zero;
  final Set<int> _expandedCaptions = {};
  bool _showReelsText = true;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _heartAnimation = CurvedAnimation(parent: _heartController, curve: Curves.elasticOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reelsGlobalStateProvider.notifier).callReelsListAPI(context);
    });
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _focusedIndex = index);
    _controllers.forEach((key, controller) {
      if (key == index) {
        // Requirement 4: Always play from start
        controller.seekTo(Duration.zero);
        controller.play();
        controller.setPlaybackSpeed(1.0);
      } else {
        controller.pause();
      }
    });

    final state = ref.read(reelsGlobalStateProvider);
    if (index + 1 < state.reelsList.length) _initController(index + 1);
    if (index >= state.reelsList.length - 2 && state.hasMore) {
      ref.read(reelsGlobalStateProvider.notifier).callReelsListAPI(context, loadMore: true);
    }
  }

  Future<void> _initController(int index) async {
    if (_controllers.containsKey(index)) return;
    final reels = ref.read(reelsGlobalStateProvider).reelsList;
    if (index >= reels.length) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(reels[index].reelUrl));
    _controllers[index] = controller;
    await controller.initialize();
    controller.setLooping(true);
    if (index == _focusedIndex) {
      controller.seekTo(Duration.zero);
      controller.play();
    }
    controller.addListener(() { if (mounted) setState(() {}); });
  }

  void _handleDoubleTap(Offset position, ReelData reel, int index) {
    setState(() { _heartPosition = position; _isHeartVisible = true; });
    _heartController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _isHeartVisible = false);
      });
    });
    if (!reel.isLikedByUser) {
      ref.read(reelsGlobalStateProvider.notifier).callReelLikeAPI(context, reel.reelId, true, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reelsGlobalStateProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: state.isLoading && state.reelsList.isEmpty
          ? _buildFullShimmer()
          : Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: state.reelsList.length,
            itemBuilder: (context, index) {
              _initController(index);
              return _buildReelItem(index, state.reelsList[index]);
            },
          ),
          if (_isHeartVisible)
            Positioned(
              left: _heartPosition.dx - 50,
              top: _heartPosition.dy - 50,
              child: ScaleTransition(
                scale: _heartAnimation,
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(colors: [Colors.red, Colors.orangeAccent]).createShader(rect),
                  child: Icon(Icons.favorite, size: 100.dp, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReelItem(int index, ReelData reel) {
    final controller = _controllers[index];
    final isInitialized = controller?.value.isInitialized ?? false;
    _showReelsText = index == 0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // VIDEO LAYER
        if (isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          )
        else
          _buildPartialShimmer(),

        _buildGradientOverlay(),

        // GESTURE ZONES
        Row(
          children: [
            // Left Edge: 2x Speed
            Expanded(
              flex: 1,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPressStart: (_) => _setSpeed(controller, true),
                onLongPressEnd: (_) => _setSpeed(controller, false),
                onDoubleTapDown: (d) => _handleDoubleTap(d.globalPosition, reel, index),
                onDoubleTap: () {},
              ),
            ),
            // Center Area: Play/Pause via Long Press + Single Tap
            Expanded(
              flex: 3,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPressStart: (_) {
                  if (isInitialized) controller!.pause();
                  setState(() {});
                },
                onLongPressEnd: (_) {
                  if (isInitialized) controller!.play();
                  setState(() {});
                },
                onTap: () {
                  /*if (isInitialized) {
                    controller!.value.isPlaying ? controller.pause() : controller.play();
                    setState(() {});
                  }*/
                },
                onDoubleTapDown: (d) => _handleDoubleTap(d.globalPosition, reel, index),
                onDoubleTap: () {},
              ),
            ),
            // Right Edge: 2x Speed
            Expanded(
              flex: 1,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPressStart: (_) => _setSpeed(controller, true),
                onLongPressEnd: (_) => _setSpeed(controller, false),
                onDoubleTapDown: (d) => _handleDoubleTap(d.globalPosition, reel, index),
                onDoubleTap: () {},
              ),
            ),
          ],
        ),


        Positioned(
          right: 10,
          bottom: 85,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isSpeedUp ? 0.0 : 1.0,
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: _isSpeedUp,
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

                      if (reel.isLikedByUser){
                        ref.read(reelsGlobalStateProvider.notifier).callReelLikeAPI(context, reel.reelId, false, index);
                      } else {
                        final size = MediaQuery
                            .of(context)
                            .size;
                        final centerPosition = Offset(
                          size.width / 2,
                          size.height / 2,
                        );
                        _handleDoubleTap(centerPosition, reel, index);
                      }
                    },
                  ),
                  customText(
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
                          .read(reelsGlobalStateProvider.notifier)
                          .shareReel(context, reel);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),



        Positioned(
          left: 15,
          bottom: 15,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isSpeedUp ? 0.0 : 1.0,
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: _isSpeedUp,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 40.dp,
                        height: 40.dp,
                        child: NetworkImageLoader(
                          imageUrl: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
                          placeHolder: objConstantAssest.placeHolder,
                          size: 40.dp,
                          imageSize: 40.dp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.dp),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          customText(
                            'Nourish Organics',
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
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: ConstrainedBox(
                              constraints: _expandedCaptions.contains(index)
                                  ? BoxConstraints(
                                maxHeight: 250.dp, //  Limit height when expanded
                              )
                                  : const BoxConstraints(),
                              child: SingleChildScrollView(
                                physics: _expandedCaptions.contains(index)
                                    ? const BouncingScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                                child: Text(
                                  reel.caption,
                                  softWrap: true,
                                  overflow: _expandedCaptions.contains(index)
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                  maxLines: _expandedCaptions.contains(index) ? null : 1,
                                  style: TextStyle(
                                    color: objConstantColor.white,
                                    fontSize: 10.dp,
                                    fontFamily: objConstantFonts.montserratMedium,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),



        Positioned(
          top: 0.dp,
          left: _showReelsText ? 15.dp : 0.dp,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isSpeedUp ? 0.0 : 1.0,
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: _isSpeedUp,
              child: SafeArea(
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
                            fontSize: 30.dp,
                            fontFamily: objConstantFonts.montserratSemiBold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        
        if (_isSpeedUp)
          Positioned(
            bottom: 15.dp, // Just above the slider
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  objCommonWidgets.customText(context, '2x Speed', 12, Colors.white, objConstantFonts.montserratSemiBold),
                  SizedBox(width: 5.dp),
                  Icon(Icons.fast_forward, color: Colors.white, size: 18.dp),
                ],
              ),
            ),
          ),


        if (isInitialized)
          Positioned(bottom: 3.5, left: 0, right: 0, child: _buildProgressBar(controller!)),
      ],
    );
  }

  void _setSpeed(VideoPlayerController? controller, bool speedUp) {
    if (controller == null || !controller.value.isInitialized) return;
    setState(() => _isSpeedUp = speedUp);
    controller.setPlaybackSpeed(speedUp ? 2.0 : 1.0);
  }

  Widget _buildProgressBar(VideoPlayerController controller) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: _isDragging ? 6.0 : 3.0, // 🔥 Thicker when dragging
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: _isDragging ? 6.0 : 0.0, // 👈 Show circle only when dragging
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: 1.0,
        ),
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white.withOpacity(0.2),
        thumbColor: Colors.white,
        overlayColor: Colors.white.withOpacity(0.2),
      ),
      child: Slider(
        value: controller.value.position.inMilliseconds
            .toDouble()
            .clamp(
          0,
          controller.value.duration.inMilliseconds.toDouble(),
        ),
        min: 0.0,
        max: controller.value.duration.inMilliseconds.toDouble(),

        onChangeStart: (_) {
          setState(() {
            _isDragging = true;
          });
        },

        onChanged: (value) {
          controller.seekTo(Duration(milliseconds: value.toInt()));
        },

        onChangeEnd: (_) {
          setState(() {
            _isDragging = false;
          });
        },
      ),
    );
  }


  // Requirement 3: Shimmer only for Header & Side Widgets
  Widget _buildPartialShimmer() {
    return Stack(
      children: [
        const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),

        Positioned(
          top: 0.dp,
          left: _showReelsText ? 15.dp : 0.dp,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isSpeedUp ? 0.0 : 1.0,
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: _isSpeedUp,
              child: SafeArea(
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
                            fontSize: 30.dp,
                            fontFamily: objConstantFonts.montserratSemiBold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullShimmer() => Container(color: Colors.black, child: _buildPartialShimmer());



  Widget _actionIcon(String iconPath, String label, {required VoidCallback onTap}) {
    return Column(
      children: [
        CupertinoButton(padding: EdgeInsets.zero, onPressed: onTap, child: Image.asset(iconPath, width: 28.dp, color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }



  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.5)],
              stops: const [0, 0.2, 0.8, 1],
            ),
          ),
        ),
      ),
    );
  }

  Widget customText(String text, int size, Color color, String font) {
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