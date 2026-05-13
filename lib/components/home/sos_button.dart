import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vanguard/controllers/home_controller.dart';
import 'package:vanguard/core/themes/app_theme.dart';

class SOSButton extends GetView<HomeController> {
  const SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.15,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTapDown: (_) => controller.setPressingSOS(true),
        onTapUp: (_) => controller.setPressingSOS(false),
        onTapCancel: () => controller.setPressingSOS(false),
        onLongPress: controller.triggerEmergencyBroadcast,
        child: Center(
          child: Obx(() => AnimatedScale(
                scale: controller.isPressingSOS.value ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.sosCrimson,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: controller.isPressingSOS.value ? 5 : 10,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "SOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.06,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
