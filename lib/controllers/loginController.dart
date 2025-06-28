
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

    if (!formKey.currentState!.validate()) {
      print("Form validation failed!");
      return;
    }

    formKey.currentState!.save();
    isLoading.value = true;
    print("Logging in...");

    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("Login successful: ${userCredential.user?.email}");
      Get.offAll(() => MainScreen());
    } on FirebaseAuthException catch (e) {
      print(" FirebaseAuthException: ${e.code} - ${e.message}");
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