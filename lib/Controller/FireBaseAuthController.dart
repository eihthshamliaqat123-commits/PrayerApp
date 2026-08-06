import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Added Firestore Import
import 'package:task2_namaztime/Views/HomeScreen.dart';
import 'package:task2_namaztime/Views/SignIn.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  var firebaseUser = Rxn<User>();
  // 3. This observable map holds the profile data that your new profile screen will display
  var userData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();

    firebaseUser.bindStream(_auth.authStateChanges());

    ever(firebaseUser, (User? user) {
      if (user != null) {
        _fetchUserProfile(user.uid);
      } else {
        userData.clear();
      }
    });
  }

  // 5. Real-time stream to listen to user profile data changes
  void _fetchUserProfile(String uid) {
    _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        userData.value = snapshot.data()!;
      }
    });
  }

  // 6. Sign Out Method to link up with your new Profile Screen button
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      Get.offAll(() => SignInScreen());
    } catch (e) {
      Get.snackbar("Logout Error", e.toString());
    }
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

      // 7. Write Data to Firestore on Email Registration
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'fullName': fullName.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

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
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      } else {
        await _googleSignIn.signOut();
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoginLoading.value = false;
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // 8. Handle Firestore saving/merging for Google Users
      if (userCredential.user != null) {
        DocumentReference userDoc = _firestore
            .collection('users')
            .doc(userCredential.user!.uid);
        DocumentSnapshot docSnapshot = await userDoc.get();

        // Only create a database file if they are a completely new user
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': userCredential.user!.uid,
            'fullName': userCredential.user!.displayName ?? "Google User",
            'email': userCredential.user!.email ?? "",
            'phone': userCredential.user!.phoneNumber ?? "Not Provided",
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

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
