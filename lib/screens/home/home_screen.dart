import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vanguard/controllers/home_controller.dart';
import 'package:vanguard/core/themes/app_theme.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: Stack(
        children: [
          // 1. BASE LAYER: OSM MAP
                  Obx(() => controller.isLoadingLocation.value
              ? const Center(child: CircularProgressIndicator(color: AppTheme.sosCrimson))
              : controller.currentPosition.value == null
                  ? const Center(child: Text("Unable to get location", style: TextStyle(color: Colors.white)))
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: controller.currentPosition.value!,
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                        minZoom: 13.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.vanguardnet.app',
                          maxZoom: 18.0,
                        ),
                        // Current location marker with custom design
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: controller.currentPosition.value!,
                              width: 80,
                              height: 80,
                              child: Obx(() => _buildLocationMarker(controller)),
                            ),
                          ],
                        ),
                        // Accuracy circle
                        Obx(() => controller.currentPosition.value != null && controller.isTrackingActive.value
                            ? CircleLayer(
                                circles: [
                                  CircleMarker(
                                    point: controller.currentPosition.value!,
                                    radius: _getAccuracyRadius(controller.gpsAccuracy.value),
                                    color: Colors.blue.withOpacity(0.1),
                                    borderColor: Colors.blue.withOpacity(0.3),
                                    borderStrokeWidth: 2.0,
                                  ),
                                ],
                              )
                            : const CircleLayer(circles: [])),
                      ],
                    )),

          // 2. TOP TELEMETRY PILL
          Positioned(
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
          ),

          // 3. BOTTOM SLIDE-UP PANEL (Incident Feed)
          DraggableScrollableSheet(
            initialChildSize: 0.15,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)],
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 5, // Mock data
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: MediaQuery.of(context).size.width * 0.01,
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                      );
                    }
                    return ListTile(
                      leading: Icon(Icons.warning_amber_rounded, color: AppTheme.warningAmber, size: MediaQuery.of(context).size.width * 0.06),
                      title: Text("Medical Emergency", style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.04)),
                      subtitle: Text("2.4 km away • 1m ago", style: TextStyle(color: Colors.white70, fontSize: MediaQuery.of(context).size.width * 0.035)),
                      trailing: TextButton(
                        onPressed: () {},
                        child: Text("RESPOND", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035)),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // 4. THE PULSE BUTTON (Center-Bottom)
          Positioned(
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
          ),
        ],
      ),
    );
  }

  // Custom location marker widget
  Widget _buildLocationMarker(HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.2),
              border: Border.all(color: Colors.blue, width: 2),
            ),
          ),
          // Inner solid circle
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 12,
            ),
          ),
          // Direction indicator (shows heading)
          if (controller.heading.value > 0)
            Positioned(
              top: 2,
              child: Transform.rotate(
                angle: controller.heading.value * 3.14159 / 180,
                child: const Icon(
                  Icons.north_rounded,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Convert GPS accuracy string to radius in meters
  double _getAccuracyRadius(String accuracy) {
    try {
      // Extract numeric value from string like "±5m"
      final numericValue = double.parse(accuracy.replaceAll(RegExp(r'[^\d.]'), ''));
      return numericValue; // Return accuracy as radius
    } catch (e) {
      return 10.0; // Default 10m radius if parsing fails
    }
  }
}