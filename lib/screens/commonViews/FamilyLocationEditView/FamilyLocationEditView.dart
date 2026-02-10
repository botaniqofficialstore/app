import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../CodeReusable/CodeReusability.dart';
import '../../../constants/ConstantVariables.dart';
import 'FamilyLocationEditViewState.dart';

class FamilyLocationScreen extends ConsumerStatefulWidget {
  final String name;
  final String phone;
  final String address;

  const FamilyLocationScreen({super.key,
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  FamilyLocationScreenState createState() => FamilyLocationScreenState();
}

class FamilyLocationScreenState extends ConsumerState<FamilyLocationScreen> {

  @override
  void initState() {
    Future.microtask(() {
      final notifier = ref.read(familyLocationEditViewStateProvider.notifier);
      notifier.loadData(widget.name, widget.phone, widget.address);

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyLocationEditViewStateProvider);
    final notifier = ref.read(familyLocationEditViewStateProvider.notifier);

    return GestureDetector(
      onTap: () => CodeReusability.hideKeyboard(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          child: Column(
            children: [

              _buildHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.dp),
                    child: Column(
                      children: [
                        SizedBox(height: 15.dp),

                        CodeReusability().customTextField(
                            context,
                            "Full Name",
                            "enter full name",
                            Icons.person_2_outlined,
                            state.firstNameController,
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

                        SizedBox(height: 15.dp),

                        if (state.location.isNotEmpty)...{
                          locationEditView(context)
                        }else...{
                          addLocationView(context)
                        },
                        SizedBox(height: 20.dp),
                        CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero, onPressed: notifier.allowSave()
                            ? () {
                          Navigator.pop(context);
                            } : null,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 13.dp),
                              decoration: BoxDecoration(
                                  color: notifier.allowSave() ? Colors.black : Colors.black.withAlpha(50),
                                  borderRadius: BorderRadius.circular(20.dp)
                              ),
                              child: Center(
                                child: objCommonWidgets.customText(context, 'Save', 13, Colors.white, objConstantFonts.montserratSemiBold),
                              ),
                            ),
                        ),

                      ],
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget addLocationView(BuildContext context) {
    final notifier = ref.read(familyLocationEditViewStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        objCommonWidgets.customText(
          context,
          'Add Delivery Address',
          12,
          Colors.black,
          objConstantFonts.montserratMedium,
        ),

        SizedBox(height: 5.dp),

         CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => notifier.callMapScreen(context),
            child: Container(
              height: 130.dp,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.dp),
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.dp),
                child: Stack(
                  children: [

                    const GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(10.8505, 76.2711), // Kerala default
                        zoom: 14,
                      ),
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      liteModeEnabled: true,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                    ),

                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withAlpha(50),
                      ),
                    ),

                    Positioned.fill(
                        child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.dp)
                        ),
                        padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 5.dp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.my_location_rounded,
                              size: 15.dp,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(width: 4.dp),
                            objCommonWidgets.customText(
                              context,
                              'Pick a Location',
                              10,
                              Colors.blueAccent,
                              objConstantFonts.montserratMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                    )

                  ],
                ),
              ),
            ),
          ),

      ],
    );
  }



  Widget locationEditView(BuildContext context){
    final state = ref.watch(familyLocationEditViewStateProvider);
    final notifier = ref.read(familyLocationEditViewStateProvider.notifier);

    return Container(
      padding: EdgeInsets.all(14.dp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.dp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(5.dp),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.deepOrange,
                  size: 15.dp,
                ),
              ),
              SizedBox(width: 10.dp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    objCommonWidgets.customText(context, 'Selected location', 10, Colors.black, objConstantFonts.montserratRegular),
                    objCommonWidgets.customText(context, state.location, 11, Colors.black, objConstantFonts.montserratMedium),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.dp),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5.dp, horizontal: 8.dp),
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10.dp)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.my_location_rounded, size: 15.dp, color: Colors.white,),
                        SizedBox(width: 3.5.dp),
                        objCommonWidgets.customText(context, 'Change Location', 10, Colors.white, objConstantFonts.montserratSemiBold)
                      ],
                    ),
                  ), onPressed: (){
                notifier.callMapScreen(context);
              }
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final state = ref.watch(familyLocationEditViewStateProvider);
    final title = state.isAdd ? 'Add new family member or friends' : 'Edit';

    return Container(
      padding: EdgeInsets.only(left: 10.dp, top: 10.dp, bottom: 5.dp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoButton(padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.black,
                  size: 20.dp),
              onPressed: (){
                Navigator.pop(context);
              }),
          SizedBox(width: 5.dp),
          Expanded(child: objCommonWidgets.customText(context, title, 13, objConstantColor.black, objConstantFonts.montserratMedium)),
        ],
      ),
    );
  }


}