import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../CodeReusable/FacebookSignInService.dart';
import '../../../../CodeReusable/GoogleSignInService.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../Utility/ScrollingImageBackground.dart';
import '../OtpScreen/OtpScreen.dart';
import 'LoginScreenState.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  static  List<String> backgroundImages = [
    objConstantAssest.sampleThree,
    objConstantAssest.sampleFour,
    objConstantAssest.sampleFive,
    objConstantAssest.sampleTwo,
  ];

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginScreenProvider);
    final loginNotifier = ref.read(loginScreenProvider.notifier);

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, dynamic) {
          if (didPop) return;
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: GestureDetector(
            onTap: () => CodeReusability.hideKeyboard(context),
            child: Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),

              /// ✅ SAFE FOOTER (gesture + button navigation safe)

              body: LayoutBuilder(builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [

                            /// 🔹 TOP IMAGE SECTION
                            Stack(
                              children: [
                                SizedBox(
                                  height: 57.h,
                                  child: ScrollingImageBackground(
                                    imageList: backgroundImages,
                                    duration: const Duration(seconds: 5),
                                  ),
                                ),
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 2,
                                      sigmaY: 2,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,             // Clear at the top
                                            Colors.black.withAlpha(50),  // Slight tint in the middle
                                            Colors.black.withAlpha(200),  // Darker at the bottom for text readability
                                          ],
                                          stops: const [0.0, 0.5, 1.0],     // Controls where the transitions happen
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 45.dp,
                                  left: 15.dp,
                                  right: 15.dp,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      objCommonWidgets.customText(
                                        context,
                                        'Welcome',
                                        30,
                                        Colors.white,
                                        objConstantFonts
                                            .montserratSemiBold,
                                      ),
                                      SizedBox(height: 5.dp),
                                      objCommonWidgets.customText(
                                        context,
                                        'Purely organic. Perfectly delivered your daily\nessentials right to your door.',
                                        //'Pure organic goodness,\ndelivered to your door.',
                                        10,
                                        Colors.white,
                                        objConstantFonts.montserratMedium,
                                      ),
                                      SizedBox(height: 10.dp),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            /// 🔹 FORM SECTION
                            Transform.translate(
                              offset: const Offset(0, -40),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.only(
                                    topLeft:
                                    Radius.circular(35.dp),
                                    topRight:
                                    Radius.circular(35.dp),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [

                                    SizedBox(height: 5.dp),

                                    objCommonWidgets.customText(
                                      context,
                                      'Login',
                                      25,
                                      Colors.black,
                                      objConstantFonts
                                          .montserratSemiBold,
                                    ),

                                    SizedBox(height: 13.dp),

                                    _customTextField(
                                      "Enter Mobile Number",
                                      "Enter your reg. mobile number",
                                      loginState.emailMobileController,
                                      keyboardType:
                                      TextInputType.number,
                                      prefixText: "+91",
                                      maxLength: 10,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly,
                                      ],
                                      onChanged: (value){
                                        if (value.length == 10) {
                                          FocusScope.of(context).unfocus();
                                        }
                                      }
                                    ),

                                    SizedBox(height: 3.h),

                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {

                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (_) => OtpScreen(loginWith: '9061197858',
                                                isEmail: CodeReusability().isEmail('9061197858')),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding:
                                        EdgeInsets.symmetric(
                                          vertical: 15.dp,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                          BorderRadius.circular(
                                            25.dp,
                                          ),
                                        ),
                                        child: Center(
                                          child: objCommonWidgets
                                              .customText(
                                            context,
                                            'Get OTP',
                                            16,
                                            Colors.white,
                                            objConstantFonts
                                                .montserratSemiBold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 20.dp),


                                    Row(
                                      children: [
                                        Expanded(child: Divider(thickness: 1.dp)),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16.dp),
                                          child: objCommonWidgets.customText(
                                            context,
                                            'OR LOGIN WITH',
                                            10,
                                            Colors.grey.shade600,
                                            objConstantFonts.montserratMedium, // Using Medium for a cleaner look
                                          ),
                                        ),
                                        Expanded(child: Divider(thickness: 1.dp)),
                                      ],
                                    ),

                                    SizedBox(height: 20.dp),

                                    // Social Buttons Layout
                                    Row(
                                      children: [
                                        // Google Button
                                        Expanded(
                                          child: socialButton(
                                            asset: objConstantAssest.google,
                                            label: 'Google',
                                            onTap: () async {
                                              final user = await GoogleSignInService.signInWithGoogle();
                                              if (user != null) {
                                                var result = CodeReusability().splitFullName('${user.displayName}');
                                                loginNotifier.callSocialSignInAPI(context, user.email, 'google', '${result["firstName"]}', '${result["lastName"]}');
                                              }
                                            },
                                          ),
                                        ),

                                        SizedBox(width: 5.w),

                                        // Facebook Button
                                        Expanded(
                                          child: socialButton(
                                            asset: objConstantAssest.facebook,
                                            label: 'Facebook',
                                            onTap: () async {
                                              final user = await FacebookSignInService.signInWithFacebook();
                                              if (user != null) {
                                                var result = CodeReusability().splitFullName('${user.displayName}');
                                                loginNotifier.callSocialSignInAPI(context, '${user.email}', 'facebook', '${result["firstName"]}', '${result["lastName"]}');
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            ),


                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        )
    );
  }

  Widget _customTextField(
      String hint,
      String label,
      TextEditingController? controller, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        void Function(String)? onChanged,
        List<TextInputFormatter>? inputFormatters,
        String? prefixText,
        int? maxLength,
      }) {
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
        SizedBox(height: 3.dp), // ↓ reduced from 5.dp
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          cursorColor: Colors.black,
          style: TextStyle(
            fontSize: 14.dp,
            fontFamily: objConstantFonts.montserratMedium,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            counterText: "",
            prefixIcon: prefixText != null ? Padding(
              padding: EdgeInsets.only(left: 15.dp, right: 5.dp), // ↓ reduced
              child: Center(
                widthFactor: 0.0,
                child: Text(
                  prefixText,
                  style: TextStyle(
                    fontSize: 15.dp,
                    fontFamily: objConstantFonts.montserratSemiBold,
                    color: Colors.black,
                  ),
                ),
              ),
            )
                : null,
            hintText: label,
            hintStyle: TextStyle(
              fontSize: 10.dp,
              fontFamily: objConstantFonts.montserratRegular,
              color: Colors.black.withAlpha(150),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.dp),
              borderSide: BorderSide(color: Colors.black.withAlpha(65)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.dp),
              borderSide: BorderSide(
                color: controller!.text.trim().isNotEmpty
                    ? Colors.black
                    : Colors.black.withAlpha(65),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.dp),
              borderSide: const BorderSide(color: Colors.black),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.dp,
              vertical: 10.dp, // ↓ reduced from 15.dp
            ),
          ),
          maxLength: maxLength,
        ),
      ],
    );
  }




  //MARK: - Widget
  /*@override
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
                    child: Column(
                      children: [
                        const Spacer(),
                        // LOGO
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
                        const Spacer(),
                        // White Bottom Section
                        loginBottomContainer(context),

                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget loginBottomContainer(BuildContext context) {
    final loginState = ref.watch(loginScreenProvider);
    final loginNotifier = ref.read(loginScreenProvider.notifier);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.dp),
            child: Center(
              child: objCommonWidgets.customText(
                context,
                'Login',
                30,
                objConstantColor.navyBlue,
                objConstantFonts.montserratBold,
              ),
            ),
          ),

          SizedBox(height: 15.dp),

          objCommonWidgets.customText(
            context,
            'Email/Mobile Number',
            15,
            objConstantColor.navyBlue,
            objConstantFonts.montserratSemiBold,
          ),

          SizedBox(height: 5.dp),

          CommonTextField(
            controller: loginState.emailMobileController,
            placeholder: "Enter your email or mobile number",
            textSize: 15,
            fontFamily: objConstantFonts.montserratMedium,
            textColor: objConstantColor.navyBlue,
            isNumber: false,
            onChanged: (value) {},
          ),

          SizedBox(height: 18.dp),

          // OTP Button
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 15.dp),
              color: objConstantColor.orange,
              borderRadius: BorderRadius.circular(12.dp),
              onPressed: () {
                loginNotifier.checkLoginFieldValidation(context);
              },
              child: objCommonWidgets.customText(
                context,
                'GET OTP',
                18,
                objConstantColor.white,
                objConstantFonts.montserratSemiBold,
              ),
            ),
          ),

          SizedBox(height: 25.dp),

          objCommonWidgets.orWidget(context),

          SizedBox(height: 20.dp),

          // Social buttons
          Row(
            children: [
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: socialIcon(objConstantAssest.google, 16.dp),
                onPressed: () async {
                  final user = await GoogleSignInService.signInWithGoogle();
                  if (user != null){
                    var result = CodeReusability().splitFullName('${user.displayName}');
                    loginNotifier.callSocialSignInAPI(context, user.email, 'google', '${result["firstName"]}', '${result["lastName"]}');
                  }
                },
              ),
              SizedBox(width: 50.dp),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: socialIcon(objConstantAssest.facebook, 18.dp),
                onPressed: () async {
                  final user = await FacebookSignInService.signInWithFacebook();
                  var result = CodeReusability().splitFullName('${user?.displayName}');
                  if (user != null){
                    loginNotifier.callSocialSignInAPI(context, '${user.email}', 'facebook', '${result["firstName"]}', '${result["lastName"]}');
                  }
                },
              ),
              const Spacer(),
            ],
          ),

          SizedBox(height: 25.dp),

          // Create account
          Row(
            children: [
              const Spacer(),
              objCommonWidgets.customText(
                  context,
                  'New User?',
                  12,
                  Colors.grey.shade600,
                  objConstantFonts.montserratMedium),
              SizedBox(width: 5.dp),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: objCommonWidgets.customText(
                    context,
                    'Create Account',
                    13,
                    objConstantColor.orange,
                    objConstantFonts.montserratSemiBold),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom)


        ],
      ),
    );
  }*/

  Widget socialButton({required String asset, required String label, required VoidCallback onTap}) {
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.dp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.dp),
          border: Border.all(color: Colors.grey.shade200), // Soft border instead of heavy shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(asset, width: 18.dp),
            SizedBox(width: 7.dp),
            objCommonWidgets.customText(context, label, 12, Colors.black, objConstantFonts.montserratSemiBold)
          ],
        ),
      ),
    );
  }



}
