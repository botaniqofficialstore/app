import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../CodeReusable/CodeReusability.dart';
import '../../../../CodeReusable/CommonWidgets.dart';
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

  EditProfileScreenGlobalState({
    this.currentModule = ScreenName.home,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.mobileNumberController,
    required this.addressController,
  });

  EditProfileScreenGlobalState copyWith({
    ScreenName? currentModule,
    TextEditingController? firstNameController,
    TextEditingController? lastNameController,
    TextEditingController? emailController,
    TextEditingController? mobileNumberController,
    TextEditingController? addressController,
  }) {
    return EditProfileScreenGlobalState(
      currentModule: currentModule ?? this.currentModule,
      firstNameController: firstNameController ?? this.firstNameController,
      lastNameController: lastNameController ?? this.lastNameController,
      emailController: emailController ?? this.emailController,
      mobileNumberController: mobileNumberController ?? this.mobileNumberController,
      addressController: addressController ?? this.addressController,
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
  ));

  @override
  void dispose() {
    super.dispose();

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
    );
  }

  ///This method is used to check empty validation
  void checkEmptyValidation(BuildContext context, MainScreenGlobalStateNotifier notifier){
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
      callEditProfileAPI(context, notifier);
    }

  }


  ///This method used to call Edit Profile PUT API
  void callEditProfileAPI(BuildContext context, MainScreenGlobalStateNotifier notifier) {
    if (!context.mounted) return;

    CodeReusability().isConnectedToNetwork().then((isConnected) async {
      if (isConnected) {

        Map<String, dynamic> requestBody = {
          'firstName': state.firstNameController.text,
          'lastName': state.lastNameController.text,
          'email': state.emailController.text,
          'mobileNumber': state.mobileNumberController.text,
          'address': 'Chendrathil House Vadakkathara, Chittur, Palakkad, Kerala (P.O) 678101',
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
            prefs.setStringValue(PreferenceKeys.userAddress, requestBody['address']);

            CommonWidgets().showLoadingBar(false, context); //  Loading bar is disabled Here
            callNavigation(context, notifier);
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
    notifier.callNavigation(ScreenName.profile);
    callOrderSuccessPopup(context);
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



final EditProfileScreenGlobalStateProvider = StateNotifierProvider.autoDispose<
    EditProfileScreenGlobalStateNotifier, EditProfileScreenGlobalState>((ref) {
  var notifier = EditProfileScreenGlobalStateNotifier();
  return notifier;
});

