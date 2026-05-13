import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vanguard/controllers/auth_controller.dart';
import 'package:vanguard/core/themes/app_theme.dart';

class UserTypeSelector extends GetView<AuthController> {
  const UserTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Row(
          children: [
            Expanded(
              child: Obx(() => GestureDetector(
                onTap: () => controller.setUserType('victim'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: controller.userType.value == 'victim' 
                        ? AppTheme.sosCrimson 
                        : Colors.transparent,
                    border: Border.all(
                      color: controller.userType.value == 'victim' 
                          ? AppTheme.sosCrimson 
                          : Colors.white24,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_pin_circle,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                      Text(
                        'Victim',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Expanded(
              child: Obx(() => GestureDetector(
                onTap: () => controller.setUserType('volunteer'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: controller.userType.value == 'volunteer' 
                        ? AppTheme.secureGreen 
                        : Colors.transparent,
                    border: Border.all(
                      color: controller.userType.value == 'volunteer' 
                          ? AppTheme.secureGreen 
                          : Colors.white24,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                      Text(
                        'Volunteer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }
}
