import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:vanguard/services/auth_service.dart';
import 'package:vanguard/services/base_api_service.dart';

class AuthController extends GetxController {
  // Form states
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString userType = 'victim'.obs; // Default to victim
  
  // UI states
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoginMode = true.obs; // Toggle between login/signup
  
  // User data
  final Rx<Map<String, dynamic>?> currentUser = Rx<Map<String, dynamic>?>(null);
  
  // Form validation
  final RxString nameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  
  // Session management
  Timer? _sessionTimer;
  
  @override
  void onInit() {
    super.onInit();
    _checkExistingAuth();
    _startSessionTimer();
  }
  
  @override
  void onClose() {
    _sessionTimer?.cancel();
    super.onClose();
  }
  
  // Check if user is already authenticated
  Future<void> _checkExistingAuth() async {
    debugPrint('=== CHECKING EXISTING AUTH ===');
    
    try {
      final token = await BaseApiService.getToken();
      debugPrint('Token exists: ${token != null}');
      
      if (token != null) {
        // Check if token is expired
        final isExpired = await BaseApiService.isTokenExpired();
        debugPrint('Token expired: $isExpired');
        
        if (isExpired) {
          debugPrint('Token expired, removing and redirecting to auth');
          await BaseApiService.removeToken();
          return;
        }
        
        // Try to get current user from API first
        try {
          debugPrint('Fetching current user from API...');
          final response = await AuthService.getCurrentUser();
          
          if (response['success'] == true && response['data']['user'] != null) {
            currentUser.value = response['data']['user'];
            debugPrint('User authenticated successfully: ${currentUser.value}');
            
            // Start session timer
            _startSessionTimer();
            
            // Navigate to home screen
            Get.offAllNamed('/home');
          } else {
            debugPrint('API response invalid, trying stored user data');
            await _tryStoredUserData();
          }
        } catch (e) {
          debugPrint('API call failed, trying stored user data: $e');
          await _tryStoredUserData();
        }
      } else {
        debugPrint('No token found, user needs to login');
      }
    } catch (e) {
      debugPrint('Auth check failed completely: $e');
      await BaseApiService.removeToken();
    }
    
    debugPrint('=== AUTH CHECK COMPLETE ===');
  }
  
  // Try to use stored user data as fallback
  Future<void> _tryStoredUserData() async {
    try {
      final storedUser = await BaseApiService.getStoredUser();
      if (storedUser != null) {
        currentUser.value = storedUser;
        debugPrint('Using stored user data: ${currentUser.value}');
        
        // Show snackbar to indicate offline mode
        Get.snackbar(
          'Offline Mode',
          'Using cached data. Some features may be limited.',
          backgroundColor: const Color(0xFF2196F3),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        
        // Navigate to home screen
        Get.offAllNamed('/home');
        
        // Start session timer
        _startSessionTimer();
      } else {
        debugPrint('No stored user data found');
        await BaseApiService.removeToken();
      }
    } catch (e) {
      debugPrint('Failed to use stored user data: $e');
      await BaseApiService.removeToken();
    }
  }
  
  // Toggle between login and signup
  void toggleAuthMode() {
    debugPrint('=== TOGGLE AUTH MODE ===');
    debugPrint('Previous mode: ${isLoginMode.value ? 'Login' : 'Signup'}');
    debugPrint('New mode: ${!isLoginMode.value ? 'Login' : 'Signup'}');
    
    isLoginMode.value = !isLoginMode.value;
    
    debugPrint('Clearing form and errors');
    _clearForm();
    _clearErrors();
    
    debugPrint('Form cleared - Name: "${name.value}", Email: "${email.value}", User Type: "${userType.value}"');
  }
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  // Validate name
  bool validateName() {
    if (name.value.isEmpty) {
      nameError.value = 'Name is required';
      return false;
    }
    if (name.value.length < 2 || name.value.length > 100) {
      nameError.value = 'Name must be between 2-100 characters';
      return false;
    }
    nameError.value = '';
    return true;
  }
  
  // Validate email
  bool validateEmail() {
    if (email.value.isEmpty) {
      emailError.value = 'Email is required';
      return false;
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.value)) {
      emailError.value = 'Please enter a valid email';
      return false;
    }
    
    emailError.value = '';
    return true;
  }
  
  // Validate password
  bool validatePassword() {
    if (password.value.isEmpty) {
      passwordError.value = 'Password is required';
      return false;
    }
    
    if (password.value.length < 6 || password.value.length > 100) {
      passwordError.value = 'Password must be between 6-100 characters';
      return false;
    }
    
    passwordError.value = '';
    return true;
  }
  
  // Validate all fields
  bool validateForm() {
    bool isValid = true;
    
    if (!isLoginMode.value) {
      isValid = validateName() && isValid;
    }
    
    isValid = validateEmail() && isValid;
    isValid = validatePassword() && isValid;
    
    return isValid;
  }
  
