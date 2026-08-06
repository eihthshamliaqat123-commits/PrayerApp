import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task2_namaztime/Controller/Controller.dart';
import 'package:task2_namaztime/Sqflite/DBView.dart';
import 'package:task2_namaztime/Views/NewPrayers.dart';
import 'package:task2_namaztime/Views/Prayers.dart';
import 'package:task2_namaztime/Views/ProfileScreen.dart';
import 'package:task2_namaztime/Views/VerseOfDayScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MainDashboardView(),
    PrayersScreen(),
    VerseOfTheDayScreen(),
    //PrayersScreenNew(),
    DatabaseViewerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C5CE7),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Prayers',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Quran'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Qibla'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class MainDashboardView extends StatelessWidget {
  MainDashboardView({super.key});
  final controller = Get.put(PrayerApi());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black54),
          onPressed: () {},
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.location_on_outlined, color: Colors.black54, size: 20),
            SizedBox(width: 4),
            Text(
              "Karachi, Pakistan",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ],
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout_outlined, color: Colors.purple),
        //     onPressed: () {
        //       Get.offAll(() => SignInScreen());
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: const [
            NextPrayerCard(),
            SizedBox(height: 12),
            InfoGridRow(),
            SizedBox(height: 12),
            PrayerTimetableCard(),
            SizedBox(height: 12),
            ReminderCard(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({super.key});

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case "Fajr":
        return Icons.wb_twilight;
      case "Dhuhr":
        return Icons.wb_sunny_outlined;
      case "Asr":
        return Icons.wb_cloudy_outlined;
      case "Maghrib":
        return Icons.brightness_6;
      case "Isha":
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrayerApi>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.prayerData?.data?.timings == null) {
          return const SizedBox();
        }

        final timings = controller.prayerData!.data!.timings!;
        final status = controller.getPrayerStatus(timings);
        final activePrayer = status["active"] as String? ?? "Dhuhr";
        final today = DateTime.now();

        final isPrayed = controller.isPrayerPrayedOnDate(today, activePrayer);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Side Info
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Current Prayer",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              activePrayer,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _getPrayerIcon(activePrayer),
                              color: Colors.orangeAccent,
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Obx(
                          () => Text(
                            controller.timeString.value.isEmpty
                                ? DateFormat(
                                    'hh:mm:ss a',
                                  ).format(DateTime.now())
                                : controller.timeString.value,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C5CE7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Next prayer ${status['next']} ${status['remainingText']}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value:
                                (status['progress'] as double?)?.clamp(
                                  0.0,
                                  1.0,
                                ) ??
                                0.0,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE0E0E0),
                            color: const Color(0xFF6C5CE7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'Assets/mas.jpeg',
                      fit: BoxFit.contain,
                      height: 110,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.mosque,
                          size: 70,
                          color: Color(0xFF6C5CE7),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPrayed
                        ? Colors.green
                        : const Color(0xFF6C5CE7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    controller.togglePrayerStatus(today, activePrayer);
                  },
                  icon: Icon(
                    isPrayed ? Icons.check_circle : Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  label: Text(
                    isPrayed ? "Prayed" : "Mark As Prayed",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class InfoGridRow extends StatelessWidget {
  const InfoGridRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildInfoBox(
          icon: Icons.calendar_today_outlined,
          iconColor: Colors.green,
          title: "19",
          subtitle: "Muharram 1447 AH",
        ),
        const SizedBox(width: 8),
        _buildInfoBox(
          icon: Icons.calendar_month_outlined,
          iconColor: Colors.purple,
          title: DateFormat('dd').format(DateTime.now()),
          subtitle: DateFormat('MMMM yyyy').format(DateTime.now()),
        ),
        const SizedBox(width: 8),
        _buildInfoBox(
          icon: Icons.explore_outlined,
          iconColor: Colors.orange,
          title: "252°",
          subtitle: "Qibla Direction",
        ),
        const SizedBox(width: 8),
        _buildInfoBox(
          icon: Icons.menu_book_outlined,
          iconColor: Colors.blue,
          title: "Verse of Day",
          subtitle: "Al-Inshirah (94:6)",
          isVerse: true,
        ),
      ],
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isVerse = false,
  }) {
    return Expanded(
      child: Container(
        height: 85,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isVerse ? 10 : 14,
                      color: isVerse ? Colors.indigo : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: isVerse ? Colors.indigo.shade700 : Colors.grey,
                fontWeight: isVerse ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class PrayerTimetableCard extends StatelessWidget {
  const PrayerTimetableCard({super.key});

  List<DateTime> _getWeekDays() {
    final now = DateTime.now();
    final sunday = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (index) => sunday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();
    final today = DateTime.now();

    return GetBuilder<PrayerApi>(
      builder: (controller) {
        final timings = controller.prayerData?.data?.timings;
        final statusMap = timings != null
            ? controller.getPrayerStatus(timings)
            : {"active": "Dhuhr"};
        final String activePrayer = statusMap["active"] ?? "Dhuhr";

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Weekly Prayer Timetable",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    "${DateFormat('dd').format(weekDays.first)} - ${DateFormat('dd MMM yyyy').format(weekDays.last)} 📅",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.5),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1),
                  6: FlexColumnWidth(1),
                  7: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "Prayer",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...weekDays.map((day) {
                        final isToday =
                            day.year == today.year &&
                            day.month == today.month &&
                            day.day == today.day;
                        return _buildDayHeader(
                          DateFormat('E').format(day).toUpperCase(),
                          DateFormat('dd MMM').format(day),
                          isSelected: isToday,
                        );
                      }),
                    ],
                  ),
                  _buildPrayerRow(
                    context,
                    controller,
                    "Fajr",
                    timings?.fajr ?? "05:00 AM",
                    Icons.wb_twilight,
                    weekDays,
                    activePrayer,
                  ),
                  _buildPrayerRow(
                    context,
                    controller,
                    "Dhuhr",
                    timings?.dhuhr ?? "12:30 PM",
                    Icons.wb_sunny_outlined,
                    weekDays,
                    activePrayer,
                  ),
                  _buildPrayerRow(
                    context,
                    controller,
                    "Asr",
                    timings?.asr ?? "04:30 PM",
                    Icons.wb_cloudy_outlined,
                    weekDays,
                    activePrayer,
                  ),
                  _buildPrayerRow(
                    context,
                    controller,
                    "Maghrib",
                    timings?.maghrib ?? "07:00 PM",
                    Icons.brightness_6,
                    weekDays,
                    activePrayer,
                  ),
                  _buildPrayerRow(
                    context,
                    controller,
                    "Isha",
                    timings?.isha ?? "08:30 PM",
                    Icons.nightlight_round,
                    weekDays,
                    activePrayer,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend(
                    Icons.check_circle_outline,
                    Colors.green,
                    "Prayed",
                  ),
                  const SizedBox(width: 12),
                  _buildLegend(
                    Icons.cancel_outlined,
                    Colors.redAccent,
                    "Not Prayed",
                  ),
                  const SizedBox(width: 12),
                  _buildLegend(
                    Icons.remove_circle_outline,
                    Colors.grey,
                    "Not Time Yet",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayHeader(String day, String date, {bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? const Color.fromARGB(255, 97, 83, 202).withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildPrayerRow(
    BuildContext context,
    PrayerApi controller,
    String name,
    String time,
    IconData icon,
    List<DateTime> weekDays,
    String activePrayer,
  ) {
    final bool isHighlightedRow = (name == activePrayer);
    final now = DateTime.now();

    return TableRow(
      decoration: BoxDecoration(
        color: isHighlightedRow
            ? const Color(0xFF6C5CE7).withOpacity(0.05)
            : Colors.transparent,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: .1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: Colors.purple.shade300),
                  const SizedBox(width: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
        ...weekDays.map((date) {
          final isToday =
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
          final isPast = date.isBefore(DateTime(now.year, now.month, now.day));

          bool isPrayed = controller.isPrayerPrayedOnDate(date, name);

          bool isTimePassedToday = false;
          if (isToday) {
            final pTime = controller.parsePrayerTime(time);
            isTimePassedToday = now.isAfter(pTime) || name == activePrayer;
          }

          Widget iconWidget;

          if (isPast) {
            iconWidget = Icon(
              isPrayed ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isPrayed ? Colors.green : Colors.redAccent,
              size: 16,
            );
          } else if (isToday) {
            if (isTimePassedToday) {
              iconWidget = Icon(
                isPrayed ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: isPrayed ? Colors.green : Colors.redAccent,
                size: 16,
              );
            } else {
              iconWidget = const Icon(
                Icons.remove_circle_outline,
                color: Colors.grey,
                size: 16,
              );
            }
          } else {
            iconWidget = const Icon(
              Icons.remove_circle_outline,
              color: Colors.grey,
              size: 16,
            );
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (isToday) {
                if (isTimePassedToday) {
                  controller.togglePrayerStatus(date, name);
                } else {
                  Get.snackbar(
                    "Time Notice",
                    "$name time has not arrived yet today.",
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                }
              } else if (isPast) {
                Get.snackbar(
                  "Restricted",
                  "Previous days status cannot be changed.",
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: Container(
              color: isToday
                  ? const Color(0xFF6C5CE7).withOpacity(0.08)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(child: iconWidget),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLegend(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}

class ReminderCard extends StatelessWidget {
  const ReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Color(0xFF6C5CE7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Don't forget!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  "Asr prayer time is running.",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF6C5CE7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "View All Reminders",
              style: TextStyle(
                color: Color(0xFF6C5CE7),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
