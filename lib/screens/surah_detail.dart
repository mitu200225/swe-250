import 'package:flutter/material.dart';
import 'package:flutter_quran_yt/constants/constants.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

import '../models/translation.dart';
import '../services/api_services.dart';
import '../widgets/custom_translation.dart';

enum TranslationLang { urdu, hindi, english, spanish }

class Surahdetail extends StatefulWidget {
  const Surahdetail({Key? key}) : super(key: key);
  static const String id = 'surahDetail_screen';

  @override
  _SurahdetailState createState() => _SurahdetailState();
}

class _SurahdetailState extends State<Surahdetail> {
  final ApiServices _apiServices = ApiServices();
  TranslationLang _translation = TranslationLang.urdu;
  late Future<SurahTranslationList> _futureTranslation;

  @override
  void initState() {
    super.initState();
    _futureTranslation = _apiServices.getTranslation(
      Constants.surahIndex!,
      getTranslationId(_translation),
    );
  }

  int getTranslationId(TranslationLang lang) {
    switch (lang) {
      case TranslationLang.urdu:
        return 131;
      case TranslationLang.hindi:
        return 149;
      case TranslationLang.english:
        return 85;
      case TranslationLang.spanish:
        return 136;
    }
  }

  void _updateTranslation(TranslationLang lang) {
    setState(() {
      _translation = lang;
      _futureTranslation = _apiServices.getTranslation(
        Constants.surahIndex!,
        getTranslationId(_translation),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<SurahTranslationList>(
          future: _futureTranslation,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: ListView.builder(
                  itemCount: snapshot.data!.translationList.length,
                  itemBuilder: (context, index) {
                    return TranslationTile(
                      index: index,
                      surahTranslation: snapshot.data!.translationList[index],
                    );
                  },
                ),
              );
            } else {
              return const Center(child: Text(' Translation Not Found'));
            }
          },
        ),
        bottomSheet: SolidBottomSheet(
          headerBar: Container(
            color: Theme.of(context).primaryColor,
            height: 50,
            child: const Center(
              child: Text("Swipe up for Translation Language",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          body: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Urdu'),
                  leading: Radio<TranslationLang>(
                    value: TranslationLang.urdu,
                    groupValue: _translation,
                    onChanged: (TranslationLang? value) {
                      if (value != null) _updateTranslation(value);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Hindi'),
                  leading: Radio<TranslationLang>(
                    value: TranslationLang.hindi,
                    groupValue: _translation,
                    onChanged: (TranslationLang? value) {
                      if (value != null) _updateTranslation(value);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('English'),
                  leading: Radio<TranslationLang>(
                    value: TranslationLang.english,
                    groupValue: _translation,
                    onChanged: (TranslationLang? value) {
                      if (value != null) _updateTranslation(value);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Spanish'),
                  leading: Radio<TranslationLang>(
                    value: TranslationLang.spanish,
                    groupValue: _translation,
                    onChanged: (TranslationLang? value) {
                      if (value != null) _updateTranslation(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
