import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class ScrollingImageBackground extends StatefulWidget {
  final List<String> imageList;
  final Duration duration;

  const ScrollingImageBackground({
    super.key,
    required this.imageList,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ScrollingImageBackground> createState() => _ScrollingImageBackgroundState();
}

class _ScrollingImageBackgroundState extends State<ScrollingImageBackground> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Pre-cache images to prevent flickering on first load
  @override
  void didChangeDependencies() {
    for (var path in widget.imageList) {
      precacheImage(AssetImage(path), context);
    }
    super.didChangeDependencies();
  }

  void _startTimer() {
    _timer = Timer.periodic(widget.duration, (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.imageList.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Stack(
        children: widget.imageList.asMap().entries.map((entry) {
          int index = entry.key;
          String path = entry.value;

          return AnimatedOpacity(
            // Duration of the fade itself (should be shorter than widget.duration)
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            opacity: _currentIndex == index ? 1.0 : 0.0,
            child: Image.asset(
              path,
              width: double.infinity,
              height: 52.h,
              fit: BoxFit.cover, // Cover is usually smoother for backgrounds than fitHeight
            ),
          );
        }).toList(),
      ),
    );
  }
}