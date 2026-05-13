import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vanguard/controllers/emergency_controller.dart';
import 'package:vanguard/core/themes/app_theme.dart';

class EmergencyNavigation extends GetView<EmergencyController> {
  const EmergencyNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          Obx(() => controller.currentStep.value > 0
              ? TextButton(
                  onPressed: controller.previousStep,
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          
          // Next/Submit button
          Obx(() {
            final isLastStep = controller.currentStep.value == 4;
            return ElevatedButton(
              onPressed: controller.isSubmitting.value 
                  ? null 
                  : isLastStep 
                      ? controller.submitEmergency 
                      : controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.sosCrimson,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.08,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: controller.isSubmitting.value
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.06,
                      height: MediaQuery.of(context).size.width * 0.06,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isLastStep ? 'Send Alert' : 'Next',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          }),
        ],
      ),
    );
  }
}
