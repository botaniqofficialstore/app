import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:lottie/lottie.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../Utility/PreferencesManager.dart';
import '../LoginScreen/LoginScreen.dart';
import 'OtpScreenState.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String loginWith;
  final bool isEmail;

  const OtpScreen({
    super.key,
    required this.loginWith,
    required this.isEmail,
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
    BackButtonInterceptor.add(otpInterceptor);
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
    BackButtonInterceptor.remove(otpInterceptor);
    super.dispose();
  }

  //MARK: - METHODS
  /// Return true to prevent default behavior (app exit)
  /// Return false to allow default behavior
  bool otpInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (kDebugMode) {
      print("Back button intercepted!");
    }
    PreferencesManager.getInstance().then((prefs) {
      if (prefs.getBooleanValue(PreferenceKeys.isDialogOpened) == true) {
        return false;
      } else if ((prefs.getBooleanValue(PreferenceKeys.isLoadingBarStarted) ==
          true)) {
        return true;
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



  //MARK: - Widget
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => CodeReusability.hideKeyboard(context),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: objConstantColor.navyBlue,
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

          const Spacer(),

          Padding(
            padding: EdgeInsets.only(top: 35.dp),
            child: Center(
              child: Image.asset(
                objConstantAssest.loginLogo,
                width: 150.dp,
                height: 90.dp,
              ),
            ),
          ),

          const Spacer(),
          const Spacer(),
    
    
          /// Center Content
          Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35.dp),
                    topRight: Radius.circular(35.dp),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(25.dp, 20.dp, 25.dp, MediaQuery.of(context).viewInsets.bottom + 5.dp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.dp),
                    child: Center(
                      child: objCommonWidgets.customText(
                          context, 'Verify OTP', 30,
                          objConstantColor.navyBlue,
                          objConstantFonts.montserratBold),
                    ),
                  ),

                  SizedBox(height: 10.dp),

                  objCommonWidgets.customText(
                    context,
                    'Enter the OTP sended to the ${widget.isEmail ? 'Email' : 'Mobile Number'} ${CodeReusability().maskEmailOrMobile(widget.loginWith)}',
                    15,
                    objConstantColor.navyBlue,
                    objConstantFonts.montserratSemiBold,
                    textAlign: TextAlign.center
                  ),
                  SizedBox(height: 35.dp),

                  //OTP Field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.dp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                          (index) => SizedBox(
                        width: 11.w, // Adjust width for better spacing
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


                  Row(
                    children: [
                      const Spacer(),
                      if (remainingSeconds == 0) ...[
                        CupertinoButton(
                          onPressed: () async {
                            setState(() async {
                            bool otpSend = await otpNotifier.callReSendOtpAPI(context);
                            if (otpSend){
                              otpNotifier.clearOtpFields();
                              remainingSeconds = 60;
                              startTimer();
                              otpState.focusNodes[0].requestFocus();
                            }
                            });

                          },
                          padding: EdgeInsets.zero,
                          child: objCommonWidgets.customText(context, 'Resend OTP', 14, objConstantColor.orange, objConstantFonts.montserratSemiBold),
                        )
                      ] else ...[
                        Padding(
                          padding: EdgeInsets.all(10.dp),
                          child: objCommonWidgets.customText(context, 'Get new one after ${otpNotifier.formatTime(remainingSeconds)}', 12, Colors.grey.shade500, objConstantFonts.montserratMedium),
                        ),
                      ],
                    ],
                  ),


                  SizedBox(height: 25.dp),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 15.dp),
                      color: objConstantColor.orange,
                      borderRadius: BorderRadius.circular(12.dp),
                      onPressed: () {
                        setState(() {
                          otpNotifier.checkEmptyValidation(context);
                        });
                      },
                      child: objCommonWidgets.customText(
                        context,
                        'Verify OTP',
                        18,
                        objConstantColor.white,
                        objConstantFonts.montserratSemiBold,
                      ),
                    ),
                  ),

                  SizedBox(height: 60.dp,),

                  Row(
                    children: [
                      const Spacer(),
                      objCommonWidgets.customText(
                          context, 'Back to', 12, Colors.grey.shade600,
                          objConstantFonts.montserratMedium),
                      SizedBox(width: 2.dp,),
                      CupertinoButton(padding: EdgeInsets.zero,
                          child: objCommonWidgets.customText(
                              context, 'Login', 13,
                              objConstantColor.orange,
                              objConstantFonts.montserratSemiBold),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (
                                      context) => const LoginScreen()),
                            );
                          }),
                      const Spacer(),
                    ],
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom)

                ],
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
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1),
      ],
      onChanged: (string) {
        if (string.trim().isNotEmpty) {
          otpStateWatch.otpValues[index] = string.trim();

          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );

          if (index < otpStateWatch.focusNodes.length - 1) {
            FocusScope.of(context)
                .requestFocus(otpStateWatch.focusNodes[index + 1]);
          } else {
            FocusScope.of(context).unfocus();
          }
        } else {
          otpStateWatch.otpValues[index] = "";

          if (index > 0) {
            FocusScope.of(context)
                .requestFocus(otpStateWatch.focusNodes[index - 1]);
          }
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
          borderSide: BorderSide(color: otpStateWatch.otpValues[index].isNotEmpty
              ? objConstantColor.orange
              : objConstantColor.navyBlue, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: objConstantColor.orange, width: 2),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: objConstantColor.navyBlue, width: 1.5),
        ),
      ),
    );
  }


}
