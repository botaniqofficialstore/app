import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'EditProfileScreenState.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends ConsumerState<EditProfileScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final profileScreenNotifier = ref.read(editProfileScreenStateProvider.notifier);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          profileScreenNotifier.toggleExpandBtn(true);
        }
      });
      profileScreenNotifier.updateUserDetails();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Start entrance animation immediately
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileScreenStateProvider);
    final notifier = ref.read(editProfileScreenStateProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.dp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerView(),
                          SizedBox(height: 25.dp),
                          genderDobView(),
                          SizedBox(height: 15.dp),
                          contactDetailsView(),
                          SizedBox(height: 15.dp),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            /// FLOATING BUTTON – now sticks to screen bottom
            if (!state.showEdit)
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    notifier.callEditProfilePopupView(context);
                    //notifier.toggleEdit(true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: state.isExpandedButton ? 13.dp : 10.dp,
                      vertical: 10.dp,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30.dp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 15.dp),
                        if (state.isExpandedButton) ...[
                          SizedBox(width: 5.dp),
                          objCommonWidgets.customText(
                            context,
                            'Edit',
                            13,
                            Colors.white,
                            objConstantFonts.montserratSemiBold,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

    );
  }



  Widget genderDobView(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.dp),
          child: objCommonWidgets.customText(
            context,
            'Age & gender details',
            13,
            objConstantColor.black,
            objConstantFonts.montserratMedium,
          ),
        ),

        SizedBox(height: 5.dp),

        Container(
          color: Colors.white,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleAndValue('Date of Birth', '17/08/2000'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.dp),
                child: Divider(color: Colors.black.withAlpha(85), thickness: 0.5.dp, height: 0,),
              ),
              titleAndValue('Gender', 'Male'),
            ],
          ),
        )

      ],
    );
  }

  Widget contactDetailsView(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.dp),
          child: objCommonWidgets.customText(
            context,
            'Contact details',
            13,
            objConstantColor.black,
            objConstantFonts.montserratMedium,
          ),
        ),

        SizedBox(height: 5.dp),

        Container(
          color: Colors.white,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleAndValue('Email', 'vikasbalakrishnan25@gmail,com'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.dp),
                child: Divider(color: Colors.black.withAlpha(85), thickness: 0.5.dp, height: 0,),
              ),
              titleAndValue('Mobile Number', '+91 7306045788'),
            ],
          ),
        )

      ],
    );
  }

  Widget titleAndValue(String title, String value){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.dp, vertical: 7.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          objCommonWidgets.customText(
            context,
            title,
            12,
            const Color(0xFF0347FB),
            objConstantFonts.montserratSemiBold,
          ),
          objCommonWidgets.customText(
            context,
            value,
            10,
            Colors.black,
            objConstantFonts.montserratMedium,
          ),
        ],
      ),
    );
  }



  Widget headerView(){
    //final state = ref.watch(sellerAccountScreenStateProvider);
    //final notifier = ref.read(sellerAccountScreenStateProvider.notifier);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.dp),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30.dp),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 34.dp,
                    backgroundColor: Colors.black,
                    child: ClipOval(
                      child: Image.network(
                        'https://i.pravatar.cc/150?u=123',
                        width: 65.dp,
                        height: 65.dp,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // 1. Local Placeholder Image
                              Image.asset(
                                objConstantAssest.defaultProfile,
                                width: 65.dp,
                                height: 65.dp,
                                fit: BoxFit.cover,
                              ),
                              // 2. Small White Circular Progress Bar
                              SizedBox(
                                width: 12.dp, // Scaled down for the small avatar
                                height: 12.dp,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  backgroundColor: Colors.white24,
                                ),
                              ),
                            ],
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            objConstantAssest.defaultProfile,
                            width: 65.dp,
                            height: 65.dp,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox(height: 6.dp),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      objCommonWidgets.customText(
                        context,
                        'Gabriel Joseph',
                        15,
                        objConstantColor.black,
                        objConstantFonts.montserratSemiBold,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            left: 0,
            top: 0.dp,
            child: Row(
              children: [
                CupertinoButton(padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.black,
                        size: 18.dp),
                    onPressed: (){
                      ref.watch(MainScreenGlobalStateProvider.notifier)
                          .callNavigation(ScreenName.profile);
                    }),

                SizedBox(width: 2.5.dp),

                objCommonWidgets.customText(
                  context,
                  'Profile',
                  14,
                  objConstantColor.black,
                  objConstantFonts.montserratMedium,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }




}
