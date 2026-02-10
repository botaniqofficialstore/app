import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:botaniqmicrogreens/Utility/Logger.dart';
import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../Constants/Constants.dart';
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

  bool isNotValidUrl(String url) {
    // 1. Try to parse the string into a Uri object
    final uri = Uri.tryParse(url);

    // 2. Check if parsing was successful and if it contains necessary components
    if (uri != null && uri.hasAbsolutePath && uri.scheme.startsWith('http')) {
      // Optional: Ensure there is a dot in the host (e.g., "google.com" vs "localhost")
      if (uri.host.contains('.')) {
        return false;
      }

      // Allow 'localhost' for development purposes if needed
      if (uri.host == 'localhost') {
        return false;
      }
    }

    return true;
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

  Future<String> getAddressFromPosition(String position) async {
    try {
      // Split the string and extract latitude & longitude
      final parts = position.split(',');
      if (parts.length != 2) {
        throw FormatException("Invalid position format. Expected 'lat, lng'");
      }

      final latitude = double.parse(parts[0].trim());
      final longitude = double.parse(parts[1].trim());

      // Perform reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // Build address components
        final addressParts = [
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
        ];

        // Log useful details
        Logger().log(
          'name:${place.name}, street:${place.street}, administrativeArea:${place.administrativeArea}, locality:${place.locality}, subLocality:${place.subLocality}, subThoroughfare:${place.subThoroughfare}',
        );

        // Filter null/empty and join with commas
        final filtered = addressParts
            .where((e) => e != null && e.toString().trim().isNotEmpty)
            .toList();

        final address = filtered.join(", ");
        return address.isNotEmpty ? address : '';
      } else {
        return '';
      }
    } catch (e) {
      print("Reverse geocoding error: $e");
      return '';
    }
  }

