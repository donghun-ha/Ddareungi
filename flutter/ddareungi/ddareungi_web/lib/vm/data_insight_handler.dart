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

        Map<String, List<dynamic>> typedData = {};
        data.forEach((key, value) {
          if (value is List) {
            typedData[key] = value
                .map((item) => {
                      "time": item["time"],
                      "rent": item["rent"],
                      "restore": item["restore"],
                      "fill_count": item["fill_count"],
                    })
                .toList();
          }
        });

        stationData.assignAll(typedData);
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
