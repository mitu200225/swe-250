
import 'package:flutter/material.dart';
import 'package:flutter_quran_yt/constants/constants.dart';
import 'package:flutter_quran_yt/controllers/loginController.dart';
import 'package:flutter_quran_yt/controllers/registrationController.dart';
import 'package:flutter_quran_yt/widgets/decoration_widget.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final LoginController _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: height * 0.3,
                    decoration: const BoxDecoration(
                      color: Constants.kPrimary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(70),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 40,
                    right: 30,
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 38, left: 8, right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Form(
                      key: _loginController.formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: TextFormField(
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              // The validator receives the text that the user has entered.
                              controller:
                              _loginController.emailController,
                              onSaved: (value) {
                                _loginController.email = value!;
                              },
                              validator: (value) {
                                return _loginController.validEmail(value!);
                              },
                              // Bloater -> Long Parameter List
                              decoration: DecorationWidget(context, "Enter Email", Icons.email),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: TextFormField(
                              obscureText: true,
                              controller:
                              _loginController.passwordController,
                              onSaved: (value) {
                                _loginController.password = value!;
                              },
                              validator: (value) {
                                return _loginController
                                    .validPassword(value!);
                              },
                              decoration: DecorationWidget(context, "Enter Password", Icons.vpn_key),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            height: 40,
                            child: TextButton(
                              // Dispensable -> Dead Code
                              onPressed: () {
                                //Get.toNamed('/forgetPassword');
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Constants.kPrimary,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Constants.kPrimary, elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 10),
                                  textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'CormorantGaramond'),
                                ),
                                child: FittedBox(
                                  child: Obx(
                                        () => _loginController
                                        .isLoading.value
                                        ? const Center(
                                      child: CircularProgressIndicator(color: Colors.white,),
                                    )
                                        : const Text(
                                      'Login',
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  _loginController.login();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text('Don\'t have an account ? '),
                  TextButton(
                    onPressed: () {
                      Get.offNamed('/register');
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Constants.kPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// After solving code smell

/*
import 'package:flutter/material.dart';
import 'package:flutter_quran_yt/constants/constants.dart';
import 'package:flutter_quran_yt/controllers/loginController.dart';
import 'package:get/get.dart';
import 'package:flutter_quran_yt/utils/input_decorations.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final LoginController _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: height * 0.3,
                    decoration: const BoxDecoration(
                      color: Constants.kPrimary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(70),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 40,
                    right: 30,
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(top: 38, left: 8, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Form(
                      key: _loginController.formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: TextFormField(
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              controller: _loginController.emailController,
                              onSaved: (value) => _loginController.email = value!,
                              validator: (value) => _loginController.validEmail(value!),
                              decoration: customInputDecoration("Enter Email", Icons.email),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: TextFormField(
                              obscureText: true,
                              controller: _loginController.passwordController,
                              onSaved: (value) => _loginController.password = value!,
                              validator: (value) => _loginController.validPassword(value!),
                              decoration: customInputDecoration("Enter Password", Icons.vpn_key),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Forgot Password Button
                          Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            height: 40,
                            child: TextButton(
                              onPressed: () {
                                Get.toNamed('/forgetPassword'); // enabled
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Constants.kPrimary,
                                ),
                              ),
                            ),
                          ),

                          // Login Button
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Constants.kPrimary,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'CormorantGaramond',
                                  ),
                                ),
                                onPressed: () {
                                  _loginController.login();
                                },
                                child: FittedBox(
                                  child: Obx(() {
                                    return _loginController.isLoading.value
                                        ? const Center(
                                            child: CircularProgressIndicator(color: Colors.white),
                                          )
                                        : const Text('Login');
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Register redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? '),
                  TextButton(
                    onPressed: () {
                      Get.offNamed('/register');
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Constants.kPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 */