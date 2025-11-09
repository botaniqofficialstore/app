import 'dart:io';
import 'package:intl/intl.dart';
import 'package:botaniqmicrogreens/Utility/Logger.dart';
import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../Utility/PreferencesManager.dart';

class CodeReusability {

  ///This method used to hide keyboard
  static void hideKeyboard(BuildContext context) {
    if (!context.mounted) return;
    FocusScope.of(context).requestFocus(FocusNode());
  }

  ///This function is used to check a string is empty or not
  ///
  ///[string] - used to send string text.
  static bool isEmptyOrWhitespace(String string) {
    return string.trim().isEmpty;
  }

  ///This method used to check internet Connection.
  Future<bool> isConnectedToNetwork() async {
    return await InternetConnection().hasInternetAccess;
  }


  ///This function is used to check a string is valid email or mobile number
  ///
  ///[bool] - used to send valid or not.
  static bool isValidMailOrMobile(String input) {
    // Regex for 10-digit mobile number (Indian-style, starting with 6–9)
    final RegExp mobileRegex = RegExp(r'^[6-9]\d{9}$');

    // Regex for valid Gmail address
    final RegExp gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');

    if (mobileRegex.hasMatch(input)) {
      print("✅ Valid 10-digit mobile number");
      return true;
    } else if (gmailRegex.hasMatch(input)) {
      print("✅ Valid Gmail address");
      return true;
    } else {
      print("❌ Invalid input: neither mobile number nor Gmail");
      return false;
    }
  }

  ///This function is used to check a string is valid email
  ///
  ///[bool] - used to send valid or not.
  static bool isValidEmail(String input) {
    // Regex for 10-digit mobile number (Indian-style, starting with 6–9)
    final RegExp mobileRegex = RegExp(r'^[6-9]\d{9}$');

    // Regex for valid Gmail address
    final RegExp gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');

    if (gmailRegex.hasMatch(input)) {
      print("✅ Valid Gmail address");
      return true;
    } else {
      print("❌ Invalid input: neither mobile number nor Gmail");
      return false;
    }
  }


  ///This method is used to check the string is valid mobile number
  bool isEmail(String input) {
    // Basic email regex
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    // Check if input matches email pattern
    if (emailRegex.hasMatch(input.trim())) {
      return true; // It's an email
    } else {
      return false; // Not an email (assume mobile)
    }
  }

///This method is used to mask the email or mobile number
  String maskEmailOrMobile(String input) {
    input = input.trim();

    // Check if it's an email
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (emailRegex.hasMatch(input)) {
      // Email masking
      int atIndex = input.indexOf('@');
      if (atIndex <= 2) {
        // If email username is too short, mask all except first char
        return '${input[0]}${'*' * (atIndex - 1)}${input.substring(atIndex)}';
      }
      String visible = input.substring(atIndex - 2, input.length); // last 2 chars before @ and domain
      String masked = '*' * (atIndex - 2);
      return masked + visible;
    } else {
      // Assume mobile number masking
      if (input.length <= 4) {
        return '*' * (input.length - 1) + input.substring(input.length - 1);
      }
      String visible = input.substring(input.length - 5); // show last 5 digits
      String masked = '*' * (input.length - visible.length);
      return masked + visible;
    }
  }


  ///This function is used to check a string is valid mobile number
  ///
  ///[bool] - used to send valid or not.
  static bool isValidMobileNumber(String input) {
    // Regex for 10-digit mobile number (Indian-style, starting with 6–9)
    final RegExp mobileRegex = RegExp(r'^[6-9]\d{9}$');

    if (mobileRegex.hasMatch(input)) {
      print("✅ Valid 10-digit mobile number");
      return true;
    } else {
      print("❌ Invalid input: neither mobile number nor Gmail");
      return false;
    }
  }

  ///This function is used to check the password is valid or noyt
  ///
  ///[bool] - used to send valid or not.
  static bool isPasswordValid(String password) {
    // Define regex patterns for each rule
    final hasMinLength = password.length >= 8;
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);

    // Check if all conditions are met
    return hasMinLength && hasLowercase && hasUppercase && hasNumber && hasSpecialChar;
  }


  ///This method is used to delete the 'Microgreens' text
  String cleanProductName(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.split(RegExp(r'\s+'));
    final filtered = parts.where((w) => w.toLowerCase() != 'microgreens').toList();
    return filtered.join(' ').trim();
  }

  ///This method is used to convert UTC date to local date and time
  String convertUTCToIST(String utcString) {
    try {
      // Parse the UTC date string
      DateTime utcDateTime = DateTime.parse(utcString);

      // Convert to local IST (India Standard Time)
      // IST = UTC + 5 hours 30 minutes
      DateTime istDateTime = utcDateTime.add(const Duration(hours: 5, minutes: 30));

      // Format as "dd/MM/yyyy hh:mm a"
      String formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(istDateTime);

      return formattedDate;
    } catch (e) {
      // In case of invalid format
      return "";
    }
  }


  ///This method used to show alert dialog.
  ///
  ///[title] - This param used to pass Title of Alert
  ///[message] - This Param used to pass Alert Message
  void showAlert(BuildContext context, String message,
      {String title = '', VoidCallback? action, bool barrierDismiss = true}) {
    if (!context.mounted) return;
    if (Platform.isIOS) {
      FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
        alertStyle: AlertButtonStyle.ok,
      ).then((_) {
        if (action != null) {
          action();
        }
      });
    } else {
      PreferencesManager.getInstance().then((pref) {
        pref.setBooleanValue(PreferenceKeys.isDialogOpened, true);
        showDialog(
          barrierDismissible: barrierDismiss,
          context: context,
          builder: (BuildContext context) {
            return PopScope(
                onPopInvokedWithResult: (v, b) async {
                  pref.setBooleanValue(PreferenceKeys.isDialogOpened, false);
                  Logger().log("##POPUP DISMISSED");
                },
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: objConstantColor.white,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.dp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 1.h),
                        Text(
                          message,
                          textScaler: TextScaler.noScaling,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.dp,
                            fontFamily: objConstantFonts.montserratSemiBold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        const Divider(),
                        TextButton(
                          onPressed: () {
                            pref.setBooleanValue(
                                PreferenceKeys.isDialogOpened, false);
                            Navigator.of(context).pop();
                            if (action != null) {
                              action();
                            }
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Text( 'Ok',
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                fontSize:
                                16.dp,
                                fontFamily: objConstantFonts.montserratMedium,
                                color: objConstantColor.navyBlue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          },
        );
      });
    }
  }

}