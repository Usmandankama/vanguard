import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:vanguard/services/api_service.dart';

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
  
  @override
  void onInit() {
    super.onInit();
    _checkExistingAuth();
  }
  
  // Check if user is already authenticated
  Future<void> _checkExistingAuth() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.getCurrentUser();
        if (response['success'] == true) {
          currentUser.value = response['data']['user'];
          // Navigate to home screen
          Get.offAllNamed('/home');
        }
      }
    } catch (e) {
      debugPrint('Auth check failed: $e');
      // Token might be expired, remove it
      await ApiService.removeToken();
    }
  }
  
  // Toggle between login and signup
  void toggleAuthMode() {
    isLoginMode.value = !isLoginMode.value;
    _clearForm();
    _clearErrors();
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
    name.value = '';
    email.value = '';
    password.value = '';
    userType.value = 'victim';
    isPasswordVisible.value = false;
  }
  
  // Clear errors
  void _clearErrors() {
    nameError.value = '';
    emailError.value = '';
    passwordError.value = '';
  }
  
  // Handle authentication
  Future<void> authenticate() async {
    if (!validateForm()) {
      HapticFeedback.lightImpact();
      return;
    }
    
    isLoading.value = true;
    HapticFeedback.mediumImpact();
    
    try {
      Map<String, dynamic> response;
      
      if (isLoginMode.value) {
        response = await ApiService.signin(email.value, password.value);
      } else {
        response = await ApiService.signup(
          name.value,
          email.value,
          password.value,
          userType.value,
        );
      }
      
      if (response['success'] == true) {
        currentUser.value = response['data']['user'];
        
        Get.snackbar(
          'Success',
          isLoginMode.value ? 'Welcome back!' : 'Account created successfully!',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        // Navigate to home screen
        Get.offAllNamed('/home');
      } else {
        throw Exception(response['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      debugPrint('Auth error: $e');
      Get.snackbar(
        'Authentication Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await ApiService.removeToken();
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
  }
  
  // Set user type
  void setUserType(String type) {
    userType.value = type;
  }
}
