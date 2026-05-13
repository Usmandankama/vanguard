import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiLogger {
  static void logRequest(String method, String endpoint, Map<String, dynamic>? data) {
    debugPrint('=== API REQUEST ===');
    debugPrint('Method: $method');
    debugPrint('Endpoint: $endpoint');
    if (data != null) {
      debugPrint('Request Data: ${json.encode(data)}');
    }
    debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
    debugPrint('====================');
  }

  static void logResponse(int statusCode, String responseBody, {String? error}) {
    debugPrint('=== API RESPONSE ===');
    debugPrint('Status Code: $statusCode');
    debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
    
    if (error != null) {
      debugPrint('Error: $error');
    } else {
      debugPrint('Response Body: $responseBody');
      
      try {
        final decodedResponse = json.decode(responseBody);
        debugPrint('Parsed Response: $decodedResponse');
      } catch (e) {
        debugPrint('Failed to parse JSON response: $e');
      }
    }
    
    debugPrint('====================');
  }

  static void logError(String operation, dynamic error) {
    debugPrint('=== API ERROR ===');
    debugPrint('Operation: $operation');
    debugPrint('Error: $error');
    debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
    debugPrint('Stack Trace: ${StackTrace.current}');
    debugPrint('====================');
  }
}

class BaseApiService {
  static const String baseUrl = 'http://192.168.137.2:3000'; 
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';
  
  // Get stored JWT token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Get token expiry time
  static Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }
  
  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }
  
  // Store JWT token with expiry
  static Future<void> storeToken(String token, {Duration? expiry}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    
    // Set expiry time (default 24 hours if not specified)
    final expiryTime = DateTime.now().add(expiry ?? const Duration(hours: 24));
    await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
    
    ApiLogger.logResponse(200, 'Token stored successfully');
  }
  
  // Remove JWT token and related data
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_tokenExpiryKey);
    
    ApiLogger.logResponse(200, 'Token and user data removed');
  }
  
  // Get stored user data
  static Future<Map<String, dynamic>?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);
      if (userString != null) {
        return json.decode(userString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      ApiLogger.logError('Get stored user', e);
      return null;
    }
  }
  
  // Store user data
  static Future<void> storeUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(userData));
      ApiLogger.logResponse(200, 'User data stored successfully');
    } catch (e) {
      ApiLogger.logError('Store user data', e);
    }
  }
  
  // Get headers with authorization
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null && !(await isTokenExpired())) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Generic POST request with token validation
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      // Check if token is expired before making request
      if (await isTokenExpired() && endpoint != '/api/auth/signin' && endpoint != '/api/auth/signup') {
        await removeToken();
        throw Exception('Session expired. Please login again.');
      }
      
      ApiLogger.logRequest('POST', endpoint, data);
      
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      
      ApiLogger.logResponse(response.statusCode, response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await removeToken();
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      ApiLogger.logError('POST $endpoint', e);
      throw Exception('Network error: $e');
    }
  }
  
  // Generic GET request with token validation
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      // Check if token is expired before making request
      if (await isTokenExpired()) {
        await removeToken();
        throw Exception('Session expired. Please login again.');
      }
      
      ApiLogger.logRequest('GET', endpoint, null);
      
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      
      ApiLogger.logResponse(response.statusCode, response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await removeToken();
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      ApiLogger.logError('GET $endpoint', e);
      throw Exception('Network error: $e');
    }
  }
}
