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
      backgroundColor: Colors.grey.withAlpha(30),
      body: profileView(context),
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
            padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 5.dp),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2.dp, offset: const Offset(0, 1))],
            ),
            child: Row(
              children: [
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.dp),
                      child: Image.asset(
                        objConstantAssest.backIcon,
                        height: 20.dp,
                        color: objConstantColor.navyBlue,
                      ),
                    ),
                    onPressed: () {
                      mainScreenNotifier.callNavigation(ScreenName.profile);
                    }),


                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.dp),
                  child: objCommonWidgets.customText(
                    context,
                    screenState.currentPage,
                    15,
                    objConstantColor.navyBlue,
                    objConstantFonts.montserratSemiBold,
                  ),
                ),


              ],
            )
        ),

        SizedBox(height: 10.dp),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: _policyContentView(context),
          ),
        )





      ],
    );
  }



  Widget _policyContentView(BuildContext context) {
    final screenState = ref.watch(InformationScreenGlobalStateProvider);

    final content = LegalContentHelper.getContent(selectedLegalInformation!);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.dp),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.dp,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.dp),

          objCommonWidgets.customText(context, content, 12, objConstantColor.navyBlue, objConstantFonts.montserratMedium)
        ],
      ),
    );
  }




}
