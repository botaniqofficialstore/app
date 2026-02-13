import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

import '../../../CodeReusable/CodeReusability.dart';
import '../../../constants/ConstantVariables.dart';
import 'CancelRequestPopupState.dart';


class CancelRequestPopup extends ConsumerStatefulWidget {
  const CancelRequestPopup({super.key});

  @override
  CancelRequestPopupState createState() => CancelRequestPopupState();
}

class CancelRequestPopupState extends ConsumerState<CancelRequestPopup> {

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(cancelRequestPopupStateProvider);
    final notifier = ref.read(cancelRequestPopupStateProvider.notifier);

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
                              'Orders can be cancelled before dispatch. If the order has already been shipped, cancellation may not be possible and you may need to request a return after delivery. Eligible refunds will be processed to the original payment method as per the refund timeline.',
                              10, Colors.black,
                              objConstantFonts.montserratMedium,
                          textAlign: TextAlign.justify),
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
                            prefixIcon: Icons.highlight_off_rounded,
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
                                "Explain the cancellation reason",
                                "Enter your cancellation in detail here...",
                                description: 'Brief your exact cancel reason, this will help us to proceed this request quickly',
                                Icons.description_outlined,
                                state.reasonController,
                                onChanged: (_) => notifier.onChanged()
                            ),
                          ),



                      ],
                    ),
                  ),
                ),

                if (MediaQuery.of(context).viewInsets.bottom == 0)
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
                          'Confirm', 13, Colors.white, objConstantFonts.montserratSemiBold)),
                    )
                ),

                SizedBox(height: 20.dp)
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
            'Cancel Order',
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