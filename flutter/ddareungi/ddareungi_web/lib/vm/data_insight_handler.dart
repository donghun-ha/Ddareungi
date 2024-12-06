import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DataInsightHandler extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var stationData = <String, List<dynamic>>{}.obs;

  fetchStationPredictions(String region) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await http.get(
        Uri.parse(
            "http://127.0.0.1:8000/data_insight/$region/station_predictions"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        stationData.assignAll(data.cast<String, List<dynamic>>());
      } else {
        errorMessage.value = "Failed to load data: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
