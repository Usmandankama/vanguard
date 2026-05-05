import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vanguard/controllers/auth_controller.dart';
import 'package:vanguard/core/themes/app_theme.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              
              // Logo/Title
              _buildHeader(context),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              
              // Auth Form
              _buildAuthForm(context),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              
              // Submit Button
              _buildSubmitButton(context),
              
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              
              // Toggle Auth Mode
              _buildToggleAuthMode(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.emergency_rounded,
          size: MediaQuery.of(context).size.width * 0.2,
          color: AppTheme.sosCrimson,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Text(
          'VanguardNet',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.08,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Text(
          'Decentralized Emergency Response',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.04,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForm(BuildContext context) {
    return Form(
      child: Column(
        children: [
          // Name field (only for signup)
          Obx(() => !controller.isLoginMode.value
              ? _buildNameField(context)
              : const SizedBox.shrink()),
          
          // Email field
          _buildEmailField(context),
          
          // Password field
          _buildPasswordField(context),
          
          // User type selection (only for signup)
          Obx(() => !controller.isLoginMode.value
              ? _buildUserTypeSelection(context)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        TextFormField(
          onChanged: (value) => controller.name.value = value,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.sosCrimson),
            ),
            errorText: controller.nameError.value.isEmpty ? null : controller.nameError.value,
            errorStyle: TextStyle(color: AppTheme.warningAmber),
          ),
          style: TextStyle(color: Colors.white),
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        TextFormField(
          onChanged: (value) => controller.email.value = value,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.sosCrimson),
            ),
            errorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
            errorStyle: TextStyle(color: AppTheme.warningAmber),
          ),
          style: TextStyle(color: Colors.white),
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        TextFormField(
          onChanged: (value) => controller.password.value = value,
          obscureText: !controller.isPasswordVisible.value,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.sosCrimson),
            ),
            errorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
            errorStyle: TextStyle(color: AppTheme.warningAmber),
          ),
          style: TextStyle(color: Colors.white),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => controller.authenticate(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }

  Widget _buildUserTypeSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Row(
          children: [
            Expanded(
              child: Obx(() => GestureDetector(
                onTap: () => controller.setUserType('victim'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: controller.userType.value == 'victim' 
                        ? AppTheme.sosCrimson 
                        : Colors.transparent,
                    border: Border.all(
                      color: controller.userType.value == 'victim' 
                          ? AppTheme.sosCrimson 
                          : Colors.white24,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                      Text(
                        'Victim',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Expanded(
              child: Obx(() => GestureDetector(
                onTap: () => controller.setUserType('volunteer'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: controller.userType.value == 'volunteer' 
                        ? AppTheme.secureGreen 
                        : Colors.transparent,
                    border: Border.all(
                      color: controller.userType.value == 'volunteer' 
                          ? AppTheme.secureGreen 
                          : Colors.white24,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                      Text(
                        'Volunteer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : controller.authenticate,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.sosCrimson,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: controller.isLoading.value
          ? SizedBox(
              height: MediaQuery.of(context).size.width * 0.06,
              width: MediaQuery.of(context).size.width * 0.06,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              controller.isLoginMode.value ? 'Sign In' : 'Create Account',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
    ));
  }

  Widget _buildToggleAuthMode(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          controller.isLoginMode.value 
              ? 'Don\'t have an account?' 
              : 'Already have an account?',
          style: TextStyle(
            color: Colors.white70,
            fontSize: MediaQuery.of(context).size.width * 0.035,
          ),
        ),
        TextButton(
          onPressed: controller.toggleAuthMode,
          child: Text(
            controller.isLoginMode.value ? 'Sign Up' : 'Sign In',
            style: TextStyle(
              color: AppTheme.sosCrimson,
              fontSize: MediaQuery.of(context).size.width * 0.035,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
