import 'dart:async';
import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Timings {
  final String? fajr;
  final String? dhuhr;
  final String? asr;
  final String? maghrib;
  final String? isha;

  Timings({this.fajr, this.dhuhr, this.asr, this.maghrib, this.isha});

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(
      fajr: json['Fajr'],
      dhuhr: json['Dhuhr'],
      asr: json['Asr'],
      maghrib: json['Maghrib'],
      isha: json['Isha'],
    );
  }
}

class PrayerTimingsModel {
  final Data? data;
  PrayerTimingsModel({this.data});

  factory PrayerTimingsModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimingsModel(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }
}

class Data {
  final Timings? timings;
  Data({this.timings});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      timings: json['timings'] != null
          ? Timings.fromJson(json['timings'])
          : null,
    );
  }
}

class PrayerApi extends GetxController {
  PrayerTimingsModel? prayerData;
  bool isLoading = false;

  var timeString = "".obs;
  late Timer _timer;

  // Map to store statuses per date key: {"YYYY-MM-DD_PrayerName": true/false}
  Map<String, bool> prayerRecords = {};

  @override
  void onInit() {
    super.onInit();
    loadPrayerRecords();
    getPrayer(DateTime.now());
    _startClock();
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeString.value = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  }

  Future<void> loadPrayerRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.contains('_')) {
        prayerRecords[key] = prefs.getBool(key) ?? false;
      }
    }
    update();
  }

  Future<void> getPrayer(
    DateTime date, {
    double latitude = 24.8607,
    double longitude = 67.0011,
  }) async {
    isLoading = true;
    update();

    final formattedDate = DateFormat('dd-MM-yyyy').format(date);
    final url = Uri.parse(
      "https://api.aladhan.com/v1/timings/$formattedDate?latitude=$latitude&longitude=$longitude",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        prayerData = PrayerTimingsModel.fromJson(data);
      } else {
        prayerData = null;
      }
    } catch (e) {
      prayerData = null;
    } finally {
      isLoading = false;
      update();
    }
  }

  // Key generator: e.g. "2026-07-21_Fajr"
  String _getStorageKey(DateTime date, String prayerName) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return "${formattedDate}_$prayerName";
  }

  bool isPrayerPrayedOnDate(DateTime date, String prayerName) {
    final key = _getStorageKey(date, prayerName);
    return prayerRecords[key] ?? false;
  }

  Future<void> togglePrayerStatus(DateTime date, String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(date, prayerName);

    bool current = prayerRecords[key] ?? false;
    bool updated = !current;

    prayerRecords[key] = updated;
    await prefs.setBool(key, updated);
    update();
  }

  DateTime parsePrayerTime(String timeStr) {
    try {
      final now = DateTime.now();
      final cleanTime = timeStr.trim().split(' ')[0];
      final parts = cleanTime.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> getPrayerStatus(Timings timings) {
    final now = DateTime.now();

    final fajr = parsePrayerTime(timings.fajr ?? '05:00');
    final dhuhr = parsePrayerTime(timings.dhuhr ?? '12:00');
    final asr = parsePrayerTime(timings.asr ?? '15:30');
    final maghrib = parsePrayerTime(timings.maghrib ?? '18:00');
    final isha = parsePrayerTime(timings.isha ?? '19:30');

    String currentActive = 'Isha';
    String nextPrayer = 'Fajr';
    DateTime nextPrayerTime = fajr.add(const Duration(days: 1));

    if (now.isAfter(fajr) && now.isBefore(dhuhr)) {
      currentActive = 'Fajr';
      nextPrayer = 'Dhuhr';
      nextPrayerTime = dhuhr;
    } else if (now.isAfter(dhuhr) && now.isBefore(asr)) {
      currentActive = 'Dhuhr';
      nextPrayer = 'Asr';
      nextPrayerTime = asr;
    } else if (now.isAfter(asr) && now.isBefore(maghrib)) {
      currentActive = 'Asr';
      nextPrayer = 'Maghrib';
      nextPrayerTime = maghrib;
    } else if (now.isAfter(maghrib) && now.isBefore(isha)) {
      currentActive = 'Maghrib';
      nextPrayer = 'Isha';
      nextPrayerTime = isha;
    } else if (now.isAfter(isha)) {
      currentActive = 'Isha';
      nextPrayer = 'Fajr';
      nextPrayerTime = fajr.add(const Duration(days: 1));
    } else {
      currentActive = 'Isha';
      nextPrayer = 'Fajr';
      nextPrayerTime = fajr;
    }

    final diff = nextPrayerTime.difference(now);
    final hoursLeft = diff.inHours;
    final minutesLeft = diff.inMinutes.remainder(60);

    String timeLeftString = "in ";
    if (hoursLeft > 0) timeLeftString += "${hoursLeft}h ";
    timeLeftString += "${minutesLeft}m";

    return {
      'active': currentActive,
      'next': nextPrayer,
      'remainingText': timeLeftString,
    };
  }
}
