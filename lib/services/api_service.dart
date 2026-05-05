import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000'; // Update with your backend URL
  static const String _tokenKey = 'auth_token';
  
  // Get stored JWT token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Store JWT token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  // Remove JWT token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
  
  // Get headers with authorization
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Generic POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      
      debugPrint('API Response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // Generic GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      
      debugPrint('API Response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // Auth endpoints
  static Future<Map<String, dynamic>> signup(String name, String email, String password, String type) async {
    return post('/api/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
      'type': type,
    });
  }
  
  static Future<Map<String, dynamic>> signin(String email, String password) async {
    final response = await post('/api/auth/signin', {
      'email': email,
      'password': password,
    });
    
    // Store token on successful login
    if (response['success'] == true && response['data']['token'] != null) {
      await storeToken(response['data']['token']);
    }
    
    return response;
  }
  
  static Future<Map<String, dynamic>> refreshToken(String token) async {
    return post('/api/auth/refresh', {'token': token});
  }
  
  static Future<Map<String, dynamic>> getCurrentUser() async {
    return get('/api/auth/me');
  }
}
