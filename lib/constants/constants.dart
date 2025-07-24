import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Constants {

 static const kPrimary = Color(0xff8a51d1);
// Bloaters -> Long Method/Long List
 static const MaterialColor kSwatchColor = MaterialColor(
  0xff8A51D1,
  <int, Color>{
   50: Color(0xff9662d6), //10%
   100:  Color(0xffa174da), //20%
   200: Color(0xffad85df), //30%
   300: Color(0xffb997e3), //40%
   400: Color(0xffc5a8e8), //50%
   500: Color(0xffd0b9ed), //60%
   600: Color(0xffdccbf1), //70%
   700: Color(0xffe8dcf6), //80%
   800: Color(0xfff3eefa), //90%
   900: Color(0xffffffff), //100%
  },
 );

 //Dispensables ->Global Data

 static int? juzIndex;
 static int? surahIndex;
}


// After solving code smell

/*
import 'package:flutter/material.dart';

class AppColorSwatch {
  static const MaterialColor kPrimarySwatch = MaterialColor(
    0xff8A51D1,
    <int, Color>{
      50: Color(0xff9662d6),
      100: Color(0xffa174da),
      200: Color(0xffad85df),
      300: Color(0xffb997e3),
      400: Color(0xffc5a8e8),
      500: Color(0xffd0b9ed),
      600: Color(0xffdccbf1),
      700: Color(0xffe8dcf6),
      800: Color(0xfff3eefa),
      900: Color(0xffffffff),
    },
  );
}

 */