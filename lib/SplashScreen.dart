import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:task2_namaztime/Views/SignIn.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Get.to(SignInScreen());
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) =>  SignInScreen()),
      //);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('Assets/logo.jpeg', width: 400, height: 500),
      ),
    );
  }
}
