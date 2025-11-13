import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  late SharedPreferences _prefManager;

  PreferencesManager._(SharedPreferences sharedPreferences) {
    _prefManager = sharedPreferences;
  }

  static Future<PreferencesManager> getInstance() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return PreferencesManager._(sharedPreferences);
  }

  void setStringValue(String keyName, String value) {
    _prefManager.setString(keyName, value);
  }

  String? getStringValue(String keyName) {
    return _prefManager.getString(keyName) ?? "";
  }

  void setAPIResponseStringValue(String keyName, String value) {
    _prefManager.setString(keyName, value);
  }

  String? getAPIResponseStringValue(String keyName) {
    return _prefManager.getString(keyName) ?? "";
  }

  void setBooleanValue(String keyName, bool value) {
    _prefManager.setBool(keyName, value);
  }

  bool getBooleanValue(String keyName) {
    return _prefManager.getBool(keyName) ?? false;
  }

  void setIntValue(String keyName, int value) {
    _prefManager.setInt(keyName, value);
  }

  int getIntValue(String keyName) {
    return _prefManager.getInt(keyName) ?? 0;
  }

  void removePref() {
    _prefManager.clear();
  }

  void removePrefValue(String val) {
    _prefManager.remove(val);
  }
}

class PreferenceKeys {
  //Authentication
  static String accessToken = 'accessToken';
  static String refreshToken = 'refreshToken';
  static String loginActivityId = 'loginActivityId';

  //User
  static String userID = 'userID';
  static String userFirstName = 'userFirstName';
  static String userLastName = 'userLastName';
  static String userEmailID = 'userEmailID';
  static String userAddress = 'userAddress';
  static String userMobileNumber = 'userMobileNumber';

  //count
  static String wishListCount = 'wishListCount';
  static String cartCount = 'cartCount';

  //User Location
  static String selectedLatitude = 'selectedLatitude';
  static String selectedLongitude = 'selectedLongitude';

  //Utility
  static String isUserLogged = 'isUserLogged';
  static String isDialogOpened = 'isDialogOpened';
  static String isLoadingBarStarted = "isLoadingBarStarted";

  //Device
  static String fcmToken = 'fcmToken';


}
