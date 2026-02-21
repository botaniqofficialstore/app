import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
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
  double _dragValue = 0.0;

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

        Positioned.fill(
          bottom: 60.dp,
          child: Row(
            children: [
              _buildGestureZone(controller, isInitialized, reel, index, 1),
              _buildGestureZone(controller, isInitialized, reel, index, 3, isCenter: true),
              _buildGestureZone(controller, isInitialized, reel, index, 1),
            ],
          ),
        ),

        headerView(),
        optionsView(reel, index),
        profileView(reel, index),

        if (_isDragging && isInitialized)
          _buildLiveScrubbingPreview(controller!),

        if (_isSpeedUp)
          Positioned(
            bottom: 40.dp,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customText('2x Speed', 12, Colors.white, objConstantFonts.montserratSemiBold),
                    SizedBox(width: 5.dp),
                    Icon(Icons.fast_forward, color: Colors.white, size: 18.dp),
                  ],
                ),
              ),
            ),
          ),

        if (isInitialized)
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: _buildProgressBar(controller!),
          ),
      ],
    );
  }

  Widget _buildGestureZone(VideoPlayerController? controller, bool init, ReelData reel, int index, int flex, {bool isCenter = false}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: (_) {
          if (isCenter) { if (init) controller!.pause(); }
          else { _setSpeed(controller, true); }
          setState(() {});
        },
        onLongPressEnd: (_) {
          if (isCenter) { if (init) controller!.play(); }
          else { _setSpeed(controller, false); }
          setState(() {});
        },
        onDoubleTapDown: (d) => _handleDoubleTap(d.globalPosition, reel, index),
      ),
    );
  }

  void _setSpeed(VideoPlayerController? controller, bool speedUp) {
    if (controller == null || !controller.value.isInitialized) return;
    setState(() => _isSpeedUp = speedUp);
    controller.setPlaybackSpeed(speedUp ? 2.0 : 1.0);
  }

  /// 👇 FIX 1: Removed AnimatedPositioned from inside the Row.
  /// Using AnimatedContainer and standard Alignment to avoid ParentData error.
  Widget headerView(){
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: (_isSpeedUp || _isDragging) ? 0.0 : 1.0,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.dp),
            child: Row(
              children: [
                if (!_showReelsText)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: Image.asset(objConstantAssest.backIcon, color: Colors.white, width: 25.dp),
                    onPressed: () => ref.read(MainScreenGlobalStateProvider.notifier).callNavigation(ScreenName.home),
                  ),
                if (_showReelsText)...{
                  SizedBox(width: 10.dp),
                  Text(
                    'Reels',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.dp,
                      fontFamily: objConstantFonts.montserratSemiBold,
                    ),
                  ),
                }
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget optionsView(ReelData reel, int index){
    return Positioned(
      right: 10,
      bottom: 120,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: (_isSpeedUp || _isDragging) ? 0.0 : 1.0,
        child: Column(
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Image.asset(reel.isLikedByUser ? objConstantAssest.likedIcon : objConstantAssest.disLikedIcon, width: 25.dp),
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
            customText('${reel.totalLikes}', 13, Colors.white, objConstantFonts.montserratSemiBold),
            SizedBox(height: 15.dp),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Image.asset(objConstantAssest.shareIcon, width: 25.dp),
              onPressed: () => ref.read(reelsGlobalStateProvider.notifier).shareReel(context, reel),
            ),
          ],
        ),
      ),
    );
  }

  /// 👇 FIX 2: Wrapped in Flexible/SizedBox to prevent Gray Screen (layout overflow)
  Widget profileView(ReelData reel, int index){
    return Positioned(
      left: 15,
      bottom: 25,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: (_isSpeedUp || _isDragging) ? 0.0 : 1.0,
        child: SizedBox(
          width: 75.w,
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
                    width: 38.dp,
                    height: 38.dp,
                    child: NetworkImageLoader(
                      imageUrl: 'https://drive.google.com/uc?id=1Rmn4MxWtMaV7sEXqxGszVWud8XuyeRnv',
                      placeHolder: objConstantAssest.placeHolder,
                      size: 38.dp,
                      imageSize: 38.dp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.dp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customText('Nourish Organics', 14, Colors.white, objConstantFonts.montserratSemiBold),
                    GestureDetector(
                      onTap: () => setState(() {
                        _expandedCaptions.contains(index) ? _expandedCaptions.remove(index) : _expandedCaptions.add(index);
                      }),
                      child: Text(
                        reel.caption,
                        maxLines: _expandedCaptions.contains(index) ? 5 : 1,
                        overflow: _expandedCaptions.contains(index) ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 11.dp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(VideoPlayerController controller) {
    double total = controller.value.duration.inMilliseconds.toDouble();
    double currentVal = _isDragging ? _dragValue : controller.value.position.inMilliseconds.toDouble();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: _isDragging ? 6.0 : 0.0),
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white30,
      ),
      child: Slider(
        value: currentVal.clamp(0.0, total > 0 ? total : 1.0),
        min: 0.0,
        max: total > 0 ? total : 1.0,
        onChangeStart: (val) { setState(() { _isDragging = true; _dragValue = val; }); controller.pause(); },
        onChanged: (val) { setState(() { _dragValue = val; }); controller.seekTo(Duration(milliseconds: val.toInt())); },
        onChangeEnd: (val) { setState(() => _isDragging = false); controller.seekTo(Duration(milliseconds: val.toInt())); controller.play(); },
      ),
    );
  }

  Widget _buildLiveScrubbingPreview(VideoPlayerController controller) {
    double screenWidth = MediaQuery.of(context).size.width;
    double duration = controller.value.duration.inMilliseconds.toDouble();
    double percent = _dragValue / (duration > 0 ? duration : 1);
    double previewWidth = 100.dp;
    double xPos = (percent * screenWidth) - (previewWidth / 2);
    xPos = xPos.clamp(15.0, screenWidth - previewWidth - 15.0);

    return Positioned(
      bottom: 60.dp,
      left: xPos,
      child: Column(
        children: [
          Container(
            width: previewWidth,
            height: 140.dp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: VideoPlayer(controller),
            ),
          ),
          SizedBox(height: 8.dp),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
            child: Text(_formatDuration(Duration(milliseconds: _dragValue.toInt())), style: TextStyle(color: Colors.white, fontSize: 11.dp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  Widget _buildPartialShimmer() => Stack(
    children: [
      headerView(),
      const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
    ],
  );
  Widget _buildFullShimmer() => Container(color: Colors.black, child: _buildPartialShimmer());

  Widget _buildGradientOverlay() => Positioned.fill(child: IgnorePointer(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black26, Colors.transparent, Colors.transparent, Colors.black54], stops: const [0, 0.2, 0.8, 1])))));

  Widget customText(String text, int size, Color color, String font) => Text(text, style: TextStyle(color: color, fontSize: size.dp, fontFamily: font));
}