import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task2_namaztime/Views/HomeScreen.dart';
import 'package:task2_namaztime/Views/SignIn.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  var isLoginLoading = false.obs;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;
  var isObscurePassword = true.obs;
  var isObscureConfirmPassword = true.obs;
  var rememberMe = false.obs;
  var agreeTerms = false.obs;

  void onInit() {
    super.onInit();
    // _googleSignIn.initialize();
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.trim().isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    if (!agreeTerms.value) {
      Get.snackbar("Error", "You must agree to the Terms and Conditions");
      return;
    }

    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      Get.snackbar("Success", "Account created successfully!");

      Get.offAll(() => SignInScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "An error occurred");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar("Error", "Please fill out all fields");
      return;
    }

    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      Get.snackbar("Success", "Logged in successfully!");

      Get.offAll(() => const HomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Authentication failed");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoginLoading.value = true;

      // 1. FORCE ACCOUNT SELECTION POPUP:
      // This clears the cached Google account from memory, forcing the email picker list to appear every time.
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      } else {
        // Safety step: clear any partial Google session tokens
        await _googleSignIn.signOut();
      }

      // 2. Trigger the fresh native Google Sign-In prompt window overlay
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user aborts or cancels the pop-up, return early safely
      if (googleUser == null) {
        isLoginLoading.value = false;
        return;
      }

      // 3. Fetch authentication tokens from the newly selected Google account
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 4. Formulate a brand new credential token pack for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Authenticate into Firebase with the Google generated token credential
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        // Success! Route them completely onto your Dashboard Screen
        Get.offAll(() => const HomeScreen());
      }
    } catch (e) {
      Get.snackbar(
        "Authentication Error",
        "Google Sign-In failed: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } finally {
      isLoginLoading.value = false;
    }
  }
}
