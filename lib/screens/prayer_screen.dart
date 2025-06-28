import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({Key? key}) : super(key: key);

  @override
  _PrayerScreenState createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late Future<Map<String, dynamic>> prayerTimes;

  @override
  void initState() {
    super.initState();
    prayerTimes = fetchPrayerTimes();
  }

  Future<Map<String, dynamic>> fetchPrayerTimes() async {
    const String city = 'Dhaka';
    const String country = 'Bangladesh';
    const int method = 2;

    const url =
        'http://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=$method';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['timings'];
    } else {
      throw Exception('Failed to load prayer times');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prayer Times"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: prayerTimes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final timings = snapshot.data!;
            final filteredKeys = [
              'Fajr',
              'Dhuhr',
              'Asr',
              'Maghrib',
              'Isha',
              'Sunrise'
            ]; // Show only these

            return ListView.builder(
              itemCount: filteredKeys.length,
              itemBuilder: (context, index) {
                final key = filteredKeys[index];
                final value = timings[key] ?? 'N/A';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(key,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    trailing: Text(value,
                        style: const TextStyle(
                            color: Colors.teal, fontSize: 18)),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

