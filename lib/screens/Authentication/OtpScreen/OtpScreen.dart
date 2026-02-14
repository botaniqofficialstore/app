import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../LoginScreen/LoginScreen.dart';
import 'OtpScreenState.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String loginWith;
  final bool isEmail;

  const OtpScreen({
    super.key,
    this.loginWith = '',
    this.isEmail = false,
  });

  @override
  OtpScreenState createState() => OtpScreenState();
}

class OtpScreenState extends ConsumerState<OtpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int remainingSeconds = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Start SMS Listener
    SmsAutoFill().listenForCode();
    Future.microtask(() {
      final otpScreenNotifier = ref.read(otpScreenGlobalStateProvider.notifier);
      otpScreenNotifier.updateUserData(widget.loginWith);
      startTimer();

      // ✅ Auto focus first text field after small delay
      Future.delayed(const Duration(milliseconds: 300), () {
        final otpState = ref.read(otpScreenGlobalStateProvider);
        if (otpState.focusNodes.isNotEmpty) {
          otpState.focusNodes[0].requestFocus();
        }
      });

    });
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SmsAutoFill().code.listen((code) {
      final otpNotifier = ref.read(otpScreenGlobalStateProvider.notifier);
      otpNotifier.listenOtpAutoFill(context, code);
    });
  }




  //MARK: - Widget
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // 🔥 We fully control back navigation
      onPopInvokedWithResult: (didPop, dynamic) {
        if (didPop) return;
        if (!context.mounted) return;
        Navigator.pop(context);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // optional
          statusBarIconBrightness: Brightness.dark, // ANDROID → black icons
          statusBarBrightness: Brightness.light, // iOS → black icons
        ),
        child: GestureDetector(
          onTap: () => CodeReusability.hideKeyboard(context),
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xFFF9FAFB),
            body: SafeArea(
                bottom: false,
                child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight, // important
                            ),
                            child: IntrinsicHeight(
                                child: otpView(context))
                        ),
                      );
                    })),
          ),
        ),
      ),
    );
  }


  ///This method used to start OTP Timer
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (remainingSeconds == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }


  Widget otpView(BuildContext context) {
    final otpState = ref.watch(otpScreenGlobalStateProvider);
    final otpNotifier = ref.read(otpScreenGlobalStateProvider.notifier);

    return Column(
      children: [

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.dp, vertical: 5.dp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios, size: 20.dp, color: Colors.black,),
              ),
            ],
          ),
        ),

        /// Main Content (takes available height)
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              25.dp,
              50.dp,
              25.dp,
              MediaQuery.of(context).viewInsets.bottom + 5.dp,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.dp),
                  child: objCommonWidgets.customText(
                    context,
                    'Verify OTP',
                    25,
                    objConstantColor.black,
                    objConstantFonts.montserratSemiBold,
                  ),
                ),

                SizedBox(height: 10.dp),

                objCommonWidgets.customText(
                  context,
                  'Enter the OTP sended to the Mobile Number '
                      '${CodeReusability().maskEmailOrMobile(widget.loginWith)}',
                  13,
                  objConstantColor.black,
                  objConstantFonts.montserratMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 50.dp),

                /// OTP Boxes
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.dp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                          (index) => SizedBox(
                        width: 11.w,
                        child: otpBox(
                          context,
                          index,
                          otpState.controllers[index],
                          otpState.focusNodes[index],
                          otpState,
                        ),
                      ),
                    ),
                  ),
                ),

                /// Resend OTP
                Row(
                  children: [
                    const Spacer(),
                    if (remainingSeconds == 0)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          bool otpSend =
                          await otpNotifier.callReSendOtpAPI(context);
                          if (otpSend) {
                            otpNotifier.clearOtpFields();
                            setState(() {
                              remainingSeconds = 60;
                            });
                            startTimer();
                            otpState.focusNodes[0].requestFocus();
                          }
                        },
                        child: objCommonWidgets.customText(
                          context,
                          'Resend OTP',
                          12,
                          Colors.deepOrange,
                          objConstantFonts.montserratSemiBold,
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.all(10.dp),
                        child: objCommonWidgets.customText(
                          context,
                          'Get new one after '
                              '${otpNotifier.formatTime(remainingSeconds)}',
                          10,
                          Colors.black.withAlpha(180),
                          objConstantFonts.montserratMedium,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 25.dp),

                /// Verify Button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    otpNotifier.checkEmptyValidation(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15.dp),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25.dp),
                    ),
                    child: Center(
                      child: objCommonWidgets.customText(
                        context,
                        'Verify',
                        16,
                        Colors.white,
                        objConstantFonts.montserratSemiBold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  //MARK: - METHODS
  /// This method used to create an OTP container box
  ///
  /// [index] - This param used to pass the OTP index
  /// [controller] - This param used to pass the OTP field Controller
  /// [focusNode] - This param used to pass the OTP field Focus nodes
  Widget otpBox(
      BuildContext context,
      int index,
      TextEditingController controller,
      FocusNode focusNode,
      OtpScreenGlobalState otpState,
      ) {
    final otpStateWatch = ref.watch(otpScreenGlobalStateProvider);
    final bool hasText = otpStateWatch.otpValues[index].isNotEmpty;
    final bool hasFocus = focusNode.hasFocus;

    Color getBorderColor() {
      if (hasText) {
        return Colors.black;
      } else if (hasFocus) {
        return Colors.deepOrange;
      } else {
        return Colors.grey;
      }
    }

    return RawKeyboardListener(
      focusNode: FocusNode(), // separate listener node
      onKey: (event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {

          /// If current box is empty → move back
          if (controller.text.isEmpty && index > 0) {
            otpStateWatch.otpValues[index - 1] = '';
            otpStateWatch.controllers[index - 1].clear();

            FocusScope.of(context)
                .requestFocus(otpStateWatch.focusNodes[index - 1]);
          }
        }
      },

      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        cursorColor: Colors.black,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            otpStateWatch.otpValues[index] = value;

            if (index < otpStateWatch.focusNodes.length - 1) {
              FocusScope.of(context)
                  .requestFocus(otpStateWatch.focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          } else {
            otpStateWatch.otpValues[index] = '';
          }
        },
        style: TextStyle(
          fontFamily: objConstantFonts.montserratSemiBold,
          color: objConstantColor.navyBlue,
          fontSize: 20.dp,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.only(bottom: 8.dp),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: getBorderColor(), width: 1.5),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: getBorderColor(), width: 2),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: getBorderColor(), width: 1.5),
          ),
        ),
      ),
    );
  }


}
