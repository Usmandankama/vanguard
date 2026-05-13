import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vanguard/controllers/home_controller.dart';
import 'package:vanguard/core/themes/app_theme.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<HomeController>();

    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: Stack(
        children: [
          // ─── 1. BASE MAP ────────────────────────────────────────────────
          Obx(() {
            if (controller.isLoadingLocation.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.sosCrimson),
              );
            }
            if (controller.currentPosition.value == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off_rounded,
                        color: Colors.white38, size: sw * 0.12),
                    SizedBox(height: sh * 0.02),
                    Text(
                      'Unable to acquire location',
                      style: TextStyle(
                          color: Colors.white38, fontSize: sw * 0.04),
                    ),
                  ],
                ),
              );
            }
            return FlutterMap(
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
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.vanguardnet.app',
                  maxZoom: 18.0,
                ),
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
                Obx(() =>
                    controller.currentPosition.value != null &&
                            controller.isTrackingActive.value
                        ? CircleLayer(
                            circles: [
                              CircleMarker(
                                point: controller.currentPosition.value!,
                                radius:
                                    _getAccuracyRadius(controller.gpsAccuracy.value),
                                color: Colors.blue.withOpacity(0.07),
                                borderColor: Colors.blue.withOpacity(0.25),
                                borderStrokeWidth: 1.5,
                              ),
                            ],
                          )
                        : const CircleLayer(circles: [])),
              ],
            );
          }),

          // ─── 2. TOP TELEMETRY BAR ───────────────────────────────────────
          Positioned(
            top: top + 16,
            left: sw * 0.04,
            right: sw * 0.04,
            child: _TelemetryBar(controller: controller, sw: sw),
          ),


          // ─── 4. SOS LONG-PRESS BUTTON ────────────────────────────────────
          Positioned(
            bottom: sh * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: _SOSButton(controller: controller, sw: sw),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMarker(HomeController controller) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.15),
            border: Border.all(color: Colors.blue.withOpacity(0.6), width: 1.5),
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: const Icon(Icons.my_location_rounded,
              color: Colors.white, size: 11),
        ),
        if (controller.heading.value > 0)
          Positioned(
            top: 4,
            child: Transform.rotate(
              angle: controller.heading.value * 3.14159265 / 180,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _getAccuracyRadius(String accuracy) {
    try {
      return double.parse(accuracy.replaceAll(RegExp(r'[^\d.]'), ''));
    } catch (_) {
      return 10.0;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TELEMETRY BAR
// ─────────────────────────────────────────────────────────────────────────────
class _TelemetryBar extends StatelessWidget {
  final HomeController controller;
  final double sw;
  const _TelemetryBar({required this.controller, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04, vertical: sw * 0.025),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.82),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // WS status
          Obx(() => _StatusDot(
                active: controller.isConnected.value,
                activeColor: AppTheme.secureGreen,
                inactiveColor: AppTheme.warningAmber,
              )),
          SizedBox(width: sw * 0.02),
          Obx(() => Text(
                controller.isConnected.value ? 'WSS · LIVE' : 'WSS · RECONNECTING',
                style: TextStyle(
                  color: controller.isConnected.value
                      ? Colors.white70
                      : AppTheme.warningAmber,
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              )),
          const Spacer(),
          // GPS accuracy
          Icon(Icons.gps_fixed_rounded,
              color: Colors.white38, size: sw * 0.035),
          SizedBox(width: sw * 0.015),
          Obx(() => Text(
                controller.gpsAccuracy.value,
                style: TextStyle(
                  color: controller.isTrackingActive.value
                      ? Colors.white54
                      : AppTheme.warningAmber,
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w500,
                ),
              )),
          SizedBox(width: sw * 0.04),
          // Nearby responders count
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.025, vertical: sw * 0.01),
            decoration: BoxDecoration(
              color: AppTheme.sosCrimson.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppTheme.sosCrimson.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.people_alt_rounded,
                    color: AppTheme.sosCrimson, size: sw * 0.03),
                SizedBox(width: sw * 0.012),
                Obx(() => Text(
                      '${controller.nearbyResponderCount.value}',
                      style: TextStyle(
                        color: AppTheme.sosCrimson,
                        fontSize: sw * 0.028,
                        fontWeight: FontWeight.w700,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  const _StatusDot(
      {required this.active,
      required this.activeColor,
      required this.inactiveColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? activeColor : inactiveColor,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SOS BUTTON — long press to fire, hold-ring animation
// ─────────────────────────────────────────────────────────────────────────────
class _SOSButton extends StatefulWidget {
  final HomeController controller;
  final double sw;
  const _SOSButton({required this.controller, required this.sw});

  @override
  State<_SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<_SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _holdController;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSOSTrigger();
      }
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _startHold() {
    setState(() => _holding = true);
    HapticFeedback.mediumImpact();
    _holdController.forward(from: 0);
  }

  void _cancelHold() {
    setState(() => _holding = false);
    _holdController.reverse();
  }

  void _onSOSTrigger() {
    HapticFeedback.heavyImpact();
    widget.controller.triggerEmergencyBroadcast();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.sw * 0.26;

    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _cancelHold(),
      onLongPressCancel: _cancelHold,
      child: SizedBox(
        width: size + 24,
        height: size + 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hold-progress ring
            AnimatedBuilder(
              animation: _holdController,
              builder: (_, __) => SizedBox(
                width: size + 20,
                height: size + 20,
                child: CircularProgressIndicator(
                  value: _holdController.value,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _holding
                        ? AppTheme.sosCrimson
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
            // Core button
            AnimatedScale(
              scale: _holding ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.sosCrimson,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.sosCrimson.withOpacity(
                          _holding ? 0.7 : 0.45),
                      blurRadius: _holding ? 30 : 20,
                      spreadRadius: _holding ? 8 : 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: widget.sw * 0.065,
                        letterSpacing: 2.5,
                      ),
                    ),
                    Text(
                      'hold to send',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: widget.sw * 0.024,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}