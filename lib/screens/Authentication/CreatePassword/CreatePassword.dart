
import 'dart:math' as math;
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../Utility/PreferencesManager.dart';
import '../../../constants/ConstantVariables.dart';
import '../../commonViews/CommonWidgets.dart';
import '../LoginScreen/LoginScreen.dart';
import 'CreatePasswordState.dart';

class CreatePassword extends ConsumerStatefulWidget {
  final String userID; // 👈 received string

  const CreatePassword({
    super.key,
    required this.userID,
  });

  @override
  CreatePasswordState createState() => CreatePasswordState();
}

class CreatePasswordState extends ConsumerState<CreatePassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode _passwordFocusNode;
  String _currentPassword = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userScreenNotifier = ref.read(CreatePasswordScreenStateProvider.notifier);
      userScreenNotifier.updateUserID(widget.userID);
    });

    _passwordFocusNode = FocusNode();
    _passwordFocusNode.addListener(() {
      setState(() {}); // refresh UI when focus changes
    });
    BackButtonInterceptor.add(screenInterceptor);
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    BackButtonInterceptor.remove(screenInterceptor);
    super.dispose();
  }

  bool _isPasswordValid(String password) {
    // define password rules
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    final hasMinLength = password.length >= 8;

    return hasUpper && hasLower && hasDigit && hasSpecial && hasMinLength;
  }


  //MARK: - METHODS
  /// Return true to prevent default behavior (app exit)
  /// Return false to allow default behavior
  bool screenInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (kDebugMode) {
      print("Back button intercepted!");
    }
    PreferencesManager.getInstance().then((prefs) {
      if (prefs.getBooleanValue(PreferenceKeys.isDialogOpened) == true) {
        return true;
      } else if (prefs.getBooleanValue(PreferenceKeys.isLoadingBarStarted) ==
          true) {
        return false;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginScreen()),
        );
      }
    });
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CodeReusability.hideKeyboard(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
              child: createPasswordView(context)
          ),
        ),
      ),
    );
  }

  Widget createPasswordView(BuildContext context) {
    final screenState = ref.watch(CreatePasswordScreenStateProvider);
    final screenNotifier = ref.read(CreatePasswordScreenStateProvider.notifier);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Stack(
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Image.asset(
                  objConstantAssest.createPassword,
                  fit: BoxFit.cover, // adjust image scaling
                ),
              ),

              Positioned(top: 10.dp,
                  left: 5.dp, child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Image.asset(
                      objConstantAssest.backIcon,
                      color: objConstantColor.white,
                      height: 30.dp,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                  )),

              Positioned(bottom: 10.dp, left: 10.dp, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  objCommonWidgets.customText(
                    context,
                    'Create',
                    30,
                    objConstantColor.white,
                    objConstantFonts.montserratBold,
                  ),
                  objCommonWidgets.customText(
                    context,
                    'New Password',
                    30,
                    objConstantColor.white,
                    objConstantFonts.montserratBold,
                  )
                ],
              ))
            ],
          ),

          SizedBox(height: 20.dp,),


          /// Center Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                objCommonWidgets.customText(
                  context,
                  'New Password',
                  15,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratSemiBold,
                ),
                SizedBox(height: 2.dp),
                CommonTextField(
                  focusNode: _passwordFocusNode,
                  controller: screenState.passwordController,
                  placeholder: "Enter your new password",
                  textSize: 15,
                  fontFamily: objConstantFonts.montserratMedium,
                  textColor: objConstantColor.navyBlue,
                  isNumber: false,
                  onChanged: (value) {
                    setState(() => _currentPassword = value);
                  },
                ),


                if (_passwordFocusNode.hasFocus &&
                    !_isPasswordValid(_currentPassword))...{
                  SizedBox(height: 5.dp),
                  PasswordHintBubble(
                    password: screenState.passwordController.text,
                    borderRadius: 14.0,
                    borderColor: Colors.grey.shade400,
                    backgroundColor: Colors.grey.shade200,
                    hints: const [
                      'At least 8 characters long',
                      'Include at least one lowercase letter',
                      'Include at least one uppercase letter',
                      'Include numbers (0-9)',
                      'Include a special character (e.g. !@#\$%)',
                    ],
                  ),},


                SizedBox(height: 10.dp),

                objCommonWidgets.customText(
                  context,
                  'Confirm Password',
                  15,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratSemiBold,
                ),
                SizedBox(height: 2.dp),
                CommonTextField(
                  controller: screenState.confirmPasswordController,
                  placeholder: "Enter your confirm password",
                  textSize: 15,
                  fontFamily: objConstantFonts.montserratMedium,
                  textColor: objConstantColor.navyBlue,
                  isNumber: false,
                  onChanged: (value) {},
                ),


                SizedBox(height: 25.dp),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: 15.dp),
                    color: objConstantColor.navyBlue,
                    borderRadius: BorderRadius.circular(12.dp),
                    onPressed: () {
                      screenNotifier.checkTextFieldValidation(context);
                    },
                    child: objCommonWidgets.customText(
                      context,
                      'Confirm',
                      18,
                      objConstantColor.white,
                      objConstantFonts.montserratSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),


        ]
    );
  }


}







