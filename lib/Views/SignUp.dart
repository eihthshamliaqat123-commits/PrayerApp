import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task2_namaztime/Controller/FireBaseAuthController.dart';
import 'package:task2_namaztime/Views/SignIn.dart';
import 'package:task2_namaztime/Widget/FormValidator.dart';
import 'package:task2_namaztime/Widget/TextWidget.dart';
// import 'package:task2_namaztime/Utils/FormValidators.dart'; // 👈 Class import karein

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  // 1. Form Key Definition
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthController auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AuthWidgets.circularIconButton(
                    Icons.arrow_back_ios_new,
                    () => Get.back(),
                  ),
                  AuthWidgets.languageDropdown(),
                ],
              ),
              const SizedBox(height: 15),

              // Header Artwork & Titles
              const Icon(
                Icons.nightlight_round,
                color: Color(0xFFB8A2F8),
                size: 36,
              ),
              const SizedBox(height: 10),
              const Text(
                "Create Your Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1B4B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Join us and strengthen your connection\nwith your faith.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // White Card Form Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.04),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Form(
                  // 👈 2. Form Widget se wrap karein
                  key: _formKey, // 👈 Form Key assign karein
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      AuthWidgets.buildTextField(
                        controller: _fullNameController,
                        hint: "Full Name",
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Full Name is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Email Field with RegEx
                      AuthWidgets.buildTextField(
                        controller: _emailController,
                        hint: "Email Address",
                        prefixIcon: Icons.email_outlined,
                        validator: FormValidators.validateEmail,
                      ),
                      const SizedBox(height: 14),

                      AuthWidgets.buildTextField(
                        controller: _phoneController,
                        hint: "Mobile Number (e.g., 03001234567)",
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: FormValidators.validatePakistaniPhone,
                      ),
                      const SizedBox(height: 14),

                      Obx(
                        () => AuthWidgets.buildTextField(
                          controller: _passwordController,
                          hint: "Password",
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          obscureText: auth.isObscurePassword.value,
                          onToggleObscure: () =>
                              auth.isObscurePassword.toggle(),
                          validator: FormValidators.validatePassword,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          "Minimum 8 characters with letters and numbers",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Obx(
                        () => AuthWidgets.buildTextField(
                          controller: _confirmPasswordController,
                          hint: "Confirm Password",
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          obscureText: auth.isObscureConfirmPassword.value,
                          onToggleObscure: () =>
                              auth.isObscureConfirmPassword.toggle(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please confirm your password";
                            }
                            if (value != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Terms & Conditions Checkbox
                      Row(
                        children: [
                          Obx(
                            () => Checkbox(
                              value: auth.agreeTerms.value,
                              activeColor: const Color(0xFF5A42EC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) =>
                                  auth.agreeTerms.value = val ?? false,
                            ),
                          ),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                children: [
                                  TextSpan(text: "I agree to the "),
                                  TextSpan(
                                    text: "Terms of Service ",
                                    style: TextStyle(
                                      color: Color(0xFF5A42EC),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: "and "),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(
                                      color: Color(0xFF5A42EC),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Obx(
                          () => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5A42EC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: auth.isLoading.value
                                ? null
                                : () {
                                    // 👈 3. Validate Form before submitting
                                    if (_formKey.currentState!.validate()) {
                                      if (!auth.agreeTerms.value) {
                                        Get.snackbar(
                                          "Terms & Conditions",
                                          "Please agree to Terms and Privacy Policy",
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red
                                              .withOpacity(0.1),
                                          colorText: Colors.red,
                                        );
                                        return;
                                      }

                                      auth.signUp(
                                        fullName: _fullNameController.text,
                                        email: _emailController.text,
                                        phone: _phoneController.text,
                                        password: _passwordController.text,
                                        confirmPassword:
                                            _confirmPasswordController.text,
                                      );
                                    }
                                  },
                            child: auth.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_add_alt_1_outlined,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Create Account",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      AuthWidgets.buildDivider(),
                      const SizedBox(height: 16),

                      // Social Buttons
                      Row(
                        children: [
                          Expanded(
                            child: AuthWidgets.socialButton(
                              "Google",
                              Icons.g_mobiledata,
                              Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AuthWidgets.socialButton(
                              "Apple",
                              Icons.apple,
                              Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AuthWidgets.socialButton(
                              "Facebook",
                              Icons.facebook,
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              AuthWidgets.privacyMattersCard(),
              const SizedBox(height: 16),

              // Footer Redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => SignInScreen());
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5A42EC),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
