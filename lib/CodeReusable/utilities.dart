
import 'dart:io';

//import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';


ScreenType screenSizeType = ScreenType.mobile;

class Utilities {

  ///This method used to check whether its an mobile or tablet.
  bool isMobile() {
    return screenSizeType == ScreenType.mobile;
  }

  ///This method used to check internet Connection.
  Future<bool> isConnectedToNetwork() async {
    return true;//await InternetConnectionChecker().hasConnection;
  }

  /// Generates a random UUID (v4)
  String generateUUID() {
    final Uuid _uuid = Uuid();
    return _uuid.v4();
  }


  ///This method is used to get device and app details
  /*Future<Map<String, String>> getDeviceAndAppInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId = 'Unknown Device ID';
    String platform = 'Unknown Platform';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id; // unique per device (not resettable)
      platform = 'Android';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'Unknown iOS ID';
      platform = 'iOS';
    }

    return {
      'deviceId': deviceId,
      'platform': platform,
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
  }*/

}

class PriceHelper {
  /// Calculate discount percentage between actual price and selling price
  /// Always returns a rounded value as String (e.g. "25%")
  static String getDiscountPercentage({
    required num productPrice,
    required num sellingPrice,
  }) {
    if (productPrice <= 0 || sellingPrice <= 0 || sellingPrice > productPrice) {
      return "0%";
    }

    final discount = ((productPrice - sellingPrice) / productPrice) * 100;
    final rounded = discount.round();
    return "$rounded%";
  }
}

