import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();

  final List<String> reelsList = [
    'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138814/SnapInsta.to_AQMEqax1BBYme00g3Oilz6OfR0yauZcg-De76JVzGfzhmzXRoZzpvhqWGy9K_E3xI97wW83cKGrBgwSdEvCET5J5mIXr1BG9hE_Xh2o_ijsj79.mp4',
    'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138796/SnapInsta.to_AQPS9ds3-4d7WKpasvRKYAHJObMfSH_JHyDeW6Wc-34qzL93DNU1wfHMlRRpLfzby1xJJQAkC4NYxpvM85aOhiuPnBTbkftYD-lQVl4_vmt7cu.mp4',
    'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138792/SnapInsta.to_AQPyfoGS1yuPyVbgftcFiEHrg2aFc7cshSiKFe7EGn5CSKQLof-bMsm6z6nz8S3I6_zpCImPmcz17fkTSzC2xu0MtSz55Cc2sLkHE80_ounszk.mp4',
    'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138771/SnapInsta.to_AQPoGLAnqAl2aiYcWV_24tGgowtylD81l-utzuMmDIslGla8v3pCXJLmN3BnC_UuEXMTKbA1P-HZ-jlF8Qr3_F_Ga08syvLGZn7C0jI_isfnyr.mp4',
    'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138747/SnapInsta.to_AQPpZtQ7bKg2koYcilH1vUqdqu5SwE7yvrylBWK8QzvIbmCiLG567CIxzNVOEULRje8Kj6Bus4YQbEj7QQVrWSM5ACi6pcjIQS3mAFo_xukvql.mp4',
    'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138739/SnapInsta.to_AQOk0IcWRqTl3u_vSeoqrHhbOhFDG_WpWHNoATsWYJmT0eSgMMIBzo1UuQwBZuLRm5FDM4HWWPLkDNOFwTyH6AVBD8cdPEF7MXa6N3c_eeuhe1.mp4',
    'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138720/SnapInsta.to_AQOts8468lXOl27PrNJoK9VtNUvn-YVjowfVqJB6kfo1zFOGRqkU6ZUoFHufRpNkN2yNV8f4gaHu0-50iVane1jCO-wCX-zYlhwrNq0_yvbkyd.mp4',
    'https://res.cloudinary.com/dya1uuvah/video/upload/v1761138705/SnapInsta.to_AQNNFZPoa4YLTl7YB-S1one5dPHJL7Q-wcEVUwou_yQsiEQuUFcd844X8M2d46p1_eRdj5NBQ1ZZJoPityhT_7zp34XBT-JhohFVFO0_qg1ibq.mp4',
  ];

  final List<VideoPlayerController> _controllers = [];
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _showLike = false;
  Offset? _tapPosition;
  bool _showReelsText = true;



  @override
  void initState() {
    super.initState();

    // Init all controllers
    for (var url in reelsList) {
      final controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {});
        });
      _controllers.add(controller);
    }

    // Autoplay first video
    if (_controllers.isNotEmpty) {
      _controllers[0].play();
      _controllers[0].setLooping(true);
    }

    // Heart animation
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }



  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    _pageController.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _onSingleTap(VideoPlayerController controller) {
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  void _onDoubleTap({bool fromButton = false}) {
    setState(() {
      _showLike = true;
      if (fromButton) {
        _tapPosition = null; // 👈 force center if from button
      }
    });

    _likeAnimationController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _showLike = false);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: reelsList.length,
        onPageChanged: (index) {
          for (var c in _controllers) {
            c.pause();
          }
          _controllers[index].play();
          _controllers[index].setLooping(true);

          // 👇 Hide the text after leaving first reel
          setState(() {
            _showReelsText = index == 0;
          });
        },
        itemBuilder: (context, index) {
          final controller = _controllers[index];

          return GestureDetector(
            onTap: () => _onSingleTap(controller),
            onDoubleTap: _onDoubleTap,
            onDoubleTapDown: (details) { // 👈 capture where double tap happened
              _tapPosition = details.localPosition;
            },
            child: Stack(
              children: [
                // Background video
                controller.value.isInitialized
                    ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                )
                    : const Center(child: CircularProgressIndicator()),

                // Heart animation on double tap
                if (_showLike)
                  Positioned(
                    left: _tapPosition?.dx != null
                        ? _tapPosition!.dx - 40
                        : null,
                    // adjust offset
                    top: _tapPosition?.dy != null
                        ? _tapPosition!.dy - 40
                        : null,
                    right: _tapPosition == null ? 0 : null,
                    bottom: _tapPosition == null ? 0 : null,
                    child: Center( // only centers when from button
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
                  ),


                // 'Reels' Text Animation (top-left)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  top: _showReelsText ? 15.dp : -50.dp, // 👈 moves up to hide
                  left: 15.dp,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _showReelsText ? 1 : 0, // 👈 fades out smoothly
                    child: Text(
                      'Reels',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35.dp,
                        fontFamily: objConstantFonts.montserratSemiBold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),



                // Like & Share buttons
                Positioned(
                  right: 10,
                  bottom: 85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Image.asset(
                          objConstantAssest.heartIcon,
                          width: 25.dp,
                        ),
                        onPressed: () {
                          _onDoubleTap();
                        },
                      ),
                      customeText(
                        '1.2k',
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
                        onPressed: () {},
                      ),
                      customeText(
                        '786',
                        13,
                        objConstantColor.white,
                        objConstantFonts.montserratSemiBold,
                      ),

                      SizedBox(height: 15.dp),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Image.asset(
                          objConstantAssest.chatIcon,
                          width: 25.dp,
                        ),
                        onPressed: () {},
                      ),
                      customeText(
                        '152',
                        13,
                        objConstantColor.white,
                        objConstantFonts.montserratSemiBold,
                      ),
                    ],
                  ),
                ),

                // Profile bottom-left
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
                            width: 35.dp,
                            height: 35.dp,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.dp),
                      customeText(
                        'BotaniQ',
                        14,
                        objConstantColor.white,
                        objConstantFonts.montserratMedium,
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
