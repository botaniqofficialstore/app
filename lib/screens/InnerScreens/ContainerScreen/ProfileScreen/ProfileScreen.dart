import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'ProfileScreenState.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends ConsumerState<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final profilrScreenNotifier = ref.read(ProfileScreenGlobalStateProvider.notifier);
      profilrScreenNotifier.updateUserDetails();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: profileView(context),
      ),
    );
  }


  ///Profile Screen
Widget profileView(BuildContext context){
  final screenState = ref.watch(ProfileScreenGlobalStateProvider);
  final screenNotifier = ref.read(ProfileScreenGlobalStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Stack(
          children: [
            Image.asset(
              objConstantAssest.addImage6,
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
                    'Welcome',
                    40,
                    objConstantColor.white,
                    objConstantFonts.montserratBold,
                  ),
                  objCommonWidgets.customText(
                    context,
                    '${screenState.firstName} ${screenState.lastName}',
                    30,
                    objConstantColor.white,
                    objConstantFonts.montserratSemiBold,
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
                        .callNavigation(ScreenName.home);
                  },
                ),
              ),
            ),

            /// Logout Button
            Positioned(
              top: 10.dp,
              right: 15.dp,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.all(4.dp),
                          minSize: 35.dp,
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            objConstantAssest.logout,
                            color: objConstantColor.white,
                            width: 18.dp,
                          ),
                          onPressed: () {

                          },
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            )
          ],
        ),

        SizedBox(height: 20.dp),

        /// Info Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.dp),
          child: Column(
            children: [
              buildInfoTile(context,"First Name", screenState.firstName, screenState.firstName.isEmpty, '--'),
              buildInfoTile(context,"Last Name", screenState.lastName, screenState.lastName.isEmpty, '--'),
              buildInfoTile(context,"Email", screenState.email, screenState.email.isEmpty, '--'),
              buildInfoTile(context,"Mobile", "+91 ${screenState.mobileNumber}", screenState.mobileNumber.isEmpty, '--'),
              buildInfoTile(context,"Address", screenState.address, screenState.address.isEmpty, '--'),

              Padding(
                padding: EdgeInsets.only(top: 10.dp, bottom: 20.dp),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: 15.dp),
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.dp),
                    onPressed: () {
                      ref.watch(MainScreenGlobalStateProvider.notifier)
                          .callNavigation(ScreenName.editProfile);
                    },
                    child: objCommonWidgets.customText(
                      context,
                      'Edit Profile',
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
    );
}


  /// Custom Info Tile
  Widget buildInfoTile(BuildContext context,String label, String value, bool isEmpty, String placeholder) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.dp),
      padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 10.dp),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          objCommonWidgets.customText(context, label, 12.5, objConstantColor.navyBlue, objConstantFonts.montserratSemiBold),
          SizedBox(height: 2.dp),
          objCommonWidgets.customText(context, isEmpty ? placeholder : value, 15, isEmpty ? objConstantColor.gray : objConstantColor.navyBlue, objConstantFonts.montserratSemiBold)
        ],
      ),
    );
  }
}
