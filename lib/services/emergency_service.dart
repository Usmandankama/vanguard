import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'base_api_service.dart';

class EmergencyService {
  // SOS endpoints matching backend API
  
  /// Creates a new emergency alert
  /// POST /api/sos/create
  static Future<Map<String, dynamic>> createEmergency(Map<String, dynamic> emergencyData) async {
    // Transform data to match backend API structure
    final sosData = {
      'victim_id': emergencyData['victim_id'], // Should come from auth context
      'type': _mapIncidentTypeToSosType(emergencyData['incident_type']),
      'description': emergencyData['description'],
      'metadata': {
        'people_involved': emergencyData['people_involved'],
        'injured_count': emergencyData['injured_count'],
        'critical_injured': emergencyData['critical_injured'],
        'has_fire': emergencyData['has_fire'],
        'has_weapons': emergencyData['has_weapons'],
        'has_structural_collapse': emergencyData['has_structural_collapse'],
        'location_description': emergencyData['location_description'],
        'immediate_danger': emergencyData['immediate_danger'],
        'emergency_services': emergencyData['emergency_services'],
        'urgency_level': emergencyData['urgency_level'],
      },
      'latitude': emergencyData['latitude'],
      'longitude': emergencyData['longitude'],
    };
    
    // Enhanced debugging for location data
    debugPrint('=== EMERGENCY SERVICE DEBUG ===');
    debugPrint('Original emergencyData: ${json.encode(emergencyData)}');
    debugPrint('Transformed sosData: ${json.encode(sosData)}');
    debugPrint('Latitude being sent: ${sosData['latitude']} (type: ${sosData['latitude'].runtimeType})');
    debugPrint('Longitude being sent: ${sosData['longitude']} (type: ${sosData['longitude'].runtimeType})');
    debugPrint('Victim ID being sent: ${sosData['victim_id']}');
    debugPrint('============================');
    
    return BaseApiService.post('/api/sos/create', sosData);
  }
  
  /// Retrieves active emergency alerts for community map
  /// GET /api/sos/active
  static Future<Map<String, dynamic>> getActiveAlerts({double? lat, double? lng}) async {
    String endpoint = '/api/sos/active';
    if (lat != null && lng != null) {
      endpoint += '?lat=$lat&lng=$lng';
    }
    return BaseApiService.get(endpoint);
  }
  
  /// Get nearby emergencies (alias for getActiveAlerts with location)
  static Future<Map<String, dynamic>> getNearbyEmergencies(double latitude, double longitude) async {
    return getActiveAlerts(lat: latitude, lng: longitude);
  }
  
  /// Update emergency status (if supported by backend)
  static Future<Map<String, dynamic>> updateEmergencyStatus(String emergencyId, String status) async {
    return BaseApiService.post('/api/sos/$emergencyId/status', {'status': status});
  }
  
  /// Respond to emergency (for volunteers)
  static Future<Map<String, dynamic>> respondToEmergency(String emergencyId, Map<String, dynamic> responseData) async {
    return BaseApiService.post('/api/sos/$emergencyId/respond', responseData);
  }
  
  /// Cancel emergency alert
  static Future<Map<String, dynamic>> cancelEmergency(String emergencyId) async {
    return BaseApiService.post('/api/sos/$emergencyId/cancel', {});
  }
  
  /// Report updated location for emergency
  static Future<Map<String, dynamic>> reportEmergencyLocation(String emergencyId, double latitude, double longitude) async {
    return BaseApiService.post('/api/sos/$emergencyId/location', {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Get emergency details
  static Future<Map<String, dynamic>> getEmergencyDetails(String emergencyId) async {
    return BaseApiService.get('/api/sos/$emergencyId');
  }
  
  /// Maps frontend incident types to backend SOS types
  static String _mapIncidentTypeToSosType(String incidentType) {
    switch (incidentType) {
      case 'Medical Emergency':
        return 'medical';
      case 'Fire':
        return 'fire';
      case 'Violence/Assault':
        return 'crime';
      case 'Traffic Accident':
        return 'accident';
      case 'Natural Disaster':
        return 'accident'; // Map to accident for now
      case 'Structural Collapse':
        return 'accident'; // Map to accident for now
      case 'Chemical Spill':
        return 'accident'; // Map to accident for now
      case 'Other Emergency':
        return 'medical'; // Default to medical
      default:
        return 'medical';
    }
  }
}
