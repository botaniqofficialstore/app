import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../MainScreen/MainScreenState.dart';
import '../LocationScreen/LocationScreenState.dart';
import 'FamilyLocationScreenState.dart';

class FamilyLocationScreen extends ConsumerStatefulWidget {
  const FamilyLocationScreen({super.key});

  @override
  FamilyLocationScreenState createState() => FamilyLocationScreenState();
}

class FamilyLocationScreenState extends ConsumerState<FamilyLocationScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyLocationScreenStateProvider);
    final notifier = ref.read(familyLocationScreenStateProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            SizedBox(height: 5.dp),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                        child: objCommonWidgets.customText(context,
                            'This option lets you save delivery addresses for your friends and family, so you can place orders for them without re-entering details every time. Simply add their location once, select it during checkout, and we’ll take care of delivering the order directly to them.',
                            10,
                            Colors.black,
                            objConstantFonts.montserratRegular,
                            textAlign: TextAlign.justify
                        ),
                      ),
                    ),

                    SizedBox(height: 15.dp),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                      child: objCommonWidgets.customText(context,
                          'Friends & Family List',
                          12,
                          Colors.black,
                          objConstantFonts.montserratMedium,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.dp),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => SizedBox(height: 8.dp),
                        itemCount: state.familyMembers.length,
                        itemBuilder: (context, index) {
                          final member = state.familyMembers[index];
                          return listViewCell(context, member.name, member.mobileNumber, member.address, (){
                            notifier.callAddMemberView(context, member.name, member.mobileNumber, member.address);
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 15.dp,),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.dp),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20.dp)
                        ),
                        padding: EdgeInsets.symmetric(vertical: 13.dp),
                        child: Center(
                          child: objCommonWidgets.customText(context, 'Add new member', 13, Colors.white, objConstantFonts.montserratMedium),
                        ),
                      ), onPressed: (){
                          notifier.callAddMemberView(context, '', '', '');
                      }),
                    )



                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listViewCell(
      BuildContext context,
      String name,
      String number,
      String location,
      VoidCallback edit
      ) {
    return Stack(
      children: [

        Container(
          padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.dp),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              objCommonWidgets.customText(context,
                name,
                11,
                Colors.black,
                objConstantFonts.montserratMedium,
              ),

              SizedBox(height: 8.dp),

              titleValueRow(context, Icons.phone, '+91 $number'),
              SizedBox(height: 8.dp),
              titleValueRow(context, Icons.location_pin, location),

            ],
          ),
        ),

        Positioned(
            top: 8.dp,
            right: 8.dp,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: edit,
                child:
                SizedBox(
                  height: 15.dp,
                    width: 15.dp,
                    child: Image.asset(objConstantAssest.editImage, color: Colors.black,)
                )
            )
        )

      ],
    );
  }

  Widget titleValueRow(BuildContext context, IconData titleIcon, String value){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(5.dp),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.deepOrange.withAlpha(25)
          ),
          child: Icon(
            titleIcon,
            size: 10.dp,
            color: Colors.deepOrange,
          ),
        ),
        SizedBox(width: 5.dp),
        Expanded(
          child: objCommonWidgets.customText(context,
            value,
            10,
            Colors.black,
            objConstantFonts.montserratRegular,
          ),
        ),
      ],
    );
  }


  // Modern Header
  Widget _buildHeader(BuildContext context) {
    final userScreenNotifier = ref.watch(MainScreenGlobalStateProvider.notifier);

    return Container(
      padding: EdgeInsets.only(left: 10.dp, top: 10.dp, bottom: 5.dp),
      child: Row(
        children: [
          CupertinoButton(padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.black,
                  size: 20.dp),
              onPressed: (){
                userScreenNotifier.callBackNavigationFromLocationScreen();
              }),
          SizedBox(width: 5.dp),
          objCommonWidgets.customText(context, 'Buy for family & friends', 13, objConstantColor.black, objConstantFonts.montserratMedium),
        ],
      ),
    );
  }
}