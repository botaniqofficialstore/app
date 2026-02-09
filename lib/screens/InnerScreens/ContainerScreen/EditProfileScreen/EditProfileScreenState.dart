import 'package:botaniqmicrogreens/screens/InnerScreens/ContainerScreen/EditProfileScreen/EditProfilePopupVIew.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
import '../../../../Utility/MediaHandler.dart';
import '../../../../Utility/PreferencesManager.dart';
import '../../../../constants/Constants.dart';
import '../../../commonViews/ProfileUpdateSuccessPopup.dart';
import 'EditProfileModel.dart';
import 'EditProfileRepository.dart';
import '../../MainScreen/MainScreenState.dart';

class EditProfileScreenGlobalState {
  final ScreenName currentModule;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController mobileNumberController;
  final TextEditingController addressController;
  final bool showEdit;
  final bool isExpandedButton;
  final String profileImage;
  final TextEditingController dobController;
  final String? gender;

  EditProfileScreenGlobalState({
    this.currentModule = ScreenName.home,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.mobileNumberController,
    required this.addressController,
    this.showEdit = false,
    this.isExpandedButton = false,
    required this.profileImage,
    required this.dobController,
    this.gender,
  });

  EditProfileScreenGlobalState copyWith({
    ScreenName? currentModule,
    TextEditingController? firstNameController,
    TextEditingController? lastNameController,
    TextEditingController? emailController,
    TextEditingController? mobileNumberController,
    TextEditingController? addressController,
    bool? showEdit,
    bool? isExpandedButton,
    String? profileImage,
    TextEditingController? dobController,
    String? gender,
  }) {
    return EditProfileScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      firstNameController: firstNameController ?? this.firstNameController,
      lastNameController: lastNameController ?? this.lastNameController,
      emailController: emailController ?? this.emailController,
      mobileNumberController: mobileNumberController ?? this.mobileNumberController,
      addressController: addressController ?? this.addressController,
      showEdit: showEdit ?? this.showEdit,
      isExpandedButton: isExpandedButton ?? this.isExpandedButton,
        profileImage: profileImage ?? this.profileImage,
      dobController: dobController ?? this.dobController,
      gender: gender ?? this.gender,
    );
  }
}

