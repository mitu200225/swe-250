import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quran_yt/constants/constants.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common.dart';


class RegisterController extends GetxController {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  var name = '';
  var email = '';
  var password = '';

  var isImgAvailable = false.obs;
  final _picker = ImagePicker();
  var selectedImagePath = ''.obs;
  var selectedImageSize = ''.obs;
  var isLoading = false.obs;

  CollectionReference userDatBaseReference = FirebaseFirestore.instance.collection("user");
  final FirebaseStorage _storage = FirebaseStorage.instance;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void getImage(ImageSource imageSource) async {
    final pickedFile = await _picker.pickImage(source: imageSource);

    if (pickedFile != null) {
      selectedImagePath.value = pickedFile.path;
      selectedImageSize.value = "${((File(selectedImagePath.value)).lengthSync() / 1024 / 1024).toStringAsFixed(2)} Mb";
      isImgAvailable.value = true;
    } else {
      isImgAvailable.value = false;
      snackMessage("No image selected");
    }
  }

  String? validName(String value) {
    if (value.length < 3) {
      return "Name must be 3 characters";
    }
    return null;
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

  Future<void> registration() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    isLoading.value = true;

    formKey.currentState!.save();

    userRegister(email.trim(), password.toString().trim()).then((credentials) {
      if (credentials != null) {

      } else {
        snackMessage("User already exist");
      }
      isLoading.value = false;
    });
  }

  Future<UserCredential?> userRegister(String email, String password) async {
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password).then((value) async {
        if (value != null) {
          User? user = FirebaseAuth.instance.currentUser;
          await user!.sendEmailVerification();
          snackMessage('Check your Email');
          saveDataToDb().then((value) async {
            await FirebaseAuth.instance.currentUser!.sendEmailVerification();
            Get.offAllNamed('/login');
          });
          return;
        }
      });
    } on FirebaseAuthException catch (e) {
      snackMessage('user already exist');
    }

    return userCredential;
  }

  Future<String?> uploadFile(filePath) async {
    File file = File(filePath);
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String randomStr = String.fromCharCodes(Iterable.generate(
        8, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    try {
      await _storage.ref('uploads/user/$randomStr').putFile(file);
    } on FirebaseException catch (e) {
      snackMessage(e.code.toString());
    }
    String downloadURL =
    await _storage.ref('uploads/user/$randomStr').getDownloadURL();

    return downloadURL;
  }

  Future<void> saveDataToDb() async {
    User? user = FirebaseAuth.instance.currentUser;
    await userDatBaseReference.doc(user!.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'url': '',
    });
    return;
  }

  void updateProfile(String argUrl) {
    User? user = FirebaseAuth.instance.currentUser;

    if (isImgAvailable == true) {
      uploadFile(selectedImagePath.value).then((url) {
        if (url != null) {
          userDatBaseReference.doc(user!.uid).update({
            'uid': user.uid,
            // Object-Orientation Abuser -> Data Class/No Encapsulation
            'name': nameController.text,
            'email': emailController.text,
            'url': url
          });
        } else {
          snackMessage("Image not Uploaded");
        }
      });
    } else {
      userDatBaseReference.doc(user!.uid).update({
        'uid': user.uid,
        'name': nameController.text,
        'email': emailController.text,
        'url': argUrl == "" ? '' : argUrl,
      });

      user.updateEmail(emailController.text.toString().trim()).then((value) {
        snackMessage("Updated Successfully");
      }).catchError((error) {
        snackMessage("Email not Updated");
        print(error);
      });
    }
  }
}

// After solving code smell

/*
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../common/common.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isImgAvailable = false.obs;
  final selectedImagePath = ''.obs;
  final selectedImageSize = ''.obs;

  final _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _userDb = FirebaseFirestore.instance.collection("user");

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Validation
  String? validateName(String value) =>
      value.length < 3 ? "Name must be at least 3 characters" : null;

  String? validateEmail(String value) =>
      !GetUtils.isEmail(value.trim()) ? "Please provide a valid email" : null;

  String? validatePassword(String value) =>
      value.length < 8 ? "Password must be at least 8 characters" : null;

  // Image Handling
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      selectedImagePath.value = pickedFile.path;
      selectedImageSize.value =
          "${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} Mb";
      isImgAvailable.value = true;
    } else {
      isImgAvailable.value = false;
      snackMessage("No image selected");
    }
  }

  // Registration
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    formKey.currentState!.save();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await userCred.user!.sendEmailVerification();
      snackMessage('Check your Email');
      await _saveUserData(userCred.user!.uid);
      Get.offAllNamed('/login');
    } on FirebaseAuthException catch (_) {
      snackMessage("User already exists");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveUserData(String uid) async {
    await _userDb.doc(uid).set({
      'uid': uid,
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'url': '',
    });
  }

  // Uploading
  Future<String?> uploadImage(String filePath) async {
    final file = File(filePath);
    final randomStr = _generateRandomString(8);
    final refPath = 'uploads/user/$randomStr';

    try {
      await _storage.ref(refPath).putFile(file);
      return await _storage.ref(refPath).getDownloadURL();
    } on FirebaseException catch (e) {
      snackMessage(e.message ?? "Upload failed");
      return null;
    }
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rand.nextInt(chars.length))));
  }

  // Update
  Future<void> updateProfile({required String fallbackUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    String imageUrl = fallbackUrl;

    if (isImgAvailable.value) {
      final uploadedUrl = await uploadImage(selectedImagePath.value);
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      } else {
        snackMessage("Image not uploaded");
        return;
      }
    }

    await _userDb.doc(user.uid).update({
      'uid': user.uid,
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'url': imageUrl,
    });

    try {
      await user.updateEmail(emailController.text.trim());
      snackMessage("Updated Successfully");
    } catch (_) {
      snackMessage("Email not updated");
    }
  }
}

 */