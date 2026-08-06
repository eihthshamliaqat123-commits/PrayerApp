import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task2_namaztime/Sqflite/Database.dart';

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
  // --- NEW CALENDAR STATE VARIABLES ---
  var focusedDay = DateTime.now().obs;
  var rangeStart = Rxn<DateTime>();
  var rangeEnd = Rxn<DateTime>();
  var calendarFormat = CalendarFormat.week.obs;

  var prayerHistoryDatabase = <String, List<String>>{}.obs;

  Map<String, bool> prayerRecords = {};

  var completedPrayers = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPrayerRecords();
    getPrayer(DateTime.now());
    _startClock();
    selectEntireWeekOfDate(DateTime.now());
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }

  Future<void> refreshDatabaseLogs() async {
    await loadPrayerRecords();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeString.value = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  }

  Future<void> loadPrayerRecords() async {
    try {
      final logs = await DatabaseHelper.instance.fetchAllLogs();
      prayerRecords.clear();

      for (var row in logs) {
        final String date = row['date'];
        final String prayerName = row['prayer_name'];
        final bool isPrayed = row['is_prayed'] == 1;

        prayerRecords["${date}_$prayerName"] = isPrayed;
      }
      update();
    } catch (e) {
      print("Error loading sqflite details: $e");
    }
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

  String _getStorageKey(DateTime date, String prayerName) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return "${formattedDate}_$prayerName";
  }

  bool isPrayerPrayedOnDate(DateTime date, String prayerName) {
    final key = _getStorageKey(date, prayerName);
    return prayerRecords[key] ?? false;
  }

  Future<void> togglePrayerStatus(DateTime date, String prayerName) async {
    if (completedPrayers.contains(prayerName)) {
      completedPrayers.remove(prayerName);
    } else {
      completedPrayers.add(prayerName);
    }
    final String dateString = DateFormat('yyyy-MM-dd').format(date);
    final key = _getStorageKey(date, prayerName);

    bool current = prayerRecords[key] ?? false;
    bool updated = !current;

    prayerRecords[key] = updated;

    await DatabaseHelper.instance.saveOrUpdatePrayer(
      dateString,
      prayerName,
      updated,
    );
    String dateKey =
        "${focusedDay.value.year}-${focusedDay.value.month}-${focusedDay.value.day}";
    prayerHistoryDatabase[dateKey] = List<String>.from(completedPrayers);

    update();
  }

  double get prayerProgressValue {
    if (completedPrayers.isEmpty) return 0.0;
    return completedPrayers.length / 5.0;
  }

  // double get prayerProgressValue {
  //   if (completedPrayers.isEmpty) return 0.0;
  //   return completedPrayers.length / 5.0;
  // }

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

  void selectEntireWeekOfDate(DateTime date) {
    // REQUIREMENT 1: Block future selections
    // Clear the time part of today's date for an accurate comparison
    DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    DateTime clickedDateOnly = DateTime(date.year, date.month, date.day);

    if (clickedDateOnly.isAfter(today)) {
      Get.snackbar(
        "Selection Blocked",
        "You cannot select a future date for prayer tracking.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return; // Stop execution immediately
    }

    // REQUIREMENT 2: Set the clicked day as the start, and select 1 week forward
    rangeStart.value = clickedDateOnly;
    rangeEnd.value = clickedDateOnly.add(
      const Duration(days: 6),
    ); // 1 week window forward
    focusedDay.value = clickedDateOnly;

    // Load records for this date
    _fetchDataForDate(clickedDateOnly);
  }

  void _fetchDataForDate(DateTime date) {
    String dateKey = "${date.year}-${date.month}-${date.day}";

    // Load recorded prayers if they exist, otherwise supply a clean list
    if (prayerHistoryDatabase.containsKey(dateKey)) {
      completedPrayers.value = List<String>.from(
        prayerHistoryDatabase[dateKey]!,
      );
    } else {
      completedPrayers.clear();
    }
  }
}
