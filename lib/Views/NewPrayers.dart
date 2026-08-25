import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task2_namaztime/Controller/Controller.dart'; // Controller import verify kar lein

class PrayersScreenNew extends StatefulWidget {
  const PrayersScreenNew({super.key});

  @override
  State<PrayersScreenNew> createState() => _PrayersScreenNewState();
}

class _PrayersScreenNewState extends State<PrayersScreenNew> {
  final controllerData = Get.put(PrayerApi());

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataForDate(_selectedDay);
    });
  }

  void _fetchDataForDate(DateTime date) {}

  DateTime _parsePrayerTime(String timeStr) {
    try {
      final cleanTime = timeStr.trim().split(' ')[0];
      final parts = cleanTime.split(':');
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> _getPrayerStatus(dynamic timings) {
    final now = DateTime.now();

    final prayerTimes = [
      {'name': 'Fajr', 'time': _parsePrayerTime(timings?.fajr ?? '05:00')},
      {'name': 'Dhuhr', 'time': _parsePrayerTime(timings?.dhuhr ?? '12:00')},
      {'name': 'Asr', 'time': _parsePrayerTime(timings?.asr ?? '15:30')},
      {
        'name': 'Maghrib',
        'time': _parsePrayerTime(timings?.maghrib ?? '18:00'),
      },
      {'name': 'Isha', 'time': _parsePrayerTime(timings?.isha ?? '19:30')},
    ];

    String activePrayer = 'Isha';
    String nextPrayer = 'Fajr';
    DateTime nextTime = (prayerTimes[0]['time'] as DateTime).add(
      const Duration(days: 1),
    );

    for (int i = 0; i < prayerTimes.length; i++) {
      final current = prayerTimes[i]['time'] as DateTime;
      final nextIndex = (i + 1) % prayerTimes.length;
      final next = prayerTimes[nextIndex]['time'] as DateTime;

      if (now.isAfter(current) &&
          now.isBefore(
            i == prayerTimes.length - 1
                ? next.add(const Duration(days: 1))
                : next,
          )) {
        activePrayer = prayerTimes[i]['name'] as String;
        nextPrayer = prayerTimes[nextIndex]['name'] as String;
        nextTime = i == prayerTimes.length - 1
            ? next.add(const Duration(days: 1))
            : next;
        break;
      }
    }

    final diff = nextTime.difference(now);
    final hours = diff.inHours;
    final mins = diff.inMinutes.remainder(60);
    final remainingText = "in ${hours > 0 ? '${hours}h ' : ''}${mins}m";

    return {
      'active': activePrayer,
      'next': nextPrayer,
      'remainingText': remainingText,
    };
  }

  // Date Picker Dialog
  Future<void> _selectCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF6C5CE7)),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
        _focusedDay = picked;
      });
      _fetchDataForDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: _buildAppBar(),
      body: GetBuilder<PrayerApi>(
        builder: (c) {
          if (c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (c.prayerData?.data?.timings == null) {
            return const Center(
              child: Text("Prayer data could not be retrieved."),
            );
          }

          final timings = c.prayerData!.data!.timings!;
          final status = _getPrayerStatus(timings);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTableCalendarWidget(),
                const SizedBox(height: 16),
                _buildPrayerList(timings, status['active']),
                const SizedBox(height: 16),
                _buildInfoCardsRow(
                  nextPrayerName: status['next'],
                  remainingTimeText: status['remainingText'],
                ),
                const SizedBox(height: 16),
                _buildMenuList(),
              ],
            ),
          );
        },
      ),
      //bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- UI Components ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        onPressed: () {},
      ),
      title: Column(
        children: const [
          Text(
            "Prayer Times",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
              SizedBox(width: 4),
              Text(
                "Karachi, Pakistan",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTableCalendarWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _selectCustomDate,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF6C5CE7),
                    size: 24,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Calendar",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFFEEEEEE),
          ),
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              headerVisible: false,
              rowHeight: 65,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _fetchDataForDate(selectedDay);
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() => _calendarFormat = format);
                }
              },
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
                weekendTextStyle: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                todayTextStyle: const TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 11, color: Colors.grey),
                weekendStyle: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList(dynamic timings, String activePrayer) {
    final prayers = [
      {
        'name': 'Fajr',
        'subtitle': 'Start your day with prayer',
        'time': timings.fajr,
        'icon': Icons.wb_twilight,
        'color': Colors.indigo,
      },
      {
        'name': 'Dhuhr',
        'subtitle': 'Midday prayer',
        'time': timings.dhuhr,
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
      },
      {
        'name': 'Asr',
        'subtitle': 'Afternoon prayer',
        'time': timings.asr,
        'icon': Icons.wb_cloudy_outlined,
        'color': Colors.deepOrange,
      },
      {
        'name': 'Maghrib',
        'subtitle': 'Sunset prayer',
        'time': timings.maghrib,
        'icon': Icons.wb_sunny_outlined,
        'color': Colors.redAccent,
      },
      {
        'name': 'Isha',
        'subtitle': 'Night prayer',
        'time': timings.isha,
        'icon': Icons.nightlight_round,
        'color': Colors.purple,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: prayers.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
        itemBuilder: (context, index) {
          final item = prayers[index];
          final bool isSelected = activePrayer == item['name'];
          final color = item['color'] as Color;

          return Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF9E6) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 22),
              ),
              title: Text(
                item['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                item['subtitle'] as String,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (item['time'] as String?) ?? 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Colors.orange : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.volume_up_outlined,
                    color: isSelected ? Colors.orange : Colors.indigo.shade300,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCardsRow({
    required String nextPrayerName,
    required String remainingTimeText,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildSingleInfoCard(
            icon: Icons.calendar_today,
            iconColor: Colors.teal,
            title: "Hijri Date",
            mainText: "19",
            subText: "Muharram 1447 AH",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSingleInfoCard(
            icon: Icons.access_time,
            iconColor: Colors.deepPurple,
            title: "Next Prayer",
            mainText: nextPrayerName,
            subText: remainingTimeText,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSingleInfoCard(
            icon: Icons.explore_outlined,
            iconColor: Colors.blue,
            title: "Qibla Direction",
            mainText: "252°",
            subText: "from North",
          ),
        ),
      ],
    );
  }

  Widget _buildSingleInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String mainText,
    required String subText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mainText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    final menuItems = [
      {
        'title': 'Monthly Prayer Timetable',
        'subtitle': 'View full month schedule',
        'icon': Icons.bookmark_border,
        'color': Colors.green,
      },
      {
        'title': 'Calculation Method',
        'subtitle': 'Muslim World League',
        'icon': Icons.tune,
        'color': Colors.purple,
      },
      {
        'title': 'Prayer Notifications',
        'subtitle': 'Azan & Reminders',
        'icon': Icons.notifications_none,
        'color': Colors.blue,
      },
      {
        'title': 'Manage Locations',
        'subtitle': 'Saved locations',
        'icon': Icons.location_on_outlined,
        'color': Colors.orange,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final color = item['color'] as Color;

          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item['icon'] as IconData, color: color, size: 20),
            ),
            title: Text(
              item['title'] as String,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              item['subtitle'] as String,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  // Widget _buildBottomNavBar() {
  //   return BottomNavigationBar(
  //     currentIndex: 1,
  //     selectedItemColor: Colors.indigo,
  //     unselectedItemColor: Colors.grey,
  //     showUnselectedLabels: true,
  //     type: BottomNavigationBarType.fixed,
  //     items: const [
  //       BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.access_time_filled),
  //         label: "Prayers",
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.menu_book_outlined),
  //         label: "Quran",
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.explore_outlined),
  //         label: "Qibla",
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.person_outline),
  //         label: "Profile",
  //       ),
  //     ],
  //   );
  // }
}
