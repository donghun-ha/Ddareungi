import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/user.dart';
import '../view/rebalance_ai.dart';

class LoginHandler extends GetxController {
  final String _baseUrl = "http://127.0.0.1:8000";

  // 상태 변수
  var isLoading = false.obs;
  var errorMessage = "".obs;
  User? user;

  // 로그인 메서드
  login(String id, String pw) async {
    if (id.isEmpty || pw.isEmpty) {
      errorMessage.value = "Please enter your ID and Password.";
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id, "pw": pw}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        user = User.fromJson(data);

        // 로그인 성공 시 페이지 이동
        Get.off(() => const RebalanceAi());
      } else if (response.statusCode == 401) {
        errorMessage.value = "Invalid username or password.";
      } else {
        errorMessage.value = "Server error: ${response.body}";
      }
    } catch (e) {
      errorMessage.value = "Failed to connect to server: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
