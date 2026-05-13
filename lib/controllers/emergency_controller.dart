import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:vanguard/services/emergency_service.dart';
import 'package:vanguard/services/auth_service.dart';
import 'package:geolocator/geolocator.dart';


class EmergencyController extends GetxController {
  // Emergency incident data
  final RxString incidentType = ''.obs;
  final RxString incidentDescription = ''.obs;
  final RxInt peopleInvolved = 0.obs;
  final RxInt injuredCount = 0.obs;
  final RxInt criticalInjured = 0.obs;
  final RxBool hasFire = false.obs;
  final RxBool hasWeapons = false.obs;
  final RxBool hasStructuralCollapse = false.obs;
  final RxString locationDescription = ''.obs;
  final RxBool immediateDanger = false.obs;
  final RxList<String> emergencyServices = <String>[].obs;
  
  // Location data
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxString locationError = ''.obs;
  final RxBool isLocationLoading = false.obs;
  
  // UI state
  final RxInt currentStep = 0.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isEmergencyConfirmed = false.obs;
  
  // Form validation
  final RxString incidentTypeError = ''.obs;
  final RxString peopleInvolvedError = ''.obs;
  final RxString injuredCountError = ''.obs;
  final RxString locationDescriptionError = ''.obs;
  
  // Emergency types
  final List<String> incidentTypes = [
    'Medical Emergency',
    'Traffic Accident',
    'Fire',
    'Violence/Assault',
    'Natural Disaster',
    'Structural Collapse',
    'Chemical Spill',
    'Other Emergency',
  ];
  
  // Emergency services options
  final List<String> availableServices = [
    'Ambulance',
    'Fire Department',
    'Police',
    'Search and Rescue',
    'Hazmat Team',
  ];
  
  @override
  void onInit() {
    super.onInit();
    _initializeDefaults();
  }
  
