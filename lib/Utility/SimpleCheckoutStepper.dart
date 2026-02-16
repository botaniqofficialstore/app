import 'package:botaniqmicrogreens/constants/ConstantVariables.dart';
import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class SimpleCheckoutStepper extends StatelessWidget {
  final int currentStep;

  const SimpleCheckoutStepper({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 80.w,
        height: 50.dp, // Slightly increased to prevent title clipping
        child: EasyStepper(
          activeStep: currentStep,
          // 1. Remove the dashed border line
          showStepBorder: false,
          unreachedStepBackgroundColor: Colors.grey.shade300,
          unreachedStepBorderColor: Colors.transparent,

          // 2. Visual styling for the connecting lines
          lineStyle: LineStyle(
            lineLength: 60.dp,
            lineType: LineType.normal,
            defaultLineColor: Colors.black.withAlpha(100),
            finishedLineColor: Colors.black,
            lineThickness: 1,
          ),
          activeStepBackgroundColor: Colors.deepOrange,

          internalPadding: 20,
          // Enables the "breathing" animation on the active step
          showLoadingAnimation: true,
          stepRadius: 15.dp,

          steps: [
            EasyStep(
                customStep: _buildStepIcon(Icons.location_on, 0),
                customTitle: Center(
                  child: objCommonWidgets.customText(
                      context,
                      'Shipping Address',
                      10,
                      currentStep == 0 ? Colors.black : Colors.black.withAlpha(100),
                      objConstantFonts.montserratSemiBold
                  ),
                )
            ),
            EasyStep(
              customStep: _buildStepIcon(Icons.payment_rounded, 1),
              customTitle: Center(
                child: objCommonWidgets.customText(
                    context,
                    'Payment',
                    10,
                    currentStep == 1 ? Colors.black : Colors.black.withAlpha(100),
                    objConstantFonts.montserratSemiBold
                ),
              ),
            ),
          ],
          onStepReached: (index) {},
        ),
      ),
    );
  }

  Widget _buildStepIcon(IconData icon, int stepIndex) {
    // Check states based on 0-indexed currentStep
    bool isActive = currentStep == stepIndex;
    bool isFinished = currentStep > stepIndex;

    return Container(
      // Ensure the container fills the EasyStep radius
      width: 30.dp,
      height: 30.dp,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // If it's the active step OR already finished, show black.
        // Otherwise (unreached/animating), show gray.
        color: (isActive || isFinished) ? Colors.deepOrange : Colors.grey.shade300,
        boxShadow: isActive
            ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ]
            : [],
      ),
      child: Icon(
        icon,
        color: (isActive || isFinished) ? Colors.white : Colors.grey.shade600,
        size: 15.dp,
      ),
    );
  }
}
