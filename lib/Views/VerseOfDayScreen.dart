import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:ui' as ui;
import 'package:task2_namaztime/Controller/QuranVerseCon.dart';

class VerseOfTheDayScreen extends StatelessWidget {
  const VerseOfTheDayScreen({super.key});

  static final QuranVerseController controller = Get.put(
    QuranVerseController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Colors.black87,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Text(
          "Verse of the Day",
          style: TextStyle(
            color: Color(0xFF1E1E2D),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.bookmark_border,
                  size: 20,
                  color: Colors.black87,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF5A42EC)),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E2D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A42EC),
                    ),
                    onPressed: () => controller.loadRandomVerse(),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text(
                      "Retry Connection",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final model = controller.verseData.value;

        if (model == null) {
          return const Center(child: Text("No Data"));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF5A42EC),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        intl.DateFormat(
                          'EEEE, d MMMM yyyy',
                        ).format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5A42EC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Color(0xFF5A42EC),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  //height: 450,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EEFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFF5A42EC),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.data?.surah?.nameEnglish ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1E1E2D),
                                  ),
                                ),
                                Text(
                                  "Chapter ${model.data?.surah?.number ?? 0} · Verse ${model.data?.verse?.ayah ?? 0}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          model.data?.surah?.nameArabic ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 2.1,
                            color: Color(0xFF1E1E2D),
                            fontFamily: 'Amiri',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          //shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF5A42EC).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          "${model.data?.verse?.arabic ?? ""}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A42EC),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EEFF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "文A",
                              style: TextStyle(
                                color: Color(0xFF5A42EC),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "English Translation",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A42EC),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"${model.data?.verse?.translations?.sahihInternational ?? ""}"',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F8F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "ع",
                              style: TextStyle(
                                color: Color(0xFF27AE60),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Urdu Translation",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27AE60),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            model.data?.verse?.translations?.urdu ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            Icons.share_outlined,
                            "Share",
                            () {},
                          ),
                          _buildActionButton(
                            Icons.headphones_outlined,
                            "Listen",
                            () {},
                          ),
                          _buildActionButton(Icons.copy_outlined, "Copy", () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    '''
🕋 Ayah of the Day

${model.data?.verse?.arabic ?? ""}

English:
${model.data?.verse?.translations?.sahihInternational ?? ""}

Urdu:
${model.data?.verse?.translations?.urdu ?? ""}

Surah:
${model.data?.surah?.nameEnglish ?? ""}

Verse:
${model.data?.verse?.ayah ?? ""}
''',
                              ),
                            );
                            Get.snackbar(
                              "Copied",
                              "Verse text copied to clipboard successfully!",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF1E1E2D),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(12),
                            );
                          }),
                          _buildActionButton(
                            Icons.casino_outlined,
                            "Random",
                            () => controller.loadRandomVerse(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 18,
                              color: Color(0xFF5A42EC),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Reflect on this verse and apply it in your daily life.",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF1E1E2D),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF5A42EC)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF5A42EC),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
