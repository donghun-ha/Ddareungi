import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/user.dart';
import '../view/rebalance_ai.dart';
import '../vm/profile_handler.dart';

class LoginHandler extends GetxController {
  final String _baseUrl = "http://127.0.0.1:8000";

  // 상태 변수
  var isLoading = false.obs;
  var errorMessage = "".obs;
  User? user;

  // ProfileHandler 인스턴스 (유저 데이터를 전달하기 위해 사용)
  final ProfileHandler profileHandler = Get.put(ProfileHandler());

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
        // UTF-8로 디코딩 후 JSON 파싱
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // User 객체 생성 및 프로필 데이터 설정
        user = User.fromJson(data);
        profileHandler.setUserData(user!.id, user!.region);

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