class EditProfileScreenGlobalStateNotifier
    extends StateNotifier<EditProfileScreenGlobalState> {
  EditProfileScreenGlobalStateNotifier() : super(EditProfileScreenGlobalState(
    firstNameController: TextEditingController(),
    lastNameController: TextEditingController(),
    emailController: TextEditingController(),
    mobileNumberController: TextEditingController(),
    addressController: TextEditingController(),
    profileImage: '', dobController: TextEditingController(),

  ));


  void onChanged() {
    state = state.copyWith();
  }

  void toggleEdit(bool value) => state = state.copyWith(showEdit: value);
  void toggleExpandBtn(bool value) => state = state.copyWith(isExpandedButton: value);
  void updateGender(String type) => state = state.copyWith(gender: type);

  ///Mark:-  Profile Image Upload
  Future<void> uploadImage(BuildContext context) async {
    final imagePath = await MediaHandler().handleCommonMediaPicker(context, ImageSource.gallery);
    if (imagePath != null) {
      state = state.copyWith(profileImage: imagePath);
    }
  }

  ///This method is used to get the user profile details from local
  Future<void> updateUserDetails() async {
    final manager = await PreferencesManager.getInstance();
    final userFirstName = manager.getStringValue(PreferenceKeys.userFirstName);
    final userLastName = manager.getStringValue(PreferenceKeys.userLastName);
    final userEmailID = manager.getStringValue(PreferenceKeys.userEmailID);
    final userMobileNumber = manager.getStringValue(PreferenceKeys.userMobileNumber);
    final userAddress = manager.getStringValue(PreferenceKeys.userAddress);

    state = state.copyWith(
      firstNameController: TextEditingController(text: userFirstName),
      lastNameController: TextEditingController(text: userLastName),
      emailController: TextEditingController(text: userEmailID),
      mobileNumberController: TextEditingController(text: userMobileNumber),
      addressController: TextEditingController(text: userAddress),
        profileImage: 'https://i.pravatar.cc/150?u=123',
      gender: 'Male',
    );
  }

  ///This method is used to check empty validation
  void checkEmptyValidation(BuildContext context){
    if (!context.mounted) return;
    CodeReusability.hideKeyboard(context);

    if (CodeReusability.isEmptyOrWhitespace(state.firstNameController.text)) {
      CodeReusability().showAlert(context, 'Please enter your first name');
    } else if (CodeReusability.isEmptyOrWhitespace(state.lastNameController.text)) {
      CodeReusability().showAlert(context, 'Please enter your last name');
    } else if (CodeReusability.isEmptyOrWhitespace(state.emailController.text)) {
      CodeReusability().showAlert(context, 'Please enter your Email address');
    } else if (!CodeReusability.isValidEmail(state.emailController.text)){
      CodeReusability().showAlert(context, 'Please Enter a valid Email');
    } else if (CodeReusability.isEmptyOrWhitespace(state.mobileNumberController.text)) {
      CodeReusability().showAlert(context, 'Please enter your mobile number');
    } else if (!CodeReusability.isValidMobileNumber(state.mobileNumberController.text)){
      CodeReusability().showAlert(context, 'Please Enter a valid mobile number');
    } else {
      callEditProfileAPI(context);
    }

  }


  ///This method used to call Edit Profile PUT API
  void callEditProfileAPI(BuildContext context) {
    if (!context.mounted) return;

    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        Map<String, dynamic> requestBody = {
          'firstName': state.firstNameController.text,
          'lastName': state.lastNameController.text,
          'email': state.emailController.text,
          'mobileNumber': state.mobileNumberController.text,
        };

        final manager = await PreferencesManager.getInstance();
        String? userID = manager.getStringValue(PreferenceKeys.userID);
        String url = '${ConstantURLs.updateCustomerUrl}$userID';

        CommonWidgets().showLoadingBar(true, context); //  Loading bar is Enabled Here
        EditProfileRepository().callEditProfileApi(url, requestBody, (statusCode, responseBody) async {
          EditProfileResponse response = EditProfileResponse.fromJson(responseBody);

          if (statusCode == 200 || statusCode == 201) {
            var prefs = await PreferencesManager.getInstance();
            prefs.setStringValue(PreferenceKeys.userFirstName, state.firstNameController.text);
            prefs.setStringValue(PreferenceKeys.userLastName, state.lastNameController.text);
            prefs.setStringValue(PreferenceKeys.userEmailID, state.emailController.text);
            prefs.setStringValue(PreferenceKeys.userMobileNumber, state.mobileNumberController.text);
            prefs.setStringValue(PreferenceKeys.userAddress, '${requestBody['address']}');

            CommonWidgets().showLoadingBar(false, context); //  Loading bar is disabled Here
            //callNavigation(context, notifier);
            Navigator.pop(context);
            callOrderSuccessPopup(context);
          } else {
            CommonWidgets().showLoadingBar(false, context);
            CodeReusability().showAlert(context, response.message ?? "something Went Wrong");
          }
        });


      } else {
        CodeReusability().showAlert(
            context, 'Please Check Your Internet Connection');
      }
    });

  }

  void callNavigation(BuildContext context, MainScreenGlobalStateNotifier notifier){
    if (!context.mounted) return;
    notifier.callNavigation(ScreenName.profile);
    callOrderSuccessPopup(context);
  }

  void callEditProfilePopupView(BuildContext context){
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const EditProfilePopupView(
        ),
      ),
    );
  }


  //MARK:- Common Views
  ///
  ///This method used to call success popup
  //////
  void callOrderSuccessPopup(BuildContext context) {
    if (!context.mounted) return;
    ProfileUpdateSuccesspopup.showSuccessConfirmationPopup(
        context, onDonePressed: () {
      Navigator.pop(context);
    });
  }



}



final editProfileScreenStateProvider = StateNotifierProvider.autoDispose<
    EditProfileScreenGlobalStateNotifier, EditProfileScreenGlobalState>((ref) {
  var notifier = EditProfileScreenGlobalStateNotifier();
  return notifier;
});

/// Header
/*Stack(
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
                                'Edit Profile',
                                25,
                                objConstantColor.white,
                                objConstantFonts.montserratSemiBold,
                              ),
                            ],
                          ),
                        ),

                        /// Back Button
                        Positioned(
                          top: 0.dp,
                          left: 15.dp,
                          child: SafeArea(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: CupertinoButton(
                                padding: EdgeInsets.all(4.dp),
                                minimumSize: const Size(0, 0),
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

                          SizedBox(height: 15.dp,),

                          Padding(
                            padding: EdgeInsets.only(top: 10.dp, bottom: 20.dp),
                            child: SizedBox(
                              width: double.infinity,
                              child: CupertinoButton(
                                padding: EdgeInsets.symmetric(vertical: 10.dp),
                                color: objConstantColor.orange,
                                borderRadius: BorderRadius.circular(25.dp),
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
                    ),*/