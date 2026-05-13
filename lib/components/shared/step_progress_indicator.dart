import 'package:flutter/material.dart';
import 'package:vanguard/core/themes/app_theme.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double? height;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              return Expanded(
                child: Container(
                  height: height ?? 4,
                  margin: EdgeInsets.only(
                    right: index < totalSteps - 1 ? MediaQuery.of(context).size.width * 0.02 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: index <= currentStep
                        ? AppTheme.sosCrimson
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: TextStyle(
              color: Colors.white70,
              fontSize: MediaQuery.of(context).size.width * 0.035,
            ),
          ),
        ],
      ),
    );
  }
}