  void _initializeDefaults() {
    peopleInvolved.value = 1; // Default to at least 1 person (the victim)
    emergencyServices.addAll(['Ambulance']); // Default to ambulance
    _getCurrentLocation(); // Get user location on initialization
  }
  
  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      isLocationLoading.value = true;
      locationError.value = '';
      
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationError.value = 'Location permissions are denied';
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        locationError.value = 'Location permissions are permanently denied';
        return;
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      
      debugPrint('=== LOCATION DEBUG ===');
      debugPrint('Raw position: ${position.toString()}');
      debugPrint('Latitude: ${latitude.value} (type: ${latitude.value.runtimeType})');
      debugPrint('Longitude: ${longitude.value} (type: ${longitude.value.runtimeType})');
      debugPrint('Accuracy: ${position.accuracy} meters');
      debugPrint('Timestamp: ${position.timestamp}');
      debugPrint('==================');
    } catch (e) {
      debugPrint('Error getting location: $e');
      locationError.value = 'Failed to get location: $e';
    } finally {
      isLocationLoading.value = false;
    }
  }
  
  // Refresh location
  Future<void> refreshLocation() async {
    await _getCurrentLocation();
  }
  
  // Navigation
  void nextStep() {
    if (_validateCurrentStep()) {
      HapticFeedback.lightImpact();
      if (currentStep.value < 4) {
        currentStep.value++;
      }
    }
  }
  
  void previousStep() {
    HapticFeedback.lightImpact();
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }
  
  // Incident type selection
  void setIncidentType(String type) {
    incidentType.value = type;
    incidentTypeError.value = '';
    
    // Auto-select relevant services based on incident type
    _autoSelectServices(type);
  }
  
  void _autoSelectServices(String type) {
    emergencyServices.clear();
    
    switch (type) {
      case 'Medical Emergency':
        emergencyServices.add('Ambulance');
        break;
      case 'Traffic Accident':
        emergencyServices.addAll(['Ambulance', 'Police']);
        break;
      case 'Fire':
        emergencyServices.addAll(['Fire Department', 'Ambulance']);
        break;
      case 'Violence/Assault':
        emergencyServices.addAll(['Police', 'Ambulance']);
        break;
      case 'Natural Disaster':
        emergencyServices.addAll(['Search and Rescue', 'Ambulance', 'Fire Department']);
        break;
      case 'Structural Collapse':
        emergencyServices.addAll(['Search and Rescue', 'Ambulance', 'Fire Department']);
        break;
      case 'Chemical Spill':
        emergencyServices.addAll(['Hazmat Team', 'Ambulance', 'Fire Department']);
        break;
      default:
        emergencyServices.add('Ambulance');
    }
  }
  
  // People involved
  void setPeopleInvolved(int count) {
    peopleInvolved.value = count;
    peopleInvolvedError.value = '';
    
    // Ensure injured count doesn't exceed total people
    if (injuredCount.value > count) {
      injuredCount.value = count;
    }
    if (criticalInjured.value > injuredCount.value) {
      criticalInjured.value = injuredCount.value;
    }
  }
  
  void incrementPeopleInvolved() {
    setPeopleInvolved(peopleInvolved.value + 1);
  }
  
  void decrementPeopleInvolved() {
    if (peopleInvolved.value > 1) {
      setPeopleInvolved(peopleInvolved.value - 1);
    }
  }
  
  // Injured people
  void setInjuredCount(int count) {
    if (count <= peopleInvolved.value) {
      injuredCount.value = count;
      injuredCountError.value = '';
      
      // Ensure critical injured doesn't exceed total injured
      if (criticalInjured.value > count) {
        criticalInjured.value = count;
      }
    }
  }
  
  void incrementInjured() {
    if (injuredCount.value < peopleInvolved.value) {
      setInjuredCount(injuredCount.value + 1);
    }
  }
  
  void decrementInjured() {
    if (injuredCount.value > 0) {
      setInjuredCount(injuredCount.value - 1);
    }
  }
  
  // Critical injured
  void setCriticalInjured(int count) {
    if (count <= injuredCount.value) {
      criticalInjured.value = count;
    }
  }
  
  void incrementCritical() {
    if (criticalInjured.value < injuredCount.value) {
      setCriticalInjured(criticalInjured.value + 1);
    }
  }
  
  void decrementCritical() {
    if (criticalInjured.value > 0) {
      setCriticalInjured(criticalInjured.value - 1);
    }
  }
  
  // Boolean flags
  void toggleFire() {
    hasFire.value = !hasFire.value;
    if (hasFire.value && !emergencyServices.contains('Fire Department')) {
      emergencyServices.add('Fire Department');
    }
  }
  
  void toggleWeapons() {
    hasWeapons.value = !hasWeapons.value;
    if (hasWeapons.value && !emergencyServices.contains('Police')) {
      emergencyServices.add('Police');
    }
  }
  
  void toggleStructuralCollapse() {
    hasStructuralCollapse.value = !hasStructuralCollapse.value;
    if (hasStructuralCollapse.value && !emergencyServices.contains('Search and Rescue')) {
      emergencyServices.add('Search and Rescue');
    }
  }
  
  void toggleImmediateDanger() {
    immediateDanger.value = !immediateDanger.value;
  }
  
  // Emergency services
  void toggleEmergencyService(String service) {
    if (emergencyServices.contains(service)) {
      emergencyServices.remove(service);
    } else {
      emergencyServices.add(service);
    }
  }
  
  // Validation
  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        return _validateIncidentType();
      case 1:
        return _validatePeopleInvolved();
      case 2:
        return _validateInjuries();
      case 3:
        return _validateHazards();
      case 4:
        return _validateLocation();
      default:
        return true;
    }
  }
  
  bool _validateIncidentType() {
    if (incidentType.value.isEmpty) {
      incidentTypeError.value = 'Please select an incident type';
      return false;
    }
    incidentTypeError.value = '';
    return true;
  }
  
  bool _validatePeopleInvolved() {
    if (peopleInvolved.value < 1) {
      peopleInvolvedError.value = 'At least 1 person must be involved';
      return false;
    }
    peopleInvolvedError.value = '';
    return true;
  }
  
  bool _validateInjuries() {
    if (injuredCount.value < 0 || injuredCount.value > peopleInvolved.value) {
      injuredCountError.value = 'Invalid number of injured people';
      return false;
    }
    injuredCountError.value = '';
    return true;
  }
  
  bool _validateHazards() {
    // Hazards step is optional - no validation needed
    return true;
  }
  
  bool _validateLocation() {
    if (locationDescription.value.trim().isEmpty) {
      locationDescriptionError.value = 'Please provide location details';
      return false;
    }
    locationDescriptionError.value = '';
    return true;
  }
  
  // Emergency submission
  Future<void> submitEmergency() async {
    if (!_validateAllSteps()) {
      HapticFeedback.heavyImpact();
      Get.snackbar(
        'Validation Error',
        'Please complete all required fields',
        backgroundColor: const Color(0xFFFF9800),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    
    isSubmitting.value = true;
    HapticFeedback.heavyImpact();
    
    try {
      // Validate location is available
      if (latitude.value == 0.0 && longitude.value == 0.0) {
        await _getCurrentLocation();
        if (latitude.value == 0.0 && longitude.value == 0.0) {
          Get.snackbar(
            'Location Required',
            'Please enable location services to send emergency alert',
            backgroundColor: const Color(0xFFFF9800),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      }
      
      // Get current user for victim_id
      final currentUserResponse = await AuthService.getCurrentUser();
      final victimId = currentUserResponse['data']['user']['id'];
      
      // Create emergency data package matching backend API
      final emergencyData = {
        'victim_id': victimId,
        'incident_type': incidentType.value,
        'description': incidentDescription.value,
        'people_involved': peopleInvolved.value,
        'injured_count': injuredCount.value,
        'critical_injured': criticalInjured.value,
        'has_fire': hasFire.value,
        'has_weapons': hasWeapons.value,
        'has_structural_collapse': hasStructuralCollapse.value,
        'location_description': locationDescription.value,
        'immediate_danger': immediateDanger.value,
        'emergency_services': emergencyServices.toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'urgency_level': _calculateUrgencyLevel(),
        'latitude': latitude.value,
        'longitude': longitude.value,
      };
      
      debugPrint('=== EMERGENCY SUBMISSION ===');
      debugPrint('Emergency Data: ${json.encode(emergencyData)}');
      debugPrint('Latitude: ${latitude.value} (type: ${latitude.value.runtimeType})');
      debugPrint('Longitude: ${longitude.value} (type: ${longitude.value.runtimeType})');
      debugPrint('Victim ID: $victimId');
      debugPrint('Urgency Level: ${_calculateUrgencyLevel()}');
      debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('========================');
      
      // Send to backend API
      await EmergencyService.createEmergency(emergencyData);
      
      isEmergencyConfirmed.value = true;
      
      Get.snackbar(
        'Emergency Alert Sent',
        'Help is on the way!',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
      
      // Navigate to home screen after delay
      Future.delayed(const Duration(seconds: 3), () {
        Get.offAllNamed('/home');
      });
      
    } catch (e) {
      debugPrint('Emergency submission error: $e');
      Get.snackbar(
        'Submission Error',
        'Failed to send emergency alert. Please try again.',
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
  
  bool _validateAllSteps() {
    return _validateIncidentType() &&
           _validatePeopleInvolved() &&
           _validateInjuries() &&
           _validateLocation();
  }
  
  String _calculateUrgencyLevel() {
    int score = 0;
    
    if (criticalInjured.value > 0) score += 3;
    if (injuredCount.value > 2) score += 2;
    if (immediateDanger.value) score += 2;
    if (hasFire.value) score += 2;
    if (hasWeapons.value) score += 2;
    if (hasStructuralCollapse.value) score += 2;
    if (peopleInvolved.value > 5) score += 1;
    
    if (score >= 6) return 'CRITICAL';
    if (score >= 4) return 'HIGH';
    if (score >= 2) return 'MEDIUM';
    return 'LOW';
  }
  
  // Reset form
  void resetForm() {
    incidentType.value = '';
    incidentDescription.value = '';
    peopleInvolved.value = 1;
    injuredCount.value = 0;
    criticalInjured.value = 0;
    hasFire.value = false;
    hasWeapons.value = false;
    hasStructuralCollapse.value = false;
    locationDescription.value = '';
    immediateDanger.value = false;
    emergencyServices.clear();
    currentStep.value = 0;
    isSubmitting.value = false;
    isEmergencyConfirmed.value = false;
    
    // Reset location
    latitude.value = 0.0;
    longitude.value = 0.0;
    locationError.value = '';
    isLocationLoading.value = false;
    
    // Clear errors
    incidentTypeError.value = '';
    peopleInvolvedError.value = '';
    injuredCountError.value = '';
    locationDescriptionError.value = '';
    
    _initializeDefaults();
  }
}
