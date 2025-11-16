import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:lottie/lottie.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../../commonViews/CommonWidgets.dart';
import '../../MainScreen/MainScreenState.dart';
import 'EditProfileScreenState.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final profilrScreenNotifier = ref.read(EditProfileScreenGlobalStateProvider.notifier);
      profilrScreenNotifier.updateUserDetails();
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenState = ref.watch(EditProfileScreenGlobalStateProvider);
    final screenNotifier = ref.read(EditProfileScreenGlobalStateProvider.notifier);
    var userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Header
            Stack(
              children: [
                Image.asset(
                  objConstantAssest.addImage8,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180.dp,
                ),

                Positioned(
                  left: 15.dp,
                  bottom: 10.dp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      objCommonWidgets.customText(
                        context,
                        'Edit',
                        35,
                        objConstantColor.white,
                        objConstantFonts.montserratBold,
                      ),
                      objCommonWidgets.customText(
                        context,
                        'Profile',
                        35,
                        objConstantColor.white,
                        objConstantFonts.montserratBold,
                      ),
                    ],
                  ),
                ),

                /// Back Button
                Positioned(
                  top: 10.dp,
                  left: 15.dp,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.all(4.dp),
                      minSize: 35.dp,
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        objConstantAssest.backIcon,
                        color: objConstantColor.white,
                        width: 25.dp,
                      ),
                      onPressed: () {
                        ref.watch(MainScreenGlobalStateProvider.notifier)
                            .callNavigation(ScreenName.profile);
                      },
                    ),
                  ),
                ),


              ],
            ),

            SizedBox(height: 20.dp),

            /// Info Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.dp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  objCommonWidgets.customText(context, 'First Name', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
                  CommonTextField(
                    controller: screenState.firstNameController,
                    placeholder: "Enter First Name",
                    textSize: 15,
                    fontFamily: objConstantFonts.montserratMedium,
                    textColor: objConstantColor.navyBlue,
                    isNumber: false, // alphabetic
                    onChanged: (value) {

                    },
                  ),
                  SizedBox(height: 10.dp,),


                  objCommonWidgets.customText(context, 'Last Name', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
                  CommonTextField(
                    controller: screenState.lastNameController,
                    placeholder: "Enter Last Name",
                    textSize: 15,
                    fontFamily: objConstantFonts.montserratMedium,
                    textColor: objConstantColor.navyBlue,
                    isNumber: false, // alphabetic
                    onChanged: (value) {

                    },
                  ),
                  SizedBox(height: 10.dp,),


                  objCommonWidgets.customText(context, 'Email Address', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
                  CommonTextField(
                    controller: screenState.emailController,
                    placeholder: "Enter Email Address",
                    textSize: 15,
                    fontFamily: objConstantFonts.montserratMedium,
                    textColor: objConstantColor.navyBlue,
                    isNumber: false, // alphabetic
                    onChanged: (value) {

                    },
                  ),
                  SizedBox(height: 10.dp,),


                  objCommonWidgets.customText(context, 'Mobile Number', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.dp),
                          child: objCommonWidgets.customText(context,
                              '+91', 15,
                              objConstantColor.navyBlue,
                              objConstantFonts.montserratSemiBold
                          ),
                        ),
                      ),

                      SizedBox(width: 10.dp,),

                      Expanded(
                        child: CommonTextField(
                          controller: screenState.mobileNumberController,
                          placeholder: "Enter Mobile Number",
                          textSize: 15,
                          fontFamily: objConstantFonts.montserratMedium,
                          textColor: objConstantColor.navyBlue,
                          isNumber: true, // alphabetic
                          onChanged: (value) {
                        
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.dp,),



                  objCommonWidgets.customText(context, 'Address', 15, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
                  SizedBox(height: 5.dp,),

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5.dp,),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Row(
                      children: [
                        /// Animated Location Icon
                        Lottie.asset(
                          objConstantAssest.locationIcon,
                          width: 35.dp,
                          repeat: true,
                        ),
                        /// Address Text
                        Expanded(
                          child: objCommonWidgets.customText(context, (exactAddress.isEmpty ? 'Select delivery address' : exactAddress), 13, (exactAddress.isEmpty ? objConstantColor.gray : objConstantColor.navyBlue), objConstantFonts.montserratMedium),
                        ),
                        CupertinoButton(
                          borderRadius: BorderRadius.circular(8.dp),
                          onPressed: (){
                            userFrom = ScreenName.editProfile;
                            userScreenNotifier.callNavigation(ScreenName.map);
                          }, padding: EdgeInsets.zero,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 6.dp),
                            child: Image.asset(objConstantAssest.editImage, width: 20.dp,),
                          ),
                        ),

                        SizedBox(width: 5.dp,)
                      ],
                    ),
                  ),
                  SizedBox(height: 10.dp,),

                  Padding(
                    padding: EdgeInsets.only(top: 10.dp, bottom: 20.dp),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(vertical: 15.dp),
                        color: objConstantColor.navyBlue,
                        borderRadius: BorderRadius.circular(12.dp),
                        onPressed: () {
                          screenNotifier.checkEmptyValidation(context, userScreenNotifier);
                        },
                        child: objCommonWidgets.customText(
                          context,
                          'Save',
                          18,
                          objConstantColor.white,
                          objConstantFonts.montserratSemiBold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




}
