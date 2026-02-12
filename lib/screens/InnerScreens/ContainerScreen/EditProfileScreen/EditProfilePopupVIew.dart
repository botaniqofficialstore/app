import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../constants/ConstantVariables.dart';
import 'EditProfileScreenState.dart';

class EditProfilePopupView extends ConsumerStatefulWidget {

  const EditProfilePopupView({
    super.key,
  });

  @override
  EditProfilePopupViewState createState() => EditProfilePopupViewState();
}


class EditProfilePopupViewState extends ConsumerState<EditProfilePopupView> {
  final List<String> genderType = [
    'Male',
    'Female',
    'Other',
  ];

  @override
  void initState() {
    Future.microtask(() {
    final notifier = ref.read(editProfileScreenStateProvider.notifier);
    notifier.updateUserDetails();
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileScreenStateProvider);
    final notifier = ref.read(editProfileScreenStateProvider.notifier);


    return GestureDetector(
      onTap: () => CodeReusability.hideKeyboard(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 15.dp),
              child: Column(
                children: [
                  
                  Row(
                    children: [
                      CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          child: Icon(Icons.arrow_back_rounded,
                              color: Colors.black,
                              size: 20.dp),
                          onPressed: () => Navigator.pop(context)
                      ),
                      SizedBox(width: 3.dp),
                      objCommonWidgets.customText(context, 'Edit Profile', 14, Colors.black, objConstantFonts.montserratMedium)
                      
                    ],
                  ),
                  
                  SizedBox(height: 15.dp),
      
                  profileImageView(),
      
                  SizedBox(height: 20.dp),
      
                  CodeReusability().customTextField(
                      context,
                      "First Name",
                      "enter your first name",
                      Icons.person_2_outlined,
                      state.firstNameController,
                      onChanged: (_) => notifier.onChanged()
                  ),
      
                  SizedBox(height: 20.dp),
      
                  CodeReusability().customTextField(
                      context,
                      "Last Name",
                      "enter your last name",
                      Icons.person_2_outlined,
                      state.lastNameController,
                      onChanged: (_) => notifier.onChanged()
                  ),
      
                  SizedBox(height: 15.dp),
      
                  CodeReusability().customTextField(
                      context,
                      "Email",
                      "enter your email",
                      Icons.mail_outline_rounded,
                      state.emailController,
                      onChanged: (_) => notifier.onChanged()
                  ),
      
                  SizedBox(height: 15.dp),
      
                  CodeReusability().customTextField(
                    context,
                    "Mobile Number",
                    "enter valid mobile number",
                    Icons.phone,
                    state.mobileNumberController,
                    inputType: CustomInputType.mobile,
                    prefixText: '+91',
                    onChanged: (_){
                      notifier.onChanged();
                    },
                    suffixWidget: null,
                  ),
      
                  SizedBox(height: 20.dp),
      
                  CodeReusability().datePickerTextField(
                    context,
                    "Date of birth",
                    "select your date of birth",
                    Icons.calendar_today,
                    state.dobController,
                    minimumAge: 0
                  ),
      
                  SizedBox(height: 20.dp),
      
                  CodeReusability().customSingleDropdownField(
                    context: context,
                    placeholder: "Select Your Gender",
                    items: genderType,
                    selectedValue: state.gender,
                    prefixIcon: Icons.wc,
                    onChanged: (value) {
                      setState(() {
                        notifier.updateGender(value!);
                      });
                    },
                  ),
      
                  SizedBox(height: 30.dp),
      
                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.dp),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(25.dp)
                        ),
                        child: Center(
                          child: objCommonWidgets.customText(context, 'Update', 14, Colors.white, objConstantFonts.montserratSemiBold),
                        ),
                      ),
                      onPressed: () => notifier.checkEmptyValidation(context,)
                  ),
      
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget profileImageView(){
    final state = ref.watch(editProfileScreenStateProvider);
    final bool isEmpty = state.profileImage.isEmpty;
    final bool isNetworkImage = !CodeReusability().isNotValidUrl(state.profileImage);
    final notifier = ref.read(editProfileScreenStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 35.dp,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                radius: 34.dp,
                backgroundImage: isEmpty
                    ? AssetImage(objConstantAssest.defaultProfile)
                    : isNetworkImage
                    ? NetworkImage(state.profileImage)
                    : FileImage(File(state.profileImage)) as ImageProvider,
              ),
            ),

            Positioned(
              bottom: 0.dp,
              right: 0.dp,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => notifier.uploadImage(context),
                child: Container(
                  padding: EdgeInsets.all(5.dp),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 12.dp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          ],
        ),
        SizedBox(height: 6.dp),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            objCommonWidgets.customText(
              context,
              'Profile Image',
              13,
              objConstantColor.black,
              objConstantFonts.montserratMedium,
            ),
          ],
        ),
      ],
    );
  }

}