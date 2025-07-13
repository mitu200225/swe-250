
import 'package:flutter/material.dart';
import 'package:flutter_quran_yt/constants/constants.dart';
import 'package:flutter_quran_yt/screens/jus_screen.dart';
import 'package:flutter_quran_yt/screens/login_screen.dart';
import 'package:flutter_quran_yt/screens/main_screen.dart';
import 'package:flutter_quran_yt/screens/onboarding_screen.dart';
import 'package:flutter_quran_yt/screens/register_screen.dart';
import 'package:flutter_quran_yt/screens/splash_screen.dart';
import 'package:flutter_quran_yt/screens/surah_detail.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/constants.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio_background/just_audio_background.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.yourapp.audio',
    androidNotificationChannelName: 'Quran Playback',
    androidNotificationOngoing: true,
  );


  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslim Soul',
      theme: ThemeData(
          primarySwatch: Constants.kSwatchColor,
          primaryColor: Constants.kPrimary,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins'
      ),
      home: SplashScreen(),
      routes: {
        JuzScreen.id:(context)=>JuzScreen(),
        Surahdetail.id:(context)=>const Surahdetail(),
      },

      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/main', page: () => MainScreen()),
        GetPage(name: '/onboarding', page: () => OnBoardingScreen()), // Add this
      ],
    );
  }
}
