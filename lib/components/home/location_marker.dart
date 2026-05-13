import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vanguard/controllers/home_controller.dart';

class LocationMarker extends GetView<HomeController> {
  const LocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
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
}
