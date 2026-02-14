import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class NetworkImageLoader extends StatefulWidget {
  final String imageUrl;
  final String placeHolder;
  final double size;
  final double imageSize;

  /// NEW: Local image flag
  final bool isLocal;
  final int topCurve;
  final int bottomCurve;

  const NetworkImageLoader({
    super.key,
    required this.imageUrl,
    required this.placeHolder,
    required this.size,
    required this.imageSize,
    this.isLocal = false,
    this.topCurve = 10,
    this.bottomCurve = 0,
  });

  @override
  State<NetworkImageLoader> createState() =>
      _NetworkImageWithLoaderState();
}

class _NetworkImageWithLoaderState extends State<NetworkImageLoader> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _isLoaded = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.topCurve.dp),
          bottom: Radius.circular(widget.bottomCurve.dp),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(widget.topCurve.dp),
            bottom: Radius.circular(widget.bottomCurve.dp)
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [

            /// PLACEHOLDER (always visible initially)
            Image.asset(
              widget.placeHolder,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
              color: Colors.black26,
            ),

            /// ---------------- LOCAL IMAGE FLOW ----------------
            if (widget.isLocal)
              Image.file(
                File(widget.imageUrl),
                height: widget.imageSize,
                width: widget.imageSize,
                fit: BoxFit.cover,
              )

            /// ---------------- NETWORK IMAGE FLOW (UNCHANGED) ----------------
            else
              Image.network(
                widget.imageUrl,
                width: widget.imageSize,
                height: widget.imageSize,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, _) {
                  if (frame != null && !_isLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _isLoaded = true);
                    });
                  }
                  return AnimatedOpacity(
                    opacity: _isLoaded ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  );
                },
                errorBuilder: (_, __, ___) {
                  return Image.asset(
                    widget.placeHolder,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.cover,
                    color: Colors.black26,
                  );
                },
              ),

            /// iOS LOADER (only for network images)
            if (!widget.isLocal && !_isLoaded)
              const CupertinoActivityIndicator(
                radius: 12,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }
}
