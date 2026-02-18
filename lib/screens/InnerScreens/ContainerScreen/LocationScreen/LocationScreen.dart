import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../constants/ConstantVariables.dart';
import '../../MainScreen/MainScreenState.dart';
import 'LocationScreenState.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends ConsumerState<LocationScreen> {

  @override
  void initState() {
    Future.microtask(() {
      final notifier = ref.read(locationScreenStateProvider.notifier);
      notifier.loadLocation();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationScreenStateProvider);
    final notifier = ref.read(locationScreenStateProvider.notifier);
    String btnText = state.selectedLocation == null ? 'Pick Location' : 'Change Location';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4), // Clean organic off-white
      body: SafeArea(
        child: Column(
          children: [

            _buildHeader(context),

            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 15.dp),
                child: objCommonWidgets.customText(context,
                    'Please provide the correct delivery address where you would like your order to be delivered. This helps us ensure timely delivery, accurate service availability, and a smooth order experience.',
                    10,
                    Colors.black,
                    objConstantFonts.montserratRegular,
                textAlign: TextAlign.start
                ),
              ),
            ),

            if (state.selectedLocation != null)
              Padding(
                padding: EdgeInsets.only(left: 15.dp, right: 15.dp, top: 25.dp),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.dp, horizontal: 10.dp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.dp),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(35),
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      objCommonWidgets.customText(context, 'Selected Location', 12,
                          Colors.black.withAlpha(150), objConstantFonts.montserratMedium),

                      SizedBox(height: 5.dp),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 3.dp),
                            child: Image.asset(objConstantAssest.locFour, width: 18.dp),
                          ),
                          SizedBox(width: 5.dp),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              objCommonWidgets.customText(context, state.selectPickupAddress.split(',').first, 15,
                                  Colors.black, objConstantFonts.montserratBold),
                              objCommonWidgets.customText(context, state.selectPickupAddress, 12,
                                  Colors.black, objConstantFonts.montserratRegular),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.dp, vertical: 15.dp),
              child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15.dp, horizontal: 10.dp),
                    decoration: BoxDecoration(
                        color: const Color(0xFF4D7BFA),
                        borderRadius: BorderRadius.circular(20.dp)
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.my_location, color: Colors.white, size: 18.dp),
                          SizedBox(width: 5.dp,),
                          objCommonWidgets.customText(context, btnText, 13, Colors.white, objConstantFonts.montserratSemiBold),
                        ],
                      ),
                    ),
                  ), onPressed: ()=> notifier.callMapPopup(context)
              ),
            )
          ],
        ),
      ),
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
          objCommonWidgets.customText(context, 'Delivery Location', 14, objConstantColor.black, objConstantFonts.montserratMedium),
        ],
      ),
    );
  }
}