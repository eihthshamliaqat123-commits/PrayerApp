import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task2_namaztime/Controller/Controller.dart';
import 'package:task2_namaztime/Controller/FireBaseAuthController.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Connect to your active AuthController instance
    final AuthController authController = Get.find<AuthController>();
    final PrayerApi prayerApiController = Get.find<PrayerApi>();

    int completedCount = prayerApiController.completedPrayers.length;
    double progressFraction = prayerApiController.prayerProgressValue;
    int percentage = (progressFraction * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEDE9FE), // Soft light purple at the top
                    Color(0xFFF9FAFB), // Fades out into the main background
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    // Right Side Background Image Overlay
                    Positioned(
                      right: 10,
                      top: 0,
                      bottom: 0,
                      child: Opacity(
                        opacity: 0.30,
                        child: Image.asset('Assets/mas.jpeg'),
                      ),
                    ),
                    // Left Side User Profile Row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 24.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDDD6FE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF6D28D9),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Name and Email Box (Reactive via Obx)
                          Expanded(
                            child: Obx(() {
                              String name =
                                  authController.userData['fullName'] ??
                                  "Loading Name...";
                              String email =
                                  authController.userData['email'] ??
                                  "Loading Email...";

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: CircularProgressIndicator(
                                        value: progressFraction,
                                        strokeWidth: 10,
                                        backgroundColor: const Color(
                                          0xFFE2E8F0,
                                        ),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF6366F1),
                                            ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "$completedCount/5",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[900],
                                          ),
                                        ),
                                        Text(
                                          "$percentage/100%",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Today's Score",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right Prayers Checklist Column
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Today's Prayers",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildPrayerRow(
                                  Icons.wb_twilight,
                                  "Fajr",
                                  "04:18 AM",
                                ),
                                _buildPrayerRow(
                                  Icons.wb_sunny,
                                  "Dhuhr",
                                  "12:34 PM",
                                ),
                                _buildPrayerRow(
                                  Icons.wb_sunny_outlined,
                                  "Asr",
                                  "04:45 PM",
                                ),
                                _buildPrayerRow(
                                  Icons.nightlight_round,
                                  "Maghrib",
                                  "07:12 PM",
                                ),
                                _buildPrayerRow(
                                  Icons.bedtime,
                                  "Isha",
                                  "08:42 PM",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    return _buildTableCalendarWidget(prayerApiController);
                  }),

                  const SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Obx(() {
                        String name =
                            authController.userData['fullName'] ??
                            "Not Provided";
                        String email =
                            authController.userData['email'] ?? "Not Provided";
                        String phone =
                            authController.userData['phone'] ?? "Not Provided";
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 20,
                                      color: Color(0xFF6366F1),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Account Information",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 170),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: Color(0xFF6366F1),
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const Divider(height: 20, color: Color(0xFFF1F5F9)),
                            _buildInfoRow(
                              Icons.person_outline,
                              "Full Name",
                              name,
                            ),
                            _buildInfoRow(
                              Icons.email_outlined,
                              "Email Address",
                              email,
                            ),
                            _buildInfoRow(
                              Icons.phone_outlined,
                              "Mobile Number",
                              phone,
                            ),
                            _buildInfoRow(
                              Icons.lock_open_outlined,
                              "Password",
                              "••••••••",
                              isPassword: true,
                            ),
                            _buildInfoRow(
                              Icons.cake_outlined,
                              "Date of Birth",
                              "12 May 1998",
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEEF2F6),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        authController.signOut();
                      },
                      icon: const Icon(Icons.logout, color: Color(0xFF4F46E5)),
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerRow(IconData icon, String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      key: ValueKey(name),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF818CF8)),
              const SizedBox(width: 10),

              SizedBox(
                width: 70,
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.check_circle, size: 14, color: Colors.green),
              const SizedBox(width: 12),

              SizedBox(
                width: 75,
                child: Text(
                  time,
                  textAlign: TextAlign
                      .right, // Pushes text smoothly against the right margin
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF818CF8)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
          if (isPassword) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.visibility_off_outlined,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableCalendarWidget(PrayerApi controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side static calendar header button trigger layout
          GestureDetector(
            onTap: () {
              // Toggle between single-line week view or monthly box view on click
              controller.calendarFormat.value =
                  controller.calendarFormat.value == CalendarFormat.week
                  ? CalendarFormat.month
                  : CalendarFormat.week;
            },
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
                    "View Type",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 40, width: 1, color: const Color(0xFFEEEEEE)),

          // Right side actual dynamic calendar interface rendering block
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: controller.focusedDay.value,
              calendarFormat: controller.calendarFormat.value,
              headerVisible:
                  false, // Hides top control arrows for clean custom look
              rowHeight: 52,

              // CRUCIAL FOR WEEK SELECTION: Forces range coloring styles onto the week
              rangeSelectionMode: RangeSelectionMode.enforced,
              rangeStartDay: controller.rangeStart.value,
              rangeEndDay: controller.rangeEnd.value,

              onDaySelected: (selectedDay, focusedDay) {
                // When any day is clicked, pass it to our calculator to snap selection to its full week bounds
                controller.selectEntireWeekOfDate(selectedDay);
              },
              onFormatChanged: (format) {
                controller.calendarFormat.value = format;
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

                // Weekly highlighted background block styling
                rangeHighlightColor: const Color(0xFF6C5CE7).withOpacity(0.12),
                withinRangeTextStyle: const TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontWeight: FontWeight.w600,
                ),

                // FIX: Added 'shape: BoxShape.rectangle' inside the decorations instead of undefined parameters
                rangeStartDecoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  shape: BoxShape.rectangle, // Sets the shape to rectangle
                  borderRadius: BorderRadius.circular(12),
                ),

                rangeEndDecoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  shape: BoxShape.rectangle, // Sets the shape to rectangle
                  borderRadius: BorderRadius.circular(12),
                ),

                selectedDecoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  shape: BoxShape.rectangle, // Sets the shape to rectangle
                  borderRadius: BorderRadius.circular(12),
                ),

                todayDecoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.2),
                  shape: BoxShape.rectangle, // Sets the shape to rectangle
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
}
