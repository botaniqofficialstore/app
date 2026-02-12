import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

import '../../../CodeReusable/CodeReusability.dart';
import '../../../constants/ConstantVariables.dart';
import 'ReturnRequestPopupState.dart';


class ReturnRequestPopup extends ConsumerStatefulWidget {
  const ReturnRequestPopup({super.key});

  @override
  ReturnRequestPopupState createState() => ReturnRequestPopupState();
}

class ReturnRequestPopupState extends ConsumerState<ReturnRequestPopup> {

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(returnRequestPopupStateProvider);
    final notifier = ref.read(returnRequestPopupStateProvider.notifier);

    return GestureDetector(
      onTap: () => CodeReusability.hideKeyboard(context),
      child: Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          body: SafeArea(
            child: Column(
              children: [
                headerView(),
      
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.dp, vertical: 10.dp),
                          child: objCommonWidgets.customText(
                              context,
                              'Returns can be requested within 24 hours of delivery. Select the reason and submit your request. Once approved, we will arrange pickup, and the refund will be processed to your original payment method after verification. Processing time may vary based on your payment provider.',
                              10, Colors.black,
                              objConstantFonts.montserratMedium),
                        ),
      
                        SizedBox(height: 20.dp),
      
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.dp, vertical: 5.dp),
                          child: CodeReusability().customSingleDropdownField(
                            context: context,
                            placeholder: "Select Reason",
                            items: state.returnReason,
                            selectedValue: state.reason,
                            prefixIcon: Icons.restart_alt_sharp,
                            onChanged: (value) {
                              setState(() {
                                notifier.updateReason(value!);
                              });
                            },
                          ),
                        ),
      
                        if(state.isOther)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.dp, vertical: 10.dp),
                          child: CodeReusability().customTextView(
                              context,
                              "Explain the return reason",
                              "Enter your reason in detail here...",
                              description: 'Brief your exact reason for this return, this will help us to proceed this request quickly',
                              Icons.description_outlined,
                              state.reasonController,
                              onChanged: (_) => notifier.onChanged()
                          ),
                        ),
      
                        SizedBox(height: 20.dp),

                        CupertinoButton(
                            padding: EdgeInsets.symmetric(horizontal: 15.dp),
                            onPressed: state.isSubmit ? () => notifier.callSubmit(context)
                            : null,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 13.dp),
                              decoration: BoxDecoration(
                                  color: state.isSubmit ? Colors.deepOrange : Colors.grey,
                                  borderRadius: BorderRadius.circular(20.dp)
                              ),
                              child: Center(child: objCommonWidgets.customText(context,
                                  'Submit', 13, Colors.white, objConstantFonts.montserratSemiBold)),
                            ) )
      
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }


  Widget headerView() {
    return Container(
      padding: EdgeInsets.only(
          top: 5.dp, right: 10.dp, left: 10.dp, bottom: 8.dp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          CupertinoButton(padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            child: Icon(Icons.arrow_back_rounded,
                color: Colors.black,
                size: 18.dp),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          SizedBox(width: 5.dp),

          objCommonWidgets.customText(
            context,
            'Request for return',
            14,
            objConstantColor.black,
            objConstantFonts.montserratMedium,
          ),

          const Spacer(),

        ],
      ),
    );
  }
}