///This method is used to clear local variables
  void clearLocalVariables() {
    savedCartItems.clear();
    savedOrderData = null;
    savedProductDetails = null;
    savedFooterCount = null;
    userFrom = null;
    exactAddress = '';

    // Optional: You can log this for debugging
    print('✅ Local saved data cleared successfully.');
  }

  ///This method is used to separate string
  Map<String, String> splitFullName(String fullName) {
    // Trim extra spaces
    fullName = fullName.trim();

    // Split by spaces
    List<String> parts = fullName.split(" ");

    if (parts.length == 1) {
      // Only one name given
      return {
        "firstName": parts[0],
        "lastName": "",
      };
    }

    // First word = first name
    String firstName = parts.first;

    // Everything after first = last name
    String lastName = parts.sublist(1).join(" ");

    return {
      "firstName": firstName,
      "lastName": lastName,
    };
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


  ///Custom TextField Widget
  Widget customTextField(
      BuildContext context,
      String hint,
      String label,
      IconData icon,
      TextEditingController? controller, {
        int maxLines = 1,
        void Function(String)? onChanged,
        List<TextInputFormatter>? inputFormatters,
        String? prefixText,
        Widget? suffixWidget,
        CustomInputType inputType = CustomInputType.normal,
        description = ''
      }) {

    /// 🔹 Keyboard type decision
    TextInputType keyboardType = TextInputType.text;

    /// 🔹 Input formatters decision
    List<TextInputFormatter> finalInputFormatters = [];

    switch (inputType) {
      case CustomInputType.mobile:
        keyboardType = TextInputType.number;
        finalInputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ];
        break;

      case CustomInputType.pincode:
        keyboardType = TextInputType.number;
        finalInputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ];
        break;

      case CustomInputType.aadhaar:
        keyboardType = TextInputType.number;
        finalInputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(12),
        ];
        break;

      case CustomInputType.bankAccount:
        keyboardType = TextInputType.number;
        finalInputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(18),
        ];
        break;

      case CustomInputType.fssai:
        keyboardType = TextInputType.number;
        finalInputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(14),
        ];
        break;

      case CustomInputType.pan:
        keyboardType = TextInputType.visiblePassword; // Prevents unwanted suggestions
        finalInputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          UpperCaseTextFormatter(),
          LengthLimitingTextInputFormatter(10),
        ];
        break;

      case CustomInputType.gst:
        keyboardType = TextInputType.visiblePassword;
        finalInputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          UpperCaseTextFormatter(),
          LengthLimitingTextInputFormatter(15),
        ];
        break;

      case CustomInputType.ifsc:
        keyboardType = TextInputType.visiblePassword;
        finalInputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          UpperCaseTextFormatter(),
          LengthLimitingTextInputFormatter(11),
        ];
        break;

      case CustomInputType.normal:
        keyboardType = TextInputType.text;
        if (inputFormatters != null) finalInputFormatters.addAll(inputFormatters);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label text using your custom text widget
        objCommonWidgets.customText(
          context,
          hint,
          12,
          Colors.black,
          objConstantFonts.montserratMedium,
        ),

        SizedBox(height: 5.dp),

        if (description.isNotEmpty)...{
          objCommonWidgets.customText(
            context,
            description,
            10,
            Colors.black,
            objConstantFonts.montserratRegular,
          ),
          SizedBox(height: 10.dp),
        },

        AnimatedBuilder(
          animation: controller ?? TextEditingController(),
          builder: (context, _) {
            final text = controller?.text ?? '';

            return TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              inputFormatters: finalInputFormatters,
              cursorColor: Colors.black,
              textAlignVertical: TextAlignVertical.center,

              onChanged: (value) {
                onChanged?.call(value);

                /// 🔹 Auto close keyboard only when max length reached for numeric IDs
                bool isFullLength =
                    (inputType == CustomInputType.mobile && value.length == 10) ||
                        (inputType == CustomInputType.pincode && value.length == 6) ||
                        (inputType == CustomInputType.aadhaar && value.length == 12) ||
                        (inputType == CustomInputType.fssai && value.length == 14);

                if (isFullLength) {
                  FocusScope.of(context).unfocus();
                }
              },

              style: TextStyle(
                fontSize: _getFontSize(text),
                fontFamily: objConstantFonts.montserratMedium,
                color: Colors.black,
              ),

              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(
                    fontSize: 12.dp,
                    fontFamily: objConstantFonts.montserratRegular,
                    color: Colors.black.withAlpha(150)),

                prefixIcon: prefixText != null
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.black, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        prefixText,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: objConstantFonts.montserratMedium,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
                    : Icon(icon, color: Colors.black, size: 20),

                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                suffixIcon: suffixWidget != null
                    ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: suffixWidget,
                )
                    : null,

                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.black, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.deepOrange, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: _getPadding(text)),
              ),
            );
          },
        ),
      ],
    );
  }


  double _getFontSize(String text) {
    if (text.length <= 20) return 13.dp;
    if (text.length <= 30) return 13.dp;
    return 12.dp;
  }

  double _getPadding(String text){
    if (text.length <= 20) return 12.dp;
    if (text.length <= 30) return 13.dp;
    return 14.dp;
  }


  Widget verified(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(3.dp), // 👈 reduce padding
      child: Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 10.dp, // 👈 reduce icon size
      ),
    );
  }


  ///Date Picker TextField
  Widget datePickerTextField(BuildContext context,
      String hint,
      String label,
      IconData icon,
      TextEditingController controller, {
        void Function(String)? onChanged,
        int minimumAge = 18,
      }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        objCommonWidgets.customText(
          context,
          hint,
          12,
          Colors.black,
          objConstantFonts.montserratMedium,
        ),

        SizedBox(height: 5.dp),

        TextField(
          controller: controller,
          maxLines: 1,
          readOnly: true, // 👈 Disable keyboard
          keyboardType: TextInputType.none,
          cursorColor: Colors.black,
          onTap: () => pickDateOfBirth(
              context: context,
              controller: controller,
              minimumAge: minimumAge
          ),
          style: TextStyle(
            fontSize: 15.dp,
            fontFamily: objConstantFonts.montserratMedium,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(
              fontSize: 12.dp,
              fontFamily: objConstantFonts.montserratRegular,
              color: Colors.black.withAlpha(150),
            ),
            prefixIcon: Icon(Icons.calendar_today_rounded, color: Colors.black, size: 20.dp),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.dp),
              borderSide: const BorderSide(color: Colors.black, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.dp),
              borderSide: const BorderSide(color: Colors.black, width: 0.5),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.dp),
          ),
        ),
      ],
    );
  }

  ///Date Picker for DOB Widget...
  Future<void> pickDateOfBirth({
    required BuildContext context,
    required TextEditingController controller,
    int minimumAge = 18,
  }) async {
    final DateTime today = DateTime.now();

    final DateTime initialDate = DateTime(
      today.year - minimumAge,
      today.month,
      today.day,
    );

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: initialDate,
      helpText: "Select Date of Birth",
      cancelText: "Cancel",
      confirmText: "Confirm",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),

            // 👇 Font styling (SUPPORTED)
            textTheme: TextTheme(
              headlineSmall: TextStyle(
                fontFamily: objConstantFonts.montserratSemiBold,
                fontSize: 18,
              ),
              titleMedium: TextStyle(
                fontFamily: objConstantFonts.montserratMedium,
                fontSize: 14,
              ),
              bodyMedium: TextStyle(
                fontFamily: objConstantFonts.montserratRegular,
                fontSize: 14,
              ),
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepOrange,
                textStyle: TextStyle(
                  fontFamily: objConstantFonts.montserratMedium,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      controller.text =
      "${pickedDate.day.toString().padLeft(2, '0')}-"
          "${pickedDate.month.toString().padLeft(2, '0')}-"
          "${pickedDate.year}";
    }
  }

  Widget customSingleDropdownField({
    required BuildContext context,
    required String placeholder,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onChanged,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⭐ Label
        objCommonWidgets.customText(
          context,
          placeholder,
          12,
          Colors.black,
          objConstantFonts.montserratMedium,
        ),

        SizedBox(height: 5.dp),

        // ⭐ Dropdown container
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 2.dp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13.dp),
            border:  BoxBorder.all(color: Colors.black, width: 0.5),
          ),
          child: Row(
            children: [
              // Optional prefix icon
              if (prefixIcon != null)
                Padding(
                  padding: EdgeInsets.only(right: 8.dp),
                  child: Icon(prefixIcon, color: Colors.black, size: 20.dp,),
                ),

              SizedBox(width: 5.dp,),

              // Dropdown
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedValue,
                    icon: const SizedBox.shrink(),
                    dropdownColor: Colors.white,

                    hint: objCommonWidgets.customText(
                      context,
                      placeholder,
                      13,
                      Colors.grey,
                      objConstantFonts.montserratMedium,
                    ),

                    items: items.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 15.dp,
                            color: (selectedValue == value) ? Colors.black : Colors.black.withAlpha(200),
                            fontFamily: (selectedValue == value) ? objConstantFonts.montserratMedium : objConstantFonts.montserratRegular,
                          ),
                        ),
                      );
                    }).toList(),

                    onChanged: onChanged,
                  ),
                ),
              ),

              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              ),

            ],
          ),
        ),
      ],
    );
  }

}

enum CustomInputType {
  normal,
  mobile,
  pincode,
  gst,
  pan,
  ifsc,
  bankAccount,
  aadhaar,
  fssai
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}