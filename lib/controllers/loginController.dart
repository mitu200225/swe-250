
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../common/common.dart';
import '../screens/main_screen.dart';

class LoginController extends GetxController{

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  // Dispensable -> Duplicate Code/ Dead Code
  var isLoading = false.obs;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validEmail(String value) {
    if (!GetUtils.isEmail(value.trim())) {
      return "Please Provide Valid Email";
    }
    return null;
  }

  String? validPassword(String value) {
    if (value.length < 8) {
      return "Password must be of 8 characters";
    }
    return null;
  }

  Future<void> login() async {
    print("Login button pressed!");
    // Bloaters -> Long Method
    if (!formKey.currentState!.validate()) {
      print("Form validation failed!");
      return;
    }

    formKey.currentState!.save();
    isLoading.value = true;
    print("Logging in...");

    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      // Object Orientation Abuser -> Feature Envy
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("Login successful: ${userCredential.user?.email}");
      Get.offAll(() => MainScreen());
    } on FirebaseAuthException catch (e) {
      print(" FirebaseAuthException: ${e.code} - ${e.message}");
      // Change Prevent -> Divergent Change(Tightly Coupled)
      Get.snackbar("Error", "${e.code}: ${e.message}",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print("Unexpected Error: $e");
      Get.snackbar("Error", "An unexpected error occurred.",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}

//After solving code smell

/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../screens/main_screen.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String value) {
    if (!GetUtils.isEmail(value.trim())) {
      return "Please provide a valid email";
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final result = await _authService.login(email, password);

    result.fold(
      (error) => Get.snackbar("Error", error, snackPosition: SnackPosition.BOTTOM),
      (_) => Get.offAll(() => MainScreen()),
    );

    isLoading.value = false;
  }
}

 */