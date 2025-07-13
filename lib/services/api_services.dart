
import 'dart:convert';
import 'dart:math';
import 'package:flutter_quran_yt/models/aya_of_the_day.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../models/juz.dart';
import '../models/qari.dart';
import '../models/sajda.dart';
import '../models/surah.dart';
import '../models/translation.dart';

class ApiServices{

  final endPointUrl ="http://api.alquran.cloud/v1/surah";
  List<Surah> list = [];

  Future<AyaOfTheDay> getAyaOfTheDay() async {
    String url = "https://api.alquran.cloud/v1/ayah/${random(1,6237)}/editions/quran-humanist,en.asad,en.picokatal";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return AyaOfTheDay.fromJSON(json.decode(response.body));
    } else {
      print("Failed to load");
      throw Exception("Failed  to Load Post");
    }
  }
  random(min, max){
    var rn = Random();
    return min + rn.nextInt(max - min);
  }

  Future<List<Surah>> getSurah() async{

    Response res = await http.get(Uri.parse(endPointUrl));
    if(res.statusCode == 200){
      Map<String,dynamic> json = jsonDecode(res.body);
      json['data'].forEach((element){
        if(list.length<114) {
          list.add(Surah.fromJson(element));
        }
      });
      print('ol ${list.length}');
      return list;
    }else{
      throw ("Can't get the Surah");
    }
  }

  Future<SajdaList> getSajda() async {
    String url =   "http://api.alquran.cloud/v1/sajda/en.asad";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return SajdaList.fromJSON(json.decode(response.body));
    } else {
      print("Failed to load");
      throw Exception("Failed  to Load Post");
    }
  }

  Future<JuzModel> getJuzz(int index) async {
    String url = "http://api.alquran.cloud/v1/juz/$index/quran-humanist";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return JuzModel.fromJSON(json.decode(response.body));
    } else {
      print("Failed to load");
      throw Exception("Failed  to Load Post");
    }
  }

  Future<SurahTranslationList> getTranslation(int index, int translationIndex) async {
    final url = 'https://api.quran.com/v4/quran/translations/$translationIndex?chapter_number=$index';

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      return SurahTranslationList.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(" Failed to load translation");
    }
  }

  List<Qari> qarilist = [];

  Future<List<Qari>> getQariList() async {
    const url = "https://mp3quran.net/api/v3/reciters?language=eng";
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List reciters = data['reciters'];
      qarilist.clear();

      for (var element in reciters) {
        qarilist.add(Qari.fromMp3QuranJson(element));
      }

      qarilist.sort((a, b) => a.name!.compareTo(b.name!));
      return qarilist;
    } else {
      throw Exception("Failed to load Qari list");
    }
  }

}