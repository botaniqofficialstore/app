// ImageCropScreen.dart
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropScreen extends StatefulWidget {
  final String imagePath;
  const ImageCropScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  bool _processing = false;

  Future<void> _cropImage() async {
    setState(() {
      _processing = true;
    });

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.imagePath,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.yellow,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    setState(() {
      _processing = false;
    });

    if (croppedFile == null) {
      Navigator.of(context).pop(null); // user cancelled crop
    } else {
      Navigator.of(context).pop(croppedFile.path);
    }
  }

  @override
  void initState() {
    super.initState();
    // auto open crop when screen mounts
    WidgetsBinding.instance.addPostFrameCallback((_) => _cropImage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: _processing
              ? CircularProgressIndicator()
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Preparing crop...'),
            ],
          ),
        ),
      ),
    );
  }
}
