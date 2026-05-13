import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vanguard/controllers/home_controller.dart';
import 'package:vanguard/core/themes/app_theme.dart';

class TelemetryPill extends GetView<HomeController> {
  const TelemetryPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: MediaQuery.of(context).size.width * 0.05,
      right: MediaQuery.of(context).size.width * 0.05,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: MediaQuery.of(context).size.height * 0.015,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Obx(() => Icon(
                      Icons.circle,
                      color: controller.isConnected.value ? AppTheme.secureGreen : AppTheme.warningAmber,
                      size: MediaQuery.of(context).size.width * 0.03,
                    )),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                Obx(() => Text(
                      controller.isConnected.value ? "WSS: SECURE" : "WSS: RECONNECTING",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                      ),
                    )),
              ],
            ),
            Obx(() => Text(
                  controller.gpsAccuracy.value,
                  style: TextStyle(
                    color: controller.isTrackingActive.value ? Colors.white70 : Colors.orange,
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontWeight: controller.isTrackingActive.value ? FontWeight.normal : FontWeight.bold,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
