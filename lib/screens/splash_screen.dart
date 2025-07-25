
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quran_yt/screens/main_screen.dart';
import 'package:flutter_quran_yt/screens/onboarding_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
// TODO: implement createState
}

class _SplashScreenState  extends State<SplashScreen> {
  bool alreadyUsed = false;
  void getDate()async{
    final prefs = await SharedPreferences.getInstance();
    alreadyUsed = prefs.getBool("alreadyUsed") ?? false;
  }
  @override
  void initState(){
    super.initState();
    getDate();
    Timer(Duration(seconds: 3),() {
      Get.offNamed("/login");
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(child: Text('Muslim Soul',style: TextStyle(color: Colors.black,fontSize: 30),),),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset('assets/islamic.png'),),
          ],
        ),
      ),
    );
  }

}