import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../../../constants/Constants.dart';
import '../../MainScreen/MainScreenState.dart';
import 'InformationScreenState.dart';
import 'LegalContentHelper.dart';


class InformationScreen extends ConsumerStatefulWidget {
  const InformationScreen({super.key});

  @override
  InformationScreenState createState() => InformationScreenState();
}

class InformationScreenState extends ConsumerState<InformationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final screenNotifier = ref.read(InformationScreenGlobalStateProvider.notifier);
      screenNotifier.updatePageDetails();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(child: profileView(context)),
    );
  }


  ///Profile Screen
  Widget profileView(BuildContext context) {
    final screenState = ref.watch(InformationScreenGlobalStateProvider);
    final mainScreenNotifier = ref.read(MainScreenGlobalStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
            padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 10.dp),
            child: Row(
              children: [
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.dp),
                      child: Icon(Icons.arrow_back_rounded,
                          color: Colors.black,
                          size: 20.dp),
                    ),
                    onPressed: () {
                      mainScreenNotifier.callNavigation(ScreenName.profile);
                    }),


                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.dp),
                  child: objCommonWidgets.customText(
                    context,
                    screenState.currentPage,
                    14,
                    objConstantColor.navyBlue,
                    objConstantFonts.montserratMedium,
                  ),
                ),


              ],
            )
        ),


        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 10.dp),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _policyContentView(context),
            ),
          ),
        ),

        SizedBox(height: 10.dp),



      ],
    );
  }



  Widget _policyContentView(BuildContext context) {
    final content = LegalContentHelper.getContent(selectedLegalInformation!);
    final lines = content.split('\n');

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          final text = line.trim();

          // Empty line
          if (text.isEmpty) {
            return SizedBox(height: 8.dp);
          }

          // Headings (end with :)
          if (text.endsWith(':')) {
            return Padding(
              padding: EdgeInsets.only(left: 15.dp, top: 12.dp, bottom: 5.dp),
              child: objCommonWidgets.customText(
                context,
                text.toUpperCase(),
                10,
                objConstantColor.navyBlue,
                objConstantFonts.montserratSemiBold,
              ),
            );
          }

          // Bullet points

          if (text.startsWith('•')) {
            return Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15.dp, vertical: 2.dp),
              child: objCommonWidgets.customText(
                context,
                text,
                10,
                objConstantColor.navyBlue,
                objConstantFonts.montserratMedium,
              ),
            );
          }

          // Normal paragraph
          return Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
            child: objCommonWidgets.customText(
              context,
              text,
              10,
              objConstantColor.navyBlue,
              objConstantFonts.montserratMedium,
            ),
          );
        }).toList(),
      ),
    );
  }






}
