import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../constants/ConstantVariables.dart';

class CyclingText extends StatefulWidget {
  const CyclingText({super.key});

  @override
  State<CyclingText> createState() => _CyclingTextState();
}

class _CyclingTextState extends State<CyclingText> {
  int _index = 0;
  final List<String> _texts = [
    "Place the pin at exact delivery location",
    "Order will be delivered here"
  ];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _texts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600), // Slightly longer for a smoother "roll"
      transitionBuilder: (Widget child, Animation<double> animation) {
        // This identifies if the current child is the one entering or leaving
        final isEntering = child.key == ValueKey<int>(_index);

        // Offset for the slide:
        // Entering text starts at (0, 1) [bottom] and goes to (0, 0)
        // Exiting text starts at (0, 0) and goes to (0, -1) [top]
        final offsetAnimation = Tween<Offset>(
          begin: isEntering ? const Offset(0.0, 1.0) : const Offset(0.0, -1.0),
          end: Offset.zero,
        ).animate(animation);

        return ClipRect( // Clips the text so it doesn't overlap other UI elements while moving
          child: SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
      // Important: Ensure the container doesn't jump size during transition
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.centerLeft, // Matches your CrossAxisAlignment.start
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: Text(
        _texts[_index],
        key: ValueKey<int>(_index),
        style: TextStyle(
          fontSize: 10.dp,
          color: const Color(0xFF6C6B6B),
          fontFamily: objConstantFonts.montserratSemiBold,
        ),
      ),
    );
  }
}