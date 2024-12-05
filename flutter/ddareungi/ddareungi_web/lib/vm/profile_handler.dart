import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileHandler extends GetxController {
  var id = "".obs;
  var region = "".obs;
  var errorMessage = "".obs;
  var isLoading = true.obs;

  final String apiUrl = "http://127.0.0.1:8000/profile"; // API URL

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  fetchProfile() async {
    try {
      isLoading(true);

      // API 호출
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        id.value = data["id"];
        region.value = data["region"];
      } else {
        errorMessage.value =
            json.decode(response.body)["detail"] ?? "Failed to load profile.";
      }
    } catch (e) {
      errorMessage.value = "Server error: $e";
    } finally {
      isLoading(false);
    }
  }
}
