import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:task2_namaztime/Models/QuranVerseModel.dart';

class QuranVerseController extends GetxController {
  var isLoading = true.obs;
  var verseData = Rxn<QuranVerseModel>();
  var errorMessage = "".obs;

  final String _apiKey = "umh_8dae760e37cd6f9fee8f2bc0f29508155252265d";

  @override
  void onInit() {
    super.onInit();

    loadRandomVerse();
  }

  Future<void> loadRandomVerse() async {
    try {
      isLoading(true);
      errorMessage(""); // Reset older state errors

      final url =
          'https://ummahapi.com/api/quran/random?translations=en&script=uthmani';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-API-Key": _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final bodyText = response.body.trim();

        if (bodyText.startsWith("<!DOCTYPE html>") ||
            bodyText.startsWith("<html")) {
          errorMessage.value =
              "The server returned an HTML error page instead of JSON.";
          return;
        }

        final Map<String, dynamic> jsonResponse = json.decode(bodyText);

        verseData.value = QuranVerseModel.fromJson(jsonResponse);
      } else {
        errorMessage.value = "Server error status code: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Failed to sync random data: ${e.toString()}";
    } finally {
      isLoading(false);
    }
  }
}
