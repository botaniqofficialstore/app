import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../Utility/ImageCropScreen.dart';
import 'package:path/path.dart' as p;

class MediaHandler {

  final ImagePicker _picker = ImagePicker();

  Future<String?> handleCommonMediaPicker(
      BuildContext context,
      ImageSource source,
      ) async {
    try {
      final hasPermission =
      await _checkAndRequestPermission(context, source);
      if (!hasPermission) return null;

      XFile? pickedFile;

      try {
        pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 100,
          requestFullMetadata: true,
        );
      } catch (_) {
        // Xiaomi sometimes throws silently
      }

      /// 🔥 REDMI / XIAOMI FIX
      /// If preview → select kills activity, recover image here
      if (pickedFile == null && Platform.isAndroid) {
        final LostDataResponse response =
        await _picker.retrieveLostData();
        if (!response.isEmpty && response.file != null) {
          pickedFile = response.file;
        }
      }

      if (pickedFile == null) return null;

      /// Crop screen
      final String? croppedPath =
      await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) =>
              ImageCropScreen(imagePath: pickedFile!.path),
        ),
      );

      if (croppedPath == null) return null;

      /// Compress
      return await _compressImage(croppedPath);

    } catch (e, st) {
      debugPrint('Media pick error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to select image')),
      );
      return null;
    }
  }

  Future<bool> _checkAndRequestPermission(
      BuildContext context,
      ImageSource source,
      ) async {

    /// CAMERA
    if (source == ImageSource.camera) {
      final status = await Permission.camera.status;
      if (status.isGranted) return true;

      final res = await Permission.camera.request();
      if (res.isGranted) return true;

      if (res.isPermanentlyDenied) {
        await _openSettingsDialog(
          context,
          'Camera permission is permanently denied.',
        );
      }
      return false;
    }

    /// GALLERY (Android + iOS safe)
    final Permission permission = Permission.photos;

    final status = await permission.status;
    if (status.isGranted) return true;

    final res = await permission.request();
    if (res.isGranted) return true;

    if (res.isPermanentlyDenied) {
      await _openSettingsDialog(
        context,
        'Gallery permission is permanently denied.',
      );
    }
    return false;
  }

  Future<void> _openSettingsDialog(
      BuildContext context,
      String message,
      ) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<String> _compressImage(String inputPath) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'img_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      inputPath,
      targetPath,
      quality: 88,
      keepExif: true,
    );

    return result?.path ?? inputPath;
  }
}