class PasswordHintBubble extends StatelessWidget {
  final List<String> hints;
  final String password;
  final double borderRadius;
  final Color borderColor;
  final Color backgroundColor;
  final double arrowWidth;
  final double arrowHeight;
  final EdgeInsets contentPadding;

  const PasswordHintBubble({
    super.key,
    required this.hints,
    required this.password,
    this.borderRadius = 12.0,
    this.borderColor = const Color(0xFFCCCCCC),
    this.backgroundColor = Colors.white,
    this.arrowWidth = 18.0,
    this.arrowHeight = 10.0,
    this.contentPadding =
    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🔹 Main container
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: contentPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildHints(context),
          ),
        ),

        // 🔹 Upward-facing triangle (top-left)
        Positioned(
          top: -arrowHeight + 0.5,
          left: 18.dp,
          child: CustomPaint(
            size: Size(arrowWidth, arrowHeight),
            painter: _UpTrianglePainter(
              color: objConstantColor.navyBlue,
              borderColor: borderColor, // ✅ same border color
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildHints(BuildContext context) {
    final List<Widget> widgets = [];

    widgets.add(
      Padding(
        padding: EdgeInsets.only(bottom: 8.dp),
        child: Text(
          'Strong password hints',
          style: TextStyle(
            fontSize: 14.dp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );

    for (var hint in hints) {
      final bool isMatched = _checkCondition(hint, password);
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 6.dp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 6.dp, right: 8.dp),
                width: 8.dp,
                height: 8.dp,
                decoration: BoxDecoration(
                  color: isMatched ? Colors.green : Colors.grey.shade600,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 13.dp,
                    color: isMatched ? Colors.green : Colors.grey.shade800,
                    fontWeight:
                    isMatched ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  /// ✅ Updated password condition checker
  bool _checkCondition(String hint, String password) {
    if (hint.contains('8 characters') && password.length >= 8) {
      return true;
    } else if (hint.contains('uppercase') && RegExp(r'[A-Z]').hasMatch(password)) {
      return true;
    } else if (hint.contains('lowercase') && RegExp(r'[a-z]').hasMatch(password)) {
      return true;
    } else if (hint.contains('numbers') && RegExp(r'\d').hasMatch(password)) {
      return true;
    } else if (hint.contains('special character') &&
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return true;
    }
    return false;
  }
}

/// 🔺 Custom painter for upward triangle with border matching the box
class _UpTrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _UpTrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Outer border triangle
    final borderPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    // Slightly smaller inner triangle to show border outline
    final fillPath = Path()
      ..moveTo(1, size.height - 1)
      ..lineTo(size.width / 2, 1)
      ..lineTo(size.width - 1, size.height - 1)
      ..close();

    canvas.drawPath(borderPath, borderPaint);
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
