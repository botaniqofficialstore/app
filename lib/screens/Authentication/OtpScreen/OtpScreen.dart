import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:lottie/lottie.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../InnerScreens/MainScreen/MainScreenState.dart';
import 'OtpScreenState.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  OtpScreenState createState() => OtpScreenState();
}

class OtpScreenState extends ConsumerState<OtpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController otpController = TextEditingController();

  int remainingSeconds = 60;
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: otpView(context),
    );
  }


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      startTimer();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.dp, vertical: 10.dp),
      child: Column(
        children: [

          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Image.asset(
                  objConstantAssest.backIcon,
                  color: objConstantColor.navyBlue,
                  height: 30.dp,
                ),
                onPressed: () {
                  ref.watch(MainScreenGlobalStateProvider.notifier)
                      .callNavigation(ScreenName.login);
                },
              ),
              const Spacer()
            ],
          ),

          SizedBox(height: 15.dp,),


          Lottie.asset(
            objConstantAssest.otpAnimation,
            height: 200.dp,
            repeat: true,
          ),


          SizedBox(height: 50.dp,),


          /// Center Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                objCommonWidgets.customText(
                  context,
                  'Enter the OTP sended to the Email ****25@gmail.com',
                  15,
                  objConstantColor.navyBlue,
                  objConstantFonts.montserratSemiBold,
                  textAlign: TextAlign.center
                ),
                SizedBox(height: 25.dp),

                //OTP Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: objConstantColor.navyBlue,
                      width: 1.dp,
                    ),
                    borderRadius: BorderRadius.circular(10.dp),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                          (index) => Expanded(
                        child: otpBox(
                            context,
                            index,
                            otpState.controllers[index],
                            otpState.focusNodes[index],
                            otpState),
                      ),
                    ),
                  ),
                ),


                Row(
                  children: [
                    const Spacer(),
                    if (remainingSeconds == 0) ...[
                      CupertinoButton(
                        onPressed: () {
                          otpNotifier.clearOtpFields();
                          setState(() {
                            remainingSeconds = 60;
                            startTimer();
                          });
                          otpState.focusNodes[0].requestFocus();
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
                    color: objConstantColor.navyBlue,
                    borderRadius: BorderRadius.circular(12.dp),
                    onPressed: () {
                      setState(() {

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
              ],
            ),
          ),
        ],
      ),
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
      OtpScreenGlobalState otpState) {
    final otpState = ref.watch(otpScreenGlobalStateProvider);
    return Container(
      height: 6.5.h,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 5.dp),
          Expanded(
            child: TextField(
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
                  otpState.otpValues[index] = string.trim();

                  //controller.text = "*";
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );

                  if (index < 3) {
                    FocusScope.of(context)
                        .requestFocus(otpState.focusNodes[index + 1]);
                  } else {
                    FocusScope.of(context).unfocus();
                  }
                } else {
                  otpState.otpValues[index] = "";

                  if (index > 0) {
                    FocusScope.of(context)
                        .requestFocus(otpState.focusNodes[index - 1]);
                  }
                }
              },
              style: TextStyle(
                fontFamily: objConstantFonts.montserratSemiBold,
                color: objConstantColor.navyBlue,
                fontSize: 20.dp,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(width: 5.dp),
          if (index < 3)
            Container(
              width: 1.dp,
              height: double.infinity,
              color: objConstantColor.navyBlue,
            ),
        ],
      ),
    );
  }

}
