import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_quran_yt/constants/constants.dart';
import 'package:flutter_quran_yt/models/aya_of_the_day.dart';
import 'package:flutter_quran_yt/services/api_services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ApiServices _apiServices = ApiServices();

  void setData()async{
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("alreadyUsed", true);
  }

  @override
  void initState() {
    // Dispensable -> Redundant Comments
    // TODO: implement initState
    super.initState();
    setData();
  }

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    HijriCalendar.setLocal('ar');
    var _hijri = HijriCalendar.now();
    var day = DateTime.now();
    var format = DateFormat('EEE , d MMM yyyy');
    var formatted = format.format(day);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: _size.height * 0.22, // 22% of screen
              width: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/background_img.jpg')
                  )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatted,style: const TextStyle(color: Colors.white , fontSize: 30),),
                  RichText(
                    text: TextSpan(
                        children: <InlineSpan>[
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(_hijri.hDay.toString(),
                                style: const TextStyle(fontSize: 20,color: Colors.white),),
                            ),
                          ),
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(_hijri.longMonthName,
                                style: const TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
                            ) ,
                          ),
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text('${_hijri.hYear} AH',style: const TextStyle(fontSize: 20,color: Colors.white),),
                            ),
                          ),
                        ]
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.only(top: 10,bottom: 20),
                child: Column(
                  children: [
                    FutureBuilder<AyaOfTheDay>(
                      future: _apiServices.getAyaOfTheDay(),
                      builder: (context,snapshot){
                        switch(snapshot.connectionState){
                          case ConnectionState.none:
                            return const Icon(Icons.sync_problem);
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            return const CircularProgressIndicator();
                          case ConnectionState.done:
                            return  Container(
                              margin: const EdgeInsetsDirectional.all(16),
                              padding: const EdgeInsetsDirectional.all(20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                      offset: Offset(0,1),
                                    )
                                  ]
                              ),
                              child: Column(
                                children: [
                                  const Text("Quran Aya of the Day",
                                    style: TextStyle(color: Colors.black,
                                        fontWeight: FontWeight.bold,fontSize: 18),),
                                  const Divider(color: Colors.black,thickness: 0.5,),
                                  Text(
                                    snapshot.data!.arText!,
                                    style: const TextStyle(color: Colors.black54, fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    snapshot.data!.enTran!,
                                    style: const TextStyle(color: Colors.black54, fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                        children: <InlineSpan>[
                                          WidgetSpan(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(snapshot.data!.surNumber!.toString()
                                                ,style: const TextStyle(fontSize: 16),),
                                            ),
                                          ),
                                          WidgetSpan(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(snapshot.data!.surEnName!
                                                  ,style: const TextStyle(fontSize: 16)),
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                ],
                              ),
                            );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// After solving code smell
/*
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_quran_yt/constants/constants.dart';
import 'package:flutter_quran_yt/models/aya_of_the_day.dart';
import 'package:flutter_quran_yt/services/api_services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiServices _apiServices = ApiServices();
  late final String _gregorianDate;
  late final HijriCalendar _hijriDate;

  @override
  void initState() {
    super.initState();
    _setFirstUse();
    _initializeDates();
  }

  void _setFirstUse() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("alreadyUsed", true);
  }

  void _initializeDates() {
    _hijriDate = HijriCalendar.now()..setLocal('ar');
    _gregorianDate = DateFormat('EEE, d MMM yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [_buildAyaOfTheDay()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.22,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/background_img.jpg'),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _gregorianDate,
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
          RichText(
            text: TextSpan(
              children: [
                _buildHijriSpan(_hijriDate.hDay.toString()),
                _buildHijriSpan(_hijriDate.longMonthName, isBold: true),
                _buildHijriSpan('${_hijriDate.hYear} AH'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _buildHijriSpan(String text, {bool isBold = false}) {
    return WidgetSpan(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAyaOfTheDay() {
    return FutureBuilder<AyaOfTheDay>(
      future: _apiServices.getAyaOfTheDay(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return const CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final aya = snapshot.data!;
          return _buildAyaCard(aya);
        } else {
          return const Icon(Icons.sync_problem);
        }
      },
    );
  }

  Widget _buildAyaCard(AyaOfTheDay aya) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            spreadRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Quran Aya of the Day",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Divider(color: Colors.black, thickness: 0.5),
          Text(
            aya.arText ?? '',
            style: const TextStyle(color: Colors.black54, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          Text(
            aya.enTran ?? '',
            style: const TextStyle(color: Colors.black54, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      aya.surNumber?.toString() ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      aya.surEnName ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

 */