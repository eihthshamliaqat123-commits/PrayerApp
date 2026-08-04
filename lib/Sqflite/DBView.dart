import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task2_namaztime/Controller/Controller.dart';

class DatabaseViewerScreen extends StatelessWidget {
  const DatabaseViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PrayerApi controller = Get.find<PrayerApi>();

    // 2. Call a background refresh whenever this specific screen opens
    controller.refreshDatabaseLogs();

    return Scaffold(
      appBar: AppBar(
        title: const Text("SQL Database Viewer"),
        backgroundColor: const Color(0xFF6C5CE7),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.refreshDatabaseLogs(),
          ),
        ],
      ),
      // 3. Changed FutureBuilder to Obx/GetBuilder to listen for live state emissions
      body: GetBuilder<PrayerApi>(
        builder: (authController) {
          if (authController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authController.prayerRecords.isEmpty) {
            return const Center(
              child: Text(
                "No records found in SQLite.\nTry marking a prayer on the home screen!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final recordEntries = authController.prayerRecords.entries.toList();

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFEFEFF4),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Prayer Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: recordEntries.map((entry) {
                    // Splits your key string ("2026-08-04_Asr") back into separate values
                    final parts = entry.key.split('_');
                    final String date = parts.isNotEmpty ? parts[0] : 'Unknown';
                    final String prayerName = parts.length > 1
                        ? parts[1]
                        : 'Unknown';
                    final bool isPrayed = entry.value;

                    return DataRow(
                      cells: [
                        DataCell(Text(date)),
                        DataCell(Text(prayerName)),
                        DataCell(
                          Text(
                            isPrayed ? "✅ Prayed" : "❌ Missed",
                            style: TextStyle(
                              color: isPrayed ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