  // Clear form
  void _clearForm() {
    debugPrint('=== CLEARING FORM ===');
    debugPrint('Before - Name: "${name.value}", Email: "${email.value}", Password length: ${password.value.length}, User Type: "${userType.value}"');
    
    name.value = '';
    email.value = '';
    password.value = '';
    userType.value = 'victim';
    isPasswordVisible.value = false;
    
    debugPrint('After - Name: "${name.value}", Email: "${email.value}", Password length: ${password.value.length}, User Type: "${userType.value}"');
  }
  
  // Clear errors
  void _clearErrors() {
    nameError.value = '';
    emailError.value = '';
    passwordError.value = '';
  }
  
  // Handle authentication
  Future<void> authenticate() async {
    debugPrint('=== AUTHENTICATION START ===');
    debugPrint('Mode: ${isLoginMode.value ? 'Login' : 'Signup'}');
    debugPrint('Email: "${email.value}"');
    debugPrint('Password length: ${password.value.length}');
    debugPrint('Name: "${name.value}"');
    debugPrint('User Type: "${userType.value}"');
    
    if (!validateForm()) {
      debugPrint('Form validation failed');
      debugPrint('Name error: "${nameError.value}"');
      debugPrint('Email error: "${emailError.value}"');
      debugPrint('Password error: "${passwordError.value}"');
      HapticFeedback.lightImpact();
      return;
    }
    
    debugPrint('Form validation passed');
    isLoading.value = true;
    HapticFeedback.mediumImpact();
    
    try {
      Map<String, dynamic> response;
      
      debugPrint('Making API call...');
      
      if (isLoginMode.value) {
        debugPrint('Calling signin API');
        response = await AuthService.signin(email.value, password.value);
      } else {
        debugPrint('Calling signup API with role: "${userType.value}"');
        response = await AuthService.signup(
          name.value,
          email.value,
          password.value,
          userType.value,
        );
      }
      
      debugPrint('API Response received:');
      debugPrint('Success: ${response['success']}');
      debugPrint('Message: "${response['message']}"');
      debugPrint('Data keys: ${response['data']?.keys?.toList()}');
      
      if (response['success'] == true) {
        debugPrint('Authentication successful');
        currentUser.value = response['data']['user'];
        debugPrint('User data stored: ${currentUser.value}');
        
        Get.snackbar(
          'Success',
          isLoginMode.value ? 'Welcome back!' : 'Account created successfully!',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        // Clear fields on success
        debugPrint('Clearing fields on success');
        _clearForm();
        _clearErrors();
        
        // Navigate to home screen
        debugPrint('Navigating to home screen');
        Get.offAllNamed('/home');
      } else {
        debugPrint('Authentication failed with server response');
        throw Exception(response['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      debugPrint('=== AUTHENTICATION ERROR ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: "$e"');
      debugPrint('Stack trace: ${StackTrace.current}');
      
      Get.snackbar(
        'Authentication Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
      // Clear fields on error
      debugPrint('Clearing fields on error');
      _clearForm();
      _clearErrors();
    } finally {
      debugPrint('=== AUTHENTICATION END ===');
      isLoading.value = false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    debugPrint('=== LOGGING OUT ===');
    
    // Stop session timer
    _stopSessionTimer();
    
    await BaseApiService.removeToken();
    currentUser.value = null;
    _clearForm();
    _clearErrors();
    
    Get.snackbar(
      'Logged Out',
      'You have been logged out successfully',
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
    
    Get.offAllNamed('/auth');
    
    debugPrint('=== LOGOUT COMPLETE ===');
  }
  
  // Start session timer for periodic checks
  void _startSessionTimer() {
    _sessionTimer?.cancel(); // Cancel existing timer
    
    // Check session every 5 minutes
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      debugPrint('=== PERIODIC SESSION CHECK ===');
      checkSessionValidity();
    });
    
    debugPrint('Session timer started (checks every 5 minutes)');
  }
  
  // Stop session timer
  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    debugPrint('Session timer stopped');
  }
  
  // Check session validity (can be called periodically)
  Future<void> checkSessionValidity() async {
    try {
      final token = await BaseApiService.getToken();
      if (token == null) {
        debugPrint('No token found during session check');
        await logout();
        return;
      }
      
      final isExpired = await BaseApiService.isTokenExpired();
      if (isExpired) {
        debugPrint('Token expired during session check');
        _stopSessionTimer();
        
        Get.snackbar(
          'Session Expired',
          'Your session has expired. Please login again.',
          backgroundColor: const Color(0xFFD32F2F),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        await logout();
      }
    } catch (e) {
      debugPrint('Session check failed: $e');
    }
  }
  
  // Set user type
  void setUserType(String type) {
    debugPrint('=== SET USER TYPE ===');
    debugPrint('Previous type: "${userType.value}"');
    debugPrint('New type: "$type"');
    
    userType.value = type;
    
    debugPrint('User type updated to: "${userType.value}"');
  }
}
