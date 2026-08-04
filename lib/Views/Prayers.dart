import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task2_namaztime/Controller/Controller.dart';

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({super.key});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen> {
  final controllerData = Get.put(PrayerApi());
  late String formattedDate;

  @override
  void initState() {
    formattedDate = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, //alow fill
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Icon(Icons.notes, color: Colors.white, size: 28),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    "Karachi, Pakistan ⌵",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset("Assets/mas.jpeg", fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.02),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        Obx(
                          () => Text(
                            controllerData.timeString.value.isEmpty
                                ? DateFormat(
                                    'hh:mm:ss a',
                                  ).format(DateTime.now())
                                : controllerData.timeString.value,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black45,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 4,
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: GetBuilder<PrayerApi>(
                  builder: (c) {
                    if (c.isLoading || c.prayerData == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final timings = c.prayerData?.data?.timings;
                    if (timings == null) {
                      return const Center(
                        child: Text(
                          "Could not retrieve prayer times. Please try again.",
                        ),
                      );
                    }

                    final prayerList = [
                      {
                        'name': 'Fajr',
                        'time': timings.fajr ?? 'N/A',
                        'subtitle': 'Start your day',
                        'icon': Icons.wb_twilight,
                        'iconColor': Colors.blue,
                      },
                      {
                        'name': 'Dhuhr',
                        'time': timings.dhuhr ?? 'N/A',
                        'subtitle': 'Midday prayer',
                        'icon': Icons.wb_sunny,
                        'iconColor': Colors.orange,
                      },
                      {
                        'name': 'Asr',
                        'time': timings.asr ?? 'N/A',
                        'subtitle': 'Afternoon prayer',
                        'icon': Icons.wb_cloudy_outlined,
                        'iconColor': Colors.purple,
                      },
                      {
                        'name': 'Maghrib',
                        'time': timings.maghrib ?? 'N/A',
                        'subtitle': 'Sunset prayer',
                        'icon': Icons.wb_sunny_outlined,
                        'iconColor': Colors.red,
                      },
                      {
                        'name': 'Isha',
                        'time': timings.isha ?? 'N/A',
                        'subtitle': 'Night prayer',
                        'icon': Icons.nightlight_round,
                        'iconColor': Colors.indigo,
                      },
                      {
                        'name': 'Next Prayer',
                        'time': 'Asr 04:45 PM',
                        'subtitle': 'in 6h 03m',
                        'icon': Icons.timer,
                        'iconColor': Colors.teal,
                      },
                    ];

                    return Container(
                      padding: const EdgeInsets.only(
                        //top: 30.0,
                        left: 16.0,
                        right: 16.0,
                        //bottom: 1.0,
                      ),
                      child: Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: prayerList.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.35,
                                ),
                            itemBuilder: (context, index) {
                              final prayer = prayerList[index];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          prayer['icon'] as IconData,
                                          color: prayer['iconColor'] as Color,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${prayer['name']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${prayer['time']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "${prayer['subtitle']}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Container(
                              child: Text(
                                '----------o----------',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    64,
                                    181,
                                    227,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
