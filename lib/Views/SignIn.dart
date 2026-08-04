import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task2_namaztime/Controller/FireBaseAuthController.dart';
import 'package:task2_namaztime/Views/SignUp.dart';
import 'package:task2_namaztime/Widget/FormValidator.dart';
import 'package:task2_namaztime/Widget/TextWidget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController auth = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign in to continue your spiritual journey and stay connected.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    'Assets/mas.jpeg',
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 50),
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
                  key: _signInFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthWidgets.buildTextField(
                        controller: _emailController,
                        hint: "Email Address",
                        prefixIcon: Icons.email_outlined,
                        validator: FormValidators.validateEmail,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            // Add Forgot Password Logic Here
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5A42EC),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Regular Email Sign In Button
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
                                    // 1. Manually run validations before submitting
                                    final emailError =
                                        FormValidators.validateEmail(
                                          _emailController.text,
                                        );
                                    final passwordError =
                                        FormValidators.validatePassword(
                                          _passwordController.text,
                                        );

                                    if (emailError != null) {
                                      FormValidators.showWarningDialog(
                                        emailError,
                                      );
                                      return;
                                    }

                                    if (passwordError != null) {
                                      FormValidators.showWarningDialog(
                                        passwordError,
                                      );
                                      return;
                                    }

                                    // 2. If both are valid, proceed to login safely
                                    auth.signIn(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                    );
                                  },

                            child: auth.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.login_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Sign In",
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

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Obx(
                          () => OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E293B),
                              elevation: 0,
                            ),
                            // Disables interaction while fetching details to protect runtime data states
                            onPressed: auth.isLoginLoading.value
                                ? null
                                : () {
                                    auth.signInWithGoogle();
                                  },
                            child: auth.isLoginLoading.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF5A42EC),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'Assets/Google.jpeg',
                                        height: 22,
                                        width: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Continue with Google",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => SignUpScreen()),
                    child: const Text(
                      "SignUp",
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
