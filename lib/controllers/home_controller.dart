import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class HomeController extends GetxController {
  // Reactive State Variables (The 'Rx' types)
  final RxBool isConnected = true.obs; // Mock WSS state
  final RxBool isPressingSOS = false.obs;
  final RxBool isLoadingLocation = true.obs;
  final Rx<LatLng?> currentPosition = Rx<LatLng?>(null);
  final RxString gpsAccuracy = '±0m'.obs;
  final RxDouble heading = 0.0.obs; // Device heading for marker rotation
  final RxBool isTrackingActive = false.obs;

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'GPS Error',
        'Please enable location services.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required for emergency services.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
    }

    // Get initial position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      currentPosition.value = LatLng(position.latitude, position.longitude);
      _updateAccuracy(position.accuracy);
      isLoadingLocation.value = false;

      // Start real-time tracking
      _startLocationTracking();
    } catch (e) {
      debugPrint('Location error: $e');
      Get.snackbar(
        'Location Error',
        'Unable to get your location. Please check GPS settings.',
        snackPosition: SnackPosition.TOP,
      );
      isLoadingLocation.value = false;
    }
  }

  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
      timeLimit: Duration(seconds: 30),
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            currentPosition.value = LatLng(
              position.latitude,
              position.longitude,
            );
            _updateAccuracy(position.accuracy);
            heading.value = position.heading;
            isTrackingActive.value = true;
          },
          onError: (error) {
            debugPrint('Location stream error: $error');
            isTrackingActive.value = false;
            Get.snackbar(
              'GPS Lost',
              'Location tracking interrupted. Reconnecting...',
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFFFF9800),
            );
          },
          onDone: () {
            isTrackingActive.value = false;
          },
        );
  }

  void _updateAccuracy(double accuracy) {
    // Format accuracy display
    if (accuracy < 10) {
      gpsAccuracy.value = '±${accuracy.toStringAsFixed(0)}m';
    } else if (accuracy < 100) {
      gpsAccuracy.value = '±${accuracy.toStringAsFixed(1)}m';
    } else {
      gpsAccuracy.value = '±${accuracy.toStringAsFixed(0)}m';
    }
  }

  void triggerEmergencyBroadcast() {
    HapticFeedback.vibrate();
    if (currentPosition.value != null) {
      // TODO: Month 1 Backend Integration -> Send WSS Payload to Bun/ElysiaJS
      debugPrint(
        "SOS BROADCAST: ${currentPosition.value!.latitude}, ${currentPosition.value!.longitude}",
      );
      Get.snackbar(
        'SOS INITIATED',
        'Broadcasting to Vanguards within 5km...',
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void setPressingSOS(bool value) {
    isPressingSOS.value = value;
  }
}
